party = false

nodamage = false

gun = 5

local function party_loop()
	if party then
		--server.msg("\n\f0L \f1E \f2T \f0' \f5S   \f0P \f1A\f2 R\f3 T\f6 Y\f0 !\n")
		for a in server.gclients() do
			cn = a.cn
			server.send_z_hitpush(cn, 100, 200, gun)
		end
		server.sleep(200, function()
			for a in server.gclients() do
				cn = a.cn
				server.send_z_hitpush(cn, 100, -200, gun)
			end
		end)
		server.sleep(500, function()
			party_loop()
		end)
	end
end

function start_party()
	party = true
	party_loop()
end

function stop_party()
	party = false
	--server.msg("\n\f4THE PARTY IS OVER!\n")
end

-----------------------------------------------------------

local function do_gravitystep(cn, val)
	server.send_z_hitpush(cn, 100, val)
	server.sleep(100, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(150, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(200, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(250, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(300, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(350, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(400, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(450, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(500, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(550, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(600, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(650, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(700, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(750, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(800, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(850, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(900, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(950, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1000, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1050, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1100, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1150, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1200, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1250, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1300, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1350, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1400, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1450, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1500, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1550, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1600, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1650, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1700, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1750, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1800, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1850, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1900, function() server.send_z_hitpush(cn, 100, val) end, gun)
	server.sleep(1950, function() server.send_z_hitpush(cn, 100, val) end, gun)
end

local function gravity_loop(cn)
	val = server.player_pvar(cn, "doing_gravity")
	if val then
		do_gravitystep(cn, val)
		server.sleep(2000, function()
			gravity_loop(cn)
		end)
	end
end

function start_gravity(cn, val)
	if server.player_pvar(cn, "doing_gravity") then
		server.player_pvar(cn, "doing_gravity", val)
		server.player_unsetpvar(cn, "doing_fly")
		server.player_unsetpvar(cn, "doing_hold")
		server.player_msg(cn, "gravity \f0set to " .. tostring(val))
	else
		server.player_pvar(cn, "doing_gravity", val)
		server.player_unsetpvar(cn, "doing_fly")
		server.player_unsetpvar(cn, "doing_hold")
		server.player_msg(cn, "gravity \f0activated \f7(" .. tostring(val) .. ")")
		gravity_loop(cn)
	end
end

function stop_gravity(cn)
	server.player_unsetpvar(cn, "doing_gravity")
	server.player_msg(cn, "gravity \f3deactivated")
end

-----------------------------------------------------------

local function fly_loop(cn)
	if server.player_pvar(cn, "doing_fly") then
		server.send_z_hitpush(cn, 100, 1000, gun)
		server.sleep(1000, function()
			fly_loop(cn)
		end)
	end
end

function start_fly(cn)
	server.player_pvar(cn, "doing_fly", true)
	server.player_unsetpvar(cn, "doing_gravity")
	server.player_unsetpvar(cn, "doing_hold")
	fly_loop(cn)
end

function stop_fly(cn)
	server.player_unsetpvar(cn, "doing_fly")
end

-----------------------------------------------------------

lagging = false

local function lag_loop()
	if lagging then
		--server.msg("\f0L A A A A A A A A A G ! !")
		for a in server.gclients() do
			cn = a.cn
			server.send_y_hitpush(cn, 100, 100, gun)
		end
		server.sleep(100, function()
			for a in server.gclients() do
				cn = a.cn
				server.send_y_hitpush(cn, 100, -200, gun)
				server.send_x_hitpush(cn, 100, 100, gun)
			end
		end)
		server.sleep(500, function()
			for a in server.gclients() do
				cn = a.cn
				server.send_y_hitpush(cn, 100, 100, gun)
				server.send_x_hitpush(cn, 100, -100, gun)
			end
		end)
		server.sleep(700, function()
			lag_loop()
		end)
	end
end

function start_lag()
	if not lagging then
		lagging = true
		lag_loop()
	end
end

function stop_lag()
	--server.msg("\f0phew, it is over :)")
	lagging = false
end

-----------------------------------------------------------

local function hide_player(cn)
	server.send_z_hitpush(cn, 1000, 10000)
	server.sleep(2000, function()
		server.send_z_hitpush(cn, 1000, -10000, gun)
	end)
end

-----------------------------------------------------------

local function down_player(cn)
	server.send_z_hitpush(cn, 1000, -1000, gun)
end

local function up_player(cn)
	server.send_z_hitpush(cn, 1000, 1000, gun)
end

-----------------------------------------------------------

local function walk_player(cn, dir, power)
	if dir == "x" then server.send_x_hitpush(cn, 1000, power, gun)
	elseif dir == "-x" then server.send_x_hitpush(cn, 1000, (power * -1), gun)
	elseif dir == "y" then server.send_y_hitpush(cn, 1000, power, gun)
	elseif dir == "-y" then server.send_y_hitpush(cn, 1000, (power * -1), gun)
	elseif dir == "z" then server.send_z_hitpush(cn, 1000, power, gun)
	elseif dir == "-z" then server.send_z_hitpush(cn, 1000, (power * -1), gun)
	end
end

-----------------------------------------------------------

local function chainsaw_on(cn, power)
	server.player_pvar(cn, "chainsaw_jump", power)
	server.player_msg(cn, "chainsaw jump \f0activated \f7(" .. tostring(power) .. ")")
end

local function chainsaw_off(cn)
	server.player_unsetpvar(cn, "chainsaw_jump")
	server.player_msg(cn, "chainsaw jump \f3deactivated")
end

server.event_handler("chainsaw", function(cn, x, y, z, atm_gun)
	if atm_gun == 0 then
		power = server.player_pvar(cn, "chainsaw_jump")
		if power then
			server.send_x_hitpush(cn, power, x*-1, gun)
			server.send_y_hitpush(cn, power, y*-1, gun)
			server.send_z_hitpush(cn, power*1.5, z, gun)
		else
			ocn = server.player_pvar(cn, "remote_cn")
			if ocn then
				power = server.player_pvar(cn, "remote_power")
				if power then
					server.send_x_hitpush(ocn, power, x*-1, gun)
					server.send_y_hitpush(ocn, power, y*-1, gun)
					server.send_z_hitpush(ocn, power*1.5, z*-1, gun)
					if server.player_pvar(cn, "remote_follow") then
						server.send_x_hitpush(cn, power, x*-1, gun)
						server.send_y_hitpush(cn, power, y*-1, gun)
						server.send_z_hitpush(cn, power*1.5, z*-1, gun)
					end
				end
			end
		end
	end
end)

-----------------------------------------------------------

local function hold_loop(cn, old_z, times_lower)
	if server.player_pvar(cn, "doing_hold") then
		x, y, z = server.player_pos(cn)
		if old_z == "first" then
			hold_loop(cn, z, times_lower)
		else
			if old_z > z then -- player lost height
				times_lower = times_lower + 1
				server.send_z_hitpush(cn, 200, times_lower * 40, gun)
				server.player_msg(cn, tostring(times_lower * 40))
			else
				times_lower = times_lower - 1
			end
			server.sleep(500, function() hold_loop(cn, z, times_lower) end)
		end
	end
end

function start_hold(cn)
	times_lower = 0
	server.player_pvar(cn, "doing_hold", true)
	server.player_unsetpvar(cn, "doing_gravity")
	server.player_unsetpvar(cn, "doing_fly")
	server.player_msg(cn, "hold position \f0enabled")
	hold_loop(cn, "first", times_lower)
end

function stop_hold(cn)
	server.player_unsetpvar(cn, "doing_hold")
	server.player_msg(cn, "hold position \f3disabled")
end

-----------------------------------------------------------

local function speed_loop(cn, old_x, old_y)
	local speed = server.player_pvar(cn, "doing_speed")
	if speed then
		x, y, z = server.player_pos(cn)
		if old_x == "" and old_y == "" then
			speed_loop(cn, x, y)
		else
			x_dif = (x - old_x)
			y_dif = (y - old_y)
			--[[
			if x_dif < 0 then
				x_push = (speed - (speed * 2)) + x_dif
			else
				x_push = speed + x_dif
			end
			if y_dif < 0 then
				y_push = (speed - (speed * 2)) + y_dif
			else
				y_push = speed + y_dif
			end
			]]
			if (x_dif < (speed * 4)) and (x_dif > (speed * 1.2)) or (x_dif > (speed * -4)) and (x_dif < (speed * -1.2)) then
				server.send_x_hitpush(cn, 50, x_dif * speed, gun)
			end
			if (y_dif < (speed * 4)) and (y_dif > (speed * 1.2)) or (y_dif > (speed * -4)) and (y_dif < (speed * -1.2)) then
				server.send_y_hitpush(cn, 50, y_dif * speed, gun)
			end
			server.sleep(500, function() speed_loop(cn, x, y) end)
		end
	end
end

function start_speed(cn, speed)
	server.player_pvar(cn, "doing_speed", tonumber(speed))
	server.player_msg(cn, "speed \f0enabled")
	speed_loop(cn, "", "")
end

function stop_speed(cn)
	server.player_unsetpvar(cn, "doing_speed")
	server.player_msg(cn, "speed \f3disabled")
end

-----------------------------------------------------------

function check_remote(cn, ocn, power, follow)
	if not ocn then
		server.player_msg(cn, "Error: \f3a cn is missing.")
	elseif ocn == "-1" then
		server.player_unsetpvar(cn, "remote_cn")
		server.player_unsetpvar(cn, "remote_power")
		server.player_unsetpvar(cn, "remote_follow")
		server.player_msg(cn, "remote \f3disabled")
	else
		if not power then power = 100 else power = tonumber(power) end
		ocn = tonumber(ocn)
		server.player_pvar(cn, "remote_cn", ocn)
		server.player_pvar(cn, "remote_power", power)
		if follow == "1" then server.player_pvar(cn, "remote_follow", true); follow = "\f7follow \f0on\f7" else server.player_unsetpvar(cn, "remote_follow"); follow = "\f7follow \f3off\f7" end
		server.player_msg(cn, "remote \f0enabled\f7 (" .. server.player_displayname(ocn) .. " @ power " .. power .. ", " .. follow .. ")")
	end
end

-----------------------------------------------------------

server.event_handler("damage", function()
	if nodamage then return -1 end
end)

-----------------------------------------------------------

local function pos_loop(cn, ocn)
	if server.player_pvar(cn, "posloop") == ocn then
		local x, y, z = server.player_pos(cn)
		local ox, oy, oz = server.player_pos(ocn)
		server.player_msg(cn, server.player_displayname(cn) .. "\f7 -> \f3" .. x .. " \f7x\f3 " .. y .. " \f7x\f3 " .. z .. " \f7 // " .. server.player_displayname(cn) .. "\f7 -> \f3" .. ox .. " \f7x\f3 " .. oy .. " \f7x\f3 " .. oz)
		server.sleep(500, function() pos_loop(cn, ocn) end)
	end
end

-----------------------------------------------------------

radar_max_dist = 300

local function diff(new, old, minus_allowed)
	if (not new) or (not old) then return 0 end
	diff_ = new - old
	if (not minus_allowed) and diff_ < 0 then diff_ = old - new end
	return diff_
end

local function is_near(cn, ocn)
	local x, y, z = server.player_pos(cn)
	local ox, oy, oz = server.player_pos(ocn)
	if (diff(x, ox) < radar_max_dist + 1) and (diff(y, oy) < radar_max_dist + 1) and (diff(y, oy) < radar_max_dist + 1) then
		return true
	else
		return false
	end
end

local function addmsg(cn, ocn, msg)
	local x, y, z = server.player_pos(cn)
	local ox, oy, oz = server.player_pos(ocn)
	x_diff = diff(x, ox, true)
	y_diff = diff(y, oy, true)
	z_diff = diff(z, oz, true)
	if msg == "" then
		msg = "currently near players: \f3[\f7" .. server.player_displayname(ocn) .. " ( " .. x_diff .. " | " .. y_diff .. " | " .. z_diff .. ")\f3]"
	else
		msg = msg .. " \f3[\f7" .. server.player_displayname(ocn) .. " ( " .. x_diff .. " | " .. y_diff .. " | " .. z_diff .. ")\f3]"
	end
	return msg
end

function radar_loop(cn)
	if server.player_pvar(cn, "radar") then
		local msg = ""
		for a in server.gclients() do
			ocn = a.cn
			if ocn ~= cn and server.player_status(ocn) == "alive" then
				if is_near(cn, ocn) then
					msg = addmsg(cn, ocn, msg)
				end
			end
		end
		if msg ~= "" then
			server.player_msg(cn, msg)
		end
		server.sleep(1000, function() radar_loop(cn) end)
	end
end

function start_radar(cn)
	if not server.player_pvar(cn, "radar") then
		server.player_msg(cn, "radar \f0enabled\f7")
		server.player_pvar(cn, "radar", true)
		radar_loop(cn)
	else
		server.player_msg(cn, "radar is already enabled")
	end
end

function stop_radar(cn)
	if server.player_pvar(cn, "radar") then
		server.player_unsetpvar(cn, "radar")
		server.player_msg(cn, "radar \f3disabled")
	else
		server.player_msg(cn, "radar not enabled")
	end
end

-----------------------------------------------------------

local function checkcommand(cn, cmd, arg1, arg2, arg3, arg4, arg5)
	if cmd == "party" then
		if arg1 == "1" then start_party() else stop_party() end
	elseif cmd == "gravity" then
		if tonumber(arg1) > 0 then start_gravity(cn, tonumber(arg1)) else stop_gravity(cn) end
	elseif cmd == "fly" then
		if arg1 == "1" then start_fly(cn) else stop_fly(cn) end
	elseif cmd == "lag" then
		if arg1 == "1" then start_lag() else stop_lag() end
	elseif cmd == "hide" then
		hide_player(cn)
	elseif cmd == "down" then
		down_player(cn)
	elseif cmd == "up" then
		up_player(cn)
	elseif cmd == "walk" then
		walk_player(cn, arg1, tonumber(arg2))
	elseif cmd == "chainsaw" then
		if arg1 == "0" then chainsaw_off(cn) else chainsaw_on(cn, tonumber(arg1)) end
	elseif cmd == "gun" then
		gun = tonumber(arg1)
		server.player_msg(cn, "hitpush gun changed to \f0" .. tostring(gun))
	elseif cmd == "remote" then
		check_remote(cn, arg1, arg2, arg3)
	elseif cmd == "nodamage" then
		if arg1 == "1" then
			nodamage = true
			server.player_msg(cn, "nodamage \f0enabled")
		else
			nodamage = false
			server.player_msg(cn, "nodamage \f3disabled")
		end
	elseif cmd == "pos" then
		if server.valid_cn(arg1) then
			arg1 = tonumber(arg1)
			cn = tonumber(cn)
			server.player_pvar(cn, "posloop", arg1)
			pos_loop(cn, arg1)
		elseif arg1 == "-1" then
			server.player_unsetpvar(cn, "posloop")
			server.player_msg(cn, "position \f3disabled")
		end
	elseif cmd == "radar" then
		if arg1 == "1" then
			start_radar(cn)
		else
			stop_radar(cn)
		end
	end
end


function server.playercmd_cheat(cn, arg0, arg1, arg2, arg3, arg4, arg5)
	if server.player_priv(cn) ~= "admin" then
		server.player_msg(cn, "\f3Command not found.")
		return
	else
		checkcommand(cn, arg0, arg1, arg2, arg3, arg4, arg5)
	end
end


function server.playercmd_lethimcheat(cn, ocn, arg0, arg1, arg2, arg3, arg4, arg5)
	if server.player_priv(cn) ~= "admin" then
		server.player_msg(cn, "\f3Command not found.")
		return
	else
		checkcommand(ocn, arg0, arg1, arg2, arg3, arg4, arg5)
	end
end


function server.playercmd_globalcheat(cn, arg0, arg1, arg2, arg3, arg4, arg5)
	if server.player_priv(cn) ~= "admin" then
		server.player_msg(cn, "\f3Command not found.")
		return
	else
		for a in server.gclients() do
			checkcommand(a.cn, arg0, arg1, arg2, arg3, arg4, arg5)
		end
	end
end
