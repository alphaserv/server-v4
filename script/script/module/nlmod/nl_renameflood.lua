--[[
	script/module/nl_mod/nl_renameflood.lua
	Hanack (Andreas Schaeffer)
	Created: 05-Mai-2012
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Erkennen und Verhindern von Rename Floods

]]



--[[
		API
]]

renameflood = {}
renameflood.warnings = 4
renameflood.ban = 12



--[[
		EVENTS
]]

server.event_handler("allow_rename", function(cn, text)
	nl.updatePlayer(cn, "rename", 1, "add")
	if nl.getPlayer(cn, "rename") >= renameflood.ban then
		server.kick(cn, cheater.ban.time, "Server", "Automatically banned " .. server.player_name(cn) .. " (" .. cn .. ") because of rename flooding")
		messages.error(cn, players.admins(), "RENAME FLOOD", server.player_name(cn) .. " (" .. cn .. ") was kicked because of rename flooding! Demofile: " .. server.stats_demo_filename)
		return -1
	end
	if nl.getPlayer(cn, "rename") >= renameflood.warnings then
		messages.warning(cn, cn, "RENAME FLOOD", "You are not allowed to rename too often!")
		return -1
	end
end)
