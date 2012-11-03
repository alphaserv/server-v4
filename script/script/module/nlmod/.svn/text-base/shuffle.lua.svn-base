function server.shuffleteams(force)
	if (server.shuffle ~= 1 and server.shuffle ~= true) and (not force) then return end
	
	local fragsorted = {}
	for ci in server.gclients() do
		cn = ci.cn
		if server.player_status(cn) ~= "spectator" then
			frags = server.player_frags(cn)
			if not fragsorted[frags] then fragsorted[frags] = {} end
			fragsorted[frags][#fragsorted[frags]] = cn
		end
	end
	local cur_step = 1
	for frags, clients in pairs(fragsorted) do
		for _, cn in pairs(clients) do
			if cur_step == 1 then
				team_ = math.random(1, 2)
				if team_ == 1 then team = "good" else team = "evil" end
				cur_step = 2
			else
				if team == "good" then team = "evil" else team = "good" end -- switch step2-player to the opposite team of the step1-player
				cur_step = 1
			end
			server.changeteam(cn, team)
		end
	end
end

server.event_handler("changingmap", server.shuffleteams)
