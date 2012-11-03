--[[
	script/module/nl_mod/nl_camping.lua
	Hanack (Andreas Schaeffer)
	Created: 20-Sep-2010
	Last Modified: 04-Nov-2010
	License: GPL3

	Funktionen:
		* Ein Rechteck um die letzte CamperKill Position
		* Das Rechteck wird mit steigender Anzahl von CamperKills groesser
		* Es gibt zwei Warnstufen
		* Bricht der Spieler das Camping nach der ersten Warnung ab, verfallen seine CamperKills
		* Macht der Spieler weiter, bekommt er eine zweite Warnung
		* Bricht der Spieler das Camping nach der zweiten Warnung ab und bewaehrt sich die
		*  zweifache Länge seiner naechsten Zeitstrafe, so wird er rehabilitiert.
		* Sucht sich der Spieler nach der zweiten Warnung einen anderen CamperPlatz und setzt
		*  das Camping fort, befördert ihn der nächste erkannte Camperkill auf die Strafbank
		* Gelangt der Spieler auf die Strafbank bleibt er eine bestimmte Zeitspanne im Spectator
		* Die Dauer der Zeitstrafe beträgt beim ersten Mal 60 Sekunden, wird aber bei jeder
		*  weiteren Zeitstrafe länger.
		* Versucht der Camper seine Strafe zu umgehen, indem er einen Reconnect macht, so
		*  wird dies erkannt und er wird wieder auf die Strafbank gesetzt. Für diesen Versuch
		*  wird ihm ein weiterer Penalty angerechnet, d.h. die nächste Zeitstrafe wird
		*  entsprechend höher ausfallen (z.B. statt 30->45: 30->60). Die Reconnect-Erkennung
		*  erfolgt auf Basis von Name oder IP.
		* Spieler mit Flagge sind keine Camper
		* Man kann abhängig von der Map die CampingBox einstellen
		* Camperkills eines Spielers werden zurückgesetzt, wenn er stirbt
		* Da Camper öfter auch mal Teammates treffen, werden Teamkills wie normale Frags behandelt,
		*  d.h. auch ein Teamkill kann ein Camperkill sein
		* Wird ein Camper mit der 2. Warnung gefragt, so wird der Fragger belohnt (wie?)
		* Bewegt sich ein Camper aus der Box raus und gibt eine bestimmte Anzahl von Schüssen ab,
		*  und hat noch keine zweite Warnung erhalten, ist er kein Camper
		* Scored ein Camper und hat noch keine zweite Warnung, ist er kein Camper
	
		* Was kann man tun, um nicht als exzessiver Camper zu gelten?
			* Wenn man die 2. Warnung bekommen hat, darf man keine Camperkills innerhalb der
			  doppelten Strafzeit machen
			* Wenn man die 2. Warnung noch nicht bekommen hat:
				* Ein Frag außerhalb der Box -> Reset
				* 3 Misses außerhalb der Box -> Reset
				* Death -> Reset
				* Score -> Reset
		* Was hilft nicht?
			* Fraggen, aus der Box rauslaufen, wieder reinlaufen, nächsten Frag machen
			* Fraggen, aus der Box rauslaufen, zwei Schüsse abfeuern ohne jemand zu fraggen, wieder reinlaufen, nächsten Frag machen
			* Reconnect
			
		* (Optional) Die Zeitstrafen werden in der Datenbank gespeichert.
		* (Optional) Die Warnungen werden in der Datenbank gespeichert.
	
	API-Methoden:


	Commands:

	Konfigurations-Variablen:

	Laufzeit-Variablen:


]]



--[[
		API
]]

camping = {}
camping.module_name = "CAMPER DETECTION"
camping.penalty_seconds = { 30, 45, 60, 120, 180, 240, 300, 360, 420 }
camping.misses_to_reset = 3
camping.penalty_countdown = 5
camping.limit = { 3, 6, 7 }
camping.diff = {
	default = {
		box = { 50, 50 , 20 },
		extend = { 15, 15, 5 }
	},
	face_capture = {
		box = { 40, 40 , 5 },
		extend = { 10, 10, 1 }
	},
	frostbyte = {
		box = { 50, 50 , 20 },
		extend = { 15, 15, 2 }
	}
}
camping.diff_add = { 15, 15, 5 }
camping.diff_maps = {}
-- player specific memory
camping.pos = {}
camping.level = {}
camping.kills = {}
camping.penalties = {}
camping.hasflag = {}
camping.shots = {}
-- reconnect detection
local camping_namedetection = {}
local camping_ipdetection = {}
local camping_penaltyid = 0

function camping.allowed_by_mode()
	return
		maprotation.game_mode == "coop edit" or
		maprotation.game_mode == "instagib" or
		maprotation.game_mode == "instagib team" or
		maprotation.game_mode == "ffa" or
		maprotation.game_mode == "teamplay" or
		maprotation.game_mode == "tatics" or
		maprotation.game_mode == "efficiency" or
		maprotation.game_mode == "efficiency team"
