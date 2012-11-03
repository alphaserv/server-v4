--[[

	--------------------------------------------------------
	| xstats system client script for hopmod-cube2-servers |   (c) X35
	--------------------------------------------------------
	
	[ VERSION 2 ]

INFO:
	This script requires an xstats server account and
	the IP of the server which is running the client script must be allowed
	on the main server.

	You can get an account from #xstats at the IRC network gamesurge (irc.gamesurge.net:6667).

	If you modify anything in this script without permission from an OP in #xstats @ irc.gamesurge.net,
	your account will be removed, and your IP banned.

	below is the config:
]]
	xstats_password = 	"testpw"		-- server account password
	xstats_server = 	"127.0.0.1"		-- Address of the xstats main server, get it from #xstats
	xstats_port = 		28350			-- should not be changed (default: 28350)
--[[
	--	dont modify anything below this line without permission from #xstats @ irc.gamesurge.net	--
]]

local function send_xstats(line, func)
	local statserv
	statserv = net.tcp_client()
	statserv:async_connect(xstats_server, xstats_port, function(errmsg)
		if not errmsg then
			statserv:async_send(xstats_password, function()
				statserv:async_read_until("\n", function(rtext)
					if rtext then
						if string.find(rtext, "ok") then
							statserv:async_send(line, function()
								statserv:async_read_until("\n", function(rtext)
									if rtext then
										statserv:close()
										--if not string.match(rtext, "^error.*") then
										if func then func(string.gsub(rtext, "\n", "")) end
										--end
									else
										statserv:close()
									end
								end)
							end)
						else
							statserv:close()
						end
					else
						statserv:close()
					end
				end)
			end)
		else
			statserv:close()
		end
	end)
end

local function unset(cn)
	server.set_xstats_user(cn, "")
	server.set_xstats_requested_user(cn, "")
	server.set_xstats_authkey(cn, "")
	server.set_xstats_access(cn, 0)
end

local function checkname(name, func)
	send_xstats("checkname " .. name, function(text)
		if text == "free" then func(); return end
		local user, authkey, access = string.match(text, "(%S+) (%S+) (%S+).*")
		if user and authkey and access then
			func(user, authkey, tonumber(access))
		else
			func()
		end
	end)
end

function server.xstats_playerlogin(cn, user, authkey, access)
	access = access or 0
	if access > 0 then server.set_access(cn, access) end
	server.set_xstats_user(cn, user)
	server.set_xstats_requested_user(cn, user)
	server.set_xstats_authkey(cn, authkey)
	server.set_xstats_access(cn, access)
	--server.msg(getmsg("{1} logged in", server.player_displayname(cn), cn, user))
	-- INFO: ../promod/pro_banner.lua displays the country msg with the logged-in info!
	server.log(server.player_name(cn) .. " (" .. cn .. ") logged in to xstats as " .. user)
	server.signal_xstatslogin(cn, user, access)
	if xbotlog then xbotlog(server.player_name(cn) .. " (" .. cn .. ") logged in") end
end

local function registerauthkey(user, authkey)
	server.eval_lua("auth.directory.domain{ id = \"xstats:login\", server = \"LOCAL\" }")
	server.eval_lua("auth.directory.user{ domain = \"xstats:login\", id = \"" .. user .. "\", public_key = \"" .. authkey .. "\" }")
end

local function send_auth_request(cn, user, authkey, access, succfunc, failfunc, gotnouser)
	user = user or ""
	authkey = authkey or ""
	access = access or 0
	if not gotnouser then
		registerauthkey(user, authkey)
	end
	session_id = server.player_sessionid(cn)
	auth.send_quick_request(cn, "xstats:login", function(cn, user_id, domain, status)
		if session_id ~= server.player_sessionid(cn) then return end
		if status == auth.request_status.SUCCESS and (gotnouser or user_id == user) then
			succfunc(cn, user_id, authkey, access)
		else
			failfunc(cn)
		end
	end)
end

