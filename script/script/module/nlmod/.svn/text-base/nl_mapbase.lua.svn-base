--[[
	script/module/nl_mod/nl_mapbase.lua
	Hankus (Derk Haendel)
	Created: 06.02.2011
	License: GPL3

	Funktionen:
		Erweitert die Maprotation mit einer Datenbankfunktionalität

	API-Methoden:
		mapbase.fetch_maps
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
		#mdb rm
			entfernt die aktuell gespielte Map aus der Rotation
		#mdb add mode map
			Hinzufügen einer Map zur Rotation

	Konfigurations-Variablen:
		maprotation.maps
			Pro gamemode ist eine Liste von Maps verfuegbar
			Dies überschreibt die Variablen aus nl_maprotation.lua
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

require "table"
require "math"


--[[
		API
]]

mapbase = {}

function mapbase.fetch_maps(mode)
	if next(maprotation.maps[mode]) ~= nil then
		for k,v in pairs(maprotation.maps[mode]) do
			maprotation.maps[mode][k] = nil
		end
	end
	local maps = db.select( "nl_maps", { "map" }, string.format("mode='%s' AND server='%s' AND valid=1", mode, server.srvgroupid) )
	for i,map in pairs(maps) do
		table.insert(maprotation.maps[mode], map.map)
	end
end

function mapbase.load()
	if server.srvgroupid == "ml" then
		irc_say("Maprotation database started")
		mapbase.fetch_maps("insta ctf")
		mapbase.fetch_maps("efficiency ctf")
		mapbase.fetch_maps("ctf")
		mapbase.fetch_maps("insta hold")
		mapbase.fetch_maps("efficiency hold")
		mapbase.fetch_maps("hold")
		mapbase.fetch_maps("insta protect")
		mapbase.fetch_maps("efficiency protect")
		mapbase.fetch_maps("protect")
		mapbase.fetch_maps("ffa")
		mapbase.fetch_maps("instagib")
		mapbase.fetch_maps("efficiency")
		mapbase.fetch_maps("tactics")
		mapbase.fetch_maps("efficiency team")
		mapbase.fetch_maps("instagib team")
		mapbase.fetch_maps("tactics team")
		mapbase.fetch_maps("teamplay")
		mapbase.fetch_maps("capture reduced")
		mapbase.fetch_maps("regen capture")
		--mapbase.fetch_maps("coop edit")
	end
end

mapbase.load()

--[[
		COMMANDS
]]

function server.playercmd_mdb(cn, cmd, dbmap, dbmode)
	if not hasaccess(cn, admin_access) then return end
	if not cmd then return false, "#mdb <CMD> [<map> <mode>]" end
	if cmd == "crc" then
		messages.info(cn, players.admins(), "MAPBASE", string.format("Added CRC for map %s. Reloading map.", server.map ))
		db.insert_or_update("nl_mapcrc", { map = server.map, crc = crypto.tigersum(tostring(server.player_mapcrc(cn))) }, string.format("map=%s", db.escape(server.map)))
		modifiedmap.maps[server.map] = { crc = crypto.tigersum(tostring(server.player_mapcrc(cn))) }
		spectator.funspec(cn, "MODIFIEDMAP", modifiedmap.module_name)
		maprotation.restart_map()
--[[
		for i,v in pairs(modifiedmap.maps) do
			db.insert("nl_mapcrc", { map = i, crc = v.crc })
		end
]]
	end
	if cmd == "reload" then
		mapbase.load()
		maprotation.calculate_rotation()
		messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
	end
	if cmd == "rm" then
		db.update("nl_maps", { valid = 0 } , string.format("mode='%s' AND map='%s' AND server='%s'", maprotation.game_mode, maprotation.map, server.srvgroupid) )
		messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on mode %s was removed from rotation-database.", maprotation.map, maprotation.game_mode))
		server.changetime(3000)
	end
	if cmd == "addduell" then
		if not dbmap then return false, "missing map" end
		db.insert("nl_maps", { map = dbmap, mode = "ffa", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "instagib", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "tactics", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency", server = server.srvgroupid })
		messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on duell modes was added to rotation-database.", dbmap))
		mapbase.load()
		maprotation.calculate_rotation()
		messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
	end
	if cmd == "addteam" then
		if not dbmap then return false, "missing map" end
		db.insert("nl_maps", { map = dbmap, mode = "instagib team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "tactics team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "teamplay", server = server.srvgroupid })
		messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on team modes was added to rotation-database.", dbmap))
		mapbase.load()
		maprotation.calculate_rotation()
		messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
	end
	if cmd == "addall" then
		if not dbmap then return false, "missing map" end
		db.insert("nl_maps", { map = dbmap, mode = "insta ctf", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency ctf", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "ctf", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "insta hold", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency hold", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "hold", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "insta protect", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency protect", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "protect", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "ffa", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "instagib", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "tactics", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "efficiency team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "instagib team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "tactics team", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "teamplay", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "capture reduced", server = server.srvgroupid })
		db.insert("nl_maps", { map = dbmap, mode = "regen capture", server = server.srvgroupid })
		messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on all modes was added to rotation-database.", dbmap))
		mapbase.load()
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
		db.insert("nl_maps", { map = dbmap, mode = dbmode, server = server.srvgroupid })
		messages.info(cn, players.admins(), "MAPROTATION", string.format("Map %s on mode %s was added to rotation-database.", dbmap, dbmode))
		mapbase.load()
		maprotation.calculate_rotation()
		messages.info(cn, players.admins(), "MAPROTATION", "Reloaded rotation-database.")
	end
	if cmd == "fast" then
		maprotation.intermission_mode = 2
		messages.info(cn, players.admins(), "MAPROTATION", "Set intermission mode to orange<fast>")
	end
end

--[[
		EVENTS
]]


