playervars.set_default("editmuted", 1)


local function is_editmuted(cn)
	if tonumber(playervars.get(cn, "editmuted")) == tonumber(1) then
		return true
	end
	return false
end


server.event_handler("edit", function (cn)
	if is_editmuted(cn) then
		local sid = server.player_sessionid(cn)
		server.spec(cn)
		messages.warning("editmute", {cn}, config.get("editmute:no_edit"), true)
		server.sleep(3000, function()
			for i, cn_ in pairs(players.all()) do
				if sid == server.player_sessionid(cn) then
					server.unspec(cn)
				end
			end
		end)
	end	
end)

cmd.command_function("editmute", function(cn, to_cn, on)
	if not server.valid_cn(to_cn) then
		return false, config.get("usage:editmute")
	end
	local on_ = 1
	if tonumber(on) == tonumber(1) then
		on_ = 1
	else
		on_ = 0
	end
	on_ = tonumber(on_)
	playervars.set(to_cn, "editmuted", on_)
	messages.info("editmute", players.all(), string.format(config.get("editmute:set"), to_cn, on_), false)
	server.unspec(to_cn)
end, priv.MASTER)
