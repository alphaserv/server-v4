local last_pos = {}

local function checkpositions()
	if server.mastermode ~= 0 then return end
	for ci in server.gclients() do
		cn = ci.cn
		if server.player_status(cn) ~= "spectator" and server.paused ~= 1 and server.timeleft > 0 then
			if not last_pos[cn] then last_pos[cn] = {} end
			x, y, z = server.player_pos(cn)
			if x .. y .. z == last_pos[cn][1] then
				if last_pos[cn][2] >= 8 then
					server.spec(cn)
					server.player_msg(cn, getmsg("you have been put to spectators because of inactivity"))
					last_pos[cn] = nil
				else
					last_pos[cn][2] = last_pos[cn][2] + 1
				end
			else
				last_pos[cn][1] = x .. y .. z
				last_pos[cn][2] = 1
			end
		end
	end
end

server.interval(10000, checkpositions)

server.event_handler("connect", function(cn) last_pos[cn] = nil end)
server.event_handler("disconnect", function(cn) last_pos[cn] = nil end)
server.event_handler("spectator", function(cn) last_pos[cn] = nil end)

server.event_handler("mapchange", function() last_pos = {} end)
