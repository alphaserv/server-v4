alpha.settings.init_setting("auto_master", true, "bool", "let the first one to connect become master automatically.\nThis may attract noobs kicking everyone.")

server.event_handler("connect", function (cn)
	if #players.all() == 1 and (tonumber(alpha.settings:get("auto_master")) == 1) then
		server.sleep(1000, function()
			acl.tempgroup(cn, "master")
		end)
	end
	event("OnConnect", cn)
end)
