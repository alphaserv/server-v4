--[[
	script/module/nl_mod/nl_respawn.lua
	Hanack (Andreas Schaeffer)
	Created: 05-Mai-2012
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Erkennen und verhindern, dass Spieler zu schnell respawnen. 

]]



--[[
		API
]]

respawn = {}
respawn.enabled = 1
respawn.protected = 1 -- change this, if you want to do bad things like deleting the profiles
respawn.recording = 0
respawn.visualisation = 1
respawn.testing = 0
respawn.testing_errors = 0
respawn.position_check = 1
respawn.only_warnings = 1
respawn.warnings = 2
respawn.pbox = 3
respawn.ban = 4
respawn.max_distance = 40 -- the respawn point cube modulo: the respawn point has to be within this cube
respawn.tolerance = 40 -- the additional tolerance 
respawn.profile = {}
respawn.profile_size = 0
respawn.min_profile_size = 4
respawn.slay_delay = 1000
respawn.mapchange = 1
respawn.mapchange_delay = 2000
respawn.check_positions_interval = 100
respawn.lastdeath = {}
respawn.level = {}
respawn.next_check = {}
respawn.has_respawned = {}
respawn.last_positions = {}
respawn.min_respawntime = {}
respawn.min_respawntime['insta ctf'] = 4900
respawn.min_respawntime['efficiency ctf'] = 4900
respawn.min_respawntime['ctf'] = 4900
respawn.min_respawntime['insta hold'] = 4900
respawn.min_respawntime['efficiency hold'] = 4900
respawn.min_respawntime['hold'] = 4900
respawn.min_respawntime['insta protect'] = 0
respawn.min_respawntime['efficiency protect'] = 0
respawn.min_respawntime['protect'] = 0
respawn.min_respawntime['ffa'] = 0
respawn.min_respawntime['instagib'] = 0
respawn.min_respawntime['efficiency'] = 0
respawn.min_respawntime['tactics'] = 0
respawn.min_respawntime['efficiency team'] = 0
respawn.min_respawntime['instagib team'] = 0
respawn.min_respawntime['tactics team'] = 0
respawn.min_respawntime['teamplay'] = 0
respawn.min_respawntime['capture'] = 4900
respawn.min_respawntime['regen capture'] = 0
respawn.min_respawntime['coop edit'] = 0
respawn.is_teammode = {}
respawn.is_teammode['insta ctf'] = 1
respawn.is_teammode['efficiency ctf'] = 1
respawn.is_teammode['ctf'] = 1
respawn.is_teammode['insta hold'] = 2
respawn.is_teammode['efficiency hold'] = 2
respawn.is_teammode['hold'] = 2
respawn.is_teammode['insta protect'] = 2
respawn.is_teammode['efficiency protect'] = 2
respawn.is_teammode['protect'] = 2
respawn.is_teammode['ffa'] = 0
respawn.is_teammode['instagib'] = 0
respawn.is_teammode['efficiency'] = 0
respawn.is_teammode['tactics'] = 0
respawn.is_teammode['efficiency team'] = 3
respawn.is_teammode['instagib team'] = 3
respawn.is_teammode['tactics team'] = 3
respawn.is_teammode['teamplay'] = 3
respawn.is_teammode['capture'] = 2
respawn.is_teammode['regen capture'] = 2
respawn.is_teammode['coop edit'] = 0
respawn.points_x = 15
respawn.points_y = 15
respawn.points_z = 25
respawn.slots = {}



-- setzt profil zurueck
function respawn.clear_profile()
	respawn.profile = {}
	respawn.profile_size = 0
end

