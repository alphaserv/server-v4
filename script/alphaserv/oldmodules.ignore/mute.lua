


--create defaults and make them based on the player's ip
playervars.set_default("muted", false, "ipvar")
playervars.set_default("unmuted", false, "backup")
playervars.set_default("muted_from", 0, "ipvar")
playervars.set_default("muted_for", 0, "ipvar")

server.mute = function (cn, mute_time, reason, by)
	mute_time = tonumber(mute_time or config.get("mute:default_time"))
	playervars.set(cn, "muted_from", server.uptime)
	playervars.set(cn, "muted_for", mute_time)
	server.sleep(1, function()
		playervars.set(cn, "muted", true)
	end)
	if not by or not server.valid_cn(by) then
		by = "unknown"
	else
		by = "name<"..by..">"
	end
	if not reason then
		messages.info("mute", players.all(), string.format(config.get("mute:mute"), cn, "",by), false)
	else
		messages.info("mute", players.all(), string.format(config.get("mute:mute"), cn, "because of orange<"..reason.."> ",by), false)
	end
	local ip = server.player_ip(cn)
	server.sleep(mute_time, function()
		for i, cn in pairs(players.all()) do
			if server.player_ip(cn) == ip then
				server.unmute(cn)
			end
        end
	end)
end

--server.event_handler("flood_mute", server.mute) --not implemented yet

server.unmute = function (cn, by)
	playervars.set(cn, "muted", false)
	playervars.set(cn, "unmuted", true)
	if not by or not server.valid_cn(by) then
		by = "unknown"
	else
		by = "name<"..by..">"
	end
	messages.info("mute", players.all(), string.format(config.get("mute:unmute"), cn, by), false)
end

server.is_muted = function (cn)
	return playervars.get(cn, "muted")
end

server.check_mute = function(cn, text)

	if server.is_muted(cn) then
		messages.info("mute", players.all(), config.get("mute:blocked"), false)
		local muted_until = (playervars.get(cn, "muted_from") + playervars.get(cn, "muted_for"))
		local still = (muted_until - server.uptime)/1000
		if still < 1 then
			--something got wrong
			server.unmute(cn)
		end
		messages.info("mute", players.all(), string.format(config.get("mute:muted_for"), still), false)
		return -1
	elseif server.mute_spectators == true and not playervars.get(cn, "unmuted") then
		messages.warning("mute", {cn}, config.get("mute:specs_muted"), true)
		return -1
	elseif (db.isreserved_name(cn) or db.isreservedclan(cn)) and not (db.loggedin[server.player_name(cn)..server.player_sessionid(cn)]) then
		messages.warning("mute", {cn}, config.get("mute:not_authed"), true)
		return -1
	else
		return 1
	end
end

server.event_handler("text", server.check_mute)
server.event_handler("sayteam", server.check_mute)
server.event_handler("mapvote", server.check_mute)
server.event_handler("rename", server.check_mute)
server.event_handler("reteam", server.check_mute)




