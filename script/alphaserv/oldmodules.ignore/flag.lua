flag = {}
flag.owners = {}
flag.pickuptime = {}
flag.dropped = {}
function flag.isowner(cn)
	if not gamemodeinfo.ctf then return false end
	cn = tonumber(cn)
	if not server.valid_cn(cn) then return false end
	return flag.owners[server.player_sessionid(cn)] or false
end
function flag.drop(cn)
	cn = tonumber(cn)
	if not server.valid_cn(cn) then return false end
	flag.owners[server.player_sessionid(cn)] = false
    flag.dropped[server.player_team(cn)] = true
	flag.dropped[server.player_team(cn)] = false
end

function flag.reset()
	cn = tonumber(cn)
	if not server.valid_cn(cn) then return false end
	flag.dropped[server.player_team(cn)] = false
end
function flag.score(cn)
	cn = tonumber(cn)
	if not server.valid_cn(cn) then return false end
	flag.owners[server.player_sessionid(cn)] = false
end
function flag.take(cn)
	cn = tonumber(cn)
	if not server.valid_cn(cn) then return false end
	flag.pickuptime[server.player_sessionid(cn)] = server.uptime
	flag.pickuptime[server.player_team(cn)] = server.uptime
	flag.owners[server.player_sessionid(cn)] = true
end
function flag.team_time(team)
	if not gamemodeinfo.ctf then return 0 end
	return flag.pickuptime[team]
end

--[[
##################
##    events    ##
##################
]]
server.event_handler("takeflag", flag.take)
server.event_handler("scoreflag", flag.score)
server.event_handler("dropflag", flag.drop)
server.event_handler("resetflag", flag.reset)

