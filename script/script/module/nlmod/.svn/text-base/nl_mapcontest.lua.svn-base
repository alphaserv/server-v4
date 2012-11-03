--[[
	script/module/nl_mod/nl_mapcontest.lua
	Hankus (Derk Händel) nach einer Vorlage von Hanack (Andreas Schaeffer)
	Created: 30-Nov-2011
	Last Modified: 23-Okt-2010
	License: GPL3

	Funktionen:
		Ein neuer Intermission Mode: MapContest.
		Während der Intermission haben aktive Spieler die Möglichkeit, die gerade
		gespielte Map aus der Rotation zu voten.

	API-Methoden:
		mapcontest.check
			wechselt sofort zu angebener map und mode

	Commands:
		#blah
			fasel

	Laufzeit-Variablen:
		mapcontest.suggested_maps

	Events und Timer
		Alle 120sek prüfen, ob ein MapContest anliegt
		Eine Stunde vor dem MapContest alle 120sek einen Announce machen
		120sek vor dem MapContest den Intermission-Mode aktivieren

]]

require "math"


--[[
		API
]]

mapcontest = {}
mapcontest.stage = 0
mapcontest.init = {}
mapcontest.init.secondstocheck = 40
mapcontest.init.secondstovote = 30
mapcontest.init.secondstoplay = 300
mapcontest.voting = {}
mapcontest.voting.optin = 0
mapcontest.voting.optout = 0
mapcontest.voting.none = 0
mapcontest.voting.all = 0
mapcontest.names = {}
mapcontest.names.optin = ""
mapcontest.names.optout = ""
mapcontest.players = {}
mapcontest.players.optin = -1
mapcontest.players.optout = -1
mapcontest.remaining_seconds = 0
mapcontest.previous_intermission_mode = 3
mapcontest.suggested_maps = {}
mapcontest.suggestions = 0
mapcontest.lastmaps = {}

