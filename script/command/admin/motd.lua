--[[

	A player command to set a message of the day

]]

local usage = "#motd \"<text>\""

return function(cn,text)

	if not text then
		return false, usage
	end

	server.motd = text
	server.player_msg(cn,"MOTD changed to " .. text)

end
