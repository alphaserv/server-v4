camping_max_x_dist = 90
camping_max_y_dist = 90
camping_max_z_dist = 60

local positions = {}

local function clear_pos(cn)
	positions[cn] = nil
end

local function check_camping(cn)
	if positions[cn] then
		count = #positions[cn]
		if count > 3 then
			return true, count
		else
			return false, 0
		end
	else
		return false, 0
	end
end

local function diff(new, old)
	if (not new) or (not old) then return 0 end
	diff_ = new - old
	if diff_ < 0 then diff_ = old - new end
	return diff_
end

local function is_near(cn, x, y, z)
	if positions[cn] then
		local index = #positions[cn]
		ox = positions[cn][index][1]
		oy = positions[cn][index][2]
		oz = positions[cn][index][3]
		if (diff(x, ox) < camping_max_x_dist + 1) and (diff(y, oy) < camping_max_y_dist + 1) and (diff(y, oy) < camping_max_z_dist + 1) then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function save_pos(cn, x, y, z)
	if positions[cn] then
		if is_near(cn, x, y, z) then
			local index = #positions[cn]+1
			positions[cn][index] = {}
			positions[cn][index][1] = x
			positions[cn][index][2] = y
			positions[cn][index][3] = z
		else
			clear_pos(cn)
		end
	else
		positions[cn] = {}
		positions[cn][1] = {}
		positions[cn][1][1] = x
		positions[cn][1][2] = y
		positions[cn][1][3] = z
	end
end

local function shame(cn, count)
	if count == 4 then
		local index = 1
		ox = positions[cn][index][1]
		oy = positions[cn][index][2]
		oz = positions[cn][index][3]
		local index = #positions[cn]
		x = positions[cn][index][1]
		y = positions[cn][index][2]
		z = positions[cn][index][3]
		if (diff(x, ox) < camping_max_x_dist + 1) and (diff(y, oy) < camping_max_y_dist + 1) and (diff(y, oy) < camping_max_z_dist + 1) then
			local text = badmsg("{1} is camping! ({2} camperkills)", server.player_displayname(cn), count)
			server.sleep(10, function() server.msg(text) end)
		end
	elseif count == 8 or count == 12 or count > 15 then
		local text = badmsg("{1} is camping! ({2} camperkills)", server.player_displayname(cn), count)
		server.sleep(10, function() server.msg(text) end)
	end
end

server.event_handler("frag", function(target, cn)
	if server.mastermode > 1 then return end
	x, y, z = server.player_pos(cn)
	save_pos(cn, x, y, z)
	local camping, count = check_camping(cn)
	if camping then
		shame(cn, count)
	end
end)

server.event_handler("disconnect", function(cn)
	positions[cn] = nil
end)