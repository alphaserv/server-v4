--[[
	script/module/nl_mod/nl_maprotation.lua

	Authors:		Hanack (Andreas Schaeffer)
					Hankus
	Created:		17-Okt-2010
	Last Modified:	11-Mai-2012
	License: 		GPL3

	Funktionen:
		Kontrolliert die Intermission und verzögert sie, bis feststeht, welche Map geladen
		werden soll. Führt das Wechseln der Map durch. Erstellt eine Rotationsliste von
		den nächsten Maps, basierend auf einem Bewertungsverfahren. Bietet eine Schnitt-
		stelle, um in die Rotation einzugreifen (z.b. Mapbattles oder Veto-Phasen).
	

	API-Methoden:
		maprotation.fetch_maps
			Holt die Maps für die jeweilige Serverid aus der Datenbank
		maprotation.change_map
			Wechselt sofort zur angebenen Map und zum angegebenen Mode
		maprotation.next_map
			Wechselt sofort zur naechsten Map in der Rotation
		maprotation.pull_map
			Holt sich die naechste Map aus dem Stapel
		maprotation.push_map
			fuegt eine map in den stapel vorn ein
		maprotation.calculate_rotation
			speichert eine neue rotation anhand von played games und vetos

	Commands:
		#map <map> <mode>
			Wechselt nach kurzer Unterbrechung zur angegebenen Map und dem
			angegebenen Mode.
		#restartmap
			Startet die aktuelle Map neu (nur in Notfällen).
		#nextmap <map> = #nm <map>
			Setzt die nächste Map (fügt sie ganz vorn ein)
		#nm
			Zeigt die nächste Map.
		#nm persist
			Toggle. Setzt den aktuellen Game Mode als persistent. Kein Wechsel des
			Game Modes mehr möglich!
		#nm lock
			Toggle. Setzt die aktuelle Map als persistent. Kein Wechsel der Map
			mehr möglich! 
		#nm skip
			Die nächste Map in der Rotation für den aktuellen Game Mode wird
			übersprungen.
		#nm list
			Listet alle Maps auf, die dieser Server für den aktuellen Game Mode
			akzeptiert. 
		#nm nextmaps
			Listet die nächsten Maps in der Reihenfolge der Rotation auf.
		#nm announce
			Sendet allen Spielern eine Info, welche Map die nächste sein wird.
		#mdb rm
			entfernt die aktuell gespielte Map aus der Rotation
		#mdb add mode map
			Hinzufügen einer Map zur Rotation
		#intermission mode <intermission_mode>
			Wechselt den Intermissionmode:
				1 = Normal
				2 = Schnell
				3 = Veto
				4 = Map Battle
				5 = Map Contest
				6 = Mode Battle
		#intermission info
			Zeigt Informationen über die Einstellungen für die Intermission.
		#intermission list
			Listet alle Intermission Modes auf
		#intermission stop
			Beendet die Intermission unverzüglich und wechselt zur nächsten Map
			in der Rotation 

	Konfigurations-Variablen:
		maprotation.maps
			Pro gamemode ist eine Liste von Maps verfuegbar
		maprotation.intermission_predelay
			Anzahl der Sekunden, die nach Beginn der Intermission zu warten sind, bevor
			der Rotation-Modus gestartet wird (pre delay)
		maprotation.intermission_postdelay
			Anzahl der Sekunden, die vor dem Mapwechsel zu warten sind (post delay)
		maprotation.intermission_maxdelay
			Max Sekunden der Intermission

	Laufzeit-Variablen:
		maprotation.intermission_mode
			Der aktuelle Modus der Intermission (normal, fast, veto, mapbattle, ...)
		maprotation.rotation
			Es wird eine liste von maps berechnet
		maprotation.intermission_running
			Boolean, 0: keine intermission; 1: intermission laeuft
		maprotation.game_mode
			Der aktuelle Game Mode
		maprotation.map
			Die aktuelle Map


]]

require "luasql_mysql"
require "table"
require "math"


--[[
		API
]]

maprotation = {}

