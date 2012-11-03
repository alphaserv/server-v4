-- flood protection in ../promod/kick_protection.lua!

local kick_signal = server.create_event_signal("kick")
local bans = {}

server.event_handler("started", function()
	if server.uptime > 1 then return end -- exit if server was reloaded
	bans = {}
end)

function server.ban(ip, bantime, admin, reason, name)
	if not bantime or bantime == -1 then bantime = 14400 end
	if not admin then admin = -1 end
	if not reason then reason = "" end
	local a = 1
	while bans[a] ~= nil and bans[a] ~= false do a = a + 1 end -- find first empty space to place ban
	bans[a] = {}
	bans[a][1] = ip
	bans[a][2] = (os.time() + tonumber(bantime))
	bans[a][4] = name
	if server.valid_cn(admin) then
		server.log("successfully added ban for IP " .. ip .. " and bantime " .. tostring(bantime) .. " (secs)! reason: " .. reason .. " admin: " .. server.player_name(admin) .. " (" .. admin .. ")(" .. server.player_ip(admin) .. ")(" .. (server.authedname(admin) or "not authed") .. ")")
		bans[a][3] = server.authedname(admin) or false
	else
		server.log("successfully added ban for IP " .. ip .. " and bantime " .. tostring(bantime) .. " (secs)! reason: " .. reason .. " no valid admin cn given! admin var contains: " .. tostring(admin))
	end
end

function server.kick(cn, bantime, admin, reason, disc_reason)
	disc_reason = disc_reason or server.DISC_KICK
	if server.player_isbot(cn) then server.delbot(cn); return end
	if not bantime or bantime == -1 then bantime = 14400 end
	if not admin then admin = -1 end
	if not reason then reason = "" end
	if bantime >= 0 then
		server.ban(server.player_ip(cn), bantime, admin, reason, server.player_name(cn))
		server.disconnect(cn, disc_reason, "")
		kick_signal(cn, bantime, admin, reason)
	else
		server.disconnect(cn, disc_reason)
		kick_signal(cn, 0, admin, reason)
	end
end

function server.checkban(ip)
	for i, baninfo in ipairs(bans) do
		if baninfo and baninfo[1] == ip then -- make sure baninfo is not empty (it would be empty if it was false)
			if os.time() <= baninfo[2] then
				return true
			else
				bans[i] = false
			end
		end
	end
	return false
end

function server.clearbans()
	bans = {}
end

function server.clear_auth_bans()
	for i, baninfo in ipairs(bans) do
		-- if baninfo and baninfo[3] then -- make sure baninfo is not empty (it would be empty if it was false)
		if baninfo then -- make sure baninfo is not empty (it would be empty if it was false)
			bans[i] = false
		end
	end
end

function server.unban(ip)
	local unbanned = false
	for i, baninfo in ipairs(bans) do
		if baninfo and baninfo[1] == ip then -- make sure baninfo is not empty (it would be empty if it was false)
			bans[i] = false
			unbanned = true
		end
	end
	return unbanned
end

function server.unban_name(name)
	local unbanned = false
	for i, baninfo in ipairs(bans) do
		if baninfo and baninfo[4] == name then -- make sure baninfo is not empty (it would be empty if it was false)
			bans[i] = false
			unbanned = true
		end
	end
	return unbanned
end

function server.unban_id(id)
	local unbanned = false
	for i, baninfo in ipairs(bans) do
		if baninfo and i == tonumber(id) then -- make sure baninfo is not empty (it would be empty if it was false)
			bans[i] = false
			unbanned = true
		end
	end
	return unbanned
end

function server.getbans()
	local bans_ = {}
	for i, baninfo in ipairs(bans) do
		if baninfo then -- make sure baninfo is not empty (it would be empty if it was false)
			local a = 1
			while bans_[a] do a = a + 1 end -- find first empty space
			bans_[a] = {
				ip = baninfo[1],
				time = baninfo[2],
				authedname = baninfo[3],
				victimname = baninfo[4]
			}
		end
	end
	return bans_
end

server.event_handler("kick_request", function(admin_cn, admin_name, bantime, target, reason)
	if server.allowkick(admin_cn, target, bantime) then
    	server.kick(target, bantime, admin_cn, reason)
    end
    server.requestedkick(admin_cn)
end)
