--[[

	A player command to send a message to a player

]]


return function(cn, tcn, ...)

	if not tcn then
		return false, "#playermsg (<cn>|\"<name>\") <text>"
	end

	local text = ""

	for _, item in ipairs(arg) do
		item = tostring(item)
		if #item > 0 then
			if #text > 0 then
				text = text .. " "
			end

			text = text .. item
		end
	end

	if not server.valid_cn(tcn) then
		tcn = server.name_to_cn_list_matches(cn,tcn)

		if not tcn then
			return
		end
	end

    server.player_msg(tcn, string.format("PM from %s: %s", server.player_displayname(cn), green(text)))
end

