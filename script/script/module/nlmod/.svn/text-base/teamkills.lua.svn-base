server.teamkill_limit = server.teamkill_limit or 5
server.teamkill_bantime = server.teamkill_bantime or (30*60)

server.event_handler("teamkill", function(cn, victim)
	server.sleep(10, function()
		local actor_teamkills = server.player_teamkills(cn)

		if actor_teamkills == 1 then server.player_msg(cn, badmsg("WARNING: {1}", "this server has a teamkill limit, therefore you must pay attention when you shoot in order to stay on the server!")) end

		if actor_teamkills == server.teamkill_limit-1 then
			server.msg(badmsg("IMPORTANT INFORMATION ({1}): {2}", server.player_displayname(cn), "Watch your shot, one more teamkill and you will be kicked immediately!"))
		else
			server.msg(badmsg("{1} did {2} teamkills!", server.player_displayname(cn), actor_teamkills))
		end

		if actor_teamkills > server.teamkill_limit or actor_teamkills == server.teamkill_limit then
			server.kick(cn, server.teamkill_bantime, -1, "teamkilling")
		end
	end)
end)
