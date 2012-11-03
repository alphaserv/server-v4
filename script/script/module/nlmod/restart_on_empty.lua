server.signal_restarting = server.create_event_signal("restarting")

server.event_handler("disconnect", function(cn)
	if server.playercount <= 0 then
		server.log("server is empty! restarting in 1 minute, if nobody connects ..")
		server.sleep(60 * 1000, function()
			if server.playercount <= 0 and server.uptime > 86400000 then
				server.signal_restarting()
				server.restart_now()
			end
		end)
	end
end)
