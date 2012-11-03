function server.playercmd_cw(cn, list1, list2, mode, map, time)
	if not hasaccess(cn, oneonone_access) then return end

	if not list1 or not list2 then
		if server.playercount == 2 then
			list1 = "0"
			list2 = "1"
		else
			server.player_msg(cn, cmderr("missing list1 or list2, #cw list1 list2 mode map [time]"))
			return
		end
	end

	if not map then
		if server.playercount == 2 then
			map = "ot"
		else
			server.player_msg(cn, cmderr("missing map, #cw list1 list2 mode map [time]"))
			return
		end
	end

	if not mode then
		server.player_msg(cn, cmderr("missing mode, #cw list1 list2 mode map [time]"))
		return
	else
		if server.playercount == 2 then
			mode = "instagib"
		end
		mode = server.parse_mode(mode)
		if not mode then
			server.player_msg(cn, cmderr("mode is not known"))
			return
		end
	end

	if not time then local time = 10 end

	irc_say(string.format( "#cw %s %s %s %s %s", tostring(list1), tostring(list2), tostring(mode), tostring(map), tostring(time) ))

end