-- laedt profil aus der datenbank
function respawn.load_profile()
	respawn.clear_profile()
	if maprotation.game_mode == "coop edit" or respawn.is_teammode == nil or respawn.is_teammode[maprotation.game_mode] == nil then return end
	local maprsp = db.select("nl_respawnpoints", { "x", "y", "z" }, string.format("map='%s' and team=%i", maprotation.map, respawn.is_teammode[maprotation.game_mode]) )
	if #maprsp == 0 then
		messages.debug(-1, players.admins(), "RESPAWN", string.format("Could not load respawn point profile for map %s and teammode=%i", maprotation.map, respawn.is_teammode[maprotation.game_mode]))
	else
		for i, entry in pairs(maprsp) do
			rspx = tonumber(entry.x)
			rspy = tonumber(entry.y)
			rspz = tonumber(entry.z)
			table.insert(respawn.profile, { rspx, rspy, rspz })
			respawn.profile_size = respawn.profile_size + 1
		end
		messages.debug(-1, players.admins(), "RESPAWN", string.format("Successfully loaded respawn point profile for map %s and teammode=%i with %i respawn points", maprotation.map, respawn.is_teammode[maprotation.game_mode], respawn.profile_size))
	end
end

-- loescht ein profil
function respawn.delete_profile()
	if respawn.protected ~= 0 then return end
	respawn.clear_profile()
	db.delete("nl_respawnpoints", string.format("map='%s' and team=%i", maprotation.map, respawn.is_teammode[maprotation.game_mode]))
	respawn.clear_points()
end

-- respawn points ents entfernen
function respawn.clear_points()
	for i,slot in ipairs(respawn.slots) do
		entities.free(slot)
	end
	respawn.slots = {}
end

-- respawn points ents senden
function respawn.send_points()
	respawn.clear_points()
	for i,rsp in ipairs(respawn.profile) do
		local slot = entities.register()
		entities.set(
			slot,
			entities.types['respawnpoint'],
			rsp[1] + respawn.points_x,
			rsp[2] + respawn.points_y,
			rsp[3] + respawn.points_z,
			0, 0, 0, 0, 0
		)
		table.insert(respawn.slots, slot)
	end
end

function respawn.is_spectator_point(x, y, z)
	return x == -10000000000 or y == -10000000000 or z == -10000000000 or x == -10000000020 or y == -10000000020 or z == -10000000020
end

function respawn.get_nearest_respawn_point(x, y, z)
	local nearest = {}
	for i,rsp in ipairs(respawn.profile) do
		if i == 1 then
			nearest = rsp
		else
			if
				math.abs(rsp[1] - x) < math.abs(nearest[1] - x) and
				math.abs(rsp[2] - y) < math.abs(nearest[2] - y) and
				math.abs(rsp[3] - z) < math.abs(nearest[3] - z)
			then
				nearest = rsp
			end
		end
	end
	messages.debug(-1, players.admins(), "RESPAWN", string.format("nearest respawn point was (x: %i y: %i z: %i)", nearest[1], nearest[2], nearest[3]))
	return nearest
end

-- check if position is a respawn point
function respawn.is_respawn_point(x, y, z)
	for i,rsp in ipairs(respawn.profile) do
		if x > -100000000 and x < 100000000 and
		   y > -100000000 and y < 100000000 and
		   z > -100000000 and z < 100000000 and
		   x > (rsp[1] - respawn.max_distance) - respawn.tolerance and x < rsp[1] + respawn.max_distance + respawn.tolerance and
		   y > (rsp[2] - respawn.max_distance) - respawn.tolerance and y < rsp[2] + respawn.max_distance + respawn.tolerance and
		   z > (rsp[3] - respawn.max_distance) - respawn.tolerance and z < rsp[3] + respawn.max_distance + respawn.tolerance
		then
			return true
		end
	end
	return false
end

function respawn.disable_next_check(cn)
	respawn.next_check[cn] = false
end

function respawn.record_pos(cn, x, y, z, x1, y1, z1) -- TODO: use only x1,y1,z1
	if x > -100000000 and x < 100000000 and
	   y > -100000000 and y < 100000000 and
	   z > -100000000 and z < 100000000
	then
		table.insert(respawn.profile, { x1, y1, z1 })
		respawn.profile_size = respawn.profile_size + 1
		db.insert("nl_respawnpoints", { map=maprotation.map, team=respawn.is_teammode[maprotation.game_mode], x=x1, y=y1, z=z1 })
		messages.debug(-1, players.all(), "RESPAWN", string.format("%s added new respawn point (x: %i y: %i z: %i)", server.player_name(cn), x1, y1, z1))
		if respawn.visualisation == 1 then
			respawn.send_points()
		end
	end
