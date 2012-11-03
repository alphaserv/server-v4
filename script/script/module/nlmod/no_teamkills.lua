server.event_handler("damage", function(cn, ocn)
	if server.no_teamkills and server.player_team(cn) == server.player_team(ocn) then
		return -1
	end
end)