end

function camping.check(cn)
	if camping.allowed_by_mode() then return end
	local pvars = server.player_vars(cn)
	x, y, z = server.player_pos(cn)
	local diff = camping.diff["default"]
	if camping.diff[server.map] ~= nil then
		diff = camping.diff[server.map]
	end
	if camping.is_camping(cn) then
		messages.debug(-1, {cn}, "CAMPING", "New camperkill")
		camping.kills[cn] = camping.kills[cn] + 1

		if camping.kills[cn] == camping.limit[camping.level[cn]] then
			camping.level[cn] = camping.level[cn] + 1
			messages.debug(-1, {cn}, "CAMPING", "New camping level: " .. camping.level[cn])
			if camping.level[cn] == 2 then
				camping.warning(cn)
			elseif camping.level[cn] == 3 then
				camping.last_warning(cn)
			elseif camping.level[cn] == 4 then
				camping.penalty(cn, seconds)
			end
		end

	else
		-- server.msg("reset camperkills")
		if camping.level[cn] < 3 then
			camping.kills[cn] = 0
			camping.level[cn] = 1
		elseif camping.level[cn] == 3 then
			-- level und kills bleiben bestehen
		end
		camping.pos[cn][1] = x
		camping.pos[cn][2] = y
		camping.pos[cn][3] = z
	end
end

function camping.check_bounty(actorCN, targetCN)
	if camping.level[targetCN] == 3 then
		if camping.level[actorCN] == 3 then
			messages.info(-1, players.all(), "CAMPING", string.format(white("Camper %s") .. " shot camper " .. white("%s"), server.player_displayname(actorCN), server.player_displayname(targetCN)))
		else
			messages.info(-1, players.all(), "CAMPING", string.format(white("%s") .. " shot excessive camper " .. white("%s"), server.player_displayname(actorCN), server.player_displayname(targetCN)))
		end
	end
end

function camping.warning(cn)
	messages.warning(-1, {cn}, "CAMPING", " ")
	messages.warning(-1, {cn}, "CAMPING", red("Camping is BAD"))
	messages.warning(-1, {cn}, "CAMPING", "--> Stop EXCESSIVE camping NOW!")
end

function camping.last_warning(cn)
	messages.warning(-1, {cn}, "CAMPING", " ")
	messages.warning(-1, {cn}, "CAMPING", red("Camping is BAD"))
	messages.warning(-1, {cn}, "CAMPING", string.format("--> ONE more camperkill within the next %i seconds and you will be placed on the PENALTY BOX for %s seconds!", camping.penalty_seconds[camping.penalties[cn] + 1] * 2, camping.penalty_seconds[camping.penalties[cn] + 1]))
	messages.info(-1, players.admins(), "CAMPING", string.format("%s got the last warning", server.player_displayname(cn)))
	-- Rehabilitierung nach einer Zeitspanne (Zweifache Laenge der naechsten Strafe) des Nicht-Campens
	server.sleep(camping.penalty_seconds[camping.penalties[cn] + 1] * 2000, function()
		if camping.level[cn] == 3 then
			messages.debug(-1, players.admins(), "CAMPING", string.format("%s war nicht mehr als camper unterwegs und wurde rehabilitiert", server.player_displayname(cn)))
			camping.kills[cn] = 0
			camping.level[cn] = 1
		end
	end)
end

function camping.penalty(cn, seconds)
	camping_penaltyid = camping_penaltyid + 1
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	camping.penalties[cn] = camping.penalties[cn] + 1
	camping_namedetection[playerName] = { camping_penaltyid, seconds, camping.penalties[cn], camping.level[cn], camping.kills[cn], 0 }
	camping_ipdetection[playerIp] = { camping_penaltyid, seconds, camping.penalties[cn], camping.level[cn], camping.kills[cn], 0 }
	spectator.fspec(cn, "CAMPING", camping.module_name)
	messages.error(-1, players.all(), "CAMPING", string.format("%s have been placed on the penalty box because of continued excessive camping (%i camperkills)!", server.player_displayname(cn), camping.kills[cn]))
	local p = camping.penalties[cn]
	for s = 1, (camping.penalty_seconds[p] / camping.penalty_countdown)-1 do
		server.sleep(s * 5000, function()
			messages.warning(-1, {cn}, "CAMPING", string.format(white("%i").." seconds penalty left", (camping.penalty_seconds[p] - (s*camping.penalty_countdown))))
		end)
	end
	server.sleep(camping.penalty_seconds[p] * 1000, function()
		camping.unpenalty(cn, playerName, playerIp)
	end)
end

function camping.unpenalty(cn, playerName, playerIp)
	if not server.valid_cn(cn) then
		messages.debug(cn, players.admins(), "CAMPING", "Could not unspec player "..playerName.." ("..cn.."). Maybe he left the server.")
		return
	end
	if camping_namedetection[playerName][6] == 0 and playerName == server.player_name(cn) and playerIp == server.player_ip(cn) then
		spectator.funspec(cn, "CAMPING", camping.module_name)
		camping.reset(cn)
		camping_namedetection[playerName] = nil
		camping_ipdetection[playerIp] = nil
		messages.debug(cn, players.admins(), "CAMPING", "Player "..playerName.." ("..cn..") left penalty box.")
		messages.warning(-1, {cn}, "CAMPING", "Your penalty is over!")
	end