end

function respawn.add_pos(cn)
	local x, y, z = server.player_pos(cn)
	x = math.floor(tonumber(x))
	y = math.floor(tonumber(y))
	z = math.floor(tonumber(z))
	if not respawn.is_spectator_point(x, y, z) then
		for i, p in ipairs(respawn.last_positions[cn]) do
			if p[1] == x and p[2] == y and p[3] == z then return end
		end
		table.insert(respawn.last_positions[cn], { x, y, z })
		messages.debug(-1, players.admins(), "RESPAWN", string.format("added new last position for %s (x: %i, y: %i, z: %i)", server.player_displayname(cn), x, y, z))
	end
end

function respawn.check_pos(cn)
	local x = respawn.last_positions[cn][3][1]
	local y = respawn.last_positions[cn][3][2]
	local z = respawn.last_positions[cn][3][3]
	local x1 = x - (x % respawn.max_distance)
	local y1 = y - (y % respawn.max_distance)
	local z1 = z - (z % respawn.max_distance)
	if not respawn.is_respawn_point(x1, y1, z1) then
		if not respawn.is_spectator_point(x1, y1, z1) then
			if respawn.recording == 1 then
				respawn.record_pos(cn, x, y, z, x1, y1, z1)
			elseif respawn.testing == 1 then
				respawn.testing_errors = respawn.testing_errors + 1
				messages.warning(cn, players.admins(), "RESPAWN", string.format("Test failed at (%s (%i): x: %i, y: %i, z: %i)", server.player_name(cn), cn, x1, y1, z1))
			elseif respawn.only_warnings == 1 then
				messages.warning(cn, players.admins(), "RESPAWN", string.format("red<%s (%i) is using an invalid respawn point (x: %i, y: %i, z: %i)>", server.player_name(cn), cn, x1, y1, z1))
				-- TODO: remove after debug
				respawn.get_nearest_respawn_point(x1, y1, z1)
			else
				messages.error(cn, players.admins(), "RESPAWN", string.format("red<Automatically kicked %s (%i) because of invalid respawn point (x: %i, y: %i, z: %i)>", server.player_displayname(cn), cn, x1, y1, z1))
				server.kick(cn, cheater.ban.time, "Server", "Invalid respawn point")
			end
		end
	end
	respawn.last_positions[cn] = {}
	respawn.has_respawned[cn] = 0
end

-- check invalid respawn position
function respawn.check_positions()
	if respawn.enabled == 0 or respawn.position_check == 0 or maprotation.game_mode == "coop edit" then return end
	if respawn.profile_size < respawn.min_profile_size and respawn.recording == 0 then return end
	for _, cn in ipairs(players.all()) do
		if respawn.has_respawned[cn] == 1 then
			if #respawn.last_positions[cn] >= 3 then
				respawn.check_pos(cn)
			else
				respawn.add_pos(cn)
			end
		end
	end
end

-- check respawn time
function respawn.check_time(cn)
	local gm = server.gamemillis -- first command for less delay
	if respawn.enabled == 0 or respawn.mapchange == 1 or respawn.testing == 1 or maprotation.game_mode == "coop edit" then return end
	if respawn.next_check[cn] == false then
		respawn.next_check[cn] = true
		return
	end
	
	local respawntime = gm - respawn.lastdeath[cn]

	messages.debug(cn, players.admins(), "RESPAWN", string.format("respawntime of blue<%s>: %i", server.player_displayname(cn), respawntime))
	if respawntime > 0 and respawntime < respawn.min_respawntime[maprotation.game_mode] then -- es gibt eine minimale respawn zeit pro mode
		if respawntime < respawn.min_respawntime[maprotation.game_mode] - 1000 then
			respawn.level[cn] = respawn.level[cn] + 2
		else
			respawn.level[cn] = respawn.level[cn] + 1
		end
		if respawn.level[cn] < respawn.ban then
			if respawn.level[cn] < respawn.pbox then
				messages.warning(cn, players.admins(), "RESPAWN", string.format("orange<%s (%i) respawns within %s ms>", server.player_displayname(cn), cn, respawntime))
				messages.warning(cn, {cn}, "RESPAWN", string.format("%s, red<you are respawning too fast!>", server.player_displayname(cn)))
				server.sleep(respawn.slay_delay, function()
					if server.valid_cn(cn) then
						server.player_slay(cn)
					end
				end)
			else
				messages.error(cn, players.admins(), "RESPAWN", string.format("red<%s (%i) got a penalty because of respawning within %s ms>", server.player_displayname(cn), cn, respawntime))
				penaltybox.penalty(cn, cheater.pbox.time, "Respawning too fast")
			end
		else
			messages.error(cn, players.admins(), "RESPAWN", string.format("red<Automatically kicked %s (%i) because of respawning within %s ms>", server.player_displayname(cn), cn, respawntime))
			server.kick(cn, cheater.ban.time, "Server", "Respawning to fast")
		end
	end