local function check_connect(cn, succfunc, failfunc, errfunc)
	unset(cn)
	local sid = server.player_sessionid(cn)
	checkname(server.player_name(cn), function(user, authkey, access)
		if sid ~= server.player_sessionid(cn) then return end
		if user and authkey and access then
			server.set_xstats_requested_user(cn, user)
			server.set_xstats_authkey(cn, authkey)
			server.set_xstats_access(cn, tonumber(access))
			send_auth_request(cn, user, authkey, access, succfunc, failfunc)
		else
			auth.modrequest(cn, "xstats:login", function(cn, user, domain)
				send_xstats("checkloginname " .. user, function(text)
					if sid ~= server.player_sessionid(cn) then return end
					if text == "free\n" or text == "error\n" then errfunc(cn); return end
					local user_, authkey, access = string.match(text, "(%S+) (%S+) (%S+)")
					if (not user_) or (not authkey) or (not access) then errfunc(cn); return end
					server.set_xstats_requested_user(cn, user)
					server.set_xstats_authkey(cn, authkey)
					server.set_xstats_access(cn, tonumber(access))
					registerauthkey(user, authkey)
					auth.start_auth_challenge(cn, user, domain)
				end)
			end)			
			send_auth_request(cn, "", authkey, 0, function(cn, user, authkey, access)
				succfunc(cn, user, authkey, tonumber(server.xstats_access(cn)))
			end, errfunc, true) -- we are NOT using a protected name, and we also have no authkey -> exec errfunc -- last arg (true here) is for letting the func no that we don't have a username
		end
	end)
end

