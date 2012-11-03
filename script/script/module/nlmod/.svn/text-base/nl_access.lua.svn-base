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

function server.playercmd_access(cn, ocn, oaccess)
	if not ocn then
		messages.info(-1, {cn}, "ACCESS", string.format("your access is %s", access(cn)))
	elseif ocn and (not oaccess) and hasaccess(cn, viewaccess_access) then
		if not server.valid_cn(ocn) then server.player_msg(cn, cmderr("invalid cn")); return end
		messages.info(-1, {cn}, "ACCESS", string.format("%s has access %s", server.player_displayname(ocn), access(cn)))
	elseif ocn and oaccess and hasaccess(cn, setaccess_access) then
		if not server.valid_cn(ocn) then
			messages.error(-1, {cn}, "ACCESS", "invalid CN")
			return
		end
		oaccess = tonumber(oaccess)
		local maccess = access(cn)
		if oaccess > access(ocn) then
			if oaccess == maccess or oaccess > maccess then oaccess = maccess - 1 end
			server.set_access(ocn, oaccess)
			messages.info(-1, {cn}, "ACCESS", string.format("%s's access has been set to %s", server.player_name(ocn), oaccess))
			messages.info(-1, {ocn}, "ACCESS", string.format("Your access has been set to %s", oaccess))
		elseif oaccess < access(ocn) then
			if access(cn) > access(ocn) then
				server.set_access(ocn, oaccess)
				messages.info(-1, {cn}, "ACCESS", string.format("%s's access has been set to %s", server.player_name(ocn), oaccess))
				messages.info(-1, {ocn}, "ACCESS", string.format("Your access has been set to %s", oaccess))
			else
				failmsg(cn)
			end
		else
			messages.error(-1, {cn}, "ACCESS", "nothing changed!")
		end
	end
end