end

function respawn.test(remaining, total)
	remaining = remaining - 1
	if remaining <= 0 then
		respawn.testing = 0
		messages.info(-1, players.admins(), "RESPAWN", string.format("Test completed with orange<%i errors> (total tries: %i)", respawn.testing_errors, total))
		return
	end
	for _, cn in ipairs(players.all()) do
		server.spawn_player(cn)
		server.sleep(400, function()
			server.player_slay(cn)
		end)
	end
	server.sleep(600, function()
		if total == nil then
			respawn.test(remaining, remaining+1)
		else
			respawn.test(remaining, total)
		end
	end)
end




--[[
		COMMANDS
]]

function server.playercmd_respawn(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#respawn <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.recording = " .. respawn.recording)
				messages.info(cn, {cn}, "RESPAWN", "respawn.enabled = " .. respawn.enabled)
				messages.info(cn, {cn}, "RESPAWN", "respawn.position_check = " .. respawn.position_check)
				messages.info(cn, {cn}, "RESPAWN", "respawn.only_warnings = " .. respawn.only_warnings)
				messages.info(cn, {cn}, "RESPAWN", "respawn.max_distance = " .. respawn.max_distance)
				messages.info(cn, {cn}, "RESPAWN", "respawn.tolerance=" .. respawn.tolerance)
				messages.info(cn, {cn}, "RESPAWN", "respawn.slay_delay = " .. respawn.slay_delay)
				messages.info(cn, {cn}, "RESPAWN", "respawn.min_profile_size = " .. respawn.min_profile_size)
				messages.info(cn, {cn}, "RESPAWN", "profile size = " .. respawn.profile_size)
			end
			if command == "delete" then
				respawn.delete_profile()
				messages.info(cn, players.admins(), "RESPAWN", "Deleted respawn profile")
			end
			if command == "reload" then
				respawn.load_profile()
			end
			if command == "test" then
				respawn.testing = 1
				respawn.testing_errors = 0
				respawn.test(20)
			end
			if command == "recording" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.recording = " .. respawn.recording)
			end
			if command == "visualisation" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.visualisation = " .. respawn.visualisation)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.enabled = " .. respawn.enabled)
			end
			if command == "position_check" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.position_check = " .. respawn.position_check)
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.only_warnings = " .. respawn.only_warnings)
			end
			if command == "max_distance" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.max_distance = " .. respawn.max_distance)
			end
			if command == "tolerance" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.tolerance=" .. respawn.tolerance)
			end
			if command == "slay_delay" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.slay_delay = " .. respawn.slay_delay)
			end
			if command == "min_profile_size" then
				messages.info(cn, {cn}, "RESPAWN", "respawn.min_profile_size = " .. respawn.min_profile_size)
			end

			if command == "list" then
				if #respawn.profile == 0 then
					messages.info(cn, {cn}, "RESPAWN", "No respawn points recorded for map %s!", maprotation.map)
				end
				messages.info(-1, {cn}, "RESPAWN", string.format("Respawn points for map %s:", maprotation.map))
				for i,p in ipairs(respawn.profile) do
					messages.info(-1, {cn}, "RESPAWN", string.format(" x: %i y: %i z: %i", p[1], p[2], p[3]))
				end
			end
		else
			if command == "recording" then
				local recording_val = tonumber(arg)
				if respawn.recording ~= recording_val then
					if respawn.recording == 0 then
						cheater.start_recording("respawn")
						messages.info(cn, players.all(), "RESPAWN", string.format("orange<Starting profiling %s for respawn position detection...>", maprotation.map))
						if respawn.visualisation == 1 then
							respawn.send_points()
						end
					end
					if respawn.recording == 1 then
						messages.info(cn, players.all(), "RESPAWN", string.format("orange<Stopped profiling %s for respawn position detection...>", maprotation.map))
						cheater.stop_recording("respawn")
						respawn.clear_points()
					end
				else
					messages.info(cn, {cn}, "RESPAWN", "respawn.recording = " .. recording_val)
				end
				respawn.recording = recording_val
			end
			if command == "visualisation" then
				respawn.visualisation = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.visualisation = " .. respawn.visualisation)
				if respawn.visualisation == 1 then
					respawn.send_points()
				else
					respawn.clear_points()
				end
			end
			if command == "test" then
				respawn.testing = 1
				respawn.testing_errors = 0
				respawn.test(tonumber(arg))
			end
			if command == "enabled" then
				respawn.enabled = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.enabled=" .. respawn.enabled)
			end
			if command == "position_check" then
				respawn.position_check = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.position_check = " .. respawn.position_check)
			end
			if command == "only_warnings" then
				respawn.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.only_warnings = " .. respawn.only_warnings)
			end
			if command == "max_distance" then
				respawn.max_distance = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.max_distance=" .. respawn.max_distance)
			end
			if command == "tolerance" then
				respawn.tolerance = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.tolerance=" .. respawn.tolerance)
			end
			if command == "slay_delay" then
				respawn.slay_delay = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.slay_delay = " .. respawn.slay_delay)
			end
			if command == "min_profile_size" then
				respawn.min_profile_size = tonumber(arg)
				messages.info(cn, {cn}, "RESPAWN", "respawn.min_profile_size = " .. respawn.min_profile_size)
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("suicide", function(cn)
	respawn.lastdeath[cn] = server.gamemillis
	respawn.next_check[cn] = true
	if respawn.recording == 1 then
		server.spawn_player(cn)
	end
end)

