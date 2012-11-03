require("geoip")

local name_mask = nil
local ip_mask = nil
local country_mask = nil
local pwd_mask = nil

function is_invited(cn, name, ip, pwd)
	if name_mask then
		if string.match(string.lower(name), string.lower(name_mask)) or string.find(string.lower(name), string.lower(name_mask)) then return true end
	end
	if ip_mask then
		if string.find(ip, ip_mask) then return true end
	end
	if country_mask then
		if string.match(string.lower(country), string.lower(country_mask)) then return true end
	end
	if pwd_mask then
		if pwd == server.hashpassword(cn, pwd_mask) then return true end
	end
	return false
end

function server.playercmd_invite(cn, what, mask)
	if cn == "HELP" then return "#invite <name/ip/country/pwd> <value>", "forces the server to let players that match the given things connect" end
	if not hasaccess(cn, invite_access) then return end
	if not what then server.player_msg(cn, cmderr("missing match mode")) end
	if what == "name" then
		name_mask = mask
		if mask then server.msg(getmsg("{1} enabled {2} inviting ({3})", server.player_displayname(cn), what, mask)) else server.msg(getmsg("{1} disabled {2} inviting", server.player_displayname(cn), what)) end
	elseif what == "ip" then
		ip_mask = mask
		if mask then server.msg(getmsg("{1} enabled {2} inviting ({3})", server.player_displayname(cn), what, mask)) else server.msg(getmsg("{1} disabled {2} inviting", server.player_displayname(cn), what)) end
	elseif what == "country" then
		country_mask = mask
		if mask then server.msg(getmsg("{1} enabled {2} inviting ({3})", server.player_displayname(cn), what, mask)) else server.msg(getmsg("{1} disabled {2} inviting", server.player_displayname(cn), what)) end
	elseif what == "pwd" then
		pwd_mask = mask
		if mask then server.msg(getmsg("{1} enabled {2} inviting ({3})", server.player_displayname(cn), what, mask)) else server.msg(getmsg("{1} disabled {2} inviting", server.player_displayname(cn), what)) end
	else
		server.player_msg(cn, cmderr("unknown match mode"))
	end
end
