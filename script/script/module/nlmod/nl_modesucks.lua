--[[
	script/module/nl_mod/nl_modesucks.lua
	Author: Hanack (Andreas Schaeffer)
	Created: 08-Mai-2012
	Last Modified: 08-Mai-2012
	License: GPL3

	Funktion:
	

	API-Methoden:
		modesucks.sucks(cn)
			Spieler cn möchte den aktuellen Mode nicht spielen
		modesucks.loves(cn)
			Spieler cn möchte den aktuellen Mode spielen
		modesucks.check()
			Führt die Prüfung durch, ob genügend Stimmen zusammengekommen
			sind. Ist die Prüfung erfolgreich, wird die Restzeit herunter-
			gesetzt. Ist gerade Intermission, wird keine Prüfung durch-
			geführt. Wurde schon einmal die Restzeit heruntergesetzt, findet
			ebenfalls keine Prüfung statt.
		modesucks.get_needed_votes()
			Gibt die Anzahl der benötigten Votes zurück. Dazu wird die
			Tabelle modesucks.needed_votes verwendet. Spieler können mit
			#lovemode jeweils ein #modesucks neutralisieren. In jedem Fall
			reichen jedoch 50% der Spieler aus (min-Funktion).  

	Commands:
		#modesucks
		#lovemode

	Konfigurations-Variablen:
		modesucks.needed_votes
			Anzahl der benötigten Votes bei einer bestimmten Spieleranzahl (indexbasierter Zugriff)
		modesucks.lowered_gametime
			Gibt die Anzahl der Sekunden an, auf die reduziert werden soll

	Laufzeit-Variablen:
		modesucks.game.gametimelowered
			Boolean: 0 = Die Zeit wurde nicht heruntergesetzt; 1 = Die Zeit wurde heruntergesetzt
		modesucks.game.sucks
			Anzahl der bisher abgegebenen #modesucks 
		modesucks.game.loves
			Anzahl der bisher abgegebenen #lovemode

	Events:
		intermission
			Bei Intermission werden die spielabhängigen Variablen zurückgesetzt
		interval
			Unabhängig davon, ob jemand #modesucks oder #lovemode gesagt hat,
			wird periodisch alle zwei Sekunden eine Prüfung durchgeführt. Dies
			ist nötig, weil Spieler connecten und disconnecten und sich das
			Verhältnis daher verschiebt
		reconnect
			Reconnected ein Spieler kann er weder #modesucks noch #lovemode machen
		disconnect
			Disconnected ein Spieler wird seine Stimme wieder entfernt

]]

require "math"

--[[
		API
]]

modesucks = {}
modesucks.game = {}
modesucks.game.gametimelowered = 0
modesucks.game.seconds_remaining = 0
modesucks.game.sucks = 0
modesucks.game.loves = 0
--        playercount     1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
modesucks.needed_votes = { 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,10,10,10,10,11,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23,23,24,24,24,25,25 }
modesucks.lowered_gametime = 60
modesucks.lowered_more = 10
modesucks.interval = 2

function modesucks.sucks(cn, force)
	if maprotation.intermission_running == 1 and force == nil then
		if maprotation.intermission_mode == maprotation.intermission_modes.VETO then
			veto.veto(cn)
		elseif maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
			modebattle.choose_none(cn)
		else
			-- Fallback: keine modesucks während der Intermission
			messages.error(cn, {cn}, "MODESUCKS", "On "..white("intermission").." there is no possibility to vote against a mode.")
		end
	else
		if nl.getPlayer(cn, "modesucks") == 1 or nl.getPlayer(cn, "lovemode") == 1 then
			messages.error(cn, {cn}, "MODESUCKS", string.format("You have already voted! Currently there are "..white("%i/%i").." vetos.", modesucks.game.sucks, modesucks.get_needed_votes()))
		else
			nl.updatePlayer(cn, "modesucks", 1, "set")
			modesucks.game.sucks = modesucks.game.sucks + 1
			db.insert("nl_veto", { player=server.player_displayname(cn), map=maprotation.map, mode=maprotation.game_mode } )
			if force == nil then
				messages.info(cn, players.all(), "MODESUCKS", string.format(blue("%s").." thinks that this "..white("mode sucks")..". Got "..white("%i votes").." (%i needed). Use "..orange("#modesucks"), server.player_displayname(cn), modesucks.game.sucks, modesucks.get_needed_votes()))
				modesucks.check()
			end
		end
	end
end

