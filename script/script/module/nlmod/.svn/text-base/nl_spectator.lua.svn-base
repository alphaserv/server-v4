--[[
	script/module/nl_mod/nl_spectator.lua
	Hanack (Andreas Schaeffer)
	PeterPenacka
	Created: 24-Okt-2010
	Last Modified: 13-Mar-2011
	License: GPL3

	Funktionen:
		1. Spectator-Status eines Spielers ändern.
		2. Inaktive Spieler in den Spectator schieben

	API-Funktionen:
		fspec(cn, lock, owner)
			Spieler wird im Spectator gefangen. Es koennen beliebige Locks (verwende einen String!)
			verwendet werden. Wird ein Owner gesetzt, gehört dieses Lock dem Owner.
			Nur dieser Owner kann das Lock wieder lösen.
		funspec(cn, lock, owner)
			Ein Lock für den Spieler mit der entsprechenden CN wird deaktiviert. Sind keine Locks
			mehr vorhanden, kommt der Spieler aus dem Spec frei. Hat ein Lock einen Owner, kann es
			nur vom selben Owner wieder gelöst werden.
		checkpositions()
			Prueft, ob ein Spieler sich bewegt. Ist dies nicht der Fall, wird er in den Spectator
			geschoben.

	Commands:
		#sp
			Toggles den eigenen Spectator-Status
		#sp <CN>
			Toggles Spectator-Status des Spielers

	Konfigurations-Variablen:
		spectator.autospec_rounds
			Auto-Spectating in autospec_rounds * autospec_intervall seconds
		mapsucks.autospec_interval
			Das Interval, in dem geprüft werden soll

	Laufzeit-Variablen:
		spectator.game.last_pos
			Es werden die letzten Positionen der Spieler gemerkt.

]]



--[[
		API
]]

spectator = {}
spectator.enabled = 1
spectator.autospec_rounds = 8
spectator.autospec_interval = 10
spectator.game = {}
spectator.game.last_pos = {}
spectator.afk = {}
spectator.inspecbeforeafk = {}
spectator.nochatsince = {}
spectator.nochatcheck_interval = 60000 -- 1 minute
spectator.maxnochat = 600000 -- 10 minutes

function spectator.checkpositions()
	if server.paused == 1 or server.timeleft <= 0 or maprotation.game_mode == "coop edit" or spectator.enabled == 0 or cheater.is_recording() then return end
	if balance ~= nil and balance.testing == 1 then return end 
	for i,cn in ipairs(players.all()) do
		if server.player_status(cn) ~= "spectator" then
			if not spectator.game.last_pos[cn] then spectator.game.last_pos[cn] = {} end
			local x, y, z = server.player_pos(cn)
			if x .. y .. z == spectator.game.last_pos[cn][1] then
				local time_inactive = spectator.game.last_pos[cn][2]*spectator.autospec_interval
				if spectator.game.last_pos[cn][2] >= spectator.autospec_rounds then
					if spectator.game.last_pos[cn][3] ~= 1 then
						server.spec(cn)
						messages.error(cn, {cn}, "SPECTATOR", server.player_displayname(cn) .. " has been put to spectators because of inactivity (" .. time_inactive .. " seconds)")
						spectator.game.last_pos[cn] = nil
					end
				else
					if spectator.game.last_pos[cn][2] >= spectator.autospec_rounds-1 then
						messages.warning(cn, {cn}, "SPECTATOR", server.player_displayname(cn) .. " has been " .. time_inactive .. " seconds inactive. You will be spec'ed shortly because of inactivity!")
					end
					spectator.game.last_pos[cn][2] = spectator.game.last_pos[cn][2] + 1
				end
			else
				spectator.game.last_pos[cn][1] = x .. y .. z
				spectator.game.last_pos[cn][2] = 1
			end
		end
	end
end


function spectator.fspec(cn, lock, owner)
	local locks = utils.table_copy(nl.getPlayer(cn, "fspec"))
	locks[lock] = {set=true, owner=owner}
	nl.updatePlayer(cn, "fspec", locks, "set")
	server.spec(cn)
	messages.debug(-1, players.admins(), "SPECTATOR", server.player_displayname(cn).." has a new spectator lock: "..lock)
end

