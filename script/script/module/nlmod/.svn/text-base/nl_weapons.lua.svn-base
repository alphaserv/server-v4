--[[
	script/module/nl_mod/nl_weapons.lua
	Hanack (Andreas Schaeffer)
	Created: 28-Apr-2012
	Last Change: 28-Apr-2012
	License: GPL3

	Funktion:
		Erkennt Cheater, die eine ungültige Waffe haben.

	API-Methoden:
		weapons.check()
			Prueft, ob der Waffenwechsel fuer den Mode gueltig ist! 

	Commands:
		#weapons enabled 1
			Waffenwechsel-Check einschalten
		#weapons enabled 0
			Waffenwechsel-Check ausschalten
			
]]



--[[
		API
]]

weapons = {}
weapons.enabled = 1
weapons.names = { "chainsaw", "shotgun", "chaingun", "rocket launcher", "rifle", "grenade launcher", "pistol" }
weapons.weaponformode = {}
weapons.weaponformode['insta ctf'] = { 0, 4 }
weapons.weaponformode['efficiency ctf'] = { 0, 1, 2, 3, 4, 5 }
weapons.weaponformode['ctf'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['insta hold'] = { 0, 4 }
weapons.weaponformode['efficiency hold'] = { 0, 1, 2, 3, 4, 5 }
weapons.weaponformode['hold'] = { 0, 1, 2, 3, 4, 5, 6}
weapons.weaponformode['insta protect'] = { 0, 4 }
weapons.weaponformode['efficiency protect'] = { 0, 1, 2, 3, 4, 5 }
weapons.weaponformode['protect'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['ffa'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['instagib'] = { 0, 4 }
weapons.weaponformode['efficiency'] = { 0, 1, 2, 3, 4, 5 }
weapons.weaponformode['tactics'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['efficiency team'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['instagib team'] = { 0, 4 }
weapons.weaponformode['tactics team'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['teamplay'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['capture'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['regen capture'] = { 0, 1, 2, 3, 4, 5, 6 }
weapons.weaponformode['coop edit'] = { 0, 1, 2, 3, 4, 5, 6 }


-- prueft, ob die gewaehlte waffe gueltig ist
function weapons.check(cn, weapon)
	if server.paused == 1 or server.timeleft <= 0 or weapons.enabled == 0 then return end
	cn = tonumber(cn)
	found = 0
	for i,w in ipairs(weapons.weaponformode[maprotation.game_mode]) do
		if w == weapon then
			found = 1
		end
	end
	if found == 0 then
		messages.error(cn, players.admins(), "CHEATER", string.format("blue<%s (%i)> selected red<invalid weapon %s (%i)>", server.player_displayname(cn), cn, weapons.names[weapon], weapon))
		cheater.autokick(actor_cn, "Server", "Invalid weapon")
	end
end



--[[
		COMMANDS
]]

function server.playercmd_weapons(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#weapons <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "CHEATER", "weapons.enabled=" .. weapons.enabled)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "CHEATER", "weapons.enabled=" .. weapons.enabled)
			end
		else
			if command == "enabled" then
				maphack.enabled = tonumber(arg)
				messages.info(cn, {cn}, "CHEATER", "weapons.enabled=" .. weapons.enabled)
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("gunselect", function(cn, weapon)
	weapons.check(cn, weapon)
end)
