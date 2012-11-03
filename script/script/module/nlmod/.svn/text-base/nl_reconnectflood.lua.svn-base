--[[
	script/module/nl_mod/nl_reconnectflood.lua
	Hanack (Andreas Schaeffer)
	Created: 05-Mai-2012
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Erkennen und Verhindern von Reconnect Floods

]]



--[[
		API
]]

reconnectflood = {}
reconnectflood.warning = 5
reconnectflood.ban = 7



--[[
		EVENTS
]]

server.event_handler("reconnect", function(cn, connects)
	local number_of_connects = #connects
	if number_of_connects >= reconnectflood.ban then
		server.kick(cn, cheater.ban.time, "Server", "Reconnect Flood")
		messages.error(cn, players.admins(), "RECONNECT FLOOD", string.format("Automatically kicked blue<%s (%i)> because of white<reconnect flooding>", server.player_name(cn), cn))
	else
		if number_of_connects >= reconnectflood.warning then
			messages.warning(cn, cn, "RECONNECT FLOOD", server.player_name(cn) ..", you are not allowed to reconnect too often!")
		end
	end
end)
