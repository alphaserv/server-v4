
server.event_handler("request_setmastermode", function(cn, mm)
	if hasaccess(cn, setmastermode_access) then
		local mm_allowed = false
		if mm < 0 then mm = 0
		elseif mm > 3 then mm = 3 end
		if mm == 0 then
			mastermodename = "open"
			server.reassignteams = 1
			mm_allowed = true
		elseif mm == 1 then
			mastermodename = "veto"
			if server.allow_mastermode_veto then
				server.reassignteams = 1
				mm_allowed = true
			end
		elseif mm == 2 then
			mastermodename = "locked"
			if server.allow_mastermode_locked then
				server.reassignteams = 0
				mm_allowed = true
			end
		elseif mm == 3 then
			mastermodename = "private"
			if server.allow_mastermode_private then
				server.reassignteams = 0
				mm_allowed = true
			end
		else
			mastermodename = "unknown"
		end
		if mm_allowed then
			server.mastermode = mm
			server.msg(string.format(server.set_mastermode_msg, server.player_displayname(cn), mastermodename, mm))
			server.log(string.format(" -- INFO -- %s (%i) changes mastermode to '%s'", server.player_displayname(cn), cn, mastermodename))
		else
			server.player_msg(cn, badmsg("Mastermode {1} is not enabled on this server!", mastermodename))
			server.log(string.format(" -- INFO -- %s (%i) tries to change mastermode to '%s' (failed ...)", server.player_displayname(cn), cn, mastermodename))
		end
	end
	return -1
end)

server.event_handler("disconnect", function(cn)
	if server.playercount - server.speccount <= 0 then server.mastermode = 0 end
end)

server.event_handler("spectator", function(cn, val)
	if server.mastermode == 2 and val == 1 then spectator.fspec(cn, "MASTERMODE") end
end)

