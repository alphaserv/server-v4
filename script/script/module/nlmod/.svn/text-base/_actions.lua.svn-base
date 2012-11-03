server.event_handler("request_reload", function(cn)
	if not hasaccess(cn, reload_access) then return -1 end
end)

server.event_handler("request_clearbans", function(cn) -- hopmod v258: clearbans (and kickban) was moved from hardcode to script. need to exec clearbans here in order to display who cleared them.
	if not hasaccess(cn, clearbans_access) then return -1 end
	server.clear_auth_bans() -- added
	--server.msg(getmsg("{1} cleared all bans made by authed players", server.player_displayname(cn))) -- added
	server.msg(getmsg("{1} cleared all bans", server.player_displayname(cn))) -- added
	return -1 -- added
end)

server.event_handler("request_kick", function(cn) -- flood protection in ../promod/kick_protection.lua!
	if not hasaccess(cn, kick_access) then return -1 end
end)

server.event_handler("adminpriv", function(cn)
	if hasaccess(cn, admin_access) then
		return 1
	end
end)

server.event_handler("request_spectator", function(cn, ocn, val)
	if (cn == ocn and val == 1) then return end
	if (cn == ocn and server.mastermode < 2) then return end
	if not hasaccess(cn, spec_access) then return -1 end
end)

server.event_handler("request_setteam", function(cn, ocn, team)
	if cn == ocn then return end
	if not hasaccess(cn, setteam_access) then return -1 end
end)

server.event_handler("request_recorddemo", function(cn)
	if not hasaccess(cn, recorddemo_access) then return -1 end
end)

server.event_handler("request_stopdemo", function(cn)
	if not hasaccess(cn, stopdemo_access) then return -1 end
end)

server.event_handler("request_cleardemos", function(cn)
	if not hasaccess(cn, cleardemos_access) then return -1 end
end)

server.event_handler("request_listdemos", function(cn)
	if not hasaccess(cn, listdemos_access) then return -1 end
end)

server.event_handler("request_getdemo", function(cn)
	if not hasaccess(cn, getdemo_access) then return -1 end
end)

server.event_handler("request_getmap", function(cn)
	if not hasaccess(cn, getmap_access) then return -1 end
end)

server.event_handler("request_newmap", function(cn)
	if not hasaccess(cn, newmap_access) then return -1 end
end)

--[[
server.event_handler("request_addbot", function(cn)
	if not hasaccess(cn, addbot_access) then return -1 end
end)
]]

server.event_handler("request_delbot", function(cn)
	if not hasaccess(cn, delbot_access) then return -1 end
end)

server.event_handler("request_setbotlimit", function(cn)
	if not hasaccess(cn, setbotlimit_access) then return -1 end
end)

server.event_handler("request_setbotbalance", function(cn)
	if not hasaccess(cn, setbotbalance_access) then return -1 end
end)

server.event_handler("request_auth", function(cn)
	return
end)

server.event_handler("request_pausegame", function(cn)
	if not hasaccess(cn, pausegame_access) then return -1 end
end)

server.event_handler("request_remip", function(cn)
	if not hasaccess(cn, remip_access) then return -1 end
end)

server.event_handler("check_flooding", function(cn, action, time)
	if server.access(cn) == flood_access or server.access(cn) > flood_access then return -1
	else
		if time == 1 then server.player_msg(cn, badmsg("you have to wait {1} second before you can be {2} again!", tostring(time), action)) else server.player_msg(cn, badmsg("you have to wait {1} seconds before you can be {2} again!", tostring(time), action)) end
	end
end)

server.event_handler("mapvote", function(cn, map, mode)
	if (access(cn) == master_access or access(cn) > master_access) and server.mastermode > 0 then server.changemap(map, mode) end
end)
