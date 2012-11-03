--[[
	script/module/nl_mod/nl_minmax.lua
	Hanack (Andreas Schaeffer)
	Created: 05-Mai-2012
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Erkennen von Spielern die sich außerhalb der minimalen und maximalen
		x-, y- und z-Positionen befinden.

	Commands:
		#minmax recording 1
			description
		#minmax recording 0
			description

	API-Methoden:
		minmax.xyz()
			xyz

	Konfigurations-Variablen:
		minmax.xyz
			xyz
]]

--[[
		API
]]

minmax = {}
minmax.enabled = 1
minmax.only_warnings = 1
minmax.recording = 0
minmax.visualisation = 1
minmax.interval = 200
minmax.changebox_interval = 250
minmax.tolerance = 3
minmax.ready = 0
minmax.map = {}
minmax.map[1] = -1000000
minmax.map[2] = -1000000
minmax.map[3] = -1000000
minmax.map[4] = 1000000
minmax.map[5] = 1000000
minmax.map[6] = 1000000
minmax.parts = {}
minmax.warn_level = {}

function minmax.verbose_warning(cn, x, y, z)
	local min_x = ""
	local min_y = ""
	local min_z = ""
	local max_x = ""
	local max_y = ""
	local max_z = ""
	local col_x = "green"
	local col_y = "green"
	local col_z = "green"
	if x < minmax.map[1] and x > -1000000 then
		col_x = "red"
		min_x = " MIN"
	end
	if y < minmax.map[2] and y > -1000000 then
		col_y = "red"
		min_y = " MIN"
	end
	if z < minmax.map[3] and z > -1000000 then
		col_z = "red"
		min_z = " MIN"
	end
	if x > minmax.map[4] and x < 1000000 then
		col_x = "red"
		max_x = " MAX"
	end
	if y > minmax.map[5] and y < 1000000 then
		col_y = "red"
		max_y = " MAX"
	end
	if z > minmax.map[6] and z < 1000000 then
		col_z = "red"
		max_z = " MAX"
	end
	messages.warning(-1, players.admins(), "MINMAX", string.format("blue<%s (%i)> orange<left the playable region of the map!> %s<x%s%s: %i>, %s<y%s%s: %i>, %s<z%s%s: %i>", server.player_name(cn), cn, col_x, min_x, max_x, math.floor(x), col_y, min_y, max_y, math.floor(y), col_z, min_z, max_z, math.floor(z)))
end

function minmax.check()
	if server.paused == 1 or server.timeleft <= 0 or minmax.enabled == 0 or (minmax.ready == 0 and minmax.recording == 0) then return end
	if minmax.map ~= nil then
		for i,cn in ipairs(players.all()) do
			if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				local x, y, z = server.player_pos(cn)
				if minmax.recording == 1 then
					if
						x > -1000000 and x <  1000000 and y > -1000000 and y <  1000000 and z > -1000000 and z < 1000000 and (
						x < (minmax.map[1]) or x > (minmax.map[4]) or
						y < (minmax.map[2]) or y > (minmax.map[5]) or
						z < (minmax.map[3]) or z > (minmax.map[6]))
					then
						minmax.save_profile(cn, x, y, z)
					end
				else
					-- no tolerance while recording
					if
						x > -1000000 and x <  1000000 and y > -1000000 and y <  1000000 and z > -1000000 and z <  1000000 and (
						x < (minmax.map[1] - minmax.tolerance) or x > (minmax.map[4] + minmax.tolerance) or
						y < (minmax.map[2] - minmax.tolerance) or y > (minmax.map[5] + minmax.tolerance) or
						z < (minmax.map[3] - minmax.tolerance) or z > (minmax.map[6] + minmax.tolerance))
					then
						if minmax.only_warnings == 1 then
							if minmax.warn_level[cn] == nil then
								minmax.warn_level[cn] = 1
						else
								minmax.warn_level[cn] = minmax.warn_level[cn] + 1
								if minmax.warn_level[cn] % 5 == 0 then
									minmax.verbose_warning(cn, x, y, z)
								end
							end
						else
							local full_reason = string.format("Automatically kicked blue<%s (%i)> because of player left playable region of the map!> orange<Pos: %i, %i, %i>", server.player_name(cn), cn, math.floor(x), math.floor(y), math.floor(z))
							messages.error(-1, players.admins(), "CHEATER", full_reason)
							cheater.autokick(cn, "Server", "Maphacking/Flyhacking", full_reason)
						end
					end
				end
			end
		end
	end
