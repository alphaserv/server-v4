--[[
	script/module/nl_mod/nl_maprotation.lua
	Hanack (Andreas Schaeffer)
	Created: 17-Okt-2010
	Last Modified: 23-Okt-2010
	License: GPL3

	Funktionen:
		Kontrolliert die Intermission und verzögert sie, bis feststeht, welche Map geladen
		werden soll. Führt das Wechseln der Map durch. Erstellt eine Rotationsliste von
		den nächsten Maps, basierend auf einem Bewertungsverfahren. Bietet eine Schnitt-
		stelle, um in die Rotation einzugreifen (z.b. Mapbattles oder Veto-Phasen).
	

	API-Methoden:
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
		#stopintermission
			Beendet die Intermission unverzüglich und wechselt zur nächsten Map
			in der Rotation 
		#intermissionmode <intermission_mode>
			Wechselt den Intermissionmode (1 = Normal, 2 = Schnell, weitere möglich)
		#nextmap <map>
			Setzt die nächste Map (fügt sie ganz vorn ein)
		#ignorenextmap
			Die nächste Map in der Rotation wird entfernt

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
maprotation.intermission = {}
maprotation.intermission_startdelay = 7
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
maprotation.rotation = {}
maprotation.maps = {}
maprotation.maps["insta ctf reduced"] = { "l_ctf", "caribbean", "frostbyte", "reissen" }
maprotation.maps["insta ctf"] = { "suburb", "caribbean", "l_ctf", "frostbyte", "reissen", "tejen", "dust2", "akroseum", "shipwreck", "flagstone", "urban_c", "bt_falls", "valhalla", "mbt1", "berlin_wall", "authentic", "tempest", "mercury", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "wdcd", "desecration", "sacrifice", "recovery", "infamy", "tortuga", "abbey", "xenon", "hallo", "capture_night", "face-capture", "mach2", "europium", "core_transfer", "killcore3", "konkuri-to", "fc5", "alloy", "duomo" }
maprotation.maps["instagib reduced"] = { "reissen" }
maprotation.maps["instagib"] = { "reissen", "complex" }
maprotation.maps["regen capture"] = { "akroseum" }

function maprotation.change_map(map, mode)
	-- insert into database
	db.insert('nl_maprotation', {map=map, mode=mode})
	maprotation.signal(map, mode)
	-- change map
	server.sleep(maprotation.intermission_postdelay * 1000, function()
		irc_say(string.format("\0039INTERMISSION\003  Choose map %s on mode %s", map, mode))
		maprotation.game_mode = mode
		maprotation.map = map
		maprotation.intermission_running = 0
		server.changemap(map, mode)
	end)
end

function maprotation.next_map(mode)
	local map = maprotation.pull_map(mode)
	maprotation.change_map(map, mode)
	if #maprotation.rotation == 0 then
		maprotation.calculate_rotation(maprotation.game_mode)
	end
end

function maprotation.restart_map()
	maprotation.signal(maprotation.map, maprotation.game_mode)
	server.sleep(500, function()
		server.changemap(maprotation.map, maprotation.game_mode)
	end)
end

function maprotation.get_next_map()
	if #maprotation.rotation > 0 then
		return maprotation.rotation[1]
	else
		maprotation.calculate_rotation(maprotation.game_mode)
		return maprotation.rotation[1]
	end
end

function maprotation.push_map(map)
	table.insert(maprotation.rotation, 1, map)
end

function maprotation.pull_map(mode)
	if #maprotation.rotation > 0 then
		return table.remove(maprotation.rotation, 1)
	else
		maprotation.calculate_rotation(mode)
		return table.remove(maprotation.rotation, 1)
	end
end

function maprotation.calculate_rotation(mode)
	-- init
	local maps = {}
	for i, mapName in pairs(maprotation.maps[mode]) do
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
			table.insert(maprotation.rotation, map['name'])
		end
		if count < 10 then
			table.insert(maprotation.rotation, map['name'])
		end
		table.insert(maprotation.rotation, map['name'])
	end
	-- shuffle
	maprotation.shuffle(maprotation.rotation)
end

function maprotation.shuffle(t)
	local n = #t
	while n > 1 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
--	for i = 1, n - 1, 1 do
--		if t[i] == t[i+1] then
--		
--	end
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
	if not maprotation.is_valid_mode(mode) then return false end
	for _, map in pairs(maprotation.maps[mode]) do
		if reqmap == map then return true end
	end
	return false
end

maprotation.intermission[maprotation.intermission_modes.NORMAL] = function()
	--[[
		intermission mode 1: normal
		Es werden 10 Sekunden gewartet, dann wird einfach die naechste map in der rotation genommen
	]]
	server.sleep(10000, function()
		maprotation.next_map(maprotation.game_mode)
	end)
end

maprotation.intermission[maprotation.intermission_modes.FAST] = function()
	--[[
		intermission mode 2: fast
		Es wird sofort zur naechsten map gewechselt
	]]
	maprotation.next_map(maprotation.game_mode)
end

maprotation.intermission[maprotation.intermission_modes.TIMEOUT] = function()
	--[[
		intermission mode 99: wait for timeout
		Nur zu Testzwecken! Es wird gewartet, bis der Timeout der Maprotation
		abgelaufen ist, d.h. es wird rein gar nichts gemacht.
	]]
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
				maprotation.next_map(maprotation.game_mode)
				messages.info(cn, players.all(), "MAPROTATION", "Stopped intermission after " .. maprotation.intermission_delay .. " seconds. Indeed, it took really long. To avoid intermission overstays the server is choosing the next regular map immediately")
				irc_say(string.format("\0039INTERMISSION\003  Intermission took %i seconds (total %i players)", maprotation.intermission_delay, server.playercount))
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
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_mode" .. maprotation.intermission_mode)
			end
			if command == "info" then
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_mode=" .. maprotation.intermission_mode)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_running=" .. maprotation.intermission_running)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_delay=" .. maprotation.intermission_delay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_maxdelay=" .. maprotation.intermission_maxdelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_maxgamemillis=" .. maprotation.intermission_maxgamemillis)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_predelay=" .. maprotation.intermission_predelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.intermission_postdelay=" .. maprotation.intermission_postdelay)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.allowed_modes=" .. table.concat(maprotation.allowed_modes, ", "))
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.map=" .. maprotation.map)
				messages.info(cn, {cn}, "MAPROTATION", "maprotation.game_mode=" .. maprotation.game_mode)
				messages.info(cn, {cn}, "MAPROTATION", "server.intermission=" .. server.intermission)
				messages.info(cn, {cn}, "MAPROTATION", "server.intermission=" .. server.intermission)
				messages.info(cn, {cn}, "MAPROTATION", "server.gamemillis=" .. server.gamemillis)
			end
		else
			if command == "mode" then
				maprotation.intermission_mode = intermission_mode
				messages.info(cn, players.admins(), "MAPROTATION", "Set intermission mode to " .. arg)
			end
		end
	end
