local pos = {}

local intermission = false

local function diff(new, old)
	if (not new) or (not old) then return 0 end
	diff_ = new - old
	if diff_ < 0 then diff_ = old - new end
	return diff_
end

function getdistance(lx, ly, x, y)
	xdiff = diff(x, lx)
	ydiff = diff(y, ly)
	return math.sqrt((xdiff * xdiff) + (ydiff * ydiff))
end

local function onebigstep(dist1, dist2, dist3)
	if dist1 > (dist2 * 1.25) or dist1 > (dist3 * 1.25) then return true
	elseif dist2 > (dist1 * 1.25) or dist2 > (dist3 * 1.25) then return true
	elseif dist3 > (dist1 * 1.25) or dist3 > (dist2 * 1.25) then return true
	else return false end
end

local function checkspeed(cn, speed)
	pos[cn][8] = pos[cn][8] or 0
	pos[cn][9] = pos[cn][9] or 0
	if speed >= 175 then
		pos[cn][9] = pos[cn][9] + 1
		if pos[cn][9] >= 5 then
			server.log("SPEED: " .. server.player_name(cn) .. " (" .. cn .. ") seems to be moving too fast! player avg: " .. speed .. " / ping: " .. server.player_ping(cn))
			pos[cn][9] = 0
			pos[cn][8] = 0
		end
	else
		pos[cn][8] = pos[cn][8] + 1
		if pos[cn][8] >= 5 then
			pos[cn][8] = 0
			pos[cn][9] = 0
		end
	end
end

local step = 1

server.interval(500, function()
	if intermission then return end
	for ci in server.gclients() do
		cn = ci.cn
		if server.player_status(cn) ~= "spectator" then
			pos[cn] = pos[cn] or {}
			x, y, z = server.player_pos(cn)
			pos[cn][11] = pos[cn][21]
			pos[cn][12] = pos[cn][22]
			pos[cn][13] = pos[cn][23]
			pos[cn][21] = pos[cn][31]
			pos[cn][22] = pos[cn][32]
			pos[cn][23] = pos[cn][33]
			pos[cn][31] = pos[cn][41]
			pos[cn][32] = pos[cn][42]
			pos[cn][33] = pos[cn][43]
			pos[cn][41] = x
			pos[cn][42] = y
			pos[cn][43] = z
			if step >= 4 and pos[cn][11] and pos[cn][21] and pos[cn][31] and pos[cn][41] then
				if diff(z, pos[cn][33]) < 20 then
					local dist = 0
					local dist1 = getdistance(pos[cn][11], pos[cn][12], pos[cn][21], pos[cn][22])
					local dist2 = getdistance(pos[cn][21], pos[cn][22], pos[cn][31], pos[cn][32])
					local dist3 = getdistance(pos[cn][31], pos[cn][32], x, y)
					dist = dist + dist1
					dist = dist + dist2
					dist = dist + dist3
					local wholedist = getdistance(pos[cn][11], pos[cn][12], x, y)
					if wholedist > ((dist / 5) * 4) and wholedist <= dist and not onebigstep(dist1, dist2, dist3) then -- check if player ran in one line or not (saves our player of being kicked for lagging)
						pos[cn][4] = pos[cn][4] or 0
						pos[cn][4] = pos[cn][4] + 1
						pos[cn][5] = pos[cn][5] or 0
						pos[cn][5] = pos[cn][5] + (dist / 2)
						checkspeed(cn, dist/2)
					end
				end
				step = 1
			else
				step = step + 1
			end
		end
	end
end)

server.event_handler("spawn", function(cn)
	if not pos[cn] then pos[cn] = {} end
end)

server.event_handler("mapchange", function()
	pos = {}
	intermission = false
end)

server.event_handler("connect", function(cn) pos[cn] = {} end)
server.event_handler("disconnect", function(cn) pos[cn] = {} end)
server.event_handler("spectator", function(cn) pos[cn] = {} end)
server.event_handler("spawn", function(cn)
	pos[cn] = pos[cn] or {}
end)

server.event_handler("intermission", function()
	local avg = 0
	local avg_c = 0
	local lowest = 1000000
	local most = 0
	pos = pos or {}
	for ci in server.gclients() do
		cn = ci.cn
		if server.player_status(cn) ~= "spectator" then
			if pos[cn] then
				pos[cn][5] = pos[cn][5] or 0
				pos[cn][4] = pos[cn][4] or 0
				avg = avg + pos[cn][5]
				avg_c = avg_c + pos[cn][4]
				if lowest > (pos[cn][5] / pos[cn][4]) then lowest = (pos[cn][5] / pos[cn][4]) end
				if most < (pos[cn][5] / pos[cn][4]) then most = (pos[cn][5] / pos[cn][4]) end
			end
		end
	end
	server.log("SPEED AVG: (/s) " .. (avg / avg_c) .. " / LOWEST: " .. lowest .. " / MOST: " .. most)
	intermission = true
end)

function server.speed(cn)
	pos[cn] = pos[cn] or {}
	pos[cn][5] = pos[cn][5] or 0
	pos[cn][4] = pos[cn][4] or 0
	return (pos[cn][5] / pos[cn][4])
end
