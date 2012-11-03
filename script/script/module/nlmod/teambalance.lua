--[[

	player moving team balancing

]]


autobalance = true

function server.playercmd_autobalance(cn, active)
	if not hasaccess(cn, autobalance_access) then return end
	if active == "1" then
		autobalance = true
		server.player_msg(cn, togglemsg("autobalance", true))
	else
		autobalance = false
		server.player_msg(cn, togglemsg("autobalance", false))
	end
end

local event = {}

local is_intermission = false
local search_dead_player = false


local function team_size(team)

	size = 0

	for a in server.gclients() do
		cn = a.cn
		if server.player_status(cn) ~= "spectator" then
			if server.player_team(cn) == team then size = size + 1 end
		end
	end

	return size

end

local function noscoreplayers(team)
	local cnt = 0
	for ci in server.gclients() do
		cn = ci.cn
		if server.player_status(cn) ~= "spectator" and server.player_team(cn) == team and server.player_flags(cn) == 0 then
			cnt = cnt + 1
		end
	end
	return cnt
end

local function other_team(team)

	if team == "evil" then
		return "good"
	else
		return "evil"
	end

end


local function fuller_team()

	if team_size("good") > team_size("evil") then
		return "good"
	else
		return "evil"
	end

end


local function move_player(cn, team)

	if server.player_team(cn) == team then
		server.changeteam(cn,other_team(team))
		server.player_msg(cn, getmsg("you switched team for teambalance"))

		search_dead_player = false

		check_balance(5000)
	end

end



local function check_player(cn)
	if (not string.find(server.gamemode, "ctf")) and (not string.find(server.gamemode, "team")) and (not string.find(server.gamemode, "protect")) and (not string.find(server.gamemode, "hold")) then return end
	if string.find(server.gamemode, "coop") then return end
	if tonumber(server.mastermode) ~= 0 then return end
	if server.player_status(cn) == "spectator" then return end
	if autobalance then
		if server.player_flags(cn) > 0 and noscoreplayers(server.player_team(cn)) > 0 then return end
		me_team = team_size(server.player_team(cn))
		o_team = team_size(other_team(server.player_team(cn)))
		diff = me_team - o_team
		if diff < 0 then diff = o_team - me_team end
		if diff > 1 then
			if me_team > o_team then
				server.changeteam(cn, other_team(server.player_team(cn)))
				server.player_msg(cn, getmsg("you switched team for teambalance"))
			end
		end
	end
end


server.event_handler("frag", function(tcn, acn)
	server.sleep(10, function() check_player(tcn) end)
end)

server.event_handler("suicide", function(cn)
	server.sleep(10, function() check_player(cn) end)
end)

local function is_enabled()
	if autobalance and gamemodeinfo.teams and not (server.gamemode == "coop edit") and server.mastermode == 0 and is_intermission == false then -- activate conditions
		return true
	else
		return false
	end
end
