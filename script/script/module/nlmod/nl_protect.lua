--[[
	script/module/nl_mod/nl_protect.lua
	Derk Haendel
	20-Sep-2010
	License: GPL3

	function nl.check_player_status(cn, pass, method)
	  cn=clientnumber, pass=Spielerpasswort, method=("md5"/"sauer")
		Prüft den Spielerstatus und schreibt ihn in die Spielervariabe nl_status
	
	function nl.set_player_status(cn)
		Gibt oder entzieht dem Spieler Rechte gem. der Spielervariablen nl_status
	
	function nl.login(cn, arg1, arg2)
		Stellt den #login-Befehl zur Verfügung
	
]]

require "md5"
require "geoip"

local LIMIT = 5

function nl.check_player_status(cn, pass, method)

	local aktname = string.upper(server.player_name(cn))
	local basename
	local basepass
	local aktpass = "342765ewhwrzt6645"
	local cancel = false
	
	if not method then method = "md5" end
	
	if pass == "" then pass = "x1x4x7x9x0" end
	
	if method == "md5" then
		aktpass = md5.sumhexa(pass)
	else
		aktpass = pass
	end

	local users = db.select( "user", { "userID","nickname","clantag","pwd_clear","password","activated","adminlevel","greet","ts_mappack" }, string.format("CHAR_LENGTH(pwd_clear)>%s", tostring(0)) )	

	nl.updatePlayer(cn, "nl_status", "none", "set")
	nl.updatePlayer(cn, "statsname", tostring(server.player_name(cn)), "set")

	for i,row in pairs(users) do
		basename = string.upper(row.nickname)
		clantag = string.upper(row.clantag)
		activated = tostring(row.activated)
		if (aktname == basename) or (aktname == clantag .. basename) or (aktname == basename .. clantag) then
			if (activated == '1') then
				nl.updatePlayer(cn, "nl_status", "protected", "set")
				if method == "md5" then
					basepass = row.password
				else
					basepass = server.hashpassword(cn, row.pwd_clear)
				end
				if tostring(row.adminlevel) == "9" then
					nl.updatePlayer(cn, "nl_status", "banned", "set")
					cancel = true
				end
				if tostring(row.adminlevel) == "8" then
					nl.updatePlayer(cn, "nl_status", "blocked", "set")
					cancel = true
				end
				
				if not cancel then
					if string.match(aktpass, basepass) then
						nl.updatePlayer(cn, "nl_status", "user", "set")
						nl.updatePlayer(cn, "nl_greet", tostring(row.greet), "set")
						nl.updatePlayer(cn, "statsname", tostring(row.nickname), "set")
						nl.updatePlayer(cn, "ts_mappack", tostring(row.ts_mappack), "set")
						local servergroups = db.select( "nm_servers_groups", { "id","name_short","name_long" }, string.format("name_short='%s'", server.nmgrpid) )
						if #servergroups ~= 1 then
							nl.updatePlayer(cn, "nl_greet", "Fehler: Servergruppe nicht gefunden.", "set")
						else
							-- nl.updatePlayer(cn, "nl_greet", "servergroupid = " .. tostring(servergroups[1].id), "set")
							local admins = db.select( "nm_servers_admins", { "type" }, string.format("id_servergroup=%s AND id_admin=%s", tostring(servergroups[1].id), tostring(row.userID)) )
							if #admins > 0 then
								if tostring(admins[1].type) == "1" then
									nl.updatePlayer(cn, "nl_status", "serverowner", "set")
								end
								if tostring(admins[1].type) == "2" then
									nl.updatePlayer(cn, "nl_status", "masteradmin", "set")
								end
								if tostring(admins[1].type) == "3" then
									nl.updatePlayer(cn, "nl_status", "admin", "set")
								end
								if tostring(admins[1].type) == "4" then
									nl.updatePlayer(cn, "nl_status", "honoraryadmin", "set")
								end
							end
						end
					end
				end

			else
				nl.updatePlayer(cn, "nl_status", "pending", "set")
			end
		end
	end
end

