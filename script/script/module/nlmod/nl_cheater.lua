--[[
	script/module/nl_mod/nl_cheater.lua
	Hanack (Andreas Schaeffer)
	Created: 24-Okt-2010
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Rahmenwerk fuer Anti-Cheats
		Erkennen von bereits vorhandenen IPs
		Erkennen von Annoymous Proxies

	Commands:
		#disapear <CN>
			Den Spieler mit der CN verschwinden lassen

]]



require "geoip"



--[[
		API
]]

cheater = {}
cheater.pbox = {}
cheater.pbox.time = 120
cheater.ban = {}
cheater.ban.time = 3600
cheater.ban.delay = 30000
cheater.nameban = {}
cheater.ipban = {}
cheater.recordings = {}
cheater.kill = 0
cheater.RENAME = "CHEATER"

function cheater.check_same_ip(cn)
	for _, player_cn in ipairs(players.all()) do
		if cn ~= player_cn and server.player_ip(cn) == server.player_ip(player_cn) then
			messages.warning(cn, players.admins(), "CHEATER", string.format("%s (%i) has same ip as %s (%i).", server.player_name(cn), cn, server.player_name(player_cn), player_cn))
		end
	end
end

function cheater.check_ap(cn)
	local country = geoip.ip_to_country(server.player_ip(cn))
	if country == "Anonymous Proxy" then
		server.kick(cn, cheater.ban.time, server.player_displayname(cn), "cheating")
	end
end

function cheater.check_nameban(cn)
	for k, player_name in pairs(cheater.nameban) do
		if server.player_name(cn) == player_name then
			server.kick(cn, cheater.ban.time, server.player_displayname(cn), "Name was banned.")
		end 
	end
end

function cheater.check_ipban(cn)
	for k, player_ip in pairs(cheater.ipban) do
		if server.player_ip(cn) == player_ip then
			server.kick(cn, cheater.ban.time, server.player_displayname(cn), "IP was banned.")
		end 
	end
end

function cheater.autokick(cn, who, reason)
	-- server.player_rename(cn, cheater.RENAME, false)
	server.kick(cn, cheater.ban.time, who, reason)
end

function cheater.start_recording(name)
	if not cheater.is_recording() then
		messages.info(cn, players.all(), "CHEATER", "red<=========== RECORDING STARTED ===========>")
	end
	cheater.recordings[name] = 1
end

function cheater.stop_recording(name)
	local is_already_recording = cheater.is_recording()
	cheater.recordings[name] = nil
	if is_already_recording and not cheater.is_recording() then
		messages.info(cn, players.all(), "CHEATER", "red<=========== RECORDING STOPPED ===========>")
	end
end

function cheater.is_recording()
	local is_recording = false
	for k,v in pairs(cheater.recordings) do
		is_recording = true
		break
	end
	return is_recording
end



--[[
		COMMANDS
]]

function server.playercmd_cheater(cn, cmd, arg)
	if not hasaccess(cn, admin_access) then return end
	if arg == nil then
		if cmd == "info" then
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.kill = %i (kills allowed on recording)", cheater.kill))
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.pbox.time = %i", cheater.pbox.time))
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.ban.time = %i", cheater.ban.time))
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.ban.delay = %i", cheater.ban.delay))
		end
		if cmd == "kill" then
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.kill = %i (kills allowed on recording)", cheater.kill))
		end
	else
		if cmd == "kill" then
			cheater.kill = tonumber(arg)
			messages.info(cn, {cn}, "CHEATER", string.format("cheater.kill = %i (kills allowed on recording)", cheater.kill))
		end
	end
end

function server.playercmd_disapear(cn, targetCN)
	if not hasaccess(cn, disapear_access) then return end
	server.disconnect(targetCN, server.DISC_TAGT, "")
end

function server.playercmd_nameban(cn, cmd, name)
	if not hasaccess(cn, admin_access) then return end
	if cmd == nil then return end
	if cmd == "list" then
		local names = ""
		for k, player_name in pairs(cheater.nameban) do
			names = names .. " " .. player_name
		end
		messages.info(cn, players.admins(), "CHEATER", string.format("Current name bans: %s", names))
		return
	end
	if cmd == "add" then
		if name == nil then return end
		if cheater.nameban[name] == nil then
			cheater.nameban[name] = name
			messages.warning(cn, players.admins(), "CHEATER", string.format("%s added a new temporary name ban for %s.", server.player_name(cn), name))
			for _, player_cn in ipairs(players.all()) do
				if server.player_name(player_cn) == name then
					server.kick(player_cn, cheater.ban.time, server.player_displayname(player_cn), "Name was banned.")
				end
			end
		else
			messages.warning(cn, {cn}, "CHEATER", string.format("Name %s was already banned.", name))
		end
		return
	end
	if cmd == "remove" then
		cheater.nameban[name] = nil
		return
	end
end

function server.playercmd_ipban(cn, cmd, ip)
	if not hasaccess(cn, admin_access) then return end
	if cmd == nil then return end
	if cmd == "list" then
		local ips = ""
		for k, player_ip in pairs(cheater.ipban) do
			ips = ips .. " " .. player_ip
		end
		messages.info(cn, players.admins(), "CHEATER", string.format("Current ip bans: %s", ips))
		return
	end
	if cmd == "add" then
		if ip == nil then return end
		if cheater.ipban[ip] == nil then
			cheater.ipban[ip] = ip
			messages.warning(cn, players.admins(), "CHEATER", string.format("%s added a new temporary ip ban for %s.", server.player_name(cn), ip))
			for _, player_cn in ipairs(players.all()) do
				if server.player_ip(player_cn) == ip then
					server.kick(player_cn, cheater.ban.time, server.player_displayname(player_cn), "IP was banned.")
				end
			end
		else
			messages.warning(cn, {cn}, "CHEATER", string.format("ip %s was already banned.", ip))
		end
		return
	end
	if cmd == "remove" then
		if ip == nil then return end
		cheater.ipban[ip] = nil
		return
	end
end


--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	cheater.check_ap(cn)
	cheater.check_same_ip(cn)
	cheater.check_nameban(cn)
	cheater.check_ipban(cn)
end)

server.event_handler("damage", function(target_cn, actor_cn, damage, gun)
	-- no damage on recording sessions
	if target_cn == nil or actor_cn == nil or target_cn == actor_cn or cheater.kill == 1 then return end
	if cheater.is_recording() then
		messages.debug(target_cn, {actor_cn}, "CHEATER", "red<You cannot damage other players while recording!>")
		return -1
	end
end)