maprotation.intermission_modes.MAPCONTEST = 5
maprotation.intermission[maprotation.intermission_modes.MAPCONTEST] = function()
	--[[
		intermission mode 4: mapcontest
		Es findet ein MapContest statt
	]]
	if mapcontest.stage == 2 then
		mapcontest.stage = 3
		cmd_blacklist["nextmap"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["nm"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["changetime"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["mute"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["pbox"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["penaltybox"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["map"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["veto"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["mapsucks"] = "red<This command is temporarily unavailable during MapContest.>"
		cmd_blacklist["mapbattle"] = "red<This command is temporarily unavailable during MapContest.>"
		maprotation.change_map(mapcontest.maps[mapcontest.mapcnt].map, mapcontest.mode)
	else
		mapcontest.remaining_seconds = mapcontest.init.secondstovote
		messages.info(cn, players.all(), "MAPCONTEST", " " )
		messages.info(cn, players.all(), "MAPCONTEST", string.format(" red<VOTE NOW for the map:> %s yellow<(Mode: %s)>", server.map, server.gamemode))
		messages.info(cn, players.all(), "MAPCONTEST", "   yellow<Commands are:> orange<in> yellow<and> orange<out>")
		mapcontest.update()
	end
end

function mapcontest.update()

	-- Abbruch, wenn Zeit abgelaufen ist
	if mapcontest.remaining_seconds <= 0 then
		mapcontest.check_votes()
		return
	end
	
	-- Intermission fortsetzen
	server.sleep(1000, function()
		mapcontest.remaining_seconds = mapcontest.remaining_seconds - 1
		mapcontest.update()
	end)
end

function mapcontest.check_votes()
	messages.debug( -1, players.admins(), "MAPCONTEST", string.format("red<Checking for:> %s", "Votes") )
	if mapcontest.voting.optin > mapcontest.voting.optout then
		-- Map bleibt in der Rotation für diesen Mode
		messages.warning(-1, players.all(), "MAPCONTEST", "orange<WINNER:> "..mapcontest.maps[mapcontest.mapcnt].map.." stays in the Rotation.")
	elseif mapcontest.voting.optin < mapcontest.voting.optout then
		-- Map fliegt aus der Rotation für diesen Mode
		messages.warning(-1, players.all(), "MAPCONTEST", "orange<LOSER:> "..mapcontest.maps[mapcontest.mapcnt].map.." is kicked from the Rotation.")
	elseif mapcontest.voting.optin == mapcontest.voting.optout then
		-- Unentschieden
		messages.warning(-1, players.all(), "MAPCONTEST", "orange<TIE:> "..mapcontest.maps[mapcontest.mapcnt].map.." stays in the Rotation.")
	end
	
	mapcontest.mapcnt = mapcontest.mapcnt + 1
	if mapcontest.mapcnt <= #mapcontest.maps then
		maprotation.push_map(mapcontest.maps[mapcontest.mapcnt].map, mapcontest.mode)
		mapcontest.reset_votes()
		maprotation.next_map(mapcontest.mode)
	else
		cmd_blacklist["nextmap"] = nil
		cmd_blacklist["nm"] = nil
		cmd_blacklist["changetime"] = nil
		cmd_blacklist["mute"] = nil
		cmd_blacklist["pbox"] = nil
		cmd_blacklist["penaltybox"] = nil
		cmd_blacklist["map"] = nil
		cmd_blacklist["veto"] = nil
		cmd_blacklist["mapsucks"] = nil
		cmd_blacklist["mapbattle"] = nil
		mapcontest.stage = 0
		maprotation.intermission_mode = mapcontest.previous_intermission_mode
		maprotation.loadmaps()
		maprotation.calculate_rotation()
		maprotation.next_map()
	end
end

function mapcontest.is_mapcontest_phase()
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPCONTEST then
		return true
	else
		return false
	end
end

function mapcontest.vote_in(cn)
	if nl.getPlayer(cn, "mapcontest") == 1 then
		messages.error(cn, {cn}, "MAPCONTEST", "red<You have already voted!>")
	else
		if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "serverowner" or nl.getPlayer(cn, "nl_status") == "masteradmin" or nl.getPlayer(cn, "nl_status") == "admin" or nl.getPlayer(cn, "nl_status") == "honoraryadmin" then
			if server.player_timeplayed(cn) > mapcontest.init.secondstoplay then
				mapcontest.voting.optin = mapcontest.voting.optin + 1
				mapcontest.voting.all = mapbattle.voting.all + 1
				nl.updatePlayer(cn, "mapcontest", 1, "set")
				messages.info(-1, players.all(), "MAPCONTEST", string.format( "orange<Map: %s> %s:%s (in:out) green< -- %s votes in!>", server.map, tostring(mapcontest.voting.optin), tostring(mapcontest.voting.optout), server.player_displayname(cn) ))
				db.insert("ml_contests_votes", { id_contest=mapcontest.id, id_map=mapcontest.maps[mapcontest.mapcnt].id, statsname=server.player_displayname(cn), vote=1 } )
			else
				messages.error(cn, {cn}, "MAPCONTEST", "red<You have to play for about 5 minutes!>")
			end
		else
			messages.error(cn, {cn}, "MAPCONTEST", "red<You have to be a registered player!>")
		end
	end
end

function mapcontest.vote_out(cn)
	if nl.getPlayer(cn, "mapcontest") == 1 then
		messages.error(cn, {cn}, "MAPCONTEST", "red<You have already voted!>")
	else
		if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "serverowner" or nl.getPlayer(cn, "nl_status") == "masteradmin" or nl.getPlayer(cn, "nl_status") == "admin" or nl.getPlayer(cn, "nl_status") == "honoraryadmin" then
			if server.player_timeplayed(cn) > mapcontest.init.secondstoplay then
				mapcontest.voting.optout = mapcontest.voting.optout + 1
				mapcontest.voting.all = mapbattle.voting.all + 1
				nl.updatePlayer(cn, "mapcontest", 1, "set")
				messages.info(-1, players.all(), "MAPCONTEST", string.format( "orange<Map: %s> %s:%s (in:out) green< -- %s votes out!>", server.map, tostring(mapcontest.voting.optin), tostring(mapcontest.voting.optout), server.player_displayname(cn) ))
				db.insert("ml_contests_votes", { id_contest=mapcontest.id, id_map=mapcontest.maps[mapcontest.mapcnt].id, statsname=server.player_displayname(cn), vote=2 } )
			else
				messages.error(cn, {cn}, "MAPCONTEST", "red<You have to play for about 5 minutes!>")
			end
		else
			messages.error(cn, {cn}, "MAPCONTEST", "red<You have to be a registered player!>")
		end
	end
end

function mapcontest.reset_votes()
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "mapcontest", 0, "set")
	end
	mapcontest.voting.optin = 0
	mapcontest.voting.optout = 0
	mapcontest.voting.none = 0
	mapcontest.voting.all = 0
end

--[[
		COMMANDS
]]

--[[
		EVENTS
]]

server.interval(mapcontest.init.secondstocheck*1000, function()
	if maprotation.intermission_running == 0 then
		-- Prüfen, ob in der nächsten Stunde ein MapContest anliegt
		if mapcontest.stage == 0 then
			local contests = db.select( "ml_contests", { "id", "start", "server", "mode" }, string.format("server='%s' AND start>NOW() AND start<ADDDATE(NOW(), INTERVAL 60 MINUTE)", server.nmsrvid) )
			--messages.debug( -1, players.admins(), "MAPCONTEST", string.format("red<SQL:> %s", string.format("server='%s' AND start>NOW() AND start<ADDDATE(NOW(), INTERVAL 60 MINUTE)", server.nmsrvid)) )
			if #contests == 0 then
				messages.debug( -1, players.admins(), "MAPCONTEST", string.format("red<Checking for %s:> %s", "active MapContests", tostring(#contests)) )
			else
				mapcontest.id = contests[1].id
				mapcontest.start = db.parseDateTime(contests[1].start)
				mapcontest.server = contests[1].server
				mapcontest.mode = contests[1].mode
				mapcontest.stage = 1
				mapcontest.mapcnt = 1
				mapcontest.maps = nil
				local contestmaps = db.select( "ml_contests_maps", { "id", "map"}, string.format("id_contest=%s", tostring(mapcontest.id)) )
				-- messages.debug( -1, players.admins(), "MAPCONTEST", string.format("red<SQL:> %s", string.format("id_contest=%s", tostring(mapcontest.id))) )
				if #contestmaps > 0 then
					mapcontest.maps = {}
					local cnt = 1
					for i,contestmap in pairs(contestmaps) do
						table.insert(mapcontest.maps, {})
						mapcontest.maps[cnt].id = tonumber(contestmap.id)
						mapcontest.maps[cnt].map = tostring(contestmap.map)
						mapcontest.maps[cnt].played = 0
						mapcontest.maps[cnt].optin = 0
						mapcontest.maps[cnt].optout = 0
						mapcontest.maps[cnt].none = 0
						messages.debug( -1, players.admins(), "MAPCONTEST", string.format("From DB > red<%s.:> %s", tostring(contestmap.id), tostring(contestmap.map)) )
						cnt = cnt + 1
					end
				else
					messages.debug( -1, players.admins(), "MAPCONTEST", "red<DB Keine Maps gefunden>" )
				end
			end
		elseif mapcontest.stage == 1 then
			if #mapcontest.maps > 0 then
				local remainingmins = tonumber(os.date("%M", mapcontest.start - os.time()))
				messages.info(-1, players.all(), "MAPCONTEST", string.format( "The next MapContest will start in ~ %s minutes.", tostring(remainingmins) ))
				if remainingmins < server.timeleft then
					mapcontest.stage = 2
					mapcontest.previous_intermission_mode = maprotation.intermission_mode
					maprotation.intermission_mode = 5
				end
				--[[
			for i,map in ipairs(mapcontest.maps) do
				messages.debug( -1, players.admins(), "MAPCONTEST", string.format("From LUA > red<%s.:> %s", map.id, map.map) )
			end
			]]
			else
				messages.debug( -1, players.admins(), "MAPCONTEST", "red<TABLE Keine Maps gefunden>" )
			end
			-- mapcontest.stage = 0
		elseif mapcontest.stage == 2 then
			messages.info(-1, players.all(), "MAPCONTEST", "The next MapContest will start right after this map.")
		elseif mapcontest.stage == 3 then
			messages.info(-1, players.all(), "MAPCONTEST", "You can vote for this map in the next intermission,")
			messages.info(-1, players.all(), "MAPCONTEST", "if you played for 5 minutes as a registered player.")
			-- tonumber(server.player_timeplayed(cn))
			for _, tcn in ipairs(players.registered()) do
				messages.info(tcn, { tcn }, "MAPCONTEST", string.format( "You played for about %s.", os.date("%M min %S sec", server.player_timeplayed(tcn)) ))
			end
		end
	end
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep((maprotation.intermission_startdelay+maprotation.intermission_predelay)*1200, function()
		--[[
				EXTRACTCOMMAND RULES
		]]
		extractcommand.register("+", false, mapcontest.vote_in, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("-", false, mapcontest.vote_out, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("1", false, mapcontest.vote_in, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("2", false, mapcontest.vote_out, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("i", false, mapcontest.vote_in, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("o", false, mapcontest.vote_out, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("ín", false, mapcontest.vote_in, mapcontest.is_mapcontest_phase, false)
		extractcommand.register("out", false, mapcontest.vote_out, mapcontest.is_mapcontest_phase, false)
	end)
end)
