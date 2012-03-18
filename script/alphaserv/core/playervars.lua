--[[ "geoip"

alpha.playervars = {}
alpha.playervars.vars = {}
alpha.playervars.static = {}
alpha.playervars.ipvars = {}
alpha.playervars.defaults = {}
alpha.playervars.backup_fields = {}
alpha.playervars.ipvar_fields = {}

function alpha.playervars.set_backup(name)
	alpha.playervars.backup_fields[name] = true
end
function alpha.playervars.set_ipvar(name)
	alpha.playervars.ipvar_fields[name] = true
end

function alpha.playervars.set_default(name, value, mod)
	alpha.playervars.defaults[name] = value
	if mod == "backup" then
		alpha.playervars.set_backup(name)
	elseif mod =="ipvar" then
		alpha.playervars.set_ipvar(name)
	end
end
alpha.playervars.set_default("user_id", -1)

function alpha.playervars.get(cn, field)
	return alpha.playervars.vars[server.player_sessionid(cn)][tostring(field)] or false
end

function alpha.playervars.set(cn, field, value)
	alpha.playervars.vars[server.player_sessionid(tonumber(cn))][tostring(field)] = value
	log.write("setting ["..server.player_name(cn).."("..cn..")]["..field.."] = "..tostring(value), "core_vars")
end

function alpha.playervars.update(cn, var, way, by)
	local value = alpha.playervars.get(cn, var) or 0
	local set = value
	if way == "++" then
		set = value + 1
	elseif way == "--" then
		set = value - 1
	elseif way == "+" then
		set = value + by
	elseif way == "-" then
		set = value - by
	elseif way == "/" then
		set = value / by
	elseif way == "^" then
		set = value ^ by
	elseif way == "set" or way == "=" then
		set = by
	elseif way == "*" then
		set = value * by
	else
		return false
	end
	alpha.playervars.set(cn, var, set)
end

function alpha.playervars.save(cn)
	alpha.playervars.ipvars[server.player_ip(cn)] = {}
	alpha.playervars.static[server.player_id(cn)] = {}
	for name, value in pairs(alpha.playervars.vars[server.player_sessionid(tonumber(cn))]) do
		if alpha.playervars.backup_fields[name] then
			alpha.playervars.static[server.player_id(cn)][name] = value
		elseif alpha.playervars.ipvar_fields[name] then
			alpha.playervars.ipvars[server.player_ip(cn)][name] = value
		end
	end
end

server.interval(1000, function()
--backup a lot
	for i, cn in pairs(players.all()) do
		alpha.playervars.save(cn)
	end

end)

function alpha.playervars.restore(cn)
	for name, value in pairs(alpha.playervars.static[server.player_id(cn)] or {}) do
		alpha.playervars.update(cn, name, "set", value)
	end
	
	for name, value in pairs(alpha.playervars.ipvars[server.player_id(cn)] or {}) do
		alpha.playervars.update(cn, name, "set", value)
	end
end

function alpha.playervars.createplayer (cn)
	local id = server.player_sessionid(cn)
	if id == -1 then
		log.write("could not create an player with cn "..cn, "core_vars")
		return nil
	end
	if alpha.playervars.vars[id] then
		log.write("could not create an player with cn "..cn.." that one alredy exist" , "core_vars")
		return false
	end
	alpha.playervars.vars[id] = {
		display_name = tostring(server.player_displayname(cn)),
		name = tostring(server.player_name(cn)),
		ip = tostring(server.player_ip(cn)),
		country = tostring(geoip.ip_to_country(server.player_ip(cn)) or "Unkown"),
		team = tostring(server.player_team(cn)),
		lang = "en",
		playing = false,
		isbot = server.player_isbot(cn),
		--stats
		frags			= 0,
		deaths			= 0,
		suicides		= 0,
		misses			= 0,
		shots			= 0,
		hits_made		= 0,
		hits_get		= 0,
		tk_made     	= 0,
		tk_get			= 0,
		tk_by			= -1,
		flags_returned	= 0,
		flags_stolen	= 0,
		flags_gone		= 0,
		flags_scored	= 0,
		total_scored	= 0,
		flagholder = false
	}
	local country = tostring(geoip.ip_to_country(server.player_ip(cn)) or "Unkown")
	if country == "Netherlands" then
		alpha.playervars.vars[id].lang = "nl"
	elseif country == "Germany" then
		alpha.playervars.vars[id].lang = "de"
	end
	for name, value in pairs(alpha.playervars.defaults) do
		alpha.playervars.set(cn, name, value)
	end
end
function alpha.playervars.reset_player(cn)
	local id = server.player_sessionid(cn)
	if id == -1 then
		log.write("could not create an player with cn "..cn, "core_vars")
		return nil
	end
	if not alpha.playervars.vars[id] then
		alpha.playervars.createplayer (cn)
	end
	alpha.playervars.update(cn, "frags", "set", 0)
	alpha.playervars.update(cn, "deaths", "set", 0)
	alpha.playervars.update(cn, "suicides", "set", 0)
	alpha.playervars.update(cn, "misses", "set", 0)
	alpha.playervars.update(cn, "shots", "set", 0)
	alpha.playervars.update(cn, "hits_made", "set", 0)
	alpha.playervars.update(cn, "hits_get", "set", 0)
	alpha.playervars.update(cn, "tk_made", "set", 0)
	alpha.playervars.update(cn, "tk_get", "set", 0)
	alpha.playervars.update(cn, "tk_by", "set", -1)
	alpha.playervars.update(cn, "flags_returned", "set", 0)
	alpha.playervars.update(cn, "flags_stolen", "set", 0)
	alpha.playervars.update(cn, "flags_gone", "set", 0)
	alpha.playervars.update(cn, "flags_scored", "set", 0)
	alpha.playervars.update(cn, "total_scored", "set", 0)
	alpha.playervars.update(cn, "flagholder", "set", false)
end

server.event_handler("connect", function(cn)
	alpha.playervars.createplayer(cn)
	alpha.playervars.restore(cn)
end)

server.event_handler("maploaded", alpha.playervars.reset_player)
server.event_handler("teamkill", function(cn, targetcn)
	alpha.playervars.update(cn, "tk_made", "++")
	alpha.playervars.update(targetcn, "tk_get", "++")
	alpha.playervars.update(targetcn, "tk_by", "set", server.player_id(cn))
end)

server.event_handler("frag", function(targetcn, cn)
	alpha.playervars.update(cn, "frags", "++")
	alpha.playervars.update(targetcn, "deaths", "++")
end)

server.event_handler("shot", function(cn, gun, hit)
	alpha.playervars.update(cn, "shots", "++")
	if tostring(hit)=="1" then
		alpha.playervars.update(cn, "hits_made", "++")
	else
		alpha.playervars.update(cn, "misses", "++")
	end
end)

server.event_handler("suicide", function(cn)
		alpha.playervars.update(cn, "suicides", "++")
end)

server.event_handler("takeflag", function(cn, team)
	alpha.playervars.update(cn, "flags_stolen", "++")
	alpha.playervars.update(cn, "flagholder", "set", true)
	for a, teamcn in pairs(server.team_players(team)) do
		alpha.playervars.update(teamcn, "flags_gone", "++")
	end
end)

server.event_handler("dropflag", function(cn, team)
	alpha.playervars.update(cn, "flagholder", "set", false)
end)

server.event_handler("scoreflag", function(cn, team)
	alpha.playervars.update(cn, "flags_scored", "++")
	alpha.playervars.update(cn, "flagholder", "set", false)
	if team == "evil" then oteam = "good" end
	if team == "good" then oteam = "evil" end
	for a, teamcn in pairs(server.team_players(oteam)) do
		alpha.playervars.update(teamcn, "total_scored", "++")
	end
end)

server.event_handler("returnflag", function(cn, team)
	alpha.playervars.update(cn, "flags_returned", "++")
end)

server.event_handler("damage", function(cn, actorcn, damage, gun)
	alpha.playervars.update(cn, "hits_get", "++")
end)

server.event_handler("rename", function(cn, oldname, newname)
	alpha.playervars.update(cn, "name", "set", server.player_name(cn))
	alpha.playervars.update(cn, "display_name", "set", server.player_displayname(cn))
end)

server.event_handler("reteam", function(cn, oldteam, newteam)
	alpha.playervars.update(cn, "team", "set", newteam)
end)

server.event_handler("spectator", function(cn, val)
	if val==0 then
		alpha.playervars.update(cn, "playing", "set", true)
	end
	if val==1 then
		alpha.playervars.update(cn, "playing", "set", false)
	end
end)

server.event_handler("disconnect", function(cn, oldteam, newteam)
		alpha.playervars.update(cn, "playing", "set", false)
		alpha.playervars.save(cn)
end)]]
