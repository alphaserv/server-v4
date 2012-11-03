server.event_handler("disconnect", function(cn)
	if server.playercount - server.speccount <= 0 then server.mastermode = 0 end
end)