end

function server.playercmd_stopintermission(cn)
	if not hasaccess(cn, stopintermission_access) then return end
	messages.warning(cn, players.admins(), "MAPROTATION", server.player_displayname(cn) .. " stopped intermission!")
	maprotation.next_map(maprotation.game_mode)
end

function server.playercmd_ignorenextmap(cn)
	if not hasaccess(cn, stopintermission_access) then return end
	local m = maprotation.pull_map(maprotation.game_mode)
	messages.info(cn, players.admins(), "MAPROTATION", server.player_displayname(cn) .. " ignored next map " .. m .. "!")
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
	messages.warning(cn, players.admins(), "MAPROTATION", string.format("%s changes map to %s!", server.player_displayname(cn), map))
	maprotation.change_map(map, mode)
end

function server.playercmd_nextmap(cn, map)
	if map then
		if map == "list" then
			if not hasaccess(cn, nextmap_list_modemaps_access) then return end
			messages.info(cn, {cn}, "MAPROTATION", "List of maps: " .. table.concat(maprotation.maps[maprotation.game_mode], ", "))
		elseif map == "nextmaps" then
			if not hasaccess(cn, nextmap_list_rotationmaps_access) then return end
			messages.info(cn, {cn}, "MAPROTATION", "Next maps are: " .. table.concat(maprotation.rotation, ", "))
		elseif map == "announce" then
			if not hasaccess(cn, nextmap_announce_nextmap_access) then return end
			messages.info(cn, server.clients(), "MAPROTATION", "Next map is " .. maprotation.get_next_map())
		elseif map == maprotation.map then
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			messages.error(cn, {cn}, "MAPROTATION", "The choosen map have to be different from the current map!")
		else
			if not hasaccess(cn, nextmap_set_nextmap_access) then return end
			if maprotation.is_valid_map(map, maprotation.game_mode) then
				maprotation.push_map(map)
				messages.info(cn, {cn}, "MAPROTATION", "Next map is " .. maprotation.get_next_map())
			else
				messages.error(cn, {cn}, "MAPROTATION", "You cannot choose map " .. map .. " on this server! It have to be a " .. maprotation.game_mode .. " map. Registered users can list available maps: #nm list")
			end
		end
	else
		messages.info(cn, {cn}, "MAPROTATION", "Next map is " .. maprotation.get_next_map())
	end
end
server.playercmd_nm = server.playercmd_nextmap

function server.playercmd_restartmap(cn)
	if not hasaccess(cn, restart_map_access) then return end
	messages.warning(cn, players.admins(), "MAPROTATION", string.format("%s restarted map %s!", server.player_displayname(cn), maprotation.map))
	maprotation.restart_map()
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
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep(maprotation.intermission_startdelay * 1000, function()
		maprotation.next_map(server.default_gamemode)
	end)
end)

server.event_handler("connect", function(cn)
	if server.playercount == 1 and (server.intermission == -1 or maprotation.intermission_running == 1) then
		messages.irc("MAPROTATION", "First player enters the server, restarting current map!")
		maprotation.restart_map()
	end
end)

server.event_handler("disconnect", function(cn)
	server.sleep(250, function()
		if server.playercount == 0 then
			messages.irc("MAPROTATION", "Last player leaves the server, starting next map in rotation!")
			maprotation.next_map(maprotation.game_mode)
		end
	end)
end)

server.event_handler("mapvote", function(cn, map, mode)
	if server.playercount > 2 then
		messages.debug(-1, players.admins(), "MAPROTATION", "Denied map voting "..map.." ("..mode..") from "..server.player_displayname(cn))
		return -1
	else
		if not maprotation.is_valid_map(map, mode) then
			messages.error(-1, cn, "MAPROTATION", "Map or mode is not allowed.")
			return -1
		end
	end
end)

server.event_handler("changingmap", function(map, mode)
	messages.debug(-1, players.all(),"MAPROTATION", "Event: changingmap")
end)

