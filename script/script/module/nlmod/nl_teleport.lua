--[[
	script/module/nl_mod/nl_teleport.lua
	Hanack (Andreas Schaeffer)
	Created: 24-Apr-2012
	Last Change: 24-Apr-2012
	License: GPL3

	Funktion:
		Erkennt Teleport-Hacker:
		
		1. wenn jemand zu einer nicht existierenden teleport destination teleportiert
		2. wenn jemand zu einer teledestination teleportiert, die gar nicht ziel des teleports war
		3. wenn jemand angibt, er springt zu einer bestimmten teledestination, seine position aber eine ganz andere ist
		4. wenn jemand eine ganz andere position hat (großer sprung), also teleportiert -- aber kein teleport signal schickt

	API-Methoden:
		teleport.clear_malus(cn)
			Malus Punkte des Spielers zuruecksetzen
		
	Commands:
		#teleport recording 1
			Aufnahme starten
		#teleport recording 0
			Aufnahme stoppen
		#teleport enabled 1
			Teleport Detection einschalten
		#teleport enabled 0
			Teleport Detection ausschalten
		#teleport delete
			Teleport Profil für die Map löschen
		#teleport distance <value>
			Toleranz für die Teleport Destination einstellen
			
]]



--[[
		API
]]

teleport = {}
teleport.enabled = 0
teleport.protected = 0 -- change this, if you want to do bad things like deleting the profiles
teleport.only_warnings = 1
teleport.distance = 100
teleport.beamdistance = 350
teleport.max_lastteleport = 100
teleport.max_lastjumppad = 200
teleport.max_lastspawn = 2000
teleport.max_lastmapchange = 20000
teleport.delay = 50
teleport.interval = 50
teleport.recording = 0
teleport.lastpos = {}
teleport.lastpos[0] = {}
teleport.lastpos[1] = {}
teleport.lastteleport = {}
teleport.lastjumppad = {}
teleport.lastspawn = {}
teleport.plenabled = {}
teleport.lastmapchange = 0
teleport.profile = {}
teleport.teledests = {}
teleport.teledests_pos = {}
teleport.telesource_pos = {}
teleport.profile_size = 0


-- setzt profil zurueck
function teleport.clear_profile()
	teleport.profile = {}
	teleport.teledests = {}
	teleport.profile_size = 0
end

-- laedt profil aus der datenbank
function teleport.load_profile()
	teleport.clear_profile()
	local maptptd = db.select("nl_teleports", { "tpn", "tpx", "tpy", "tpz", "tdn", "tdx", "tdy", "tdz" }, string.format("map='%s'", maprotation.map) )
	if #maptptd == 0 then
		messages.debug(-1, players.admins(), "TELEPORT", string.format("Could not load teleport profile for map %s", maprotation.map))
	else
		for i, entry in pairs(maptptd) do
			tpn = tonumber(entry.tpn)
			tpx = tonumber(entry.tpx)
			tpy = tonumber(entry.tpy)
			tpz = tonumber(entry.tpz)
			tdn = tonumber(entry.tdn)
			tdx = tonumber(entry.tdx)
			tdy = tonumber(entry.tdy)
			tdz = tonumber(entry.tdz)
			table.insert(teleport.profile, { tpn, tpx, tpy, tpz, tdn, tdx, tdy, tdz })
			teleport.teledests[tpn] = tdn
			teleport.teledests_pos[tdn] = {}
			teleport.teledests_pos[tdn][0] = tdx
			teleport.teledests_pos[tdn][1] = tdy
			teleport.teledests_pos[tdn][2] = tdz
			teleport.telesource_pos[tpn] = {}
			teleport.telesource_pos[tpn][0] = tpx
			teleport.telesource_pos[tpn][1] = tpy
			teleport.telesource_pos[tpn][2] = tpz
			teleport.profile_size = teleport.profile_size + 1
		end
		messages.debug(-1, players.admins(), "TELEPORT", string.format("Successfully loaded teleport profile for map %s with %i teleports", maprotation.map, teleport.profile_size))
	end
end

-- loescht ein profil
function teleport.delete_profile()
	if teleport.protected ~= 0 then return end
	teleport.clear_profile()
	db.delete("nl_teleports", string.format("map='%s'", maprotation.map))
end

function teleport.clear_lastteleports()
	for i,cn in pairs(players.all()) do
		teleport.lastteleport[cn] = server.gamemillis
		teleport.lastjumppad[cn] = server.gamemillis
		teleport.lastspawn[cn] = server.gamemillis
	end
end

