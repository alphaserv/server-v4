--[[

	script/module/nl_mod/nl_reconnect.lua
	Author:      Hanack (Andreas Schaeffer)
	Created:     23-Okt-2010
	Last Change: 21-Apr-2012
	License: GPL3

	Funktion:
		Ein Spieler verbindet sich innerhalb von [offtime] Minuten neu. Dann wird ein
		Event namens reconnect ausgelöst.

]]	



--[[
		API
]]

reconnect = {}
reconnect.signal = server.create_event_signal("reconnect")
reconnect.delay=2
reconnect.offtime=2
reconnect.lastnamestime=10
reconnect.maxlastnamestime=120



--[[
		API
]]

function reconnect.get_last_names(cn, minutes)
	local lastnamestime = reconnect.lastnamestime
	if minutes ~= nil and utils.is_numeric(minutes) then
		if minutes < reconnect.maxlastnamestime then
			lastnamestime = minutes
		end
	end
	local connects = db.select("nl_reconnect", { "ip", "name", "playerid", "ts" }, string.format( "(ip='%s' OR name='%s' OR id='%s') AND ts >= DATE_SUB( NOW(), INTERVAL %i MINUTE )", server.player_ip(cn), db.escape(server.player_name(cn)), server.player_id(cn), lastnamestime ) )
	if #connects > 0 then
		local names = ""
		for i,connect in ipairs(connects) do
			names = string.format("%s %s", names, connect["name"]) 
		end
		return names
	else
		return -1
	end
end

--[[
		COMMANDS
]]

function server.playercmd_lastnames(cn, playercn, minutes)
	if not hasaccess(cn, admin_access) then return end
	if not utils.is_numeric(playercn) then
		messages.warning(cn, cn, "RECONNECT", "Usage: #lastnames <CN> [<MINUTES>]")
		return
	end
	local lastnamestime = reconnect.lastnamestime
	if minutes ~= nil and utils.is_numeric(minutes) then
		local m = tonumber(minutes)
		if m <= reconnect.maxlastnamestime then
			lastnamestime = m
		else
			messages.warning(cn, cn, "RECONNECT", "Error: Maximum: 120 minutes")
			return
		end
	end
	local names = reconnect.get_last_names(playercn, lastnamestime)
	if names == -1 then
		messages.info(cn, cn, "RECONNECT", string.format("%s has no other names in the last %i mins", server.player_name(playercn), lastnamestime))
	else
		messages.info(cn, cn, "RECONNECT", string.format(" Last names used by %s in the last %i mins: %s", server.player_name(playercn), lastnamestime, names))
	end
end

function server.playercmd_reconnect(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#reconnect <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "lastconnects" then
				return false, "#reconnect lastconnects <CN>"
			end
			if command == "info" then
				messages.info(cn, {cn}, "RECONNECT", "reconnect.delay=%s"..reconnect.delay)
				messages.info(cn, {cn}, "RECONNECT", "reconnect.offtime=%s"..reconnect.offtime)
			end
		else
			if command == "lastconnects" then
				local connects = db.select("nl_reconnect", {"ts", "name"}, string.format( "ip='%s' OR name='%s' OR id='%s' ORDER BY ts DESC LIMIT 5", server.player_ip(arg), db.escape(server.player_name(arg)), server.player_id(arg) ))
				messages.info(cn, {cn}, "RECONNECT", "List of the last 5 connects: ")
				for i,connect in pairs(connects) do
					messages.info(cn, {cn}, "RECONNECT", "  at "..connect.ts.." by "..connect.name.." ("..connect.ip..")")
				end
			end
			if command == "delay" then
				reconnect.delay = arg
				messages.info(cn, {cn}, "RECONNECT", "reconnect.delay="..reconnect.delay)
			end
			if command == "offtime" then
				reconnect.offtime = arg
				messages.info(cn, {cn}, "RECONNECT", "reconnect.offtime="..reconnect.offtime)
			end
		end
	end
end


--[[
		EVENTS
]]

server.event_handler("allow_rename", function(cn, text)
	db.insert("nl_reconnect", { ip=server.player_ip(cn), name=server.player_name(cn), playerid=server.player_id(cn) } )
end)

server.event_handler("disconnect", function(cn)
	db.insert("nl_reconnect", { ip=server.player_ip(cn), name=server.player_name(cn), playerid=server.player_id(cn) } )
end)

server.event_handler("connect", function(cn)
	local connects = db.select("nl_reconnect", { "ip", "name", "playerid", "ts" }, string.format( "(ip='%s' OR name='%s' OR id='%s') AND ts >= DATE_SUB( NOW(), INTERVAL %i MINUTE )", server.player_ip(cn), db.escape(server.player_name(cn)), server.player_id(cn), reconnect.offtime ) )
	if #connects > 0 then
		local noconnects = #connects
		messages.info(cn, players.admins(), "RECONNECT", server.player_name(cn).." ("..cn..") has reconnected ("..noconnects.." times within "..reconnect.offtime.." minutes)")

		local names = reconnect.get_last_names(tonumber(cn))
		if names == -1 then
			-- messages.info(cn, players.admins(), "RECONNECT", string.format("%s has no other names in the last %i mins", server.player_name(cn), reconnect.lastnamestime))
		else
			messages.info(cn, players.admins(), "RECONNECT", string.format(" Last names used by %s in the last %i mins: %s", server.player_name(cn), reconnect.lastnamestime, names))
		end

		for i,connect in pairs(connects) do
			messages.debug(cn, players.admins(), "RECONNECT", "  at "..connect.ts.." by "..connect.name)
		end
		reconnect.signal(cn, connects)
		server.sleep(reconnect.delay*1000, function()
			if server.valid_cn(cn) then
				messages.warning(cn, {cn}, "RECONNECT", string.format("%s, You have reconnected or you use the same IP as someone else lately! To prevent misusage you cannot use some functions till intermission!", server.player_name(cn)))
			end
		end)
	end
end)
