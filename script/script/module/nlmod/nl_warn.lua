--[[
	script/module/nl_mod/nl_warn.lua
	Hanack (Andreas Schaeffer)
	Created: 11-Nov-2010
	Last Modified: 11-Nov-2010
	License: GPL3

	Funktionen:
		Warnungen an Spieler verschicken

	Commands:
		#warn <CN> <TEXT>
			Schickt eine Warnung an den Spieler mit der entsprechenden CN
	
	Es koennen Kuerzel verwendet werden:
		* tk
		* lang / language
		* spam
		* name
]]



--[[
		COMMANDS
]]

function server.playercmd_warn(cn, tcn, ...)
	if not hasaccess(cn, admin_access) then return end
	if not tcn then
		messages.error(cn, {cn}, "WARNING", "Missing CN! Usage: #warn <CN>")
		return
	end
	if not server.valid_cn(tcn) then
		messages.error(cn, {cn}, "WARNING", "Invalid CN! Usage: #warn <CN>")
		return
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

	if text == "tk" then
		text = "Stop teamkilling. ONLY RED players are the enemies!"
	elseif text == "lang" or text == "language" then
		text = "Watch your language!"
	elseif text == "ping" or text == "pj" then
		text = "Fix you PING / PJ immediately!"
	elseif text == "spam" then
		text = "Stop spamming!"
	elseif text == "name" then
		text = "Please change your name! Your current one is not acceptable!"
	end

	if not server.valid_cn(tcn) then
		tcn = server.name_to_cn_list_matches(cn,tcn)

		if not tcn then
			return
		end
	end

	messages.warning(cn, {tcn}, "WARNING", "--------------------")
	messages.warning(cn, players.all(), "WARNING", string.format(blue("%s:").." %s", server.player_displayname(tcn), text))
	messages.warning(cn, {tcn}, "WARNING", "--------------------")
end