function nl.set_player_status(cn)
	local player_id = server.player_sessionid(cn)
	local player = nl_players[player_id]
	
	--irc_say(string.format("setPlayerStatus(cn=%i) %s-Status=%s", cn, player.name, player.nl_status))

	if player.nl_status == "none" then
		if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
		if server.is_muted(cn) then server.unmute(cn) end
		if server.player_status_code(cn) == server.SPECTATOR and server.mastermode ~= 2 then spectator.funspec(cn, "LOGIN", "NAME PROTECTION") end
		messages.error(-1, {cn}, "LOGIN", server.player_name(cn) .. ", please register your name here: www.nooblounge.net")
		-- server.player_msg(cn,red("Please register your name here: www.nooblounge.net"))
	elseif player.nl_status == "pending" then
		if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
		spectator.fspec(cn, "LOGIN", "NAME PROTECTION")
		server.mute(cn)
		messages.error(-1, {cn}, "LOGIN", "This name is red<protected but not activated>.")
		messages.error(-1, {cn}, "LOGIN", "If this is your name, orange<check your emails> for activation-link.")
		-- server.player_msg(cn,red("This name is protected but not activated."))
		-- server.player_msg(cn,red("If this is your name, check your emails for activation-link."))
	elseif player.nl_status == "protected" then
		if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
		spectator.fspec(cn, "LOGIN", "NAME PROTECTION")
		server.mute(cn)
		messages.error(-1, {cn}, "LOGIN", server.player_name(cn) .. ", you are using a red<protected name.>")
		messages.error(-1, {cn}, "LOGIN", "Please change your name or authenticate with /setmaster.")
		-- server.player_msg(cn,red("You are using a protected name."))
		-- server.player_msg(cn,red("Please change your name or authenticate with #login."))
	elseif player.nl_status == "user" then
		if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
		if server.is_muted(cn) then server.unmute(cn) end
		if server.player_status_code(cn) == server.SPECTATOR then spectator.funspec(cn, "LOGIN", "NAME PROTECTION") end
		nl.set_access(cn, 100)
		if nl.getPlayer(cn, "reconnects") <= 1 then
			server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("registered player."), server.player_displayname(cn)))
			if string.len(tostring(player.nl_greet)) > 0 then
				server.msg(string.format(white("%s says: ") .. green("%s"), player.name, tostring(player.nl_greet)))
			end
		end
	elseif player.nl_status == "serverowner" or player.nl_status == "masteradmin" or player.nl_status == "admin" or player.nl_status == "honoraryadmin" then
		if server.is_muted(cn) then server.unmute(cn) end
		if server.player_status_code(cn) == server.SPECTATOR then spectator.funspec(cn, "LOGIN", "NAME PROTECTION") end
		nl.set_access(cn, 500)
		--server.set_invisible_admin(cn)
		if nl.getPlayer(cn, "reconnects") <= 1 then
			if player.nl_status == "serverowner" then
				server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("noob."), server.player_displayname(cn)))
			elseif player.nl_status == "masteradmin" then
				server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("masteradmin."), server.player_displayname(cn)))
			elseif player.nl_status == "admin" then
				server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("admin."), server.player_displayname(cn)))
			elseif player.nl_status == "honoraryadmin" then
				if server.player_displayname(cn) == "Hanack" then
					server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("noob."), server.player_displayname(cn)))
				else
					server.msg(string.format(blue("%s") .. orange(" is now logged in as ") .. red("honoraryadmin."), server.player_displayname(cn)))
				end
			end
			if string.len(tostring(player.nl_greet)) > 0 then
				server.msg(string.format(white("%s says: ") .. green("%s"), player.name, tostring(player.nl_greet)))
			end
		end
	elseif player.nl_status == "blocked" then
		if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
		spectator.fspec(cn, "LOGIN", "NAME PROTECTION")
		server.mute(cn)
		messages.error(-1, {cn}, "LOGIN", server.player_name(cn) .. ", please change your name. For example type:")
		messages.error(-1, {cn}, "LOGIN", "/name yourname")
		--server.player_msg(cn,red("Please change your name. For example type:"))
		--server.player_msg(cn,red("/name yourname"))
	end