function teleport.setlastpos(cn)
	local x, y, z = server.player_pos(cn)
	x = math.floor(tonumber(x))
	y = math.floor(tonumber(y))
	z = math.floor(tonumber(z))
	if teleport.lastpos[0][cn] == nil then
		teleport.lastpos[0][cn] = {}
		teleport.lastpos[0][cn][0] = x
		teleport.lastpos[0][cn][1] = y
		teleport.lastpos[0][cn][2] = z
	end
	if teleport.lastpos[1][cn] == nil then
		teleport.lastpos[1][cn] = {}
	end
	teleport.lastpos[1][cn][0] = teleport.lastpos[0][cn][0]
	teleport.lastpos[1][cn][1] = teleport.lastpos[0][cn][1]
	teleport.lastpos[1][cn][2] = teleport.lastpos[0][cn][2]
	teleport.lastpos[0][cn][0] = x
	teleport.lastpos[0][cn][1] = y
	teleport.lastpos[0][cn][2] = z
end

function teleport.record_pos(cn, tpn, tdn, tpx, tpy, tpz)
	local tdx, tdy, tdz = server.player_pos(cn)
	tpx = math.floor(tonumber(tpx))
	tpy = math.floor(tonumber(tpy))
	tpz = math.floor(tonumber(tpz))
	tdx = math.floor(tonumber(tdx))
	tdy = math.floor(tonumber(tdy))
	tdz = math.floor(tonumber(tdz))
	db.insert("nl_teleports", { map=maprotation.map, tpn=tpn, tpx=tpx, tpy=tpy, tpz=tpz, tdn=tdn, tdx=tdx, tdy=tdy, tdz=tdz })
	table.insert(teleport.profile, { tpn, tpx, tpy, tpz, tdn, tdx, tdy, tdz })
	teleport.teledests[tpn] = tdn
	teleport.teledests_pos[tdn] = {}
	teleport.teledests_pos[tdn][0] = tdx
	teleport.teledests_pos[tdn][1] = tdy
	teleport.teledests_pos[tdn][2] = tdz
	teleport.telesource_pos[tpn] = {}
	teleport.telesource_pos[tpn][0] = tpx
	teleport.telesource_pos[tpn][1] = tpy
	teleport.telesource_pos[tpn][2] = tpz
	teleport.profile_size = teleport.profile_size + 1
	messages.debug(-1, players.all(), "TELEPORT", string.format("%s added new teleport (from %i:: x: %i y: %i z: %i) (to %i:: x: %i y: %i z: %i)", server.player_name(cn), tpn, tpx, tpy, tpz, tdn, tdx, tdy, tdz))
end

function teleport.check_teledest(cn, tpn, tdn)
	if teleport.recording == 1 or teleport.enabled == 0 or maprotation.game_mode == "coop edit" then return end
	if teleport.teledests[tpn] == nil or teleport.teledests[tpn] ~= tdn then
		messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of teleporting to an invalid teleport destination", server.player_name(cn), cn))
		-- cheater.autokick(cn, "Server", "Teleport Hack")
		return
	end
	if teleport.teledests_pos[tdn] == nil then
		messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of unknown teleport destination", server.player_name(cn), cn))
		-- cheater.autokick(cn, "Server", "Teleport Hack")
		return
	end
	local tdx, tdy, tdz = server.player_pos(cn)
	tdx = math.floor(tonumber(tdx))
	tdy = math.floor(tonumber(tdy))
	tdz = math.floor(tonumber(tdz))
	if
		tdx < teleport.teledests_pos[tdn][0] - teleport.distance or tdx > teleport.teledests_pos[tdn][0] + teleport.distance or
		tdy < teleport.teledests_pos[tdn][1] - teleport.distance or tdy > teleport.teledests_pos[tdn][1] + teleport.distance or
		tdz < teleport.teledests_pos[tdn][2] - teleport.distance or tdz > teleport.teledests_pos[tdn][2] + teleport.distance
	then
		messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of player position is not near the teleport destination!", server.player_name(cn), cn))
		-- cheater.autokick(cn, "Server", "Teleport Hack")
		return
	end
end

function teleport.check_telesource(cn, tpn, x, y, z)
	if teleport.recording == 1 or teleport.enabled == 0 or maprotation.game_mode == "coop edit" then return end
	x = math.floor(tonumber(x))
	y = math.floor(tonumber(y))
	z = math.floor(tonumber(z))
	if teleport.telesource_pos[tpn] == nil then
		messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of teleporting from an invalid teleport source", server.player_name(cn), cn))
		-- cheater.autokick(cn, "Server", "Teleport Hack")
		return false
	end
	if
		x < teleport.telesource_pos[tpn][0] - teleport.distance or x > teleport.telesource_pos[tpn][0] + teleport.distance or
		y < teleport.telesource_pos[tpn][1] - teleport.distance or y > teleport.telesource_pos[tpn][1] + teleport.distance or
		z < teleport.telesource_pos[tpn][2] - teleport.distance or z > teleport.telesource_pos[tpn][2] + teleport.distance
	then
		messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of player source position is not near the teleport source!", server.player_name(cn), cn))
		-- cheater.autokick(cn, "Server", "Teleport Hack")
		return false
	end
	return true
