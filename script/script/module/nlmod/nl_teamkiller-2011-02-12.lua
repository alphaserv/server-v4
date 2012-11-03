--[[
	script/module/nl_mod/nl_teamkiller.lua
	Hanack (Andreas Schaeffer)
	Created: 18-Nov-2010
	Last Change: 02-Feb-2011
	License: GPL3

	Funktion:
		TK

	API-Methoden:
		xyz.xyz()
			xxx....

	Commands:
		#xyz
			xyz...
]]



--[[
		API
]]

teamkiller = {}
-- teamkiller.limit = server.teamkill_limit or 5
teamkiller.limit_tk = {3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23}
teamkiller.penalty_tk_seconds = {15, 80, 220, 440, 960, 1920, 3600, 3600, 3600, 3600, 3600}
teamkiller.penalty_tkfs_seconds = {25, 90, 480, 960, 1920, 3600, 3600, 3600, 3600, 3600, 3600}
teamkiller.penalty_countdown = 5
teamkiller.level_tk = {}
teamkiller.level_tkfs = {}
teamkiller.flag_tks = {}
teamkiller.namedetection = {}
teamkiller.ipdetection = {}
teamkiller.penalty_active = {}
teamkiller.penalty_id = 0
teamkiller.victim_of = {}
teamkiller.forgivens = {}
teamkiller.last_teamkilled_by = {}


function teamkiller.penalty(cn, seconds)
	teamkiller.penalty_id = teamkiller.penalty_id + 1
	local penalty_id = teamkiller.penalty_id
	teamkiller.penalty_active[penalty_id] = 1
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	teamkiller.namedetection[playerName] = { seconds, teamkiller.level_tk[cn], teamkiller.level_tkfs[cn], penalty_id }
	teamkiller.ipdetection[playerIp] = { seconds, teamkiller.level_tk[cn], teamkiller.level_tkfs[cn], penalty_id }
	spectator.fspec(cn, "TEAMKILLER")
	for s = 1, (seconds / teamkiller.penalty_countdown)-1 do
		server.sleep(s * 5000, function()
			if teamkiller.penalty_active[penalty_id] == 1 then
				messages.warning(cn, {cn}, "TEAMKILLER", string.format("%i orange<seconds penalty left>", (seconds - (s*teamkiller.penalty_countdown))))
			end
		end)
	end
	server.sleep(seconds * 1000, function()
		if teamkiller.penalty_active[penalty_id] == 1 then
			teamkiller.unpenalty(cn, playerName, playerIp)
		end
	end)
end

function teamkiller.unpenalty(cn, playerName, playerIp)
	if not server.valid_cn(cn) then
		messages.debug(cn, players.admins(), "TEAMKILLER", "Could not unspec player "..playerName.." ("..cn.."). Maybe he left the server.")
		return
	end
	if playerName == server.player_name(cn) and playerIp == server.player_ip(cn) then
		spectator.funspec(cn, "TEAMKILLER")
		messages.debug(cn, players.admins(), "TEAMKILLER", "Player "..playerName.." ("..cn..") left penalty box.")
		messages.warning(cn, {cn}, "TEAMKILLER", "Your penalty is over!")
		teamkiller.namedetection[playerName] = nil
		teamkiller.ipdetection[playerIp] = nil
		teamkiller.flag_tks[cn] = 0
	end
end



--[[
		COMMANDS
]]

