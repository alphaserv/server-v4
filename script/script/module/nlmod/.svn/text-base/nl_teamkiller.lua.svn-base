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
teamkiller.module_name = "TEAMKILL DETECTION"
-- teamkiller.limit = server.teamkill_limit or 5
teamkiller.limit_tk = {3, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23}
teamkiller.penalty_tk_seconds = {15, 80, 220, 440, 960, 1920, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600}
teamkiller.penalty_tkfs_seconds = {25, 90, 480, 960, 1920, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600}
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
teamkiller.served_a_sentence = {}
teamkiller.tks = {}
teamkiller.fus = {}
teamkiller.forgive_possible = {}
teamkiller.tklog = {}


function teamkiller.penalty(cn, seconds)
	teamkiller.penalty_id = teamkiller.penalty_id + 1
	local penalty_id = teamkiller.penalty_id
	teamkiller.penalty_active[penalty_id] = 1
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	teamkiller.namedetection[playerName] = { seconds, teamkiller.level_tk[cn], teamkiller.level_tkfs[cn], penalty_id }
	teamkiller.ipdetection[playerIp] = { seconds, teamkiller.level_tk[cn], teamkiller.level_tkfs[cn], penalty_id }
	spectator.fspec(cn, "TEAMKILLER", teamkiller.module_name)
	-- TODO: creating thousands of sleep events?
	for s = 1, (seconds / teamkiller.penalty_countdown)-1 do
		server.sleep(s * 5000, function()
			if server.valid_cn(cn) and teamkiller.penalty_active[penalty_id] == 1 then
				messages.info(-1, {cn}, "TEAMKILLER", string.format("white<%i> orange<seconds penalty left>", (seconds - (s*teamkiller.penalty_countdown))))
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
		-- messages.verbose(cn, players.admins(), "TEAMKILLER", string.format("Could not unspec player %s (%i) --> Maybe he left the server.", playerName, cn))
		return
	end
	if playerName == server.player_name(cn) and playerIp == server.player_ip(cn) then
		spectator.funspec(cn, "TEAMKILLER", teamkiller.module_name)
		messages.debug(cn, players.admins(), "TEAMKILLER", "Player "..playerName.." ("..cn..") left penalty box.")
		messages.info(cn, {cn}, "TEAMKILLER", "orange<Your penalty is over!>")
		teamkiller.namedetection[playerName] = nil
		teamkiller.ipdetection[playerIp] = nil
		teamkiller.flag_tks[cn] = 0
		teamkiller.forgive_possible[cn] = 0
		if teamkiller.served_a_sentence[cn] == nil then
			teamkiller.served_a_sentence[cn] = 1
		else
			teamkiller.served_a_sentence[cn] = teamkiller.served_a_sentence[cn] + 1
		end
	end
end

function teamkiller.increase_tk(cn, victim)
	cn = tonumber(cn)
	victim = tonumber(victim)
	if teamkiller.tks[victim] == nil then
		teamkiller.tks[victim] = {}
	end
	if teamkiller.tks[victim][cn] == nil then
		teamkiller.tks[victim][cn] = 0
	end
	teamkiller.tks[victim][cn] = teamkiller.tks[victim][cn] + 1
	teamkiller.forgive_possible[cn] = 1
end

function teamkiller.add_log(cn, message)
	table.insert(teamkiller.tklog[cn], string.format("  > yellow<%s> %s", os.date(), message))
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
	else
		killer_cn = tonumber(killer_cn)
		if not server.valid_cn(killer_cn) then
			messages.error(cn, {cn}, "TEAMKILLER", string.format("There is no player with cn %i", killer_cn))
			return
		end
	end
	if teamkiller.victim_of[killer_cn] == nil then teamkiller.victim_of[killer_cn] = {} end
	local count = 0
	-- war ich opfer von killer_cn ?
	for _pos, victim_cn in pairs(teamkiller.victim_of[killer_cn]) do
		if cn == victim_cn then
			if teamkiller.forgivens[killer_cn] == nil then teamkiller.forgivens[killer_cn] = 0 end
			teamkiller.forgivens[killer_cn] = teamkiller.forgivens[killer_cn] + 1
			table.remove(teamkiller.victim_of[killer_cn], _pos)
			count = 1
			break
		end
	end
	if count == 0 then
		if server.valid_cn(killer_cn) then
			messages.error(cn, {cn}, "TEAMKILLER", string.format("red<%s, you cannot forgive %s. He didn't teamkill you lately.>", server.player_displayname(cn), server.player_displayname(killer_cn)))
			return
		end
	else
		--if teamkiller.forgive_possible[killer_cn] == 0 then
		--	messages.error(cn, {cn}, "TEAMKILLER", string.format("blue<%s>red<, you cannot forgive> blue<%s>. blue<%s> red<has already served a sentence.>", server.player_displayname(cn), server.player_displayname(killer_cn), server.player_displayname(killer_cn)))
		--	return
		--end
		messages.info(cn, players.all(), "TEAMKILLER", string.format("green<%s has forgiven %s's teamkill>", server.player_displayname(cn), server.player_displayname(killer_cn)))
		teamkiller.add_log(killer_cn, string.format("blue<%s> has forgiven", server.player_name(cn)))
		server.sleep(100, function()
			if teamkiller.ipdetection[server.player_ip(killer_cn)] ~= nil and server.valid_cn(killer_cn) then
				local penalty_id = tonumber(teamkiller.ipdetection[server.player_ip(killer_cn)][4])
				if teamkiller.penalty_active[penalty_id] == 1 then
					teamkiller.penalty_active[penalty_id] = 0
					teamkiller.unpenalty(killer_cn, server.player_name(killer_cn), server.player_ip(killer_cn))
					if teamkiller.level_tk[killer_cn] > 0 then
						teamkiller.level_tk[killer_cn] = teamkiller.level_tk[killer_cn] - 1
					end
				end
			end
		end)
	end
end
server.playercmd_fg = server.playercmd_forgive

function server.playercmd_fuckyou(cn)
	if teamkiller.last_teamkilled_by[cn] >= 0 and teamkiller.tks[cn] ~= nil then
		local lastkiller = teamkiller.last_teamkilled_by[cn]
		if teamkiller.tks[cn][lastkiller] ~= nil then
			if teamkiller.tks[cn][lastkiller] >= 2 then
				messages.warning(cn, {cn, lastkiller}, "TEAMKILLER", string.format("blue<%s> thinks that blue<%s> did %i teamkills on purpose and gave you an additional penalty", server.player_displayname(cn), server.player_displayname(lastkiller), teamkiller.tks[cn][lastkiller]))
				teamkiller.level_tk[lastkiller] = teamkiller.level_tk[lastkiller] + 1
				teamkiller.penalty(lastkiller, teamkiller.penalty_tk_seconds[teamkiller.level_tk[lastkiller]])
				teamkiller.tks[cn][lastkiller] = 0
				teamkiller.fus[cn] = teamkiller.fus[cn] + 2
				teamkiller.add_log(lastkiller, string.format("blue<%s> #fu'ed and gave an additional penalty", server.player_name(cn)))
			else
				if teamkiller.tks[cn][lastkiller] > 0 then
					messages.info(cn, players.all(), "TEAMKILLER", string.format("blue<%s> complains a little about blue<%s>'s teamkill", server.player_displayname(cn), server.player_displayname(lastkiller)))
					teamkiller.tks[cn][lastkiller] = 0
					teamkiller.fus[cn] = teamkiller.fus[cn] + 1
					teamkiller.add_log(lastkiller, string.format("blue<%s> #fu'ed", server.player_name(cn)))
				else
					messages.error(cn, {cn}, "TEAMKILLER", string.format("red<%s, you have already complained about the teamkill!>", server.player_displayname(cn)))
				end
			end
		end
	else
		messages.error(cn, {cn}, "TEAMKILLER", string.format("red<%s, it seems nobody teamkilled you lately>", server.player_displayname(cn)))
	end
end
server.playercmd_fu = server.playercmd_fuckyou

function server.playercmd_victims(cn, killer_cn)
	-- war ich opfer von victim_of ?
	if killer_cn == nil then return end
	killer_cn = tonumber(killer_cn)
	if teamkiller.victim_of[killer_cn] == nil then
		teamkiller.victim_of[killer_cn] = {}
	end
	if #teamkiller.victim_of[killer_cn] == 0 then
		messages.info(cn, {cn}, "TEAMKILLER", string.format("blue<%s> did no teamkills.", server.player_displayname(killer_cn)))
		return
	end
	messages.info(cn, {cn}, "TEAMKILLER", string.format("Victims of blue<%s>", server.player_displayname(killer_cn)))
	disconnected_victims = 0
	for k, victim_cn in pairs(teamkiller.victim_of[killer_cn]) do
		victim_cn = tonumber(victim_cn)
		if server.valid_cn(victim_cn) then
			messages.info(cn, {cn}, "TEAMKILLER", string.format("  blue<%s> teamkilled blue<%s>", server.player_displayname(killer_cn), server.player_displayname(victim_cn)))
		else
			disconnected_victims = disconnected_victims + 1
		end
	end
	if disconnected_victims > 0 then
		messages.info(cn, {cn}, "TEAMKILLER", string.format("  ... blue<%s> teamkilled %i disconnected players", server.player_displayname(killer_cn), disconnected_victims))
	end
end

function server.playercmd_fus(cn, killer_cn)
	if not hasaccess(cn, admin_access) then return end
	if killer_cn == nil then return end
	killer_cn = tonumber(killer_cn)
	if teamkiller.fus[killer_cn] == 0 then
		messages.info(cn, {cn}, "TEAMKILLER", string.format("blue<%s> got no #fu", server.player_displayname(killer_cn)))
	else
		messages.info(cn, {cn}, "TEAMKILLER", string.format("blue<%s> got %i times #fu", server.player_displayname(killer_cn), teamkiller.fus[killer_cn]))
	end
end

function server.playercmd_forgives(cn, killer_cn)
	if not hasaccess(cn, admin_access) then return end
	if killer_cn == nil then return end
	killer_cn = tonumber(killer_cn)
	if teamkiller.fus[killer_cn] == 0 then
		messages.info(cn, {cn}, "TEAMKILLER", string.format("blue<%s> got no #forgive", server.player_displayname(killer_cn)))
	else
		messages.info(cn, {cn}, "TEAMKILLER", string.format("blue<%s> got %i times #forgive", server.player_displayname(killer_cn), teamkiller.forgivens[killer_cn]))
	end
end

function server.playercmd_tklog(cn, killer_cn)
	if not hasaccess(cn, admin_access) then return end
	if killer_cn == nil then return end
	killer_cn = tonumber(killer_cn)
	if #teamkiller.tklog[killer_cn] == 0 then
		messages.info(cn, {cn}, "TEAMKILLER", string.format("No teamkill entries for blue<%s (%i)>", server.player_name(killer_cn), cn))
	else
		messages.info(cn, {cn}, "TEAMKILLER", string.format("Teamkiller log for blue<%s (%i)>", server.player_name(killer_cn), cn))
		for k, msg in pairs(teamkiller.tklog[killer_cn]) do
			messages.info(cn, {cn}, "TEAMKILLER", msg)
		end
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
		teamkiller.increase_tk(cn, victim)

		table.insert(teamkiller.victim_of[cn], victim) -- das opfer in die opferliste

		messages.info(tonumber(cn), {tonumber(victim)}, "TEAMKILLER", string.format("You have been teamkilled by blue<%s>. To forgive the teamkill, type orange<#fg> in chat.", server.player_displayname(tonumber(cn))))

		messages.debug(cn, {cn}, "TEAMKILLER", string.format("teamkiller %i ... victim %i", cn, victim))
		for k,v in pairs(teamkiller.victim_of[cn]) do
			messages.debug(cn, {cn}, "TEAMKILLER", string.format("  --- %i %i", k, v))
		end

		if actor_teamkills == 1 then
			messages.warning(cn, {cn}, "TEAMKILLER", string.format("orange<%s, this server punish teamkillers, therefore you must pay attention when you shoot!>", server.player_displayname(cn)))
		end

		if changeteam.has_flag[victim] == 1 then
			messages.warning(cn, players.all(), "TEAMKILLER", string.format("orange<%s(%s) has teamkilled the> red<flagholder %s>", server.player_displayname(cn), tostring(cn), server.player_displayname(victim)))
			teamkiller.flag_tks[cn] = server.gamemillis
			teamkiller.add_log(cn, string.format("red<teamkilled the flagholder %s>", server.player_name(tonumber(victim))))
		else
			teamkiller.add_log(cn, string.format("teamkilled blue<%s>", server.player_name(tonumber(victim))))
		end
		
		local got_penalty = false
		for _,limit_tk in pairs(teamkiller.limit_tk) do
			if actor_teamkills == limit_tk then
				messages.warning(cn, players.all(), "TEAMKILLER", string.format("red<%s has been placed on the penalty box because of teamkilling (%i teamkills)!>", server.player_displayname(cn), actor_teamkills))
				teamkiller.level_tk[cn] = teamkiller.level_tk[cn] + 1
				teamkiller.penalty(cn, teamkiller.penalty_tk_seconds[teamkiller.level_tk[cn]])
				got_penalty = true
				teamkiller.add_log(cn, string.format("orange<got penalty for %i teamkills>", actor_teamkills))
			end
		end
		if not got_penalty and changeteam.has_flag[victim] ~= 1 and actor_teamkills >= 2 then -- keine doppelten Ausgaben
			messages.warning(cn, players.all(), "TEAMKILLER", string.format("orange<%s(%s) did %i teamkills!>", server.player_displayname(cn), tostring(cn), actor_teamkills))
		end
	
	end)
