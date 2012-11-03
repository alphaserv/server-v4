--[[
	script/module/nl_mod/nl_speedhack.lua
	Hanack (Andreas Schaeffer)
	Created: 30-Sep-2010
	Last Modified: 03-Nov-2010
	License: GPL3

	Funktionsweise :
		Erkennen von Speedhackern durch Geschwindigkeitsmessung. Es werden Positionsdifferenzen
		ermittelt. Teleporter und Jumppads werden durch das Ignorieren von Ausreissern berueck-
		sichtigt. Pro Map wird ein eigenes Profil ermittelt. Dadurch koennen die Grenzen pro
		Map so eng wie moeglich gesetzt werden. Administratoren bekommen eine Warnung, sobald
		moeglicherweise ein Speedhacker spielt. Ab einem bestimmten Grenzwert wird der Speed-
		hacker gebanned. Die Profildaten pro Map werden in einer Datenbank abgelegt.
		

]]



--[[
		API
]]

speedhack = {}

-- constants
speedhack.check_interval = 250
speedhack.reduce_interval = 1500

-- vars changeable during game
speedhack.recording = 0
speedhack.debug = 0
speedhack.remember_positions = 15
speedhack.diff_between_positions = 2
speedhack.ignore_first_values = 4
speedhack.tolerance = 1.05 -- Spieler darf 5% schneller sein, als die im Profil festgelegte Maximum-Geschwindigkeit
speedhack.warnmalus = 10
speedhack.maxmalus = 20

-- player memory
speedhack.player = {}

-- map memory
speedhack.map = {}



function speedhack.reset(cn)
	speedhack.player[cn] = {}
	speedhack.player[cn].malus = 0
	speedhack.player[cn].level = 0
	speedhack.player[cn].pos_x = {}
	speedhack.player[cn].pos_y = {}
	speedhack.player[cn].pos_z = {}
end

function speedhack.save_map_profile()
	db.insert_or_update("nl_speedhack", { map=maprotation.map, max_min_x=speedhack.map[maprotation.map].max_min_x, max_min_y=speedhack.map[maprotation.map].max_min_y, max_min_z=speedhack.map[maprotation.map].max_min_z, max_max_x=speedhack.map[maprotation.map].max_max_x, max_max_y=speedhack.map[maprotation.map].max_max_y, max_max_z=speedhack.map[maprotation.map].max_max_z }, string.format("map='%s'", maprotation.map) )
	messages.debug(cn, players.admins(), "CHEATER", "Saved speedhack profile")
end

function speedhack.load_map_profile()
	if maprotation.map == nil then return false end
	local result = db.select("nl_speedhack", { "max_min_x", "max_min_y", "max_min_z", "max_max_x", "max_max_y", "max_max_z" }, string.format("map='%s'", maprotation.map) )
	if #result == 0 then
		return false
	else
		speedhack.map[maprotation.map] = result[1]
		speedhack.map[maprotation.map].max_min_x = tonumber(speedhack.map[maprotation.map].max_min_x)
		speedhack.map[maprotation.map].max_min_y = tonumber(speedhack.map[maprotation.map].max_min_y)
		speedhack.map[maprotation.map].max_min_z = tonumber(speedhack.map[maprotation.map].max_min_z)
		speedhack.map[maprotation.map].max_max_x = tonumber(speedhack.map[maprotation.map].max_max_x)
		speedhack.map[maprotation.map].max_max_y = tonumber(speedhack.map[maprotation.map].max_max_y)
		speedhack.map[maprotation.map].max_max_z = tonumber(speedhack.map[maprotation.map].max_max_z)

		return true
	end
end

function speedhack.resetmap()
	if speedhack.load_map_profile() == false then
		if maprotation.map == nil then
			server.sleep(5000, speedhack.resetmap)
			return
		else
			messages.error(cn, players.admins(), "CHEATER", "Starting profiling map for speedhack detection...")
			speedhack.map[maprotation.map] = {}
			speedhack.map[maprotation.map].max_min_x = 0
			speedhack.map[maprotation.map].max_min_y = 0
			speedhack.map[maprotation.map].max_min_z = 0
			speedhack.map[maprotation.map].max_max_x = 0
			speedhack.map[maprotation.map].max_max_y = 0
			speedhack.map[maprotation.map].max_max_z = 0
			speedhack.recording = 1
		end
	else
		speedhack.recording = 0
		messages.debug(cn, players.admins(), "CHEATER", "Sucessfully loaded speedhack profile for map " .. maprotation.map)
	end
end

