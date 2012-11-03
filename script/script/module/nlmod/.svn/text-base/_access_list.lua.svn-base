if not server.user_file then server.user_file = "script/module/nlmod/_USERS.lua" end

function server.get_user_access(user)
	if access_list[user] then
		return access_list[user]
	else
		return false
	end
end

function server.give_user_access(cn, name)
	access_ = server.get_user_access(name)
	if access_ then
		if access_ > server.access(cn) then
			server.set_access(cn, access_)
			server.player_msg(cn, getmsg("your access has been set to {1}", access_))
			server.log(string.format("%s playing as %s(%i) used auth to set access (to %s)", name, server.player_name(cn), cn, tostring(access_)))
			if xbotlog then xbotlog(name .. " (currently '" .. server.player_name(cn) .. "' (" .. cn .. ")) used auth to set access to " .. access_) end
		end
	else
		server.log_error("unknown user '" .. name .. "' (access)")
		server.player_msg(cn, cmderr("unknown user '" .. name .. "'"))
	end
end

access_list = {}
dofile(server.user_file)