server.default_gamemode = server.default_gamemode or "insta ctf"
maprotation.allowed_modes = server.parse_list(server.enabled_gamemodes) or { server.default_gamemode }
maprotation.signal = server.create_event_signal("changingmap")
maprotation.checkinjection_state = 0 -- (0=init, 1=running, 2=done)
maprotation.checkinjection_duration = 2000 -- Timeout für die CRCs der Spieler
maprotation.checkinjection_cn = {} -- 1. cn in der Tabelle koennte der Hacker sein
maprotation.intermission = {}
maprotation.intermission_break = {}
maprotation.intermission_startdelay = 30
maprotation.intermission_predelay = 3
maprotation.intermission_postdelay = 5
maprotation.intermission_maxdelay = 55
maprotation.intermission_maxgamemillis = 12*60*1000
maprotation.intermission_running = 0
maprotation.intermission_delay = 0
maprotation.intermission_mode = 3
maprotation.intermission_modes = {}
maprotation.intermission_modes.NORMAL = 1
maprotation.intermission_modes.FAST = 2
maprotation.intermission_modes.TIMEOUT = 99
maprotation.intermission_defaultmode = 3
maprotation.persist_mode = 0
maprotation.persist_map = 0
maprotation.rotation = {}
maprotation.rotationModes = {}
maprotation.maps = {}
maprotation.maps['coop'] = { "frostbyte" }
maprotation.normal_timeout = 10000

function maprotation.addmap(dbmap, dbmode)
	db.insert_or_update( "nl_maps", { map = dbmap, mode = dbmode, server = server.nmgrpid, valid=1 }, string.format("map='%s' and mode='%s' and server='%s'", tostring(dbmap), tostring(dbmode), tostring(server.nmgrpid)) )
end