--[[
	if player.nl_status == "user" or player.nl_status == "admin" then
		-- player.statsname
		-- player.ts_mappack
		result = db.select( "nl_mappack_maps", { "id" }, string.format("ts_change > '%s'", tostring(player.ts_mappack)) )
		if #result > 0 then
			messages.info( cn, { cn }, "MAPLOUNGE", string.format("Es stehen %s neue Map(s) fuer Dich zum Download bereit.", tostring(#result)) )
		end
	end
]]

end

function nl.set_access(cn, value)
	server.set_access(cn, value)
	messages.debug(-1, {cn}, "LOGIN", server.player_name(cn) .. ", your access has been set to ".. value)
	-- server.log(string.format("%s playing as %s(%i) used /setmaster to set access (to %s)", name, server.player_name(cn), cn, tostring(value)))
	-- server.sleep(10, function() xbotlog(user .. " (currently '" .. server.player_name(cn) .. "' (" .. cn .. ")) used /setmaster to set access to " .. value) end)
end

--[[ INFO MESSAGE FOR NEW LOGIN ]]--
function server.playercmd_login(cn, arg1, arg2)
    messages.error(-1, {cn}, "LOGIN", "Please use /setmaster <password> instead of #login for login.")
end

--[[ OLD #LOGIN COMMAND :: 
function server.playercmd_login(cn, arg1, arg2)
	local player_id = server.player_sessionid(cn)
	local player = nl_players[player_id]

	if player.nl_status == "user" or player.nl_status == "admin" then
		messages.error(-1, {cn}, "LOGIN", server.player_name(cn) .. ", red<you are already logged in ...>")
		return
	end

	if not arg1 then
		messages.error(-1, {cn}, "LOGIN", server.player_name(cn) .. ", your red<password is missing>")
		return
	end
	if arg2 then
		pass = arg2
	else
		pass = arg1
	end
	
	nl.check_player_status(cn, pass, "md5")
	nl.set_player_status(cn)
end
]]--
--[[
function server.playercmd_login(cn)
	if not hasaccess(cn, mute_access) then return end
	mutespecs = true
	server.msg(togglemsg("mutespecs", true))
end
]]

--[[
      EVENT HANDLERS
]]

server.event_handler("rename", function(cn, oldname, name)
	if server.player_priv_code(cn) > 0 then server.unsetpriv(cn) end
	nl.updatePlayer(cn, "nl_status", "none", "set")
	nl.set_access(cn, 0)
	if nl.getPlayer(cn, "slotpass") == "none" then
		nl.check_player_status(cn, "", "md5")
	else
		nl.check_player_status(cn, tostring(nl.getPlayer(cn, "slotpass")), "sauer")
	end
	nl.set_player_status(cn)
	if nl.getPlayer(cn, "nl_status") == "banned" then
		server.kick(cn, 3600, server.player_displayname(cn), "Use of a banned name.")
	end
end)

server.event_handler("setmaster", function(cn, hash, set)
	if set and (hash == server.hashpassword(cn, "cubes2c_gotit") or hash == server.hashpassword(cn, "cubes2c_accepted") or hash == server.hashpassword(cn, "cubes2c_norec")) then
		return
	elseif set then
		local player_id = server.player_sessionid(cn)
		local player = nl_players[player_id]
		if player.nl_status == "user" or player.nl_status == "admin" then
			messages.error(-1, {cn}, "LOGIN", "You are already logged in ...")
			return
		end
		local tries = server.player_pvar(cn, "setmaster_tries", nil, "int") or 0
		if tries < LIMIT or server.access(cn) >= flood_access then
			server.log(" -- INFO -- " .. server.player_name(cn) .. " (" .. cn .. ") is trying /setmaster!")
			nl.check_player_status(cn, hash, "sauer")
			nl.set_player_status(cn)
--[[
			local ok, user = check_pwd(cn, hash)
			if ok then
				proceed_user(cn, user)
			else
				server.player_msg(cn, cmderr("wrong password, remaining tries: " .. (LIMIT - (tries + 1))))
				server.log(" -- INFO -- " .. server.player_name(cn) .. " (" .. cn .. ") failed /setmaster!")
			end
]]
			if not player.nl_status == "user" and not player.nl_status == "admin" then
				server.player_msg(cn, cmderr("login failed, remaining tries: " .. (LIMIT - (tries + 1))))
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


