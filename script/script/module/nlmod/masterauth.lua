auth.directory.server{
    id = "MASTER",
    hostname = "sauerbraten.org",
    port = 28787
}

auth.directory.domain{
    server = "MASTER",
    id = ""
}

function server.set_authedname(cn, text)
	server.player_pvar(cn, "masterauth.authedname", text)
end

function server.authedname(cn)
	return server.player_pvar(cn, "masterauth.authedname")
end

function server.unset_authedname(cn)
	server.player_unsetpvar(cn, "masterauth.authedname")
end

auth.listener("", function(cn, user_id, domain, status)
	local name = server.player_name(cn)

	if status ~= auth.request_status.SUCCESS then
		return
	else
		if user_id == "assk" or user_id == "drakas" then
			server.msg(getmsg("{1} failed to get master as '{2}'", name, user_id))
			server.log(string.format(" -- AUTH-BAN -- %s (%i) failed to get master as '%s'", name, cn, user_id))
			return
		end
	end

	if server.setmaster(cn) then
		server.msg(getmsg("{1} claimed master as '{2}'", name, user_id))
		server.log(string.format(" -- INFO -- %s (%i) claimed master as '%s'", name, cn, user_id))
		-- if xbotlog then xbotlog(string.format("%s (%i) claimed master as '%s'", name, cn, user_id)) end
		-- 	server.set_authedname(cn, user_id)
		-- end
	end
	
--[[
	if server.no_masterauth then
		server.player_msg(cn, getmsg("auth is disabled, if you want to use your authkey here, please tell us in IRC ({1})!", "#xstats @ irc.gamesurge.net"))
		return
	end
	
	local playerlist = ""
	local admin_count = 0
	for a in server.gclients() do
		if access(a.cn) > master_access then
			admin_count = admin_count + 1
			if playerlist == "" then
				playerlist = server.color1 .. server.player_displayname(a.cn)
			else
				playerlist = playerlist .. server.color2 .. ", " .. server.color1 .. server.player_displayname(a.cn)
			end
		end
	end
	if playerlist ~= "" then
		local admin_text
		if admin_count == 1 then
			admin_text = "there is already an admin: "
		else
			admin_text = "there are already admins: "
		end
		server.player_msg(cn, getmsg("auth request ignored, " .. admin_text) .. playerlist)
	else
]]
end)

server.event_handler("privilege", function(cn, old, new)
	if new <= 0 then
		if server.authedname(cn) then server.unset_authedname(cn) end
	end
end)