function speedhack.check()
	for _, cn in pairs(players.active()) do
		if speedhack.player[cn] == nil then speedhack.reset(cn) end
		local x, y, z = server.player_pos(cn)
		table.insert(speedhack.player[cn].pos_x, x)
		table.insert(speedhack.player[cn].pos_y, y)
		table.insert(speedhack.player[cn].pos_z, z)
		local num_x = #speedhack.player[cn].pos_x
		local num_y = #speedhack.player[cn].pos_y
		local num_z = #speedhack.player[cn].pos_z
		local poscount = math.min(num_x, num_y,num_z)
		if poscount == speedhack.remember_positions then
			-- check erst mit der 15. Position durchfuehren
			if speedhack.map[maprotation.map] == nil then speedhack.resetmap() end
			local diffs2_x = {}
			local diffs2_y = {}
			local diffs2_z = {}
			for i = 1, speedhack.remember_positions-speedhack.diff_between_positions, 1 do
				table.insert(diffs2_x, math.abs(speedhack.player[cn].pos_x[i] - speedhack.player[cn].pos_x[i+speedhack.diff_between_positions]))
				table.insert(diffs2_y, math.abs(speedhack.player[cn].pos_y[i] - speedhack.player[cn].pos_y[i+speedhack.diff_between_positions]))
				table.insert(diffs2_z, math.abs(speedhack.player[cn].pos_z[i] - speedhack.player[cn].pos_z[i+speedhack.diff_between_positions]))
			end
			
			-- Diffs sortieren
			table.sort(diffs2_x)
			table.sort(diffs2_y)
			table.sort(diffs2_z)

			-- Die vier hoechsten Werte rausfiltern:
			--  Teleporter und Respawn brauchen eine oder max zwei hohe Positionsänderungen
			--  Jumppads brauchen meist weniger als 5, manchmal aber mehr
			--  Daher werden Punkte angesammelt
			for i = 1, speedhack.ignore_first_values, 1 do
				table.remove(diffs2_x)
				table.remove(diffs2_y)
				table.remove(diffs2_z)
			end

			if speedhack.debug == 1 then -- and #diffs2_x >= (speedhack.remember_positions - 2) then
				messages.debug(cn, players.admins(), "CHEATER", string.format("%s (%i) [m] %i [x] h:%i/%i l:%i/%i  [y] h:%i/%i l:%i/%i  [z] h:%i/%i l:%i/%i", server.player_displayname(cn), cn, speedhack.player[cn].malus, diffs2_x[#diffs2_x], speedhack.map[maprotation.map].max_max_x, diffs2_x[1], speedhack.map[maprotation.map].max_min_x, diffs2_y[#diffs2_x], speedhack.map[maprotation.map].max_max_y, diffs2_y[1], speedhack.map[maprotation.map].max_min_y, diffs2_z[#diffs2_x], speedhack.map[maprotation.map].max_max_z, diffs2_z[1], speedhack.map[maprotation.map].max_min_z))
			elseif speedhack.player[cn].malus > 0 then
				messages.debug(-1, players.admins(), "CHEATER", string.format("Speedhacking: %s (%i) has %i malus points", server.player_displayname(cn), cn, speedhack.player[cn].malus))
			end

			if speedhack.recording == 1 then
				-- wir merken uns die hoechsten max-min und max-max Werte
				if diffs2_x[#diffs2_x] > speedhack.map[maprotation.map].max_max_x then
					speedhack.map[maprotation.map].max_max_x = diffs2_x[#diffs2_x]
					speedhack.save_map_profile()
				end
				if diffs2_y[#diffs2_y] > speedhack.map[maprotation.map].max_max_y then
					speedhack.map[maprotation.map].max_max_y = diffs2_y[#diffs2_y]
					speedhack.save_map_profile()
				end
				if diffs2_z[#diffs2_z] > speedhack.map[maprotation.map].max_max_z then
					speedhack.map[maprotation.map].max_max_z = diffs2_z[#diffs2_z]
					speedhack.save_map_profile()
				end
				if diffs2_x[1] > speedhack.map[maprotation.map].max_min_x then
					speedhack.map[maprotation.map].max_min_x = diffs2_x[1]
					speedhack.save_map_profile()
				end
				if diffs2_y[1] > speedhack.map[maprotation.map].max_min_y then
					speedhack.map[maprotation.map].max_min_y = diffs2_y[1]
					speedhack.save_map_profile()
				end
				if diffs2_z[1] > speedhack.map[maprotation.map].max_min_z then
					speedhack.map[maprotation.map].max_min_z = diffs2_z[1]
					speedhack.save_map_profile()
				end
			else
				-- Nicht im Recording-Modus: Schwellwert-Prüfung
				--  Zugabe von z.b. 5% Tolleranz
				if diffs2_x and speedhack.map[maprotation.map] then
					if diffs2_x[#diffs2_x] > (speedhack.map[maprotation.map].max_max_x * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 1
					end
					if diffs2_y[#diffs2_y] > (speedhack.map[maprotation.map].max_max_y * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 1
					end
					if diffs2_z[#diffs2_z] > (speedhack.map[maprotation.map].max_max_z * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 1
					end
					if diffs2_x[1] > (speedhack.map[maprotation.map].max_min_x * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 1
					end
					if diffs2_y[1] > (speedhack.map[maprotation.map].max_min_y * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 2
					end
					if diffs2_z[1] > (speedhack.map[maprotation.map].max_min_x * speedhack.tolerance) then
						speedhack.player[cn].malus = speedhack.player[cn].malus + 2
					end
					if speedhack.player[cn].malus > speedhack.warnmalus and speedhack.player[cn].level == 0 then
						messages.warning(-1, players.admins(), "CHEATER", string.format("%s (%i) seems to moving too fast.", server.player_name(cn), cn))
						speedhack.player[cn].level = 1
					end
					if speedhack.player[cn].malus > speedhack.maxmalus and speedhack.player[cn].level == 1 then
						speedhack.player[cn].level = 2
						server.kick(cn, cheater.ban.time, "server", "speedhacking")
						messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked red<speedhacker %s on map %s>", server.player_displayname(cn), maprotation.map))
					end
				else
					-- messages.error(cn, players.admins(), "SPEEDHACK", "nil values")
				end
			end

			-- Die aeltesten Werte vergessen
			table.remove(speedhack.player[cn].pos_x, 1)
			table.remove(speedhack.player[cn].pos_y, 1)
			table.remove(speedhack.player[cn].pos_z, 1)
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_speedhack(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#speedhack <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.debug=" .. speedhack.debug)
				messages.info(cn, {cn}, "CHEATER", "speedhack.recording=" .. speedhack.recording)
				messages.info(cn, {cn}, "CHEATER", "speedhack.remember_positions=" .. speedhack.remember_positions)
				messages.info(cn, {cn}, "CHEATER", "speedhack.diff_between_positions=" .. speedhack.diff_between_positions)
				messages.info(cn, {cn}, "CHEATER", "speedhack.ignore_first_values=" .. speedhack.ignore_first_values)
				messages.info(cn, {cn}, "CHEATER", "speedhack.tolerance=" .. speedhack.tolerance)
				messages.info(cn, {cn}, "CHEATER", "speedhack.warnmalus=" .. speedhack.warnmalus)
				messages.info(cn, {cn}, "CHEATER", "speedhack.maxmalus=" .. speedhack.maxmalus)
			end
			if command == "infoall" then
				messages.info(cn, players.all(), "CHEATER", "speedhack.debug=" .. speedhack.debug)
				messages.info(cn, players.all(), "CHEATER", "speedhack.recording=" .. speedhack.recording)
				messages.info(cn, players.all(), "CHEATER", "speedhack.remember_positions=" .. speedhack.remember_positions)
				messages.info(cn, players.all(), "CHEATER", "speedhack.diff_between_positions=" .. speedhack.diff_between_positions)
				messages.info(cn, players.all(), "CHEATER", "speedhack.ignore_first_values=" .. speedhack.ignore_first_values)
				messages.info(cn, players.all(), "CHEATER", "speedhack.tolerance=" .. speedhack.tolerance)
				messages.info(cn, players.all(), "CHEATER", "speedhack.warnmalus=" .. speedhack.warnmalus)
				messages.info(cn, players.all(), "CHEATER", "speedhack.maxmalus=" .. speedhack.maxmalus)
			end
			if command == "map" then
				messages.info(cn, {cn}, "CHEATER", "speedhack test values for " .. maprotation.map)
				messages.info(cn, {cn}, "CHEATER", string.format("max_min: x: %i y: %i z: %i", speedhack.map[maprotation.map].max_min_x, speedhack.map[maprotation.map].max_min_y, speedhack.map[maprotation.map].max_min_z))
				messages.info(cn, {cn}, "CHEATER", string.format("max_max: x: %i y: %i z: %i", speedhack.map[maprotation.map].max_max_x, speedhack.map[maprotation.map].max_max_y, speedhack.map[maprotation.map].max_max_z))
			end
			if command == "resetmap" then
				speedhack.map[maprotation.map] = {}
				speedhack.map[maprotation.map].max_min_x = 0
				speedhack.map[maprotation.map].max_min_y = 0
				speedhack.map[maprotation.map].max_min_z = 0
				speedhack.map[maprotation.map].max_max_x = 0
				speedhack.map[maprotation.map].max_max_y = 0
				speedhack.map[maprotation.map].max_max_z = 0
				db.insert_or_update("nl_speedhack", { map=maprotation.map, max_min_x=speedhack.map[maprotation.map].max_min_x, max_min_y=speedhack.map[maprotation.map].max_min_y, max_min_z=speedhack.map[maprotation.map].max_min_z, max_max_x=speedhack.map[maprotation.map].max_max_x, max_max_y=speedhack.map[maprotation.map].max_max_y, max_max_z=speedhack.map[maprotation.map].max_max_z }, string.format("map='%s'", maprotation.map) )
				speedhack.recording = 1
				messages.info(cn, {cn}, "CHEATER", "speedhack resetting map values for " .. maprotation.map)
				messages.info(cn, {cn}, "CHEATER", string.format("max_min: x: %i y: %i z: %i", speedhack.map[maprotation.map].max_min_x, speedhack.map[maprotation.map].max_min_y, speedhack.map[maprotation.map].max_min_z))
				messages.info(cn, {cn}, "CHEATER", string.format("max_max: x: %i y: %i z: %i", speedhack.map[maprotation.map].max_max_x, speedhack.map[maprotation.map].max_max_y, speedhack.map[maprotation.map].max_max_z))
				messages.info(cn, {cn}, "CHEATER", "speedhack.recording=" .. speedhack.recording)
			end
			if command == "debug" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.debug=" .. speedhack.debug)
			end
			if command == "recording" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.recording=" .. speedhack.recording)
			end
			if command == "remember_positions" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.remember_positions=" .. speedhack.remember_positions)
			end
			if command == "diff_between_positions" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.diff_between_positions=" .. speedhack.diff_between_positions)
			end
			if command == "ignore_first_values" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.ignore_first_values=" .. speedhack.ignore_first_values)
			end
			if command == "tolerance" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.tolerance=" .. speedhack.tolerance)
			end
			if command == "warnmalus" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.warnmalus=" .. speedhack.warnmalus)
			end
			if command == "maxmalus" then
				messages.info(cn, {cn}, "CHEATER", "speedhack.maxmalus=" .. speedhack.maxmalus)
			end
		else
			if command == "debug" then
				speedhack.debug = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.debug=" .. speedhack.debug)
			end
			if command == "recording" then
				speedhack.recording = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.recording=" .. speedhack.recording)
			end
			if command == "remember_positions" then
				speedhack.remember_positions = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.remember_positions=" .. speedhack.remember_positions)
			end
			if command == "diff_between_positions" then
				speedhack.diff_between_positions = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.diff_between_positions=" .. speedhack.diff_between_positions)
			end
			if command == "ignore_first_values" then
				speedhack.ignore_first_values = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.ignore_first_values=" .. speedhack.ignore_first_values)
			end
			if command == "tolerance" then
				speedhack.tolerance = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.tolerance=" .. speedhack.tolerance)
			end
			if command == "warnmalus" then
				speedhack.warnmalus = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.warnmalus=" .. speedhack.warnmalus)
			end
			if command == "maxmalus" then
				speedhack.maxmalus = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "speedhack.maxmalus=" .. speedhack.maxmalus)
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("spawn", function(cn)
	speedhack.reset(cn)
end)

server.event_handler("connect", function(cn)
	speedhack.reset(cn)
end)

server.event_handler("disconnect", function(cn)
	speedhack.player[cn] = nil
end)

server.event_handler("mapchange", function(map, mode)
	for _, cn in pairs(players.all()) do
		speedhack.reset(cn)
	end
	speedhack.resetmap()
end)

server.event_handler("start", function()
	server.sleep(2000, function()
		speedhack.resetmap()
	end)
end)

server.interval(speedhack.reduce_interval, function()
	if server.paused ~= 1 and server.timeleft > 0 then
		for _, cn in pairs(server.players()) do
			-- player only looses malus points if playing
			if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				if speedhack.player[cn] == nil then speedhack.reset(cn) end
				if speedhack.player[cn].malus > 0 then
					speedhack.player[cn].malus = speedhack.player[cn].malus - 1
				end
			end
		end
	end
end)

server.interval(speedhack.check_interval, speedhack.check)