function modesucks.loves(cn, force)
	if maprotation.intermission_running == 1 and force == nil then
		if maprotation.intermission_mode == maprotation.intermission_modes.VETO then
			veto.noveto(cn)
		else
			-- Fallback: Keine #lovemodes während der Intermission
			messages.error(cn, {cn}, "MODESUCKS", "On "..white("intermission").." there is no possibility to love a mode.")
		end
	else
		if nl.getPlayer(cn, "modesucks") == 1 or nl.getPlayer(cn, "lovemode") == 1 then
			messages.error(cn, {cn}, "MODESUCKS", string.format("You have already voted! Currently there are "..white("%i/%i").." vetos.", modesucks.game.sucks, modesucks.get_needed_votes()))
		else
			nl.updatePlayer(cn, "lovemode", 1, "set")
			modesucks.game.loves = modesucks.game.loves + 1
			db.insert("nl_loves", { name=server.player_displayname(cn), map=maprotation.map, mode=maprotation.game_mode } )
			if force == nil then
				messages.info(cn, players.all(), "MODESUCKS", string.format(blue("%s").." likes this mode! Say "..orange("#lovemode").." if you like playing mode "..white("%s"), server.player_displayname(cn), maprotation.game_mode))
			end
		end
	end
end

function modesucks.check()
	if maprotation.intermission_running == 0 and modesucks.game.gametimelowered == 0 and (server.gamelimit - server.gamemillis) > (modesucks.lowered_gametime * 1000) then
		if modesucks.game.sucks >= modesucks.get_needed_votes() then
			modesucks.game.gametimelowered = 1
			modesucks.game.seconds_remaining = modesucks.lowered_gametime - 1
			server.changetime((modesucks.game.seconds_remaining - 1) * 1000)
			messages.warning(cn, players.all(), "MODESUCKS", string.format(white("Mode sucks!").." Game time was lowered to "..white("%s seconds"), modesucks.lowered_gametime) )
		end
	elseif maprotation.intermission_running == 0 then
		modesucks.game.seconds_remaining = modesucks.game.seconds_remaining - modesucks.interval
		local more = modesucks.game.sucks - modesucks.get_needed_votes()
		if more >= modesucks.game.gametimelowered then
			modesucks.game.gametimelowered = modesucks.game.gametimelowered + 1
			if modesucks.game.gametimelowered == 1 then
				modesucks.game.seconds_remaining = modesucks.lowered_gametime - 1
			end
			modesucks.game.seconds_remaining = modesucks.game.seconds_remaining - modesucks.lowered_more
			server.changetime(modesucks.game.seconds_remaining * 1000)
			messages.warning(cn, players.all(), "MODESUCKS", string.format(white("Mode sucks more !").." Game time was lowered to "..white("%s seconds"), modesucks.game.seconds_remaining) )
		end
	end
end

function modesucks.get_needed_votes()
	-- minimum: tabelleneintrag
	-- normal:  tabelleneintrag plus lovemodes
	-- maximum: 75% aller spieler
	if server.playercount == 0 then return 1 end
	return math.max(modesucks.needed_votes[server.playercount], math.min(modesucks.needed_votes[server.playercount] + modesucks.game.loves, math.floor((server.playercount+1) / 1.75)))
end



--[[
		COMMANDS
]]

function server.playercmd_modesucks(cn)
	modesucks.sucks(cn)
end

function server.playercmd_lovemode(cn)
	modesucks.loves(cn)
end



--[[
		EVENTS
]]

server.event_handler("disconnect", function(cn)
	if nl.getPlayer(cn, "modesucks") == 1 then
		modesucks.game.sucks = modesucks.game.sucks - 1
	end
	if nl.getPlayer(cn, "lovemode") == 1 then
		modesucks.game.loves = modesucks.game.loves - 1
	end
end)

server.event_handler("reconnect", function(cn)
	-- block modesucks and lovemode on reconnect
	nl.updatePlayer(cn, "lovemode", 1, "set")
	nl.updatePlayer(cn, "modesucks", 1, "set")
end)

server.event_handler("intermission", function()
	modesucks.game.gametimelowered = 0
	modesucks.game.secondsremaining = 0
	modesucks.game.sucks = 0
	modesucks.game.loves = 0
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "modesucks", 0, "set")
		nl.updatePlayer(cn, "lovemode", 0, "set")
	end
end)

server.interval(modesucks.interval * 1000, modesucks.check)



--[[
		EXTRACTCOMMAND RULES
]]

extractcommand.register("modesucks", false, modesucks.sucks)
extractcommand.register("mode sucks", false, modesucks.sucks)
extractcommand.register("m o d e s u c k s", false, modesucks.sucks)
extractcommand.register("shitmode", false, modesucks.sucks)
extractcommand.register("shit mode", false, modesucks.sucks)
extractcommand.register("fucking mode", false, modesucks.sucks)
extractcommand.register("hate this mode", false, modesucks.sucks)
extractcommand.register("hate mode", false, modesucks.sucks)
extractcommand.register("mode is bad", false, modesucks.sucks)

extractcommand.register("love mode", false, modesucks.loves)
extractcommand.register("love this mode", false, modesucks.loves)
extractcommand.register("lovemode", false, modesucks.loves)
extractcommand.register("lovemodes", false, modesucks.loves)
extractcommand.register("moderules", false, modesucks.loves)
extractcommand.register("moderulez", false, modesucks.loves)
extractcommand.register("mode rules", false, modesucks.loves)
extractcommand.register("mode rulez", false, modesucks.loves)
