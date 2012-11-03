function send_server_status(no_list)
playerlist = ""
if not no_list then
for a in server.gclients() do
	cn = a.cn
	if server.player_priv(cn) == "admin" then rpriv = "a"
	elseif server.player_priv(cn) == "master" then rpriv = "m"
	else rpriv = "n" end
	if server.player_status(cn) == "spectator" then
		playerlist = playerlist .. " \00300,14" .. server.player_name(cn) .. "\003(" .. cn .. "/s/" .. rpriv .. ")"
	else
		playerlist = playerlist .. " \00300,12" .. server.player_name(cn) .. "\003(" .. cn .. "/p/" .. rpriv .. ")"
	end
end
end

xbotlog("| clients: \00300,12" .. server.playercount.."\003/\00300,12" .. server.maxclients .. "\003 | players: \00300,12" .. server.playercount - server.speccount .. "\003 | specs: \00300,12"..server.speccount.."\003 | map: \00300,12"..server.map.."\003 | mode: \00300,12"..server.gamemode.."\003 | mastermode: \00300,12"..server.mastermode.."\003 | ")
if playerlist ~= "" then
	if not server.xbot_user then
		server.sleep(1300, function()
			xbotlog("list of players:" .. playerlist)
		end)
	else
		xbotlog("list of players:" .. playerlist)
	end
end
end