end

function teleport.check()
	if server.paused == 1 or server.timeleft <= 0 or maprotation.game_mode == "coop edit" then return end
	server.sleep(teleport.delay, function()
		for i,cn in ipairs(players.all()) do
		 	if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				teleport.setlastpos(cn)
			end		
		end
		if teleport.recording == 1 or teleport.enabled == 0 then return end
		for i,cn in ipairs(players.all()) do
		 	if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				if teleport.lastteleport[cn] == nil then
					teleport.lastteleport[cn] = server.gamemillis
				end
				if
					server.gamemillis > teleport.lastteleport[cn] + teleport.max_lastteleport and
					server.gamemillis > teleport.lastjumppad[cn] + teleport.max_lastjumppad and
					server.gamemillis > teleport.lastspawn[cn] + teleport.max_lastspawn and
					server.gamemillis > teleport.lastmapchange + teleport.max_lastmapchange and
					teleport.lastpos[0][cn][0] > -1000000 and teleport.lastpos[0][cn][0] < 1000000 and
					teleport.lastpos[0][cn][1] > -1000000 and teleport.lastpos[0][cn][1] < 1000000 and
					teleport.lastpos[0][cn][2] > -1000000 and teleport.lastpos[0][cn][2] < 1000000 and
					teleport.lastpos[1][cn][0] > -1000000 and teleport.lastpos[1][cn][0] < 1000000 and
					teleport.lastpos[1][cn][1] > -1000000 and teleport.lastpos[1][cn][1] < 1000000 and
					teleport.lastpos[1][cn][2] > -1000000 and teleport.lastpos[1][cn][2] < 1000000 and
					teleport.plenabled[cn] == 1 and (
						teleport.lastpos[0][cn][0] > teleport.lastpos[1][cn][0] + teleport.beamdistance or 
						teleport.lastpos[0][cn][0] < teleport.lastpos[1][cn][0] - teleport.beamdistance or 
						teleport.lastpos[0][cn][1] > teleport.lastpos[1][cn][1] + teleport.beamdistance or 
						teleport.lastpos[0][cn][1] < teleport.lastpos[1][cn][1] - teleport.beamdistance or 
						teleport.lastpos[0][cn][2] > teleport.lastpos[1][cn][2] + teleport.beamdistance or 
						teleport.lastpos[0][cn][2] < teleport.lastpos[1][cn][2] - teleport.beamdistance
					)
				then
					messages.error(-1, players.admins(), "CHEATER", string.format("0:: x:%i y:%i z:%i --- 1:: x:%i y:%i z:%i", teleport.lastpos[0][cn][0], teleport.lastpos[0][cn][1], teleport.lastpos[0][cn][2], teleport.lastpos[1][cn][0], teleport.lastpos[1][cn][1], teleport.lastpos[1][cn][2]))
					messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of player teleported without teleport signal!", server.player_name(cn), cn))
					-- cheater.autokick(cn, "Server", "Teleport Hack")
				end
			end
		end
	end)
end



--[[
		COMMANDS
]]

