--[[
	script/module/nl_mod/nl_mapsucks.lua
	Hanack (Andreas Schaeffer)
	23-Okt-2010
	License: GPL3

	Funktion:
		Ein Spieler kann während des Spiels bekunden, dass er die aktuelle Map
		nicht spielen möchte. Kommmen dafür genügend Stimmen zusammen, so wird
		die Restspielzeit auf eine Minute gesenkt.
	

	API-Methoden:
		mapsucks.sucks(cn)
			Spieler cn möchte die Map nicht spielen
		mapsucks.loves(cn)
			Spieler cn möchte die Map spielen
		mapsucks.check()
			Führt die Prüfung durch, ob genügend Stimmen zusammengekommen
			sind. Ist die Prüfung erfolgreich, wird die Restzeit herunter-
			gesetzt. Ist gerade Intermission, wird keine Prüfung durch-
			geführt. Wurde schon einmal die Restzeit heruntergesetzt, findet
			ebenfalls keine Prüfung statt.
		mapsucks.get_needed_votes()
			Gibt die Anzahl der benötigten Votes zurück. Dazu wird die
			Tabelle mapsucks.needed_votes verwendet. Spieler können mit
			#lovemap jeweils ein #mapsucks neutralisieren. In jedem Fall
			reichen jedoch 50% der Spieler aus (min-Funktion).  

	Commands:
		#mapsucks
		#lovemap

	Konfigurations-Variablen:
		mapsucks.needed_votes
			Anzahl der benötigten Votes bei einer bestimmten Spieleranzahl (indexbasierter Zugriff)
		mapsucks.lowered_gametime
			Gibt die Anzahl der Sekunden an, auf die reduziert werden soll

	Laufzeit-Variablen:
		mapsucks.game.gametimelowered
			Boolean: 0 = Die Zeit wurde nicht heruntergesetzt; 1 = Die Zeit wurde heruntergesetzt
		mapsucks.game.sucks
			Anzahl der bisher abgegebenen #mapsucks 
		mapsucks.game.loves
			Anzahl der bisher abgegebenen #lovemap

	Events:
		mapvote
			Voted ein Spieler für genau die Map, die gerade gespielt wird,
			ist dies gleichbedeutend mit #lovemap
		intermission
			Bei Intermission werden die spielabhängigen Variablen zurückgesetzt
		interval
			Unabhängig davon, ob jemand #mapsucks oder #lovemap gesagt hat,
			wird periodisch alle zwei Sekunden eine Prüfung durchgeführt. Dies
			ist nötig, weil Spieler connecten und disconnecten und sich das
			Verhältnis daher verschiebt
		reconnect
			Reconnected ein Spieler kann er weder #mapsucks noch #lovemap machen
		disconnect
			Disconnected ein Spieler wird seine Stimme wieder entfernt

]]

require "math"

--[[
		API
]]

mapsucks = {}
mapsucks.game = {}
mapsucks.game.gametimelowered = 0
mapsucks.game.seconds_remaining = 0
mapsucks.game.sucks = 0
mapsucks.game.loves = 0
--        playercount     1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
mapsucks.needed_votes = { 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,10,10,10,10,11,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23,23,24,24,24,25,25 }
mapsucks.lowered_gametime = 60
mapsucks.lowered_more = 10
mapsucks.interval = 2

function mapsucks.sucks(cn, force)
	if maprotation.intermission_running == 1 and force == nil then
		if maprotation.intermission_mode == maprotation.intermission_modes.VETO then
			veto.veto(cn)
		elseif maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
			mapbattle.choose_none(cn)
		else
			-- Fallback: keine mapsucks während der Intermission
			messages.error(cn, {cn}, "MAPSUCKS", "On "..white("intermission").." there is no possibility to vote against a map.")
		end
	else
		if nl.getPlayer(cn, "mapsucks") == 1 or nl.getPlayer(cn, "lovemap") == 1 then
			messages.error(cn, {cn}, "MAPSUCKS", string.format("You have already voted! Currently there are "..white("%i/%i").." vetos.", mapsucks.game.sucks, mapsucks.get_needed_votes()))
		else
			nl.updatePlayer(cn, "mapsucks", 1, "set")
			mapsucks.game.sucks = mapsucks.game.sucks + 1
			db.insert("nl_veto", { player=server.player_displayname(cn), map=maprotation.map, mode=maprotation.game_mode } )
			if force == nil then
				messages.info(cn, players.all(), "MAPSUCKS", string.format(blue("%s").." thinks that this "..white("map sucks")..". Got "..white("%i votes").." (%i needed). Use "..orange("#mapsucks"), server.player_displayname(cn), mapsucks.game.sucks, mapsucks.get_needed_votes()))
				mapsucks.check()
			end
		end
	end
end

