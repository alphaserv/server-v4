--[[
	script/module/nl_mod/nl_intercheck.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		26-Jun-2012
	Last Modified:	26-Jun-2012
	License:		GPL3

	Funktionen:
		* Checks for a moving player while intermission
		* Checks for scoring while intermission
		* Checks for taking the flag while intermission
		* Checks for fragging while intermission

]]



--[[
		API
]]

intercheck = {}
intercheck.enabled = 0
intercheck.only_warnings = 0
intercheck.delay = 500
intercheck.is_intermission = 0
intercheck.position_check_interval = 2500
intercheck.last_pos = {}
intercheck.prevent = {}

function intercheck.execute_check(cn, reason)
	if intercheck.enabled == 0 or intercheck.is_intermission == 0 then return end
	if intercheck.only_warnings == 1 then
		messages.warning(-1, players.admins(), "INTERCHECK", string.format("red<%s (%i) is %s while intermission!", server.player_name(cn), cn, reason))
	else
		messages.error(-1, players.admins(), "INTERCHECK", string.format("red<Automatically kicked %s (%i) because of %s while intermission>", server.player_name(cn), cn, reason))
		cheater.autokick(cn, "Server", string.format("%s while intermission", reason))
	end
end

function intercheck.position_check()
	if intercheck.enabled == 0 or intercheck.is_intermission == 0 then return end
	for _, cn in ipairs(players.all()) do
		if intercheck.prevent[cn] == nil then
			local x, y, z = server.player_pos(cn)
			if intercheck.last_pos[cn] == nil then
				if
					server.player_status_code(cn) ~= server.SPECTATOR and
					x > -10000000 and x < 10000000 and
					y > -10000000 and y < 10000000 and
					z > -10000000 and z < 10000000
				then
					intercheck.last_pos[cn] = { x, y, z }
				end
			else
				if
					x ~= intercheck.last_pos[cn][1] and
					y ~= intercheck.last_pos[cn][2] and
					z ~= intercheck.last_pos[cn][3]
				then
					if intercheck.only_warnings == 1 then
						messages.warning(-1, players.admins(), "INTERCHECK", string.format("red<%s (%i) is moving while intermission!", server.player_name(cn), cn))
					else
						messages.error(-1, players.admins(), "INTERCHECK", string.format("red<Automatically kicked %s (%i) because of moving while intermission>", server.player_name(cn), cn))
						messages.debug(-1, players.admins(), "INTERCHECK", string.format("%s (%i) --- %i %i %i --- %i %i %i", server.player_name(cn), cn, x, y, z, intercheck.last_pos[cn][1], intercheck.last_pos[cn][2], intercheck.last_pos[cn][3]))
						cheater.autokick(cn, "Server", "Moving while intermission")
					end
				end
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	intercheck.last_pos[cn] = nil
	intercheck.prevent[cn] = 1
end)

server.event_handler("disconnect", function(cn)
	intercheck.last_pos[cn] = nil
end)

server.event_handler("scoreflag", function(cn)
	intercheck.execute_check(cn, "scoring")
end)

server.event_handler("takeflag", function(cn)
	intercheck.execute_check(cn, "taking the flag")
end)

server.event_handler("frag", function(target_cn, actor_cn)
	intercheck.execute_check(actor_cn, "fragging")
end)

server.event_handler("intermission", function()
	intercheck.prevent = {}
	server.sleep(intercheck.delay, function()
		intercheck.is_intermission = 1
	end)
end)

server.event_handler("mapchange", function()
	intercheck.is_intermission = 0
	intercheck.last_pos = {}
	intercheck.prevent = {}
end)

server.event_handler("allow_rename", function(cn, text)
	intercheck.prevent[cn] = 1
end)

server.event_handler("request_spectator", function(cn, ocn, val)
	intercheck.prevent[cn] = 1
	intercheck.prevent[ocn] = 1
end)


server.interval(intercheck.position_check_interval, intercheck.position_check)

