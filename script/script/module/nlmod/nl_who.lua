--[[
	script/module/nl_mod/nl_who.lua
	Hanack (Andreas Schaeffer)
	Created: 20-Sep-2010
	Last Modified: 25-Okt-2010
	License: GPL3

	Funktionen:
		Zeigt, welche Spieler online sind. Administratoren können sich anzeigen lassen, welche
		Admins, Masters, registrierte und normale Spieler online sind.

	Commands:
		#who
		#who admins
		#who masters
		#who users
		#who normal
]]

require "table"


--[[
		COMMANDS
]]

function server.playercmd_who(cn, filter)
	local normal_names = {}
	if hasaccess(cn, who_verbose_access) then
		local admin_names = {}
		local master_names = {}
		local user_names = {}
		local afk_names = {}
		local penalty_names = {}
		for i,pcn in ipairs(server.clients()) do
			if access(pcn) >= admin_access then
				table.insert(admin_names, server.player_name(pcn))			
			elseif access(pcn) >= master_access then
				table.insert(master_names, server.player_name(pcn))			
			elseif access(pcn) >= user_access then
				table.insert(user_names, server.player_name(pcn))
			else
				table.insert(normal_names, server.player_name(pcn))
			end
			if spectator.afk[pcn] == 1 then
				table.insert(afk_names, server.player_name(pcn))
			end
			-- TODO: add new penalty box types
			if camping.penalties[pcn] > 0 then
				table.insert(penalty_names, server.player_name(pcn))
		    end
	    end
		if filter == "admin" then
			messages.info(cn, {cn}, "WHO", "  Admins: " .. table.concat(admin_names, ", "))
		elseif filter == "master" then
			messages.info(cn, {cn}, "WHO", "  Masters: " .. table.concat(master_names, ", "))
		elseif filter == "user" then
			messages.info(cn, {cn}, "WHO", "  Users: " .. table.concat(user_names, ", "))
		elseif filter == "normal" then
			messages.info(cn, {cn}, "WHO", "  Normal: " .. table.concat(normal_names, ", "))
		elseif filter == "afk" then
			messages.info(cn, {cn}, "WHO", "  AFK: " .. table.concat(afk_names, ", "))
		elseif filter == "pbox" then
			messages.info(cn, {cn}, "WHO", "  PBOX: " .. table.concat(penalty_names, ", "))
		else
			messages.info(cn, {cn}, "WHO", "Players on this server:")
			messages.info(cn, {cn}, "WHO", "  Admins: " .. table.concat(admin_names, ", "))
			messages.info(cn, {cn}, "WHO", "  Masters: " .. table.concat(master_names, ", "))
			messages.info(cn, {cn}, "WHO", "  Users: " .. table.concat(user_names, ", "))
			messages.info(cn, {cn}, "WHO", "  Normal: " .. table.concat(normal_names, ", "))
			messages.info(cn, {cn}, "WHO", "  AFK: " .. table.concat(afk_names, ", "))
			-- messages.info(cn, {cn}, "WHO", "  PBOX: " .. table.concat(penalty_names, ", "))
			messages.info(cn, {cn}, "WHO", "Press F11 to expand!")
		end
	else
		for i,pcn in ipairs(server.clients()) do
			table.insert(normal_names, server.player_name(pcn))
		end
		messages.info(cn, {cn}, "MAPSUCKS", "Players on this server: " .. table.concat(normal_names, ", "))
	end
end