function spectator.funspec(cn, lock, owner)
	local locks = utils.table_copy(nl.getPlayer(cn, "fspec"))
	if locks[lock] == nil then
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format(
				"Nothing to do, player %s was not locked in spectator because of %s.",
				server.player_displayname(cn), lock))
	elseif locks[lock][owner] == owner or locks[lock][owner] == nil then
		locks[lock] = nil
		nl.updatePlayer(cn, "fspec", locks, "set")
	else
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format(
				"Player %s cannot be unlocked from spectator because lock %s was set by %s.",
				server.player_displayname(cn), lock, owner))
	end
	
	if utils.table_size(locks) == 0 then
		server.unspec(cn)
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format(
				"%s can now leave spectator because lock %s was disabled",
				server.player_displayname(cn), lock))
	else
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format("%s is still locked in spectator because of %s",
				server.player_displayname(cn),
				table.concat(spectator.get_lock_reasons(cn), ", ")))
	end
end

function spectator.is_locked(cn)
	local locks = nl.getPlayer(cn, "fspec")
	if utils.table_size(locks) == 0 then
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format("%s has no locks", server.player_displayname(cn)))
		return false
	else
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format("%s is locked because: %s",
				server.player_displayname(cn),
				table.concat(spectator.get_lock_reasons(cn), ", ")))
		return true
	end
end

function spectator.can_unlock(cn)
	local locks = nl.getPlayer(cn, "fspec")
	local owners = spectator.get_lock_owners(cn)
	if utils.table_size(locks) == 0 then
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format("%s has no locks", server.player_displayname(cn)))
		return true
	end
	
	if table.maxn(owners) > 0 then
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format(
				"%s is locked in specator because %s and cannot be unlocked because some locks were set by %s.",
				server.player_displayname(cn),
				table.concat(spectator.get_lock_reasons(cn), ", "),
				table.concat(owners, ", ")
				))
		return false
	else
		messages.debug(-1, players.admins(), "SPECTATOR",
			string.format(
				"%s is locked in specator because %s but can be unlocked.",
				server.player_displayname(cn),
				table.concat(spectator.get_lock_reasons(cn), ", ")))
		return true
	end
end

function spectator.get_lock_reasons(cn)
	local locks = nl.getPlayer(cn, "fspec")
	local reasons = {}
	for reason, lock in pairs(locks) do
		table.insert(reasons, reason)
	end
	return reasons
end

function spectator.get_lock_owners(cn)
	local locks = nl.getPlayer(cn, "fspec")
	local owners = {}
	for reason, lock in pairs(locks) do
		if lock["owner"] ~= nil then
			table.insert(owners, lock["owner"])
		end
	end
	return owners
end

function spectator.setafk(cn)
	if spectator.afk[cn] == 0 then
		spectator.afk[cn] = 1
		if server.player_status_code(cn) ~= server.SPECTATOR then
			spectator.inspecbeforeafk[cn] = 0
			server.spec(cn)
		else
			spectator.inspecbeforeafk[cn] = 1
		end
		for _, acn in ipairs(players.all()) do
			server.send_fake_text(acn, cn, string.format(" ... is afk.", server.player_displayname(cn)))
		end
	end
end

function spectator.unsetafk(cn, norelease)
	if norelease == nil then norelease = 0 end
	if spectator.afk[cn] == 1 then
		spectator.afk[cn] = 0
		if server.player_status_code(cn) == server.SPECTATOR and spectator.inspecbeforeafk[cn] == 0 and norelease == 0 then
			server.unspec(cn)
		end
		for _, acn in ipairs(players.all()) do
			server.send_fake_text(acn, cn, string.format(" ... is no more afk.", server.player_displayname(cn)))
		end
	end
end

