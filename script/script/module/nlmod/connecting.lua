require("geoip")

local c1 = server.color_1
local c2 = server.color_2

local nounabletoconnectmsg = {}
local disappeared = {}

function server.nounabletoconnectmsg(ip)
	nounabletoconnectmsg[ip] = true
end

function server.disappeared(ip, reason)
	disappeared[ip] = reason
end

if not server.realmaxclients then server.realmaxclients = server.maxclients end
if not server.maxplayers then server.maxplayers = server.maxclients end
if not server.xstatsmaxclients then server.xstatsmaxclients = server.maxclients end

server.event_handler("connecting", function(cn, ip, name, pwd, banned)
	auth.initclienttable(cn)
	server.set_access(cn, 0)
	nl.createPlayer(cn)
	if string.len(tostring(pwd)) > 0 then
		nl.updatePlayer(cn, "slotpass", pwd, "set")
	end
	nl.check_player_status(cn, pwd, "sauer")
	-- messages.info(-1, players.all(), "CONNECT", string.format("nl_status = %s", nl.getPlayer(cn, "nl_status")))
	if nl.getPlayer(cn, "nl_status") == "serverowner" or nl.getPlayer(cn, "nl_status") == "masteradmin" or nl.getPlayer(cn, "nl_status") == "admin" or nl.getPlayer(cn, "nl_status") == "honoraryadmin" then
		return server.DISC_NONE
	elseif checkban(ip, name) or nl.getPlayer(cn, "nl_status") == "banned" then -- permanent ban
		log(name .. " (" .. ip .. ") unable to connect because permanently banned.")
		messages.warning(-1, players.admins_and_masters(), "CONNECT", string.format("%s (%s) is permanently banned", name, ip))
		return server.DISC_IPBAN
	elseif server.checkban(ip) then -- temporary ban
		messages.warning(-1, players.admins_and_masters(), "CONNECT", string.format("%s (%s) is temporarily banned", name, ip))
		if disappeared[ip] then
			return disappeared[ip]
		else
			return server.DISC_IPBAN
		end
	elseif nl.getPlayer(cn, "nl_status") == "user" then
		return server.DISC_NONE
	elseif server.playercount >= server.maxclients then
		messages.warning(-1, players.admins_and_masters(), "CONNECT", string.format("%s (%s) could not connect (server full)", name, ip))
		return server.DISC_MAXCLIENTS
	elseif server.mastermode == 3 then
		messages.warning(-1, players.admins_and_masters(), "CONNECT", string.format("%s (%s) could not connect (server private)", name, ip))
		return server.DISC_PRIVATE
	else
		return server.DISC_NONE
	end
end)

--[[
server.event_handler("setmastermode", function(cn, old, newname)
	if newname == "private" then new = 3
	elseif newname == "locked" then new = 2
	elseif newname == "veto" then new = 1
	else new = 0 end
	server.mastermode = new
end)
]]

server.event_handler("connect", function(cn)
	--server.maxclients = server.maxplayers + server.speccount
	--if server.maxclients > server.realmaxclients then server.maxclients = server.realmaxclients end
	nounabletoconnectmsg[server.player_ip(cn)] = nil
	server.unban(server.player_ip(cn))
	disappeared[server.player_ip(cn)] = nil
	if server.mastermode == 2 then spectator.fspec(cn, "MASTERMODE") end
	local country = geoip.ip_to_country(server.player_ip(cn))
	messages.info(-1, players.all(), "CONNECT", string.format("%s is fragging in %s", server.player_displayname(cn), country))
	local cheaterhunters = db.select( "nl_cheaterhunters", { "id","ip","reason","ts" }, string.format("ip='%s'", tostring(server.player_ip(cn))) )
	if #cheaterhunters > 0 then
		messages.warning(-1, players.admins_and_masters(), "CONNECT", string.format("blue<%s>white<(%s)> orange<IP %s is in CHEATER HUNTERS database for %s>", server.player_displayname(cn), tostring(cn), server.player_ip(cn), cheaterhunters[1]['reason']))
	end
	-- server.msg(getmsg("{1} is fragging in {2}", server.player_displayname(cn), country))
end)

server.event_handler("disconnect", function(cn)
	--server.maxclients = server.maxplayers + server.speccount
	--if server.maxclients > server.realmaxclients then server.maxclients = server.realmaxclients end
end)

server.event_handler("spectator", function(cn, val)
	--server.maxclients = server.maxplayers + server.speccount
	--if server.maxclients > server.realmaxclients then server.maxclients = server.realmaxclients end
end)

server.event_handler("kick", function(cn, rtime, admin_cn, rreason)
	local admin
	local admin_
	local reason
	local reason_
	local authedname
	local authedname_
	if admin_cn and admin_cn ~= -1 then
		if server.valid_cn(admin_cn) then
			admin_ = " by {4}"
			admin = server.player_displayname(admin_cn)
			authedname = server.authedname(admin_cn)
			if authedname then
				authedname_ = " (authed as {6})"
			else
				authedname_ = ""
			end
		else
			admin_ = ""
			admin = -1
			reason = ""
			reason_ = ""
			authedname = ""
			authedname_ = ""
		end
	else
		admin_ = ""
		admin = -1
		reason = ""
		reason_ = ""
		authedname = ""
		authedname_ = ""
	end
	if rreason and rreason ~= "" then
		reason_ = " ({5})"
		reason = rreason
	else
		reason_ = ""
		reason = ""
	end
	if rtime > 0 then
		time = round(rtime / 60)
		if time < 60 then
			msg = getmsg("player {1} was kicked and banned" .. admin_ .. authedname_ .. " for {2} minutes" .. reason_, server.player_displayname(cn), time, nil, admin, reason, authedname)
		else
			time = (rtime / 3600)
			hours, minutes = string.match(tostring(time), "(%S+)[.](%S+)")
			if not hours or not minutes then hours = time; minutes = 0 end
			if hours > 1 then hours_ = "hours"
			else hours_ = "hour" end
			if tonumber(minutes) == 0 then
				msg = getmsg("player {1} was kicked and banned" .. admin_ .. authedname_ .. " for {2} " .. hours_ .. reason_, server.player_displayname(cn), hours, nil, admin, reason, authedname)
			else
				msg = getmsg("player {1} was kicked and banned" .. admin_ .. authedname_ .. " for {2} " .. hours_ .. " and {3} minutes" .. reason_, server.player_displayname(cn), hours, minutes, admin, reason, authedname)
			end
		end
	else
		msg = getmsg("player {1} was kicked" .. admin_ .. authedname_ .. reason_, server.player_displayname(cn), nil, nil, admin, reason, authedname)
	end
	server.sleep(10, function() server.msg(msg) end)
end)

local nomsg = {}

function server.nodiscmsg(cn)
	nomsg[cn] = true
end

server.event_handler("disconnect", function(cn, reason)
	if reason ~= "normal" and reason ~= "kicked/banned" and reason ~= "" then
		if not nomsg[cn] then
			msg = getmsg("{1} disconnected because {2}", server.player_displayname(cn), reason)
			server.sleep(100, function() server.msg(msg) end)
		else
			nomsg[cn] = nil
		end
	end
end)