function server.playercmd_forgive(cn, killer_cn)
	if killer_cn == nil then
		if teamkiller.last_teamkilled_by[cn] >= 0 then
			killer_cn = teamkiller.last_teamkilled_by[cn]
			teamkiller.last_teamkilled_by[cn] = -1
		else
			messages.error(cn, {cn}, "TEAMKILLER", string.format("red<%s, it seems nobody teamkilled you lately>", server.player_displayname(cn)))
			return
		end
	end
	if teamkiller.victim_of[tonumber(killer_cn)] == nil then teamkiller.victim_of[tonumber(killer_cn)] = {} end
	local count = 0
	-- war ich opfer von killer_cn ?
	for _pos, victim_cn in pairs(teamkiller.victim_of[tonumber(killer_cn)]) do
		if cn == victim_cn then
			if teamkiller.forgivens[tonumber(killer_cn)] == nil then teamkiller.forgivens[tonumber(killer_cn)] = 0 end
			teamkiller.forgivens[tonumber(killer_cn)] = teamkiller.forgivens[tonumber(killer_cn)] + 1
			table.remove(teamkiller.victim_of[tonumber(killer_cn)], _pos)
			messages.info(cn, players.all(), "TEAMKILLER", string.format("green<%s has forgiven %s's teamkill>", server.player_displayname(cn), server.player_displayname(tonumber(killer_cn))))
			count = count + 1
		end
		if count == 1 then
			break
		end
	end
	if count == 0 then
		messages.error(cn, {cn}, "TEAMKILLER", string.format("red<%s, you cannot forgive %s. He didn't teamkill you lately.>", server.player_displayname(cn), server.player_displayname(tonumber(killer_cn))))
	else
		server.sleep(100, function()
			if teamkiller.ipdetection[server.player_ip(tonumber(killer_cn))] ~= nil then
				local penalty_id = tonumber(teamkiller.ipdetection[server.player_ip(tonumber(killer_cn))][4])
				if teamkiller.penalty_active[penalty_id] == 1 then
					teamkiller.penalty_active[penalty_id] = 0
					teamkiller.unpenalty(tonumber(killer_cn), server.player_name(tonumber(killer_cn)), server.player_ip(tonumber(killer_cn)))
					if teamkiller.level_tk[tonumber(killer_cn)] > 0 then
						teamkiller.level_tk[tonumber(killer_cn)] = teamkiller.level_tk[tonumber(killer_cn)] - 1
					end
				end
			end
			-- messages.error(cn, players.all(), "TEAMKILLER", "killer_cn: "..killer_cn)
			-- messages.error(cn, players.all(), "TEAMKILLER", "killer_ip: "..server.player_ip(tonumber(killer_cn)))
			-- messages.error(cn, players.all(), "TEAMKILLER", "penalty id: "..penalty_id)
			-- messages.error(cn, players.all(), "TEAMKILLER", "penalty active: "..teamkiller.penalty_active[penalty_id])
			-- messages.error(cn, players.all(), "TEAMKILLER", "killer_level (before): "..teamkiller.level_tk[tonumber(killer_cn)])
		end)
	end
end

function server.playercmd_fg(cn, killer_cn)
	server.playercmd_forgive(cn, killer_cn)
end

function server.playercmd_victims(cn, killer_cn)
	-- war ich opfer von victim_of ?
	if teamkiller.victim_of[tonumber(killer_cn)] == nil then teamkiller.victim_of[tonumber(killer_cn)] = {} end
	messages.info(cn, cn, "TEAMKILLER", string.format("green<Victims of %s>", server.player_displayname(tonumber(killer_cn))))
	for k,victim_cn in pairs(teamkiller.victim_of[tonumber(killer_cn)]) do
		messages.info(cn, cn, "TEAMKILLER", string.format("  green<%s teamkilled %s>", server.player_displayname(tonumber(killer_cn)), server.player_displayname(tonumber(victim_cn))))
	end
end


--[[
		EVENTS
]]

server.event_handler("teamkill", function(cn, victim)
	server.sleep(10, function()
		if teamkiller.forgivens[tonumber(cn)] == nil then teamkiller.forgivens[tonumber(cn)] = 0 end
		local actor_teamkills = server.player_teamkills(cn) - teamkiller.forgivens[cn]
		teamkiller.last_teamkilled_by[victim] = cn

		table.insert(teamkiller.victim_of[cn], victim) -- das opfer in die opferliste

		messages.debug(cn, {cn}, "TEAMKILLER", string.format("teamkiller %i ... victim %i", cn, victim))
		for k,v in pairs(teamkiller.victim_of[cn]) do
			messages.debug(cn, {cn}, "TEAMKILLER", string.format("  --- %i %i", k, v))
		end

		if actor_teamkills == 1 then
			messages.warning(cn, {cn}, "TEAMKILLER", string.format("orange<%s, this server punish teamkillers, therefore you must pay attention when you shoot!>", server.player_displayname(cn)))
		end

		if changeteam.has_flag[victim] == 1 then
			messages.warning(cn, players.all(), "TEAMKILLER", string.format("orange<%s has teamkilled the> red<flagholder %s>", server.player_displayname(cn), server.player_displayname(victim)))
			teamkiller.flag_tks[cn] = server.gamemillis
		end
		
		local got_penalty = false
		for _,limit_tk in pairs(teamkiller.limit_tk) do
			if actor_teamkills == limit_tk then
				messages.warning(cn, players.all(), "TEAMKILLER", string.format("red<%s has been placed on the penalty box because of teamkilling (%i teamkills)!>", server.player_displayname(cn), actor_teamkills))
				teamkiller.level_tk[cn] = teamkiller.level_tk[cn] + 1
				teamkiller.penalty(cn, teamkiller.penalty_tk_seconds[teamkiller.level_tk[cn]])
				got_penalty = true
			end
		end
		if not got_penalty and changeteam.has_flag[victim] ~= 1 and actor_teamkills >= 2 then -- keine doppelten Ausgaben
			messages.warning(cn, players.all(), "TEAMKILLER", string.format("orange<%s did %i teamkills!>", server.player_displayname(cn), actor_teamkills))
		end
	
	end)
end)

