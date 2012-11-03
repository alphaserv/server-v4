server.signal_xstatslogin = server.create_event_signal("xstatslogin")

server.event_handler("xstatslogin", function(cn, user, access)
	if access_list[user] then
		if access_list[user] > access then
			server.log("setting " .. server.player_name(cn) .. " (" .. cn .. ")'s access to " .. access_list[user] .. " (logged in to xstats as " .. user .. ")")
			server.set_access(cn, access_list[user])
		end
	end
end)