end

function minmax.save_profile(cn, x, y, z)
	local saved = 0
	if x < minmax.map[1] and x > -1000000 then
		minmax.map[1] = x
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new orange<min> position::  red<x: %i> y: %i z: %i", server.player_name(cn), x, y, z))
	end
	if y < minmax.map[2] and y > -1000000 then
		minmax.map[2] = y
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new orange<min> position::  x: %i red<y: %i> z: %i", server.player_name(cn), x, y, z))
	end
	if z < minmax.map[3] and z > -1000000 then
		minmax.map[3] = z
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new orange<min> position::  x: %i y: %i red<z: %i>", server.player_name(cn), x, y, z))
	end
	if x > minmax.map[4] and x < 1000000 then
		minmax.map[4] = x
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new green<max> position::  red<x: %i> y: %i z: %i", server.player_name(cn), x, y, z))
	end
	if y > minmax.map[5] and y < 1000000 then
		minmax.map[5] = y
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new green<max> position::  x: %i red<y: %i> z: %i", server.player_name(cn), x, y, z))
	end
	if z > minmax.map[6] and z < 1000000 then
		minmax.map[6] = z
		saved = 1
		messages.debug(-1, players.all(), "MINMAX", string.format("%s added a new green<max> position::  x: %i y: %i red<z: %i>", server.player_name(cn), x, y, z))
	end
	
	if saved == 1 then
		minmax.showbox()
		db.insert_or_update("nl_minmax", { map=maprotation.map, min_x=minmax.map[1], min_y=minmax.map[2], min_z=minmax.map[3], max_x=minmax.map[4], max_y=minmax.map[5], max_z=minmax.map[6] }, string.format("map='%s'", maprotation.map) )
	end
end

function minmax.load_profile()
	if maprotation.map == nil then return false end
	local result = db.select("nl_minmax", { "min_x", "min_y", "min_z", "max_x", "max_y", "max_z" }, string.format("map='%s'", maprotation.map) )
	if #result == 0 then
		minmax.ready = 0
		return false
	else
		minmax.ready = 1
		minmax.map = { tonumber(result[1].min_x), tonumber(result[1].min_y), tonumber(result[1].min_z), tonumber(result[1].max_x), tonumber(result[1].max_y), tonumber(result[1].max_z) }
		return true
	end
end

function minmax.reset_profile()
	if minmax.load_profile() == false then
		if maprotation.map == nil then
			server.sleep(5000, minmax.reset_profile)
			return
		else
			if minmax.recording == 1 then
				messages.error(cn, players.admins(), "MINMAX", string.format("Starting profiling map %s for minmax detection", maprotation.map))
				minmax.map = { 1000000, 1000000, 1000000, -1000000, -1000000, -1000000 }
			else
				messages.debug(cn, players.admins(), "MINMAX", string.format("Could not load minmax profile for map %s", maprotation.map))
			end
		end
	else
		minmax.recording = 0
		cheater.stop_recording("minmax")
		messages.debug(cn, players.admins(), "MINMAX", "Sucessfully loaded minmax profile for map " .. maprotation.map)
	end
end

function minmax.paint(n, x, y, z, dir, length)
	local color = 1096
	if minmax.parts[n] == nil then
		minmax.parts[n] = particles.lightning.create(x, y, z, dir, length, color)
	else
		particles.lightning.update(minmax.parts[n], x, y, z, dir, length, color)
	end
end

