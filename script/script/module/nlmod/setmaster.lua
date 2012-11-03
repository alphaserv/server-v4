local LIMIT = 5

passwords = {}

function proceed_user(cn, user)
	if user then
		access_ = get_user_access(user)
		if access_ then
			if server.access(cn) < access_ then
				server.set_access(cn, access_)
				server.player_msg(cn, getmsg("your access has been set to {1}", access_))
				server.log(string.format("%s playing as %s(%i) used /setmaster to set access (to %s)", name, server.player_name(cn), cn, tostring(access_)))
				server.sleep(10, function() xbotlog(user .. " (currently '" .. server.player_name(cn) .. "' (" .. cn .. ")) used /setmaster to set access to " .. access_) end)
			else
				server.player_msg(cn, cmderr("nothing changed"))
			end
		else
			server.player_msg(cn, cmderr("unknown user '" .. user .. "'"))
		end
	else
		server.player_msg(cn, cmderr("unknown user"))
	end
end

function check_pwd(cn, hash)
	local a = 1
	while (not (a > #passwords)) do
		if server.hashpassword(cn, passwords[a]) == hash then
			user = string.match(passwords[a], "(.+)/.*")
			return true, user
		end
		a = a + 1
	end
	return false, nil
end

server.event_handler("setmaster", function(cn, hash, set)
	irc_say(string.format( "%s, %s, %s", tostring(cn), tostring(hash), tostring(set) ))
	if set and (hash == server.hashpassword(cn, "cubes2c_gotit") or hash == server.hashpassword(cn, "cubes2c_accepted") or hash == server.hashpassword(cn, "cubes2c_norec")) then
		return
	elseif set then
		local tries = server.player_pvar(cn, "setmaster_tries", nil, "int") or 0
		if tries < LIMIT or server.access(cn) >= flood_access then
			server.log(" -- INFO -- " .. server.player_name(cn) .. " (" .. cn .. ") is trying /setmaster!")
			local ok, user = check_pwd(cn, hash)
			if ok then
				proceed_user(cn, user)
			else
				server.player_msg(cn, cmderr("wrong password, remaining tries: " .. (LIMIT - (tries + 1))))
				server.log(" -- INFO -- " .. server.player_name(cn) .. " (" .. cn .. ") failed /setmaster!")
			end
			server.player_pvar(cn, "setmaster_tries", tries + 1)
		else
			server.player_msg(cn, cmderr(LIMIT .. " fails, ignoring your setmaster requests"))
		end
	elseif server.player_priv(cn) ~= "none" then
		server.unsetpriv(cn)
		server.player_msg(cn, getmsg("your privilege has been unset"))
	elseif server.access(cn) > 0 then
		server.set_access(cn, 0)
		server.player_msg(cn, getmsg("your access has been unset"))
	else
		server.player_msg(cn, cmderr("no privilege to unset"))
	end
	return -1
end)

function load_passwords()
	if not server.passwordfile then return {} end
	nowfile = io.open(server.passwordfile, "r")
	passwords = {}
	if nowfile then
		line = ""
		while line do
			line = nowfile:read()
			if line then
				line = string.gsub(line, "\n","")
				passwords[#passwords + 1] = line
				log("added password: "..line)
			end
		end
		nowfile:close()
		log("loaded passwords")
		return passwords
	else
		log("could not read passwordfile (" .. server.passwordfile .. ")")
		return {}
	end
end

passwords = load_passwords()