function server.xstats_check_connection(cn, succfunc, failfunc, errfunc) -- called before sendinitclient by promod/connecting.lua [ succfunc = func to exec if player is able to auth // failfunc = func to exec if player isnt able to auth // errfunc = func to exec on errors or if name is not protected ]
	check_connect(cn, succfunc, failfunc, errfunc)
end

local function check_rename(cn, old, new)
	local oldusername = server.xstats_user(cn) or false
	checkname(new, function(user, authkey, access)
		if user and authkey and access then
			if user == oldusername then
				server.set_xstats_authkey(cn, authkey)
				server.set_xstats_access(cn, tonumber(access))
				return
			end
			send_auth_request(cn, user, authkey, access, function(cn, user, authkey, access)
				server.set_xstats_requested_user(cn, user)
				server.set_xstats_authkey(cn, authkey)
				server.set_xstats_access(cn, tonumber(access))
			end, function(cn)
				local sid = server.player_sessionid(cn)
				server.player_msg(cn, badmsg("you have no permission to use this name on this server, please change your name in order to be able to stay connected!"))
				server.sleep(100, function() if sid == server.player_sessionid(cn) then server.disconnect(cn, 0, "use of reserved name") end end)
			end)
		end
	end)
end

local function sendstats(statserv, stats_cns, doing, cnt)
	if doing < cnt then
		local cn = tonumber(stats_cns[doing])
		if server.xstats_user(cn) ~= "" then
			local acc = server.player_accuracy(cn)
			if server.xstats_no_acc then acc = -1 end
			statserv:async_send("save "..server.xstats_user(cn).." "..server.player_frags(cn).." "..server.player_deaths(cn).." "..server.player_teamkills(cn).." "..acc.." "..server.player_flags(cn), function()
				statserv:async_read_until("\n", function()
					sendstats(statserv, stats_cns, doing + 1, cnt)
				end)
			end)
		else
			sendstats(statserv, stats_cns, doing + 1, cnt)
		end
	else
		statserv:close()
	end
end

local function checkplayers()
	if not ((server.playercount - server.speccount) >= 4) then return end
	local cnt = 1
	local stats_cns = {}
	for a in server.gclients() do
		cn = a.cn
		if server.xstats_user(cn) ~= "" then
			stats_cns[cnt] = cn
			cnt = cnt + 1
		end
	end
	if cnt > 1 then
		local statserv
		statserv = net.tcp_client()
		statserv:async_connect(xstats_server, xstats_port, function(errmsg)
			if not errmsg then
				statserv:async_send(xstats_password, function()
					statserv:async_read_until("\n", function(rtext)
						if rtext then
							if not string.match(rtext, "^error.*") then
								sendstats(statserv, stats_cns, 1, cnt)
							else
								statserv:close()
							end
						else
							statserv:close()
						end
					end)
				end)
			else
				statserv:close()
			end
		end)
	end
end

function server.playercmd_login(cn, username)
	local sid = server.player_sessionid(cn)
	if username then
		send_xstats("checkloginname " .. username, function(text)
			if sid ~= server.player_sessionid(cn) then return end
			if text == "free\n" then server.player_msg(cn, cmderr("unknown username")); return end
			if text == "error\n" then server.player_msg(cn, cmderr("unknown error")); return end
			local user, authkey, access = string.match(text, "(%S+) (%S+) (%S+)")
			if (not user) or (not authkey) or (not access) then server.player_msg(cn, cmderr("an error occured")); return end
			send_auth_request(cn, user, authkey, tonumber(access), function(cn, user, authkey, access)
				server.xstats_playerlogin(cn, user, authkey, access)
			end, function(cn)
				server.player_msg(cn, cmderr("authing failed"))
			end)
		end)
	else
		auth.modrequest(cn, "xstats:login", function(cn, user, domain)
			send_xstats("checkloginname " .. user, function(text)
				if sid ~= server.player_sessionid(cn) then return end
				if string.match(text, "^free.*") then server.player_msg(cn, cmderr("unknown username")); return end
				if string.match(text, "^error.*") then server.player_msg(cn, cmderr("unknown error")); return end
				local user_, authkey, access = string.match(text, "(%S+) (%S+) (%S+)")
				if (not user_) or (not authkey) or (not access) then server.player_msg(cn, cmderr("an error occured")); return end
				server.set_xstats_access(cn, tonumber(access))
				registerauthkey(user, authkey)
				auth.start_auth_challenge(cn, user, domain)
			end)
		end)			
		send_auth_request(cn, "", authkey, 0, function(cn, user, authkey, access)
			server.xstats_playerlogin(cn, user, authkey, tonumber(server.xstats_access(cn)))
			server.msg(getmsg("{1} logged in", server.player_displayname(cn)))
		end, function(cn)
			server.player_msg(cn, cmderr("authing failed"))
		end, true) -- last arg (true here) is for letting the func know that we don't have a username
	end
end

function server.playercmd_logout(cn)
	if server.xstats_user(cn) ~= "" then
		unset(cn)
		server.player_msg(cn, getmsg("you were successfully logged out"))
	else
		server.player_msg(cn, cmderr("you're not logged in"))
	end
end

local function statsmsg(mode, user, f, d, t, a, fl, g, k, r)
	return getmsg("xstats - {1} | {2} | frags: {3} | deaths: {4} | teamkills: {5} | accuracy: {6}% | flags: {7} | games: {8} | kpd: {9} | rank: {10}", mode, user, f, d, t, a, fl, g, k, r)
end

function server.playercmd_xstats(cn, mode, name)
	mode = mode or "total"
	if (not (mode == "total" or mode == "year" or mode == "month" or mode == "week" or mode == "day")) then server.player_msg(cn, cmderr("unknown mode, use total, year, month, week or day")); return end
	name = name or server.xstats_user(cn)
	if not name then server.player_msg(cn, cmderr("missing username")); return end
	local sid = server.player_sessionid(cn)
	send_xstats(mode .. " " .. name, function(text)
		if sid ~= server.player_sessionid(cn) then return end
		local fr, de, te, ac, fl, ga, kp, ra = string.match(text, "(%S+) (%S+) (%S+) (%S+) (%S+) (%S+) (%S+) (%S+)")
		if fr and de and te and ac and fl and ga and kp and ra then
			server.player_msg(cn, statsmsg(mode, name, fr, de, te, ac, fl, ga, kp, ra))
		else
			send_xstats("checkname " .. name, function(text)
				if sid ~= server.player_sessionid(cn) then return end
				if text ~= "error" and text ~= "free" then
					server.playercmd_xstats(cn, mode, string.match(text, "(%S+) %S+ %S+"))
				else
					send_xstats("checkloginname " .. name, function(text)
						if sid ~= server.player_sessionid(cn) then return end
						if text ~= "error" and text ~= "free" then
							server.playercmd_xstats(cn, mode, string.match(text, "(%S+) %S+ %S+"))
						else
							server.player_msg(cn, cmderr("unknown username"))
						end
					end)
				end
			end)
		end
	end)
end

function server.playercmd_total(cn, name) server.playercmd_xstats(cn, "total", name) end
function server.playercmd_year(cn, name) server.playercmd_xstats(cn, "year", name) end
function server.playercmd_month(cn, name) server.playercmd_xstats(cn, "month", name) end
function server.playercmd_week(cn, name) server.playercmd_xstats(cn, "week", name) end
function server.playercmd_day(cn, name) server.playercmd_xstats(cn, "day", name) end

server.event_handler("rename", check_rename)

server.event_handler("intermission", checkplayers)

server.interval(180000, function()
	server.msg(getmsg("register at {1} > {2}, profit by {3} and {4}, and {5}, even if the server is full!", "http://is.kicks-ass.org/", "xstats registration", "name protection", "stats recording", "connect whenever you want"))
end)
