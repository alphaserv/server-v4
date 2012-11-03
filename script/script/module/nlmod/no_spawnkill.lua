local spawned = {}
server.spawnkill_time = server.spawnkill_time or 1000

server.event_handler("allowedconnect", function(cn) spawned[cn] = nil end)

server.event_handler("spawn", function(cn)
	spawned[cn] = server.uptime
end)

server.event_handler("damage", function(cn, acn)
	if server.no_spawnkill and (((spawned[cn] or -3000) + server.spawnkill_time) > server.uptime) then
		server.player_msg(acn, badmsg("{1} just respawned, shot ignored!", server.player_displayname(cn)))
		return -1
	end
end)