server.event_handler("scoreflag", function(cn)
	if (server.gamemillis - teamkiller.flag_tks[cn]) < 3000 then
		teamkiller.flag_tks[cn] = 0
		teamkiller.level_tkfs[cn] = teamkiller.level_tkfs[cn] + 1 
		messages.warning(cn, players.all(), "TEAMKILLER", string.format("red<%s has been placed on the penalty box because of teamkilling for a score!>", server.player_displayname(cn)))
		teamkiller.penalty(cn, teamkiller.penalty_tkfs_seconds[teamkiller.level_tkfs[cn]])
	end
end)

server.event_handler("mapchange", function()
	for i,cn in pairs(players.all()) do
		teamkiller.flag_tks[cn] = 0
		teamkiller.forgivens[cn] = 0
		teamkiller.victim_of[cn] = {} -- mit jedem neuen Spiel werden die Opfer zurueckgesetzt
		teamkiller.last_teamkilled_by[cn] = -1
	end
end)

server.event_handler("connect", function(cn)
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	teamkiller.victim_of[cn] = {}
	teamkiller.last_teamkilled_by[cn] = -1
	if teamkiller.namedetection[playerName] ~= nil then
		server.sleep(5500, function()
			server.player_msg(cn, string.format(red("  [ TEAMKILLER ]  Detected player penalty on reconnect.")))
			teamkiller.level_tk[cn] = teamkiller.namedetection[playerName][2]
			teamkiller.level_tkfs[cn] = teamkiller.namedetection[playerName][3]
			teamkiller.penalty(cn, teamkiller.namedetection[playerName][1])
		end)
	elseif teamkiller.ipdetection[playerIp] ~= nil then
		server.sleep(5500, function()
			server.player_msg(cn, string.format(red("  [ TEAMKILLER ]  Detected player penalty on reconnect.")))
			teamkiller.level_tk[cn] = teamkiller.ipdetection[playerIp][2]
			teamkiller.level_tkfs[cn] = teamkiller.ipdetection[playerIp][3]
			teamkiller.penalty(cn, teamkiller.ipdetection[playerIp][1])
		end)
	else
		teamkiller.flag_tks[cn] = 0
		teamkiller.level_tk[cn] = 0
		teamkiller.level_tkfs[cn] = 0
		teamkiller.forgivens[cn] = 0
		-- wenn ein _neuer_ spieler connected, wird dessen cn aus den victim_of Listen von allen anderen geloescht
		-- d.h. jemand anderes soll nicht fuer die Taten seines CN-Vorgaengers hinhalten... haha
		for _,vcn in pairs(players.all()) do
			for _pos, killer_cn in pairs(teamkiller.victim_of[vcn]) do
				if killer_cn == cn then
					table.remove(teamkiller.victim_of[vcn], _pos)
				end
			end
		end
	end
end)

server.event_handler("disconnect", function(cn)
	local playerName = server.player_name(cn)
	teamkiller.flag_tks[cn] = 0
	teamkiller.level_tk[cn] = 0
	teamkiller.level_tkfs[cn] = 0
	teamkiller.forgivens[cn] = 0
	teamkiller.victim_of[cn] = {} -- wenn man disconnected, ist man kein Opfer mehr
	teamkiller.last_teamkilled_by[cn] = -1
	--messages.error(cn, players.all(), "TEAMKILLER", "CN:"..cn.." playerName:"..playerName)
	if teamkiller.namedetection[playerName] then
		local penalty_id = teamkiller.namedetection[playerName][4]
		teamkiller.penalty_active[penalty_id] = 0
		-- messages.error(cn, players.admins(), "TEAMKILLER", "PENALTY ID:"..penalty_id)
	else
		-- messages.error(cn, players.admins(), "TEAMKILLER", "PENALTY ID: ist nill")
	end
end)

server.event_handler("intermission", function(cn)
	for _,cn in pairs(players.all()) do
		teamkiller.flag_tks[cn] = 0
		teamkiller.level_tk[cn] = 0
		teamkiller.level_tkfs[cn] = 0
	end
end)