function maprotation.fetch_maps(mode)
	if maprotation.maps[mode] ~= nil then
		maprotation.maps[mode] = nil
	end
	local maps = db.select( "nl_maps", { "map" }, string.format("mode='%s' AND server='%s' AND valid=1", mode, server.nmgrpid) )
	server.log( string.format("Anzahl der Maps für Mode '%s' = %s (grp=%s)", mode, tostring(#maps), tostring(server.nmgrpid)) )
	if #maps > 0 then
		maprotation.maps[mode] = {}
		for i,map in pairs(maps) do
			table.insert(maprotation.maps[mode], map.map)
		end
	else
		server.log( string.format("Keine Maps für Mode '%s' (grp=%s)", mode, tostring(server.nmgrpid)) )
	end
end

function maprotation.loadmaps()
	server.sleep(100, function()
		if irc_say ~= nil then
			irc_say("Maprotation database started")
		end
	end)
	maprotation.fetch_maps("insta ctf")
	maprotation.fetch_maps("efficiency ctf")
	maprotation.fetch_maps("ctf")
	maprotation.fetch_maps("insta hold")
	maprotation.fetch_maps("efficiency hold")
	maprotation.fetch_maps("hold")
	maprotation.fetch_maps("insta protect")
	maprotation.fetch_maps("efficiency protect")
	maprotation.fetch_maps("protect")
	maprotation.fetch_maps("ffa")
	maprotation.fetch_maps("instagib")
	maprotation.fetch_maps("efficiency")
	maprotation.fetch_maps("tactics")
	maprotation.fetch_maps("efficiency team")
	maprotation.fetch_maps("instagib team")
	maprotation.fetch_maps("tactics team")
	maprotation.fetch_maps("teamplay")
	maprotation.fetch_maps("capture")
	maprotation.fetch_maps("regen capture")
end

function maprotation.change_map(map, mode, immediately)
	-- messages.debug(-1, players.admins(), "INTERMISSION", string.format("New map %s --- New mode: %s", map, mode))
	-- insert into database
	db.insert('nl_maprotation', {map=map, mode=mode})
	maprotation.signal(map, mode)
	-- change map
	if immediately then
		messages.irc("INTERMISSION", string.format("blue<Choose map %s on mode %s>", map, mode), "red")
		maprotation.game_mode = mode
		maprotation.map = map
		maprotation.intermission_running = 0
		server.changemap(map, mode)
	else
		server.sleep(maprotation.intermission_postdelay * 1000, function()
			messages.irc("INTERMISSION", string.format("blue<Choose map %s on mode %s>", map, mode), "red")
			maprotation.game_mode = mode
			maprotation.map = map
			maprotation.intermission_running = 0
			server.changemap(map, mode)
		end)
	end
end

function maprotation.next_map(mode)
	if maprotation.persist_map == 1 then
		maprotation.change_map(map, mode)
		return
	end
	if mode ~= nil then
		local map = maprotation.pull_map(mode)
		maprotation.change_map(map, mode)
		if maprotation.rotationModes[mode] == nil then
			maprotation.rotationModes[mode] = {}
			maprotation.calculate_rotation(mode)
		end
		local rmodeMaps = maprotation.rotationModes[mode]
		if #rmodeMaps == 0 then
			maprotation.calculate_rotation(mode)
		end
	else
		local modes = maprotation.allowed_modes
		local mode = maprotation.allowed_modes[math.random(#modes)]
		local map = maprotation.pull_map(mode)
		maprotation.change_map(map, mode)
		if maprotation.rotationModes[mode] == nil then
			maprotation.rotationModes[mode] = {}
			maprotation.calculate_rotation(mode)
		end
		local rmodeMaps = maprotation.rotationModes[mode]
		if #rmodeMaps == 0 then
			maprotation.calculate_rotation(mode)
		end
	end
end

function maprotation.restart_map()
	maprotation.signal(maprotation.map, maprotation.game_mode)
	server.sleep(500, function()
		server.changemap(maprotation.map, maprotation.game_mode)
	end)
end

function maprotation.get_next_map(mode)
	if maprotation.persist_map == 1 then
		return maprotation.map
	end
	if mode ~= nil then
		local modes = maprotation.allowed_modes
		local mode = maprotation.allowed_modes[math.random(#modes)]
		if maprotation.rotationModes[mode] ~= nil then
			if #maprotation.rotationModes[mode] == 0 then
				maprotation.calculate_rotation(mode)
			end
			return maprotation.rotationModes[mode][1]
		else
			maprotation.calculate_rotation(mode)
			return maprotation.rotationModes[mode][1]
		end
	else
		if #maprotation.rotationModes[maprotation.game_mode] == 0 then
			maprotation.calculate_rotation(maprotation.game_mode)
		end
		return maprotation.rotationModes[maprotation.game_mode][1]			
	end
end

function maprotation.get_next_mode()
	if maprotation.persist_mode == 1 then
		return maprotation.game_mode
	else
		local mode = maprotation.allowed_modes[math.random(#maprotation.allowed_modes)]
		if mode == "coop edit" then
			return maprotation.get_next_mode()
		else
			return mode
		end
	end
end

function maprotation.push_map(map, mode)
	if mode ~= nil then
		if maprotation.rotationModes[mode] == nil then
			maprotation.rotationModes[mode] = {}
			maprotation.calculate_rotation(mode)
		end
		table.insert(maprotation.rotationModes[mode], 1, map)
	else
		table.insert(maprotation.rotationModes[maprotation.game_mode], 1, map)
	end
end

function maprotation.pull_map(mode)
	if maprotation.persist_map == 1 then
		return maprotation.map
	end
	if mode == nil then
		local modes = maprotation.allowed_modes
		mode = maprotation.allowed_modes[math.random(#modes)]
	end
	if maprotation.rotationModes[mode] == nil then
		maprotation.rotationModes[mode] = {}
		maprotation.calculate_rotation(mode)
	end
	if #maprotation.rotationModes[mode] > 0 then
		return table.remove(maprotation.rotationModes[mode], 1)
	else
		maprotation.calculate_rotation(mode)
		return table.remove(maprotation.rotationModes[mode], 1)
	end
end

function maprotation.break_intermission()
    if maprotation.intermission_break ~= nil and maprotation.intermission_break[tonumber(maprotation.intermission_mode)] ~= nil then
		maprotation.intermission_break[tonumber(maprotation.intermission_mode)]()
	end
end

--[[
	Diese Funktion berechnet für einen bestimmten Game Mode die nächsten
	Maps der Rotation. Im Prinzip schaut sie in der Datenbank nach, wieviele
	Vetos eine Map bekommen hat und beurteilt anhand dieses Wertes die
	Beliebtheit der Map. Die beliebtesten 5 Maps werden 3x in die Rotation
	gelegt, die nächsten 5 Maps werden 2x in die Rotation gelegt und die
	restlichen Maps nur 1x. Ganz zum Schluss wird per Zufallsfunktion die
	Reihenfolge der Maps durchgewürfelt.   
]]
function maprotation.calculate_rotation(mode)
	-- init
	local maps = {}
	if mode == nil then
		local modes = maprotation.allowed_modes
		mode = maprotation.allowed_modes[math.random(#modes)]
	end
	if mode == "coop" or mode == "coop edit" or maprotation.maps[mode] == nil then
		maprotation.rotationModes[mode] = { "frostbyte" }
		return
	end
	for i, mapName in ipairs(maprotation.maps[mode]) do
		maps[mapName] = {}
		maps[mapName]['name'] = mapName
		maps[mapName]['played'] = 0
		maps[mapName]['vetos'] = 0
		maps[mapName]['vpp'] = 0
	end
	-- fetch data from db
	local env = assert (luasql.mysql())
	local con = assert (env:connect(server.stats_mysql_database, server.stats_mysql_username, server.stats_mysql_password, server.stats_mysql_hostname, server.stats_mysql_port));
	local select_bestmap1_sql = [[SELECT map, count(map) AS anzahl FROM nl_maprotation WHERE mode='%s' GROUP BY map]]
	local cur = assert (con:execute(string.format(select_bestmap1_sql, mode)))
	if cur:numrows() > 0 then
		row = cur:fetch ({}, "a")
		while row do
			if row.map ~= nil and row.map ~= "" and maprotation.is_valid_map(row.map, mode) then
				maps[row.map]['played'] = row.anzahl
			end
			row = cur:fetch (row, "a")
		end
	end
	local select_bestmap2_sql = [[SELECT map, count(map) AS anzahl FROM nl_veto WHERE mode='%s' GROUP BY map]]
	local cur = assert (con:execute(string.format(select_bestmap2_sql, mode)))
	if cur:numrows() > 0 then
		row = cur:fetch ({}, "a")
		while row do
			if row.map ~= nil and row.map ~= "" and maprotation.is_valid_map(row.map, mode) then
				maps[row.map]['vetos'] = row.anzahl
			end
			row = cur:fetch (row, "a")
		end
	end
	if not con:close() then server.log_error("con:close failed in nl_maprotation") end
	if not env:close() then server.log_error("env:close failed in nl_maprotation") end
	
	for i, mapName in pairs(maprotation.maps[mode]) do
		maps[mapName]['vpp'] = maps[mapName]['vetos'] / (maps[mapName]['played']+1) --avoid div zero!
	end
	-- sort per vpp
	table.sort(maps, maprotation.vpp_comp)

	local count = 0
	for i, map in pairs(maps) do
		count = count + 1
		if count < 5 then
			if (maprotation.rotationModes[mode] == nil) then
				maprotation.rotationModes[mode] = {}
			end
			table.insert(maprotation.rotationModes[mode], map['name'])
		end
		if count < 10 then
			if (maprotation.rotationModes[mode] == nil) then
				maprotation.rotationModes[mode] = {}
			end
			table.insert(maprotation.rotationModes[mode], map['name'])
		end
		table.insert(maprotation.rotationModes[mode], map['name'])
	end
	-- shuffle
	maprotation.shuffle(maprotation.rotationModes[mode])
end

function maprotation.shuffle(t)
	local n = #t
	while n > 1 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
	return t
end
math.randomseed( os.time() )


function maprotation.vpp_comp(w1,w2)
	if w1['vpp'] < w2['vpp'] then
		return true
	end
end

function maprotation.is_valid_mode(reqmode)
	for _, mode in pairs(maprotation.allowed_modes) do
		if reqmode == mode then return true end
	end
	return false
end

function maprotation.is_valid_map(reqmap, mode)
	if mode == nil then return false end
	if mode == "coop" or mode == "coop edit" then return true end
	if not maprotation.is_valid_mode(mode) then return false end
	if maprotation.maps[mode] == nil then return false end
	for _, map in pairs(maprotation.maps[mode]) do
		if reqmap == map then return true end
	end
	return false
end

maprotation.intermission[maprotation.intermission_modes.NORMAL] = function()
	-- intermission mode 1 "normal": Es werden 10 Sekunden gewartet, dann wird einfach die naechste map in der rotation genommen
	server.sleep(maprotation.normal_timeout, function()
		maprotation.next_map(maprotation.game_mode)
	end)
end

maprotation.intermission_break[maprotation.intermission_modes.NORMAL] = function()
	maprotation.next_map(maprotation.game_mode)
end

maprotation.intermission[maprotation.intermission_modes.FAST] = function()
	-- intermission mode 2 ("fast"): Es wird sofort zur naechsten map gewechselt
	maprotation.next_map(maprotation.game_mode)
end

maprotation.intermission_break[maprotation.intermission_modes.FAST] = function()
	maprotation.next_map(maprotation.game_mode)
end

maprotation.intermission[maprotation.intermission_modes.TIMEOUT] = function()
	-- intermission mode 99 "TIMEOUT":
	-- Nur zu Testzwecken!
	-- Es wird gewartet, bis der Timeout der Maprotation abgelaufen ist, d.h. es wird rein gar nichts gemacht.
	-- Man kann die Intermission durch das Command "#intermission stop" beenden
	messages.debug(cn, players.admins(), "INTERMISSION", string.format("red<WARNING:> orange<Intermission Mode is TIMEOUT!>"))
end

maprotation.intermission_break[maprotation.intermission_modes.TIMEOUT] = function()
	maprotation.next_map(maprotation.game_mode)
end

function maprotation.delay_intermission()
	messages.debug(cn, players.admins(), "MAPROTATION", red("DELAY INTERMISSION: ")..maprotation.intermission_running.." ("..maprotation.intermission_delay.."/"..maprotation.intermission_maxdelay.." seconds) -- "..server.intermission.." = "..server.gamemillis.."+"..maprotation.intermission_delay.."*1000" )
	if maprotation.intermission_running == 1 and maprotation.intermission_delay < maprotation.intermission_maxdelay then
		server.intermission = server.gamemillis + maprotation.intermission_delay*1000;
		server.sleep(1000, function()
			maprotation.intermission_delay = maprotation.intermission_delay + 1
			maprotation.delay_intermission()
		end)
	else
		if server.gamemills ~= nil and maprotation.intermission_maxgamemillis ~= nil and maprotation.intermission_maxdelay ~= nil then
			if maprotation.intermission_delay >= maprotation.intermission_maxdelay or server.gamemillis > maprotation.intermission_maxgamemillis then
				maprotation.intermission_mode = maprotation.intermission_defaultmode
				maprotation.intermission_running = 0
				maprotation.next_map()
				messages.info(cn, players.all(), "MAPROTATION", "Stopped intermission after " .. maprotation.intermission_delay .. " seconds. Indeed, it took really long. To avoid intermission overstays the server is choosing the next regular map immediately")
				server.sleep(100, function()
					messages.irc("INTERMISSION", string.format("Intermission took %i seconds (total %i players)", maprotation.intermission_delay, server.playercount))
				end)
			end
		end
	end
end


--[[
		COMMANDS
]]

function server.playercmd_intermission(cn, command, arg)
	if not hasaccess(cn, intermissionmode_access) then return end
	if command == nil then
		return false, "#intermission <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "mode" then
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_mode = " .. maprotation.intermission_mode)
			end
			if command == "default" then
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_defaultmode = " .. maprotation.intermission_defaultmode)
			end
			if command == "info" then
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_mode = " .. maprotation.intermission_mode)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_running = " .. maprotation.intermission_running)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_delay = " .. maprotation.intermission_delay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_maxdelay = " .. maprotation.intermission_maxdelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_maxgamemillis = " .. maprotation.intermission_maxgamemillis)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_predelay = " .. maprotation.intermission_predelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_postdelay = " .. maprotation.intermission_postdelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.allowed_modes = " .. table.concat(maprotation.allowed_modes, ", "))
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.map = " .. maprotation.map)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.game_mode = " .. maprotation.game_mode)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.persist_mode = " .. maprotation.persist_mode)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.persist_map = " .. maprotation.persist_map)
				messages.info(cn, {cn}, "MAPROTATION", "server.intermission = " .. server.intermission)
				messages.info(cn, {cn}, "MAPROTATION", "server.gamemillis = " .. server.gamemillis)
			end
			if command == "list" then
				messages.info(cn, {cn}, "MAPROTATION", string.format("List of Intermission Modes:"))
				for k,v in pairs(maprotation.intermission_modes) do
					messages.info(cn, {cn}, "MAPROTATION", string.format("%i: %s", v, k))
				end
			end
			if command == "stop" then
				messages.warning(cn, players.admins(), "MAPROTATION", string.format("blue<%s> stopped intermission!", server.player_displayname(cn)))
				maprotation.break_intermission()
				maprotation.next_map(maprotation.game_mode)
			end
		else
			if command == "mode" then
				maprotation.intermission_mode = tonumber(arg)
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> set intermission mode to red<%i>", server.player_displayname(cn), tonumber(arg)))
			end
			if command == "default" then
				maprotation.intermission_defaultmode = tonumber(arg)
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> set default intermission mode to red<%i>", server.player_displayname(cn), tonumber(arg)))
			end
		end
	end
end

function server.playercmd_map(cn, map, mode)
	if not hasaccess(cn, forcemap_access) then return end
	if not map then
		messages.error(cn, {cn}, "MAPROTATION", "#map <MAP> [<MODE>]")
		return
	end
	if not mode then
		mode = maprotation.game_mode
	end
	if not maprotation.is_valid_mode(mode) then
		messages.error(cn, {cn}, "MAPROTATION", string.format("Mode %s is not a valid mode on this server!", mode))
		return
	end
	if not maprotation.is_valid_map(map, mode) then
		messages.error(cn, {cn}, "MAPROTATION", string.format("Map %s is not a valid map in mode %s!", map, mode))
		return
	end
	if mode ~= maprotation.game_mode then
		maprotation.rotation = {}
		maprotation.calculate_rotation(mode)
	end
	messages.warning(cn, players.admins(), "MAPROTATION", string.format("%s changes map to %s (mode %s)!", server.player_displayname(cn), map, mode))
	maprotation.break_intermission()
	maprotation.change_map(map, mode)
end

function server.playercmd_nextmap(cn, map)
	if map then
		if map == "list" then
			if not hasaccess(cn, nextmap_list_modemaps_access) then return end
			if maprotation.maps == nil or #maprotation.maps[maprotation.game_mode] == 0 then
				messages.info(cn, {cn}, "MAPROTATION", string.format("No maps available for mode %s", maprotation.game_mode))
			else
				messages.info(cn, {cn}, "MAPROTATION", "List of maps: " .. table.concat(maprotation.maps[maprotation.game_mode], ", "))
			end
		elseif map == "nextmaps" then
			if not hasaccess(cn, nextmap_list_rotationmaps_access) then return end
			if maprotation.rotationModes == nil or #maprotation.rotationModes[maprotation.game_mode] == 0 then
				messages.info(cn, {cn}, "MAPROTATION", string.format("Currently no maps in rotation of mode %s", maprotation.game_mode))
			else
				messages.info(cn, {cn}, "MAPROTATION", "Next maps are: " .. table.concat(maprotation.rotationModes[maprotation.game_mode], ", "))
			end
		elseif map == "announce" then
			if not hasaccess(cn, nextmap_announce_nextmap_access) then return end
			messages.info(cn, server.clients(), "MAPROTATION", string.format("Next map is %s", maprotation.get_next_map()))
		elseif map == "skip" then
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			local m = maprotation.pull_map(maprotation.game_mode)
			messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> skipped next map %s!", server.player_displayname(cn), m))
		elseif map == "persist" then
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			if maprotation.persist_mode == 0 then
				maprotation.persist_mode = 1
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> persisted game mode on %s", server.player_displayname(cn), maprotation.game_mode))
			else
				maprotation.persist_mode = 0
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> disabled persisted game mode", server.player_displayname(cn)))
			end
		elseif map == "lock" then
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			if maprotation.persist_map == 0 then
				maprotation.persist_map = 1
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> locked map %s", server.player_displayname(cn), maprotation.map))
			else
				maprotation.persist_map = 0
				messages.info(cn, players.admins(), "MAPROTATION", string.format("blue<%s> unlocked map %s", server.player_displayname(cn), maprotation.map))
			end
		elseif map == maprotation.map then
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			messages.error(cn, {cn}, "MAPROTATION", "The choosen map have to be different from the current map!")
		else
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			if maprotation.is_valid_map(map, maprotation.game_mode) then
				maprotation.push_map(map)
				messages.info(cn, {cn}, "MAPROTATION", string.format("Next map is %s", maprotation.get_next_map()))
			else
				messages.error(cn, {cn}, "MAPROTATION", string.format("You cannot choose map white<%s> on mode white<%s> on this server. To get a list of available maps for mode white<%s> type: orange<#nm list>", map, maprotation.game_mode, maprotation.game_mode))
			end
		end
	else
		messages.info(cn, {cn}, "MAPROTATION", string.format("Next map is %s", maprotation.get_next_map()))
	end
end
server.playercmd_nm = server.playercmd_nextmap

function server.playercmd_restartmap(cn)
	if not hasaccess(cn, restart_map_access) then return end
	messages.warning(cn, players.admins(), "MAPROTATION", string.format("%s restarted map %s!", server.player_displayname(cn), maprotation.map))
	maprotation.restart_map()
end
server.playercmd_restart = server.playercmd_restartmap

function server.playercmd_mdb(cn, cmd, dbmap, dbmode)
	local player_id = server.player_sessionid(cn)
	local player = nl_players[player_id]
	if not hasaccess(cn, admin_access) then return end
	if not cmd then return false, "#mdb <CMD> [<map> <mode>]" end
	if player.nl_status == "serverowner" or player.nl_status == "masteradmin" then
		if cmd == "crc" then
			messages.info(cn, players.admins(), "MAPBASE", string.format("Added CRC for map %s. Reloading map.", server.map ))
			db.insert_or_update("nl_mapcrc", { map = server.map, crc = crypto.tigersum(tostring(server.player_mapcrc(cn))) }, string.format("map='%s'", db.escape(server.map)))
			modifiedmap.maps[server.map] = { crc = crypto.tigersum(tostring(server.player_mapcrc(cn))) }
			spectator.funspec(cn, "MODIFIEDMAP", modifiedmap.module_name)
			maprotation.restart_map()
		end
		if cmd == "reload" then
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
		end
		if cmd == "rm" then
			db.update("nl_maps", { valid = 0 } , string.format("mode='%s' AND map='%s' AND server='%s'", maprotation.game_mode, maprotation.map, server.nmgrpid) )
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Deactivated Map %s on mode %s in rotation database.", maprotation.map, maprotation.game_mode))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			server.changetime(3000)
		end
		if cmd == "rmall" then
			db.update("nl_maps", { valid = 0 } , string.format("map='%s' AND server='%s'", maprotation.map, server.nmgrpid) )
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Deactivated Map %s on all modes %s in rotation database.", maprotation.map, maprotation.game_mode))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			server.changetime(3000)
		end
		if cmd == "addduell" then
			if not dbmap then return false, "missing map" end
			maprotation.addmap(dbmap, "ffa")
			maprotation.addmap(dbmap, "instagib")
			maprotation.addmap(dbmap, "tactics")
			maprotation.addmap(dbmap, "efficiency")
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on duell modes was added to rotation-database.", dbmap))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
		end
		if cmd == "addteam" then
			if not dbmap then return false, "missing map" end
			maprotation.addmap(dbmap, "instagib team")
			maprotation.addmap(dbmap, "tactics team")
			maprotation.addmap(dbmap, "efficiency team")
			maprotation.addmap(dbmap, "teamplay")
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on team modes was added to rotation-database.", dbmap))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
		end
		if cmd == "addall" then
			if not dbmap then return false, "missing map" end
			maprotation.addmap(dbmap, "insta ctf")
			maprotation.addmap(dbmap, "efficiency ctf")
			maprotation.addmap(dbmap, "ctf")
			maprotation.addmap(dbmap, "insta hold")
			maprotation.addmap(dbmap, "efficiency hold")
			maprotation.addmap(dbmap, "hold")
			maprotation.addmap(dbmap, "insta protect")
			maprotation.addmap(dbmap, "efficiency protect")
			maprotation.addmap(dbmap, "protect")
			maprotation.addmap(dbmap, "ffa")
			maprotation.addmap(dbmap, "instagib")
			maprotation.addmap(dbmap, "efficiency")
			maprotation.addmap(dbmap, "tactics")
			maprotation.addmap(dbmap, "efficiency team")
			maprotation.addmap(dbmap, "instagib team")
			maprotation.addmap(dbmap, "tactics team")
			maprotation.addmap(dbmap, "teamplay")
			maprotation.addmap(dbmap, "capture")
			maprotation.addmap(dbmap, "regen capture")
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on all modes was added to rotation-database.", dbmap))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
		end
		if cmd == "add" then
			if not dbmap then return false, "missing map" end
			if not dbmode then dbmode = maprotation.game_mode end
			if not maprotation.is_valid_mode(dbmode) then
				messages.error(cn, {cn}, "MAPROTATION", string.format("Mode %s is not a valid mode on this server!", dbmode))
				return
			end
			db.insert("nl_maps", { map = dbmap, mode = dbmode, server = server.nmgrpid })
			messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on mode %s was added to rotation-database.", dbmap, dbmode))
			maprotation.loadmaps()
			maprotation.calculate_rotation()
			messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
		end
		if cmd == "fast" then
			maprotation.intermission_mode = 2
			messages.info(cn, players.admins(), "MAPROTATION", "Set intermission mode to orange<fast>")
		end
	else
		return
	end
end

--[[
		EVENTS
]]

server.event_handler("intermission", function()
	maprotation.intermission_running = 1
	if server.playercount > 0 then
		server.sleep(maprotation.intermission_predelay * 1000, function()
			maprotation.intermission[tonumber(maprotation.intermission_mode)]()
		end)
		maprotation.intermission_delay = maprotation.intermission_predelay
		maprotation.delay_intermission()
	end
end)

server.event_handler("mapchange", function(map, mode)
	maprotation.map = map
	maprotation.game_mode = mode
--[[
	if server.playercount > 2 then
		maprotation.checkinjection = 0
		if next(maprotation.checkinjection_cn) ~= nil then
			for k,v in pairs(maprotation.checkinjection_cn) do
				maprotation.checkinjection_cn[k] = nil
			end
		end
	end
]]
end)

server.event_handler("mapcrc", function(cn, map, crc)
--[[
	if maprotation.checkinjection_state == 0 then
		maprotation.checkinjection_state = 1
		server.sleep(maprotation.checkinjection_duration, function()
			maprotation.checkinjection_state = 2
			local firstcn
			if next(maprotation.checkinjection_cn) ~= nil and #maprotation.checkinjection_cn > 2 then
				table.sort(maprotation.checkinjection_cn)
				for k,v in ipairs(maprotation.checkinjection_cn) do
					if k == 1 then
						firstcn = maprotation.checkinjection_cn[k]
					else
						if maprotation.checkinjection_cn[k] == firstcn then
							-- Hacker detected
						end
					end
				end
			end
		end)
	end
	if maprotation.checkinjection_state == 1 then
		table.insert(maprotation.checkinjection_cn, cn)
	end
]]
	irc_say("MAPCRC: " .. server.player_name(cn) .. " (" .. cn .. "), " .. map .. ": " .. crc)
	server.log("MAPCRC: " .. server.player_name(cn) .. " (" .. cn .. "), " .. map .. ": " .. crc)
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep(maprotation.intermission_startdelay * 1000, function()
		maprotation.next_map(server.default_gamemode)
	end)
end)

server.event_handler("connect", function(cn)
	if server.playercount == 1 and (server.intermission == -1 or maprotation.intermission_running == 1) and maprotation.game_mode ~= "coop edit" and maprotation.game_mode ~= "coop" then
		server.sleep(100, function()
			messages.irc("MAPROTATION", "First player enters the server, restarting current map!")
		end)
		maprotation.restart_map()
	end
end)

server.event_handler("disconnect", function(cn)
	server.sleep(250, function()
		if server.playercount == 0 and maprotation.game_mode ~= "coop edit" and maprotation.game_mode ~= "coop" then
			server.sleep(100, function()
				messages.irc("MAPROTATION", "Last player leaves the server, starting next map in rotation!")
			end)
			maprotation.next_map(maprotation.game_mode)
		end
	end)
end)

server.event_handler("mapvote", function(cn, map, mode)
	if server.playercount > 2 then
		messages.debug(-1, players.admins(), "MAPROTATION", string.format("Denied map voting %s (%s) from %s", map, mode, server.player_displayname(cn)))
		return -1
	else
		if not maprotation.is_valid_mode(mode) then
			messages.error(-1, cn, "MAPROTATION", "Mode is not allowed on this server!")
		else
			if not maprotation.is_valid_map(map, mode) then
				messages.error(-1, cn, "MAPROTATION", string.format("%s, you can't choose %s on %s on this server!", server.player_name(cn), mode, map))
				return -1
			end
		end
	end
end)

server.event_handler("changingmap", function(map, mode)
	messages.debug(-1, players.all(),"MAPROTATION", "Event: changingmap")
end)

maprotation.loadmaps()
