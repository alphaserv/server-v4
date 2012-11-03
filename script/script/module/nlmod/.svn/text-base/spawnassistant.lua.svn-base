local maps = {
	{map = "firstevermap", x = 0, y = 0, z = 2000}
}

server.event_handler("spawn", function(cn)
	local sid = server.player_sessionid(cn)
	server.sleep(1000, function()
		if sid == server.player_sessionid(cn) and server.player_status(cn) == "alive" then
			for _, info in pairs(maps) do
				if info.map == server.map then
					server.send_hitpush(cn, info.x, info.y, info.z)
				end
			end
		end
	end)
end)