end)

server.event_handler("scoreflag", function(cn)
	if (server.gamemillis - teamkiller.flag_tks[cn]) < 3000 then
		teamkiller.flag_tks[cn] = 0
		teamkiller.level_tkfs[cn] = teamkiller.level_tkfs[cn] + 1 
		messages.warning(cn, players.all(), "TEAMKILLER", string.format("red<%s has been placed on the penalty box because of teamkilling for a score!>", server.player_displayname(cn)))
		teamkiller.penalty(cn, teamkiller.penalty_tkfs_seconds[teamkiller.level_tkfs[cn]])
		teamkiller.add_log(cn, "red<teamkilled for a score>")
	end
end)

server.event_handler("mapchange", function()
	for i,cn in pairs(players.all()) do
		teamkiller.flag_tks[cn] = 0
		teamkiller.forgivens[cn] = 0
		teamkiller.victim_of[cn] = {} -- mit jedem neuen Spiel werden die Opfer zurueckgesetzt
		teamkiller.last_teamkilled_by[cn] = -1
		teamkiller.tks[cn] = nil
		teamkiller.fus[cn] = 0
		teamkiller.forgive_possible[cn] = 0
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
		teamkiller.fus[cn] = 0
		teamkiller.forgive_possible[cn] = 0
		teamkiller.tklog[cn] = {}
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
	teamkiller.served_a_sentence[cn] = 0
	teamkiller.tks[cn] = nil
	teamkiller.fus[cn] = 0
	teamkiller.forgive_possible[cn] = 0
	teamkiller.tklog[cn] = {}
	for _,tcn in pairs(players.all()) do
		if teamkiller.tks[tcn] ~= nil then
			teamkiller.tks[tcn][cn] = nil
		end
	end
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
		teamkiller.tks[cn] = nil
		teamkiller.fus[cn] = 0
		teamkiller.forgive_possible[cn] = 0
	end
end)



--[[
		EXTRACTCOMMAND RULES
]]

extractcommand.register("fg", false, server.playercmd_fg)
extractcommand.register("fu", false, server.playercmd_fu)