function minmax.showbox()
	if minmax.enabled == 0 or minmax.visualisation == 0 then return end
	local lx = minmax.map[4] - minmax.map[1]
	local ly = minmax.map[5] - minmax.map[2]
	local lz = minmax.map[6] - minmax.map[3]
	minmax.paint(1, minmax.map[1], minmax.map[2], minmax.map[3], 0, lz)
	minmax.paint(2, minmax.map[1], minmax.map[2], minmax.map[3], 1, lx)
	minmax.paint(3, minmax.map[1], minmax.map[2], minmax.map[3], 2, ly)
	minmax.paint(4, minmax.map[4], minmax.map[2], minmax.map[3], 0, lz)
	minmax.paint(5, minmax.map[4], minmax.map[2], minmax.map[3], 2, ly)
	minmax.paint(6, minmax.map[1], minmax.map[2], minmax.map[6], 1, lx)
	minmax.paint(7, minmax.map[1], minmax.map[2], minmax.map[6], 2, ly)
	minmax.paint(8, minmax.map[4], minmax.map[2], minmax.map[6], 2, ly)
	minmax.paint(9, minmax.map[1], minmax.map[5], minmax.map[3], 1, lx)
	minmax.paint(10, minmax.map[1], minmax.map[5], minmax.map[3], 0, lz)
	minmax.paint(11, minmax.map[4], minmax.map[5], minmax.map[3], 0, lz)
	minmax.paint(12, minmax.map[1], minmax.map[5], minmax.map[6], 1, lx)
end

function minmax.changebox()
	if minmax.enabled == 0 or minmax.recording == 0 or minmax.visualisation == 0 then return end
	local lx = minmax.map[4] - minmax.map[1]
	local ly = minmax.map[5] - minmax.map[2]
	local lz = minmax.map[6] - minmax.map[3]
	for i, cn in ipairs(players.active()) do
		local n = 12 + ((i - 1) * 12)
		local mid_x, mid_y, mid_z = server.player_pos(cn)
		minmax.paint(n+1, minmax.map[1], minmax.map[2], mid_z, 1, lx)
		minmax.paint(n+2, minmax.map[1], minmax.map[2], mid_z, 2, ly)
		minmax.paint(n+3, minmax.map[4], minmax.map[2], mid_z, 2, ly)
		minmax.paint(n+4, minmax.map[1], minmax.map[5], mid_z, 1, lx)
		minmax.paint(n+5, mid_x, minmax.map[2], minmax.map[3], 0, lz)
		minmax.paint(n+6, mid_x, minmax.map[2], minmax.map[3], 2, ly)
		minmax.paint(n+7, mid_x, minmax.map[2], minmax.map[6], 2, ly)
		minmax.paint(n+8, mid_x, minmax.map[5], minmax.map[3], 0, lz)
		minmax.paint(n+9, minmax.map[1], mid_y, minmax.map[3], 1, lx)
		minmax.paint(n+10, minmax.map[1], mid_y, minmax.map[3], 0, lz)
		minmax.paint(n+11, minmax.map[1], mid_y, minmax.map[6], 1, lx)
		minmax.paint(n+12, minmax.map[4], mid_y, minmax.map[3], 0, lz)
	end
end

function minmax.hidebox()
	for i, slot in ipairs(minmax.parts) do
		entities.free(slot)
	end
	minmax.parts = {}
end


--[[
		COMMANDS
]]