server.event_handler("frag", function(targetCN, cn)
	respawn.lastdeath[targetCN] = server.gamemillis
end)

server.event_handler("spawn", function(cn)
	respawn.check_time(cn)
	respawn.last_positions[cn] = {}
	respawn.has_respawned[cn] = 1
end)

server.event_handler("connect", function(cn)
	respawn.lastdeath[cn] = 0
	respawn.level[cn] = 0
	respawn.next_check[cn] = true
	if respawn.recording == 1 and respawn.visualisation == 1 then
		respawn.send_points()
	end
	respawn.last_positions[cn] = {}
	respawn.has_respawned[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	respawn.lastdeath[cn] = 0
	respawn.level[cn] = 0
	respawn.next_check[cn] = true
	respawn.last_positions[cn] = {}
	respawn.has_respawned[cn] = 0
end)

server.event_handler("mapchange", function()
	respawn.mapchange = 1
	respawn.recording = 0
	respawn.last_positions = {}
	respawn.has_respawned = {}
	respawn.slots = {}
	cheater.stop_recording("respawn")
	for _, cn in ipairs(players.all()) do
		respawn.lastdeath[cn] = 0
		respawn.level[cn] = 0
		respawn.next_check[cn] = true
		respawn.has_respawned[cn] = 0
		respawn.last_positions[cn] = {}
	end
	respawn.load_profile()
	server.sleep(respawn.mapchange_delay, function()
		respawn.mapchange = 0
		if respawn.profile_size < respawn.min_profile_size then
			messages.warning(cn, players.admins(), "RESPAWN", string.format("The respawn point profile size (%i) is too small (%i needed)", respawn.profile_size, respawn.min_profile_size))
		end
	end)
end)

server.event_handler("intermission", function()
	respawn.mapchange = 1
end)


server.interval(respawn.check_positions_interval, respawn.check_positions)
