if not server.max_maxclients then server.max_maxclients = 64 end

server.event_handler("spectator", function()
	server.sleep(10, function()
		if server.mastermode < 2 then
			server.maxclients = server.maxclients + 1
			if server.maxclients > server.max_maxclients then server.maxclients = server.max_maxclients end
		end
	end)
end)

server.event_handler("connect", function()
	server.sleep(10, function()
		if server.mastermode < 2 then
			server.maxclients = server.maxclients + server.speccount
			if server.maxclients > server.max_maxclients then server.maxclients = server.max_maxclients end
		end
	end)
end)

server.event_handler("disconnect", function()
	server.sleep(10, function()
		if server.mastermode < 2 then
			server.maxclients = server.maxclients + server.speccount
			if server.maxclients > server.max_maxclients then server.maxclients = server.max_maxclients end
		end
	end)
end)