function spectator.nochatcheck()
	for _,cn in pairs(players.spectators()) do
		if server.gamemillis - spectator.nochatsince[cn] > spectator.maxnochat then
			spectator.setafk(cn)
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_spectator(cn, targetCN)
	if targetCN then
		if not hasaccess(cn, putspec_access) then return end
		if not server.valid_cn(targetCN) then
			messages.error(cn, {cn}, "SPECTATOR", string.format("%s, you cannot unspec a player with cn %i (cn does not exist) ", server.player_displayname(cn), targetCN))
			return
		end
		if server.player_status_code(targetCN) == server.SPECTATOR then
			if not spectator.is_locked(targetCN) then
				server.unspec(targetCN)
			elseif spectator.can_unlock(targetCN) then
				server.unspec(targetCN)
				messages.warning(cn, {cn}, "SPECTATOR",
					string.format(
						"Caution: %s, you have unlocked player %s who was locked into spectator because of %s",
						server.player_displayname(cn),
						server.player_displayname(targetCN),
						table.concat(spectator.get_lock_reasons(targetCN), ", ")))
			else
				messages.error(cn, players.admins(), "SPECTATOR",
					string.format(
						"%s, you cannot unspec %s who was locked in spectator by %s because of %s",
						server.player_displayname(cn),
						server.player_displayname(targetCN),
						table.concat(spectator.get_lock_owners(targetCN), ", "),
						table.concat(spectator.get_lock_reasons(targetCN), ", ")))
			end
		else
			server.spec(targetCN)
			messages.warning(cn, players.admins(), "SPECTATOR", string.format("%s speced %s", server.player_displayname(cn), server.player_displayname(targetCN)))
		end
	else
		if server.player_status_code(cn) == server.SPECTATOR then
			if not spectator.is_locked(cn) and spectator.can_unlock(cn) then
				server.unspec(cn)
			else
				messages.error(cn, {cn}, "SPECTATOR", string.format("%s, you cannot leave spectator because of: %s", server.player_displayname(cn), table.concat(spectator.get_lock_reasons(cn), ", ")))
			end
		else
			server.spec(cn)
		end
	end
end
server.playercmd_sp = server.playercmd_spectator

function server.playercmd_specall(cn)
	if not hasaccess(cn, admin_access) then return end
	server.specall()
end

function server.playercmd_unspecall(cn)
	if not hasaccess(cn, admin_access) then return end
	-- server.unspecall()
	for _, tcn in pairs(players.spectators()) do
		if not spectator.is_locked(tcn) then
			server.unspec(tcn)
		end
	end
end

function server.playercmd_afk(cn)
	if spectator.afk[cn] == 1 then
		spectator.unsetafk(cn)
	else
		spectator.setafk(cn)
	end
end



--[[
		EVENTS
]]

if server.nl_clanserver ~= 1 then
	server.interval(spectator.autospec_interval*1000, spectator.checkpositions)
end

server.event_handler("request_spectator", function(cn, ocn, val)
	if spectator.is_locked(cn) then
		messages.error(cn, {cn}, "SPECTATOR", string.format("You cannot leave spectator because of: %s", table.concat(spectator.get_lock_reasons(cn), ", ")))
		return -1
	end
end)

server.event_handler("connect", function(cn)
	spectator.game.last_pos[cn] = nil
	spectator.afk[cn] = 0
	spectator.inspecbeforeafk[cn] = 0
	spectator.nochatsince[cn] = server.gamemillis
end)

server.event_handler("disconnect", function(cn)
	spectator.game.last_pos[cn] = nil
	spectator.afk[cn] = 0
	spectator.inspecbeforeafk[cn] = 0
	spectator.nochatsince[cn] = server.gamemillis
end)

server.event_handler("spectator", function(cn, val)
	spectator.game.last_pos[cn] = nil
	if val == 0 then
		spectator.unsetafk(cn)
	end
end)

server.event_handler("mapchange", function()
	spectator.game.last_pos = {}
end)

server.event_handler("takeflag", function(cn)
	if not spectator.game.last_pos[cn] then spectator.game.last_pos[cn] = {} end
	spectator.game.last_pos[cn][3] = 1
end)

server.event_handler("scoreflag", function(cn) 
	if not spectator.game.last_pos[cn] then spectator.game.last_pos[cn] = {} end
	spectator.game.last_pos[cn][3] = 0
end)

server.event_handler("dropflag", function(cn) 
	if not spectator.game.last_pos[cn] then spectator.game.last_pos[cn] = {} end
	spectator.game.last_pos[cn][3] = 0
end)
server.event_handler("text", function(cn, msg)
	if string.sub(msg,1,1) ~= "#" and string.sub(msg,1,1) ~= "!" and string.sub(msg,1,2) ~= "gg" then
		spectator.nochatsince[cn] = server.gamemillis
		spectator.unsetafk(cn, 1)
	end
end)

server.interval(spectator.nochatcheck_interval, spectator.nochatcheck)