end

function camping.is_camping(cn)
	x, y, z = server.player_pos(cn)
	local diff = camping.diff["default"]
	if camping.diff[server.map] ~= nil then
		diff = camping.diff[server.map]
	end
	if math.abs(camping.pos[cn][1] - x) <= (diff["box"][1] + diff["extend"][1] * camping.kills[cn]) and
	   math.abs(camping.pos[cn][2] - y) <= (diff["box"][2] + diff["extend"][2] * camping.kills[cn]) and
	   math.abs(camping.pos[cn][3] - z) <= (diff["box"][3] + diff["extend"][3] * camping.kills[cn]) and
	   camping.hasflag[cn] ~= 1 then
		return true
	else
		return false
	end
end

function camping.reset_position(cn)
	camping.pos[cn] = {}
	camping.pos[cn][1] = 0
	camping.pos[cn][2] = 0
	camping.pos[cn][3] = 0
	camping.shots[cn] = 0
end

function camping.reset(cn)
	camping.level[cn] = 1
	camping.kills[cn] = 0
	camping.reset_position(cn)
end

function camping.init(cn)
	camping.penalties[cn] = 0
	camping.reset(cn)
end




--[[
		EVENTS
]]

server.event_handler("frag", function(targetCN, actorCN)
	camping.check(actorCN)
	camping.check_bounty(actorCN, targetCN)
	camping.reset(targetCN)
end)

server.event_handler("teamkill", function(actorCN, targetCN)
	-- teamkills zaehlen genauso
	messages.debug(-1, players.all(), "CAMPING", string.format("target:%i actor:%i", targetCN, actorCN))
	camping.check(actorCN)
	camping.reset(targetCN)
end)
server.event_handler("shot", function(cn, gun, hits)
	-- server.player_msg(cn, string.format(red("  [ debugCAMPING ]  SHOT")))
	-- Bei einer bestimmten Anzahl von Misses außerhalb der CampingBox
	-- kann man davon ausgehen, dass es sich nicht um einen Camper handelt
	if not camping.is_camping(cn) then
		camping.shots[cn] = camping.shots[cn] + 1
		if camping.shots[cn] >= camping.misses_to_reset then
			if camping.level[cn] < 3 then
				camping.reset(cn)
			end
		end
	end
end)

server.event_handler("connect", function(cn)
	-- Wenn jemand auf der Strafbank ist, und schlauerweise einen Reconnect macht,
	-- dann wird er nach dem Connect auf die Strafbank gesetzt. Erkennung von
	-- Spieler erfolgt anhand des Names oder der IP.
	-- DONE!!! Konflikt: Unspec vom Login!
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	camping.hasflag[cn] = 0
	if camping_namedetection[playerName] ~= nil then
		server.sleep(5000, function()
			server.player_msg(cn, string.format(red("  [ CAMPING ]  Detected player penalty on reconnect.")))
			camping.penalties[cn] = camping_namedetection[playerName][3]
			camping.level[cn] = camping_namedetection[playerName][4]
			camping.kills[cn] = camping_namedetection[playerName][5]
			camping.penalty(cn, camping_namedetection[playerName][2])
		end)
	elseif camping_ipdetection[playerIp] ~= nil then
		server.sleep(5000, function()
			server.player_msg(cn, string.format(red("  [ CAMPING ]  Detected player penalty on reconnect.")))
			camping.penalties[cn] = camping_ipdetection[playerIp][3]
			camping.level[cn] = camping_ipdetection[playerIp][4]
			camping.kills[cn] = camping_ipdetection[playerIp][5]
			camping.penalty(cn, camping_ipdetection[playerIp][2])
		end)
	else
		camping.init(cn)
	end
end)

server.event_handler("disconnect", function(cn)
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	if camping_namedetection[playerName] ~= nil then
		camping_namedetection[playerName][6] = camping_namedetection[playerName][6] + 1
	end
	if camping_ipdetection[playerIp] ~= nil then
		camping_ipdetection[playerIp][6] = camping_ipdetection[playerIp][6] + 1
	end
	camping.init(cn)
end)

server.event_handler("mapchange", function(cn)
	for i,cn in pairs(players.active()) do
		camping.reset(cn)
	end
end)
server.event_handler("spectator", camping.reset_position)
server.event_handler("takeflag", function(cn) 
	camping.hasflag[cn] = 1
end)
server.event_handler("scoreflag", function(cn) 
	camping.hasflag[cn] = 0
	if camping.level[cn] < 3 then
		camping.reset(cn)
	end
end)
server.event_handler("dropflag", function(cn) 
	camping.hasflag[cn] = 0
end)
