server.event_handler("sendcurrentmap", function(cn)
	if not authconnecting.nosendinitmap(cn) then server.sendinitmap(cn) end
end)

server.event_handler("sendclients", function(cn)
	if not authconnecting.nosendclients(cn) then server.sendclients(cn) end
end)

server.event_handler("sendinitclient", function(cn)
	if not authconnecting.nosendinitclient(cn) then
		for ci in server.gclients() do
			if ci.cn ~= cn and server.isvisible(ci.cn) then server.sendinitclient(ci.cn, cn) end
		end
		server.signal_connect(cn)
	end
end)