function mapsucks.loves(cn, force)
	if maprotation.intermission_running == 1 and force == nil then
		if maprotation.intermission_mode == maprotation.intermission_modes.VETO then
			veto.noveto(cn)
		else
			-- Fallback: Keine #lovemaps während der Intermission
			messages.error(cn, {cn}, "MAPSUCKS", "On "..white("intermission").." there is no possibility to love a map.")
		end
	else
		if nl.getPlayer(cn, "mapsucks") == 1 or nl.getPlayer(cn, "lovemap") == 1 then
			messages.error(cn, {cn}, "MAPSUCKS", string.format("You have already voted! Currently there are "..white("%i/%i").." vetos.", mapsucks.game.sucks, mapsucks.get_needed_votes()))
		else
			nl.updatePlayer(cn, "lovemap", 1, "set")
			mapsucks.game.loves = mapsucks.game.loves + 1
			db.insert("nl_loves", { name=server.player_displayname(cn), map=maprotation.map, mode=maprotation.game_mode } )
			if force == nil then
				messages.info(cn, players.all(), "MAPSUCKS", string.format(blue("%s").." likes this map! Say "..orange("#lovemap").." if you like playing map "..white("%s"), server.player_displayname(cn), maprotation.map))
			end
		end
	end
end

function mapsucks.check()
	if maprotation.intermission_running == 0 and mapsucks.game.gametimelowered == 0 and (server.gamelimit - server.gamemillis) > (mapsucks.lowered_gametime * 1000) then
		if mapsucks.game.sucks >= mapsucks.get_needed_votes() then
			mapsucks.game.gametimelowered = 1
			mapsucks.game.seconds_remaining = mapsucks.lowered_gametime - 1
			server.changetime((mapsucks.game.seconds_remaining - 1) * 1000)
			messages.warning(cn, players.all(), "MAPSUCKS", string.format(white("Map sucks!").." Game time was lowered to "..white("%s seconds"), mapsucks.lowered_gametime) )
		end
	elseif maprotation.intermission_running == 0 then
		mapsucks.game.seconds_remaining = mapsucks.game.seconds_remaining - mapsucks.interval
		local more = mapsucks.game.sucks - mapsucks.get_needed_votes()
		if more >= mapsucks.game.gametimelowered then
			mapsucks.game.gametimelowered = mapsucks.game.gametimelowered + 1
			if mapsucks.game.gametimelowered == 1 then
				mapsucks.game.seconds_remaining = mapsucks.lowered_gametime - 1
			end
			mapsucks.game.seconds_remaining = mapsucks.game.seconds_remaining - mapsucks.lowered_more
			server.changetime(mapsucks.game.seconds_remaining * 1000)
			messages.warning(cn, players.all(), "MAPSUCKS", string.format(white("Map sucks more !").." Game time was lowered to "..white("%s seconds"), mapsucks.game.seconds_remaining) )
		end
	end
end

function mapsucks.get_needed_votes()
	-- minimum: tabelleneintrag
	-- normal:  tabelleneintrag plus lovemaps
	-- maximum: 75% aller spieler
	if server.playercount == 0 then return 1 end
	return math.max(mapsucks.needed_votes[server.playercount], math.min(mapsucks.needed_votes[server.playercount] + mapsucks.game.loves, math.floor((server.playercount+1) / 1.75)))
end



--[[
		COMMANDS
]]

function server.playercmd_mapsucks(cn)
	mapsucks.sucks(cn)
end
server.playercmd_sucks = server.playercmd_mapsucks

function server.playercmd_lovemap(cn)
	mapsucks.loves(cn)
end
server.playercmd_loves = server.playercmd_lovemap



--[[
		EVENTS
]]

server.event_handler("disconnect", function(cn)
	if nl.getPlayer(cn, "mapsucks") == 1 then
		mapsucks.game.sucks = mapsucks.game.sucks - 1
	end
	if nl.getPlayer(cn, "lovemap") == 1 then
		mapsucks.game.loves = mapsucks.game.loves - 1
	end
end)

server.event_handler("reconnect", function(cn)
	-- block mapsucks and lovemap on reconnect
	nl.updatePlayer(cn, "lovemap", 1, "set")
	nl.updatePlayer(cn, "mapsucks", 1, "set")
end)

server.event_handler("mapvote", function(cn, map, mode)
	if map == maprotation.map then
		mapsucks.loves(cn)
	end
end)

server.event_handler("intermission", function()
	mapsucks.game.gametimelowered = 0
	mapsucks.game.secondsremaining = 0
	mapsucks.game.sucks = 0
	mapsucks.game.loves = 0
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "mapsucks", 0, "set")
		nl.updatePlayer(cn, "lovemap", 0, "set")
	end
end)

server.interval(mapsucks.interval * 1000, mapsucks.check)



--[[
		EXTRACTCOMMAND RULES
]]

extractcommand.register("mapsucks", false, mapsucks.sucks)
extractcommand.register("map sucks", false, mapsucks.sucks)
extractcommand.register("m a p s u c k s", false, mapsucks.sucks)
extractcommand.register("shitmap", false, mapsucks.sucks)
extractcommand.register("shit map", false, mapsucks.sucks)
extractcommand.register("fucking map", false, mapsucks.sucks)
extractcommand.register("hate this map", false, mapsucks.sucks)
extractcommand.register("hate map", false, mapsucks.sucks)
extractcommand.register("map is bad", false, mapsucks.sucks)

extractcommand.register("love map", false, mapsucks.loves)
extractcommand.register("love this map", false, mapsucks.loves)
extractcommand.register("lovemap", false, mapsucks.loves)
extractcommand.register("lovemaps", false, mapsucks.loves)
extractcommand.register("maprules", false, mapsucks.loves)
extractcommand.register("maprulez", false, mapsucks.loves)
extractcommand.register("map rules", false, mapsucks.loves)
extractcommand.register("map rulez", false, mapsucks.loves)