function server.playercmd_minmax(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#minmax <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "MINMAX", "minmax.enabled=" .. minmax.enabled)
				messages.info(cn, {cn}, "MINMAX", "minmax.only_warnings=" .. minmax.only_warnings)
				messages.info(cn, {cn}, "MINMAX", "minmax.recording=" .. minmax.recording)
				messages.info(cn, {cn}, "MINMAX", "minmax.tolerance=" .. minmax.tolerance)
				messages.info(cn, {cn}, "MINMAX", "minmax.visualisation=" .. minmax.visualisation)
				messages.info(cn, {cn}, "MINMAX", "minmax.ready=" .. minmax.ready)
				messages.info(cn, {cn}, "MINMAX", string.format("minmax values for map %s", maprotation.map))
				messages.info(cn, {cn}, "MINMAX", string.format("   min: x: %i y: %i z: %i", minmax.map[1], minmax.map[2], minmax.map[3]))
				messages.info(cn, {cn}, "MINMAX", string.format("   max: x: %i y: %i z: %i", minmax.map[4], minmax.map[5], minmax.map[6]))
			end
			if command == "resetmap" then
				minmax.map = { 1000000, 1000000, 1000000, -1000000, -1000000, -1000000 }
				db.insert_or_update("nl_minmax", { map=maprotation.map, min_x=minmax.map[1], min_y=minmax.map[2], min_z=minmax.map[3], max_x=minmax.map[4], max_y=minmax.map[5], max_z=minmax.map[6] }, string.format("map='%s'", maprotation.map) )
				minmax.recording = 1
				cheater.start_recording("minmax")
			end
			if command == "show" then
				minmax.showbox()
			end
			if command == "hide" then
				minmax.hidebox()
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "MINMAX", "minmax.only_warnings=" .. minmax.only_warnings)
			end
			if command == "recording" then
				messages.info(cn, {cn}, "MINMAX", "minmax.recording=" .. minmax.recording)
			end
			if command == "tolerance" then
				messages.info(cn, {cn}, "MINMAX", "minmax.tolerance=" .. minmax.tolerance)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "MINMAX", "minmax.enabled=" .. minmax.enabled)
			end
			if command == "visualisation" then
				messages.info(cn, {cn}, "MINMAX", "minmax.visualisation=" .. minmax.visualisation)
			end
			if command == "ready" then
				messages.info(cn, {cn}, "MINMAX", "minmax.ready=" .. minmax.ready)
			end
		else
			if command == "only_warnings" then
				minmax.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "MINMAX", "minmax.only_warnings=" .. minmax.only_warnings)
			end
			if command == "recording" then
				local recording_val = tonumber(arg)
				if minmax.recording ~= recording_val then
					if minmax.recording == 0 then
						cheater.start_recording("minmax")
						messages.info(cn, players.all(), "MINMAX", string.format("orange<Starting profiling %s for minmax detection...>", maprotation.map))
						minmax.showbox()
					end
					if minmax.recording == 1 then
						messages.info(cn, players.all(), "MINMAX", string.format("orange<Stopped profiling %s for minmax detection...>", maprotation.map))
						cheater.stop_recording("minmax")
						minmax.hidebox()
					end
				else
					messages.info(cn, {cn}, "MINMAX", "minmax.recording = " .. recording_val)
				end
				minmax.recording = recording_val
				-- messages.info(cn, {cn}, "MINMAX", "minmax.recording=" .. minmax.recording)
			end
			if command == "tolerance" then
				minmax.tolerance = tonumber(arg)
				messages.info(cn, {cn}, "MINMAX", "minmax.tolerance=" .. minmax.tolerance)
			end
			if command == "enabled" then
				minmax.enabled = tonumber(arg)
				messages.info(cn, {cn}, "MINMAX", "minmax.enabled=" .. minmax.enabled)
			end
			if command == "visualisation" then
				minmax.visualisation = tonumber(arg)
				messages.info(cn, {cn}, "MINMAX", "minmax.visualisation=" .. minmax.visualisation)
			end
			if command == "ready" then
				minmax.ready = tonumber(arg)
				messages.info(cn, {cn}, "MINMAX", "minmax.ready=" .. minmax.ready)
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("start", function()
	server.sleep(2000, function()
		minmax.reset_profile()
	end)
end)

server.event_handler("mapchange", function()
	minmax.map = {}
	minmax.parts = {}
	minmax.warn_level = {}
	minmax.reset_profile()
end)

server.interval(minmax.interval, minmax.check)

server.interval(minmax.changebox_interval, minmax.changebox)