function server.playercmd_teleport(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#teleport <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.recording=" .. teleport.recording)
				messages.info(cn, {cn}, "TELEPORT", "teleport.enabled=" .. teleport.enabled)
				messages.info(cn, {cn}, "TELEPORT", "teleport.only_warnings=" .. teleport.only_warnings)
				messages.info(cn, {cn}, "TELEPORT", "teleport.protected=" .. teleport.protected)
				messages.info(cn, {cn}, "TELEPORT", "teleport.distance=" .. teleport.distance)
				messages.info(cn, {cn}, "TELEPORT", "teleport.beamdistance=" .. teleport.beamdistance)
				messages.info(cn, {cn}, "TELEPORT", "teleport.interval=" .. teleport.interval)
				messages.info(cn, {cn}, "TELEPORT", "teleport.delay=" .. teleport.delay)
				messages.info(cn, {cn}, "TELEPORT", "profile size=" .. teleport.profile_size)
			end
			if command == "delete" then
				teleport.delete_profile()
				messages.info(cn, players.admins(), "TELEPORT", "Deleted teleport profile")
			end
			if command == "reload" then
				maphack.load_profile()
			end
			if command == "recording" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.recording=" .. teleport.recording)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.enabled=" .. teleport.enabled)
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.only_warnings=" .. teleport.only_warnings)
			end
			if command == "protected" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.protected=" .. teleport.protected)
			end
			if command == "distance" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.distance=" .. teleport.distance)
			end
			if command == "beamdistance" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.beamdistance=" .. teleport.beamdistance)
			end
			if command == "interval" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.interval=" .. teleport.interval)
			end
			if command == "delay" then
				messages.info(cn, {cn}, "TELEPORT", "teleport.delay=" .. teleport.delay)
			end
			if command == "list" then
				if #teleport.profile == 0 then
					messages.info(cn, {cn}, "TELEPORT", "No teleports recorded for this map!")
				end
				for i,p in ipairs(teleport.profile) do
					messages.info(-1, {cn}, "TELEPORT", string.format("Teleport %i:: x: %i y: %i z: %i --- Teledest %i:: x: %i y: %i z: %i)", p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]))
				end
			end
		else
			if command == "recording" then
				local recording_val = tonumber(arg)
				if teleport.recording ~= recording_val then
					if teleport.recording == 0 then
						cheater.start_recording("teleport")
						messages.info(cn, players.all(), "TELEPORT", string.format("orange<Starting profiling %s for teleport detection...>", maprotation.map))
					end
					if teleport.recording == 1 then
						messages.info(cn, players.all(), "TELEPORT", string.format("orange<Stopped profiling %s for teleport detection...>", maprotation.map))
						cheater.stop_recording("teleport")
					end
				else
					messages.info(cn, {cn}, "TELEPORT", "teleport.recording = " .. recording_val)
				end
				teleport.recording = recording_val
			end
			if command == "enabled" then
				teleport.enabled = tonumber(arg)
				messages.info(cn, {cn}, "TELEPORT", "teleport.enabled=" .. teleport.enabled)
			end
			if command == "only_warnings" then
				teleport.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "TELEPORT", "teleport.only_warnings=" .. teleport.only_warnings)
			end
			if command == "distance" then
				teleport.distance = tonumber(arg)
				messages.info(cn, {cn}, "TELEPORT", "teleport.distance=" .. teleport.distance)
			end
			if command == "beamdistance" then
				teleport.beamdistance = tonumber(arg)
				messages.info(cn, {cn}, "TELEPORT", "teleport.beamdistance=" .. teleport.beamdistance)
			end
			if command == "delay" then
				teleport.delay = tonumber(arg)
				messages.info(cn, {cn}, "TELEPORT", "teleport.delay=" .. teleport.delay)
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	teleport.plenabled[cn] = 0
	teleport.lastteleport[cn] = server.gamemillis
	teleport.lastjumppad[cn] = server.gamemillis
	teleport.lastspawn[cn] = server.gamemillis
	local x, y, z = server.player_pos(cn)
	x = math.floor(tonumber(x))
	y = math.floor(tonumber(y))
	z = math.floor(tonumber(z))
	if teleport.lastpos[0][cn] == nil then teleport.lastpos[0][cn] = {} end 
	if teleport.lastpos[1][cn] == nil then teleport.lastpos[1][cn] = {} end
	teleport.lastpos[0][cn][0] = x
	teleport.lastpos[0][cn][1] = y
	teleport.lastpos[0][cn][2] = z
	teleport.lastpos[1][cn][0] = x
	teleport.lastpos[1][cn][1] = y
	teleport.lastpos[1][cn][2] = z
	teleport.plenabled[cn] = 1
end)

server.event_handler("disconnect", function(cn)
	teleport.lastteleport[cn] = server.gamemillis
	teleport.lastjumppad[cn] = server.gamemillis
	teleport.lastspawn[cn] = server.gamemillis
	teleport.plenabled[cn] = 0
end)

server.event_handler("mapchange", function()
	teleport.clear_lastteleports()
	teleport.load_profile()
	teleport.recording = 0
	cheater.stop_recording("teleport")
	teleport.lastmapchange = server.gamemillis
end)

server.event_handler("spawn", function(cn)
	teleport.lastspawn[cn] = server.gamemillis
end)

server.event_handler("teleport", function(cn, tpn, tdn, x, y, z)
	if mapportal ~= nil and mapportal.portals ~= nil and mapportal.portals[tdn] ~= nil then return end
	teleport.lastteleport[cn] = server.gamemillis
	if teleport.recording == 1 then
		server.sleep(teleport.delay, function()
			teleport.record_pos(cn, tpn, tdn, x, y, z)
		end)
	else
		if teleport.check_telesource(cn, tpn, x, y, z) then
			server.sleep(teleport.delay, function()
				teleport.check_teledest(cn, tpn, tdn)
			end)
		end
	end
end)

server.event_handler("jumppad", function(cn, jumppad, x, y, z)
	teleport.lastjumppad[cn] = server.gamemillis
end)

server.interval(teleport.interval, teleport.check)
