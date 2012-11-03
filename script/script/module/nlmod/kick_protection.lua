if not server.kick_protection_time then server.kick_protection_time = 60 * 1000 end
if not server.kick_protection_add_time then server.kick_protection_add_time = 10 * 1000 end

local lastkick = {}

function server.resetkicks(cn) lastkick[cn] = nil end
server.event_handler("connect", server.resetkicks)


function server.allowkick(cn, tcn, bantime)
	if server.access(cn) >= flood_access then return true end
	if server.valid_cn(tcn) then
		if access(cn) <= access(tcn) then server.player_msg(cn, cmderr("victim got more access")); return false end
	end
	if not lastkick[cn] then lastkick[cn] = (server.kick_protection_time * -1) end
	if server.uptime < lastkick[cn] + server.kick_protection_time then
		server.player_msg(cn, cmderr("kicking too fast, wait " .. tostring(round( (((lastkick[cn] + server.kick_protection_time) - server.uptime) + server.kick_protection_add_time) / 1000 )).. " seconds"))
		if server.authedname(cn) then server.player_msg(cn, badmsg("think before you kick! your actions are being logged!")) end
		if server.valid_cn(tcn) then name = server.player_name(tcn) else name = "" end
		server.log(server.player_name(cn) .. " (" .. cn .. ")(" .. server.player_ip(cn) .. ") is trying to kick (" .. name .. " (" .. tcn .. ")) too fast!")
		return false
	else
		return true
	end
end

function server.requestedkick(cn, tcn, bantime)
	if not lastkick[cn] then lastkick[cn] = (server.kick_protection_time * -1) end
	if server.uptime < lastkick[cn] + server.kick_protection_time then
		lastkick[cn] = lastkick[cn] + server.kick_protection_add_time
	else
		lastkick[cn] = server.uptime
	end
end
