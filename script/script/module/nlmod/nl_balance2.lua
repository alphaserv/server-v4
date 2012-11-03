--[[
	script/module/nl_mod/nl_balance2.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		21-Jun-2012
	Last Modified:	24-Jun-2012
	License:		GPL3

	Funktionen:
		* Unterschiedliche (Wahrnehmungs-) Ebenen: Spieler verstehen unter Balance
		  jeweils etwas unterschiedliches. Ein gutes Balancesystem sollte all diese
		  Punkte so gut es geht berücksichtigen
			* Nach der Anzahl von Spielern
			* Nach der Leistung der Spieler
				* Frags
				* Flags
		* Auswahl, wer gebalanced werden soll:
			* No-Flagholder: Flagholder dürfen nicht gebalanced werden (nie)
			* Spieler, die in einem Spiel bereits gebalanced wurden, sollten kein
			  zweites Mal gebalanced werden
			* Spieler, die eine gute Leistung haben, sollen weniger oft gebalanced
			  werden
		* Unterschiedliche Aktionen: das Balancessystem sollte angemessen auf eine
		  unbalancierte Situation reagieren. So ist es wünschenswert, wenn ein Spieler
		  nicht während er am Leben ist gebalanced wird. Manchmal muss aber, damit der
		  Spielbetrieb aufrecht erhalten werden kann, sofort gebalanced werden.
			* Hard Balance: Spieler werden sofort geswitched, ohne dass abgewartet
			  wird, bis sie/er stirbt
			* Sanftes Balancen: Spieler werden erst geswitched, wenn sie sterben
		* Unterschiedliche Eingreifzeiten: Es sollte umso schneller eingegriffen
		  werden, desto unbalancierter das Spiel ist
			* x>2 : 0
				sofort, hard
			* x   : x-4
				sofort, hard
			* x   : x-3
				sofort, soft
			* x   : x-2
				h
		 
	

	API-Methoden:
		balance.check()
			Prueft, ob gebalanced werden muss

	Konfigurations-Variablen:
		balance.enabled
			Ist das Balancesystem aktiv?
		balance.minactiontime
			Wieviel Zeit muss zwischen zwei Balanceaktionen liegen?
		
	Laufzeit-Variablen:
		balance.last_action
			Wann wurde zum letzten Mal gebalanced?

]]



--[[
		API
]]

balance = {}
-- Config Vars
balance.enabled = 1
balance.cancontrolrespawn = 1
balance.testing = 0
balance.documentation = 1
balance.score_base = 5
balance.guard_dist = { 100, 100, 80 } -- x, y, z
-- Timings
balance.minactiontime = 12000
balance.maxjobwait = 10000
balance.clearjobafter = 20000
balance.unbalance_detector_interval = 6000 -- means: reaction time of 0 - 6 seconds
balance.jobs_interval = 2000
balance.check_delay_after_mapchange = 10000
-- Weighted Skill Points per Game Mode
balance.factor = {}
balance.factor["insta ctf"] = {}
balance.factor["insta ctf"]["frags"] = 1
balance.factor["insta ctf"]["flagreturned"] = 5
balance.factor["insta ctf"]["shotflagholder"] = 10
balance.factor["insta ctf"]["teamkills"] = -10
balance.factor["insta ctf"]["suicides"] = -5
balance.factor["insta ctf"]["deaths"] = -1
balance.factor["insta ctf"]["damagedealth"] = 0
balance.factor["insta ctf"]["damagewasted"] = 0
balance.factor["efficiency ctf"] = balance.factor["insta ctf"]
-- balance.factor["efficiency ctf"]["damagedealth"] = 0.4
-- balance.factor["efficiency ctf"]["damagewasted"] = -0.2
balance.factor["ctf"] = balance.factor["efficiency ctf"]
-- Bonus Factors per Game Mode
balance.bonus_factor = {}
balance.bonus_factor["insta ctf"] = {}
balance.bonus_factor["insta ctf"]["playedgames"] = 1.2 -- score[4] bonus of 20%
balance.bonus_factor["insta ctf"]["alive"] = 1.4 -- score[4] bonus of 40%
balance.bonus_factor["insta ctf"]["guard"] = 4.0 -- score[4] bonus of 400%
balance.bonus_factor["insta ctf"]["scorer"] = 8.0 -- score[4] bonus of 800% (per score!)
balance.bonus_factor["insta ctf"]["gotbalanced"] = 12.0 -- score[4] bonus of 1200% (per balance!)
balance.bonus_factor["insta ctf"]["gotbalancedbefore"] = 1.4 -- score[4] bonus of 40%
balance.bonus_factor["efficiency ctf"] = balance.bonus_factor["insta ctf"]
balance.bonus_factor["ctf"] = balance.bonus_factor["efficiency ctf"]
-- Balance job types
balance.SOFT = 0
balance.HARD = 1
-- Balance strategies
balance.BESTFIT = 1
balance.WORSTFIT = 2
balance.DEADPLAYER = 3
-- running vars
balance.unbalance_detector = {}
balance.unbalance_validator = {}
balance.option = {}
balance.jobs = {}
balance.autodisabled = 0
balance.last_action = 0
balance.last_check = 0
balance.last_mapchange = 0
balance.job_wait = 0
balance.gotbalanced = {}
balance.gotbalancedbefore = {}
balance.flags = {}
balance.flagreturned = {}
balance.shotflagholder = {}
balance.flagholder = {}
balance.playedgames = {}



-- returns true if player doesn't have the flag
function balance.allow_switch(cn)
	balance.write_documentation("allow_switch", { { changeteam.has_flag[cn] ~= nil, changeteam.has_flag[cn] == 0, server.player_status_code(cn) ~= server.SPECTATOR, changeteam.has_flag[cn] ~= nil and changeteam.has_flag[cn] == 0 and server.player_status_code(cn) ~= server.SPECTATOR } } )
	return changeteam.has_flag[cn] ~= nil and changeteam.has_flag[cn] == 0 and server.player_status_code(cn) ~= server.SPECTATOR
end

function balance.switch_team(cn, force)
	if balance.enabled == 0 then return end
	if balance.allow_switch(cn) or (force ~= nil and force == 1) then
		changeteam.allow = 1
		server.sleep(100, function()
			changeteam.allow = 0
		end)
		local success = false
		if server.valid_cn(cn) then
			if server.player_team(cn) == "good" then
				success = changeteam.changeteam(cn, "evil", true)
			else
				success = changeteam.changeteam(cn, "good", true)
			end
		end
		if success then
			if balance.cancontrolrespawn == 1 then
				server.sleep(500, function()
					respawn.disable_next_check(cn)
					server.spawn_player(cn)
				end)
			else
				-- no auto respawn
			end
			balance.gotbalanced[cn] = balance.gotbalanced[cn] + 1
			balance.last_action = server.gamemillis
			messages.info(-1, players.admins(), "BALANCE", string.format("Dear Admin! Psssssst, blue<%s (%i)> has been balanced", server.player_displayname(cn), cn))
		end
		balance.write_documentation("switch_team", { { server.player_displayname(cn), cn, force, success }  })
		return success
	else
		messages.debug(cn, players.admins(), "BALANCE", string.format("not allowed to switch player %s", server.player_displayname(cn)))
		return false
	end
end

function balance.unbalance(level)
	for i,cn in pairs(players.all()) do
		if server.player_status_code(cn) ~= server.SPECTATOR and math.random(0, level) < level then
			balance.switch_team(cn, 1)
		end
	end
end

function balance.get_score(cn)
	if balance.flagreturned[cn] == nil then balance.flagreturned[cn] = 0 end
	if balance.shotflagholder[cn] == nil then balance.shotflagholder[cn] = 0 end
	balance.write_documentation("get_score", {{cn, server.player_frags(cn), balance.flagreturned[cn], balance.shotflagholder[cn], server.player_teamkills(cn), server.player_suicides(cn), server.player_deaths(cn), server.player_damage(cn), server.player_damagewasted(cn)}})
	return server.player_frags(cn) * balance.factor[maprotation.game_mode]["frags"] +
		balance.flagreturned[cn] * balance.factor[maprotation.game_mode]["flagreturned"] +
		balance.shotflagholder[cn] * balance.factor[maprotation.game_mode]["shotflagholder"] +
		server.player_teamkills(cn) * balance.factor[maprotation.game_mode]["teamkills"] +
		server.player_suicides(cn) * balance.factor[maprotation.game_mode]["suicides"] +
		server.player_deaths(cn) * balance.factor[maprotation.game_mode]["deaths"] +
		server.player_damage(cn) * balance.factor[maprotation.game_mode]["damagedealth"] +
		server.player_damagewasted(cn) * balance.factor[maprotation.game_mode]["damagewasted"]
end

function balance.get_calculated_bonus(cn, score_without_bonus)

	-- bonus for playing more the 3 games
	local bonus_playedgames = 1.0
	if balance.playedgames[cn] == nil then
		balance.playedgames[cn] = 0
	elseif balance.playedgames[cn] >= 3 then
		bonus_playedgames = balance.bonus_factor[maprotation.game_mode]["playedgames"]
	end

	-- bonus for being alive
	local bonus_isalive = 1.0
	if server.player_status_code(cn) == server.ALIVE then
		bonus_isalive = balance.bonus_factor[maprotation.game_mode]["alive"]
	end

	-- bonus for being a guard
	local bonus_guard = 1.0
	local team = server.player_team(cn)
	if balance.flagholder[team] ~= nil and balance.flagholder[team] ~= cn then -- this team has an flagholder and the flagholder is not the current player
		local x1, y1, z1 = server.player_pos(cn) -- position of this player
		local x2, y2, z2 = server.player_pos(balance.flagholder[team]) -- position of the flagholder of the team of the player
		if
			math.abs(x1-x2) < balance.guard_dist[1] and
			math.abs(y1-y2) < balance.guard_dist[2] and
			math.abs(z1-z2) < balance.guard_dist[3]
		then
			bonus_guard = balance.bonus_factor[maprotation.game_mode]["guard"]
			messages.debug(-1, players.admins(), "BALANCE", string.format("%s is guard of %s", server.player_name(cn), server.player_name(balance.flagholder[team])))
		end
	end
	
	-- bonus for being a scorer
	local bonus_scorer = 1.0
	if balance.flags[cn] == nil then
		balance.flags[cn] = 0
	elseif balance.flags[cn] > 0 then
		bonus_scorer = balance.flags[cn] * balance.bonus_factor[maprotation.game_mode]["scorer"]
	end

	-- bonus for already got balanced
	local bonus_gotbalanced = 1.0
	if balance.gotbalanced[cn] == nil then
		balance.gotbalanced[cn] = 0
	elseif balance.gotbalanced[cn] > 0 then
		bonus_gotbalanced = balance.gotbalanced[cn] * balance.bonus_factor[maprotation.game_mode]["gotbalanced"]
	end

	-- bonus for got balanced in the game before
	local bonus_gotbalancedbefore = 1.0
	if balance.gotbalancedbefore[cn] == nil then
		balance.gotbalancedbefore[cn] = 0
	elseif balance.gotbalancedbefore[cn] == 1 then
		bonus_gotbalancedbefore = balance.bonus_factor[maprotation.game_mode]["gotbalancedbefore"]
	end

	-- documentation
	balance.write_documentation("get_calculated_bonus", {{cn, score_without_bonus, bonus_playedgames, bonus_isalive, bonus_guard, bonus_scorer, bonus_gotbalanced, bonus_gotbalancedbefore }})

	-- return the score multiplied with bonus factors
	return math.floor(score_without_bonus * bonus_playedgames * bonus_isalive * bonus_guard * bonus_scorer * bonus_gotbalanced * bonus_gotbalancedbefore)

end

function balance.sort_scores(a,b)
	return a[4] < b[4]
end

function balance.get_best_fit(toteam, rank)
	local scores = {}
	scores["good"] = {}
	scores["evil"] = {}
	local team_scores = {}
	team_scores["good"] = 0
	team_scores["evil"] = 0
	for i,cn in pairs(players.all()) do
		if server.player_status_code(cn) ~= server.SPECTATOR then -- fix: spectators should be ignored on the best fit search
			local team = server.player_team(cn)
			local score = balance.get_score(cn)
			team_scores[team] = team_scores[team] + score
			table.insert(scores[team], { cn, score, 0, 0 })
		end
	end
	local score_diff = math.abs(team_scores["good"] - team_scores["evil"])
	local optimal_diff = math.floor(score_diff / 2)
	local best_fit_cn = -1
	-- messages.debug(-1, players.admins(), "BALANCE", string.format("rank: %i", rank))
	if toteam == "good" then
		for i, score in ipairs(scores["evil"]) do
			score[3] = math.abs(score[2] - optimal_diff) + balance.score_base -- adding a base score, because bonus factors are useless if score[3] == 0
			score[4] = balance.get_calculated_bonus(score[1], score[3])
			messages.debug(-1, players.admins(), "BALANCE", string.format("%s (%i evil) score: %i without_bonus: %i with_bonus: %i", server.player_name(score[1]), score[1], score[2], score[3], score[4]))
		end
		table.sort(scores["evil"], balance.sort_scores)
		balance.write_documentation("get_best_fit", scores["evil"])
		if scores["evil"][rank] ~= nil then
			best_fit_cn = scores["evil"][rank][1]
		end
	else
		for i, score in ipairs(scores["good"]) do
			score[3] = math.abs(score[2] - optimal_diff) + balance.score_base -- adding a base score, because bonus factors are useless if score[3] == 0
			score[4] = balance.get_calculated_bonus(score[1], score[3])
			messages.debug(-1, players.admins(), "BALANCE", string.format("%s (%i good) score: %i without_bonus: %i with_bonus: %i", server.player_name(score[1]), score[1], score[2], score[3], score[4]))
		end
		table.sort(scores["good"], balance.sort_scores)
		balance.write_documentation("get_best_fit", scores["good"])
		if scores["good"][rank] ~= nil then
			best_fit_cn = scores["good"][rank][1]
		end
	end
	if best_fit_cn >= 0 then
		messages.debug(-1, players.admins(), "BALANCE", string.format("Best FIT for rank %i: %s (%i)", rank, server.player_displayname(best_fit_cn), best_fit_cn))
	else
		messages.debug(-1, players.admins(), "BALANCE", string.format("Could not find best FIT"))
	end
	return best_fit_cn -- return the cn
end

function balance.get_best_team()
	local team_scores = {}
	team_scores["good"] = 0
	team_scores["evil"] = 0
	for i,cn in pairs(players.all()) do
		if server.player_status_code(cn) ~= server.SPECTATOR then -- fix: spectators should be ignored on the best fit search
			local team = server.player_team(cn)
			local score = balance.get_score(cn)
			team_scores[team] = team_scores[team] + score
			table.insert(scores[team], { cn, score, 0 })
		end
	end
	if team_scores["good"] > team_scores["evil"] then
		return "good"
	else
		return "evil"
	end
end

-- checks, if the game is balanced
function balance.check_isbalanced()
	if server.paused == 1 or server.timeleft <= 0 or maprotation.game_mode == "coop edit" or balance.enabled == 0 or server.gamemillis < (balance.last_mapchange + balance.check_delay_after_mapchange) then return end
	if cheater ~= nil and cheater.is_recording ~= nil and cheater.is_recording() then return end
	-- messages.verbose(cn, players.admins(), "BALANCE", string.format("number of balance checks: %i", #balance.unbalance_detector))
	for i,fn in ipairs(balance.unbalance_detector) do
		-- messages.verbose(cn, players.admins(), "BALANCE", string.format("execute balance check no.%i", i))
		fn()
	end
	balance.last_check = server.gamemillis
end

-- check for jobs
function balance.check_jobs()
	if server.paused == 1 or server.timeleft <= 0 or maprotation.game_mode == "coop edit" or balance.enabled == 0 then return end
	if cheater ~= nil and cheater.is_recording ~= nil and cheater.is_recording() then return end
	 -- preventing doing concurrent jobs
	if server.gamemillis < balance.last_action + balance.minactiontime then
		if #balance.jobs > 0 then
			balance.write_documentation("check_jobs_prevent_concurrent", {{ server.gamemillis, balance.last_action, balance.minactiontime, server.gamemillis < (balance.last_action + balance.minactiontime)}})
			messages.debug(-1, players.admins(), "BALANCE", string.format("The last job was executed recently. The execution of new jobs are blocked!"))
		end
		return
	end
	-- drop old or done or invalid jobs
	local new_jobs = {}
	for i, job in ipairs(balance.jobs) do
		if
			server.gamemillis < job[4] + balance.clearjobafter and
			job[4] > 0 and
			balance.unbalance_validator[job[5]](job)
		then
			table.insert(new_jobs, job)
		else
			-- messages.verbose(-1, players.admins(), "BALANCE", string.format("Dropped old or done or invalid job"))
			balance.write_documentation("check_jobs_drop_old_jobs", {{ server.gamemillis, job[4], balance.clearjobafter, ((server.gamemillis < (job[4] + balance.clearjobafter)) and (job[4] > 0)) }})
		end
	end
	balance.jobs = new_jobs
	local hard_balance_actions = 0
	for i, job in ipairs(balance.jobs) do
		local j = 1
		local rank = 1
		while j <= job[3] do
			local cn = balance.get_best_fit(job[2], rank)
			if cn == -1 then break end
			if job[1] == balance.HARD then
				if balance.switch_team(cn) then
					balance.write_documentation("check_jobs_hard_done", {job})
					balance.jobs[i][4] = -1
					messages.debug(-1, players.admins(), "BALANCE", string.format("job done HARD"))
					j = j + 1
					hard_balance_actions = hard_balance_actions + 1
				else
					messages.debug(-1, players.admins(), "BALANCE", string.format("job continued: choosing next ranked player"))
					rank = rank + 1
				end
			elseif job[1] == balance.SOFT then
				if server.player_status_code(cn) ~= server.ALIVE then
					if balance.switch_team(cn, 1) then
						balance.write_documentation("check_jobs_soft_done", {job})
						balance.jobs[i][4] = -1
						messages.debug(-1, players.admins(), "BALANCE", string.format("job done SOFT"))
						balance.drop_jobs(balance.SOFT)
					end
				end
				break -- bei soft switch wird immer nur auf den aktuell am besten passenden gewartet (wer der aktuell beste ist, kann sich bei jeder berechnung in get_best_fit() ändern)
			else
				messages.debug(-1, players.admins(), "BALANCE", string.format("unknown job type"))
				break
			end
			local teamsize = 0
			if job[2] == "good" then teamsize = server.teamsize("evil") else teamsize = server.teamsize("good") end
			messages.debug(-1, players.admins(), "BALANCE", string.format("Rank: %i ToTeam: %s Teamsize FromTeam: %i", rank, job[2], teamsize))
			if rank > teamsize then -- do not loop forever
				messages.debug(-1, players.admins(), "BALANCE", string.format("job not done: no more players"))
				break
			end
		end
		if job[4] == -1 then break end
	end
	balance.write_documentation("check_jobs_after", jobs)
	if hard_balance_actions > 0 then
		balance.drop_jobs(balance.HARD)
	end
end

function balance.add_job(type, toteam, count, validator)
	if #balance.jobs == 0 then
		balance.job_wait = server.gamemillis
	end
	local job = { type, toteam, count, server.gamemillis, validator }
	table.insert(balance.jobs, job)
	messages.debug(cn, players.admins(), "BALANCE", string.format("Add new balance job: Type: %i ToTeam: %s Count: %i Validator: %i", type, toteam, count, validator))
	balance.write_documentation("add_job", { job })
end

function balance.clear_jobs()
	balance.job_wait = server.gamemillis
	balance.jobs = {}
	-- messages.verbose(cn, players.admins(), "BALANCE", string.format("Cleared all balance jobs"))
	balance.write_documentation("clear_jobs", { { balance.job_wait } })
end

-- drop jobs by type
function balance.drop_jobs(type)
	local new_jobs = {}
	for i, job in ipairs(balance.jobs) do
		if
			job[1] ~= type
		then
			table.insert(new_jobs, job)
		else
			balance.write_documentation("drop_jobs_by_type", { job })
		end
	end
	balance.jobs = new_jobs
end

-- documention of the balance jobs
function balance.write_documentation(action, tab)
	if balance.documentation == 0 or action == nil or tab == nil then return end
	local fp = io.open("log/balance2.log", "a+")
	if fp == nil then return end
	for i,row in ipairs(tab) do
		fp:write(tostring(os.date("%Y-%m-%d %H:%M:%S"))..",")
		fp:write(tostring(action)..",")
		if type(row) == "table" then
			for j,value in ipairs(row) do
				fp:write(tostring(value)..",")
			end
		elseif type(row) == "string" then
			fp:write(row..",")
		end
		fp:write("\n")
	end
	fp:close()
end



--[[
		COMMANDS
]]

function server.playercmd_balance(cn, cmd, arg, arg2, arg3)
	if not hasaccess(cn, admin_access) then return end
	if arg == nil then
		if cmd == "info" then
			messages.info(cn, {cn}, "BALANCE", string.format("balance.enabled = %i", balance.enabled))
			messages.info(cn, {cn}, "BALANCE", string.format("balance.testing = %i", balance.testing))
			messages.info(cn, {cn}, "BALANCE", string.format("balance.cancontrolrespawn = %i", balance.cancontrolrespawn))
			messages.info(cn, {cn}, "BALANCE", string.format("balance.documentation = %i", balance.documentation))
			messages.info(cn, {cn}, "BALANCE", string.format("balance.autodisabled = %i", balance.autodisabled))
		end
		if cmd == "enabled" then
			messages.info(cn, {cn}, "BALANCE", string.format("balance.enabled = %i", balance.enabled))
		end
		if cmd == "testing" then
			messages.info(cn, {cn}, "BALANCE", string.format("balance.testing = %i", balance.testing))
		end
		if cmd == "cancontrolrespawn" then
			messages.info(cn, {cn}, "BALANCE", string.format("balance.cancontrolrespawn = %i", balance.cancontrolrespawn))
		end
		if cmd == "documentation" then
			messages.info(cn, {cn}, "BALANCE", string.format("balance.documentation = %i", balance.documentation))
		end
		if cmd == "unbalance" then
			balance.unbalance(1)
			messages.warning(cn, players.admins(), "BALANCE", string.format("blue<%s> unbalanced the game!", server.player_displayname(cn)))
		end
		if cmd == "clear" then
			balance.clear_jobs()
		end
	else
		if cmd == "enabled" then
			balance.enabled = tonumber(arg)
			messages.info(cn, {cn}, "BALANCE", string.format("balance.enabled = %i", balance.enabled))
		end
		if cmd == "testing" then
			balance.testing = tonumber(arg)
			messages.info(cn, {cn}, "BALANCE", string.format("balance.testing = %i", balance.testing))
		end
		if cmd == "cancontrolrespawn" then
			balance.cancontrolrespawn = tonumber(arg)
			messages.info(cn, {cn}, "BALANCE", string.format("balance.cancontrolrespawn = %i", balance.cancontrolrespawn))
		end
		if cmd == "documentation" then
			balance.documentation = tonumber(arg)
			messages.info(cn, {cn}, "BALANCE", string.format("balance.documentation = %i", balance.documentation))
		end
		if cmd == "unbalance" then
			balance.unbalance(tonumber(arg))
			messages.warning(cn, players.admins(), "BALANCE", string.format("blue<%s> unbalanced the game!", server.player_displayname(cn)))
		end
		if cmd == "option" then
			if arg2 == nil then
				messages.error(cn, {cn}, "BALANCE", "#balance option <BALANCE_MODE> <VAR> [<VALUE>]")
			else
				if arg3 == nil then
					messages.info(cn, {cn}, "BALANCE", string.format("balance.option (mode %d): %s %s", tonumber(arg), arg2, balance.option[tonumber(arg)][arg2]))
				else
					balance.option[tonumber(arg)][arg2] = arg3
				end
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	balance.gotbalanced[cn] = 0
	balance.gotbalancedbefore[cn] = 0
	balance.flags[cn] = 0
	balance.flagreturned[cn] = 0
	balance.shotflagholder[cn] = 0
	balance.playedgames[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	balance.gotbalanced[cn] = 0
	balance.gotbalancedbefore[cn] = 0
	balance.flags[cn] = 0
	balance.flagreturned[cn] = 0
	balance.shotflagholder[cn] = 0
	balance.playedgames[cn] = 0
	if balance.flagholder[server.player_team(cn)] == cn then
		balance.flagholder[server.player_team(cn)] = nil
	end
end)

server.event_handler("scoreflag", function(cn)
	balance.flagholder[server.player_team(cn)] = nil
	if balance.flags[cn] == nil then
		balance.flags[cn] = 1
	else
		balance.flags[cn] = balance.flags[cn] + 1
	end
end)

server.event_handler("takeflag", function(cn)
	balance.flagholder[server.player_team(cn)] = cn
end)

server.event_handler("dropflag", function(cn)
	balance.flagholder[server.player_team(cn)] = nil
end)

server.event_handler("resetflag", function(cn)
	if cn == nil then
		if balance.flagholder["good"] == nil and balance.flagholder["evil"] ~= nil then
			balance.flagholder["evil"] = nil
		else
			if balance.flagholder["good"] ~= nil and balance.flagholder["evil"] == nil then
				balance.flagholder["good"] = nil
			else
				-- balance.flagholder["evil"] = nil
				-- balance.flagholder["good"] = nil
			end
		end 
	elseif utils.is_numeric(cn) then
		balance.flagholder[server.player_team(tonumber(cn))] = nil
	else
		balance.flagholder[cn] = nil
	end
end)

server.event_handler("mapchange", function()
	balance.last_action = server.gamemillis
	balance.last_check = server.gamemillis
	balance.last_mapchange = server.gamemillis
	balance.flagholder = {}
	balance.jobs = {}
	for i,cn in pairs(players.all()) do
		if balance.gotbalanced[cn] > 0 then
			balance.gotbalancedbefore[cn] = 1
		else
			balance.gotbalancedbefore[cn] = 0
		end
		balance.gotbalanced[cn] = 0
		balance.flags[cn] = 0
		balance.flagreturned[cn] = 0
		balance.shotflagholder[cn] = 0
		balance.playedgames[cn] = balance.playedgames[cn] + 1
	end
end)

server.event_handler("started", function()
	server.sleep(10000, function()
		balance.last_action = server.gamemillis
		balance.last_check = server.gamemillis
		balance.last_mapchange = server.gamemillis
	end)
end)

server.interval(balance.unbalance_detector_interval, balance.check_isbalanced)
server.interval(balance.jobs_interval, balance.check_jobs)



--[[
		UNBALANCE DETECTORS
]]

-- Unbalance Detector "CTF - Team player count"
balance.CTF_PLAYER_COUNT = 1
balance.option[balance.CTF_PLAYER_COUNT] = {}
balance.option[balance.CTF_PLAYER_COUNT]["enabled"] = 1
balance.option[balance.CTF_PLAYER_COUNT]["minplayers"] = 2
balance.option[balance.CTF_PLAYER_COUNT]["minsoftchecks"] = 2
balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = 0
balance.unbalance_detector[balance.CTF_PLAYER_COUNT] = function()
	-- this balance check is only for ctf game modes!
	if
		tonumber(balance.option[balance.CTF_PLAYER_COUNT]["enabled"]) == 0 or
		(maprotation.game_mode ~= "insta ctf" and maprotation.game_mode ~= "efficiency ctf" and maprotation.game_mode ~= "ctf")
	then
		return
	end

	local good_players = server.team_players("good")
	local evil_players = server.team_players("evil")

	if #good_players + #evil_players < tonumber(balance.option[balance.CTF_PLAYER_COUNT]["minplayers"]) then
		return
	end

	local diff = math.abs(#good_players - #evil_players)
	if diff < 2 then
		balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = 0
		return
	end
	local toteam = ""
	if #good_players > #evil_players then
		toteam = "evil"
	elseif #good_players < #evil_players then
		toteam = "good"
	end
	if #good_players > 0 and #evil_players > 0 then
		if diff >= 4 then
			local switch_count = math.floor(diff / 2)
			balance.add_job(balance.HARD, toteam, switch_count, balance.CTF_PLAYER_COUNT)
			messages.debug(-1, players.admins(), "BALANCE", string.format("Balancing %d players (HARD) because one team has much more players", switch_count))
		else
			if #balance.jobs == 0 and server.gamemillis < (balance.job_wait + balance.maxjobwait) then
				if diff >= 2 then
					balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] + 1
					if balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] >= balance.option[balance.CTF_PLAYER_COUNT]["minsoftchecks"] then
						balance.add_job(balance.SOFT, toteam, 1, balance.CTF_PLAYER_COUNT)
						balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = 0
					end
					messages.debug(-1, players.admins(), "BALANCE", string.format("Balancing a player (SOFT) because one team has more players"))
				end
			else
				if diff == 3 then
					balance.add_job(balance.HARD, toteam, 1, balance.CTF_PLAYER_COUNT)
					messages.debug(-1, players.admins(), "BALANCE", string.format("Balancing a player (HARD) because one team has 3 more players and its long term unbalanced"))
				elseif diff == 2 then
					if server.gamemillis >= (balance.job_wait + balance.maxjobwait) then
						balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] + 1
						if balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] >= balance.option[balance.CTF_PLAYER_COUNT]["minsoftchecks"] then
							balance.add_job(balance.SOFT, toteam, 1, balance.CTF_PLAYER_COUNT)
							balance.option[balance.CTF_PLAYER_COUNT]["softchecks"] = 0
						end
						messages.debug(-1, players.admins(), "BALANCE", string.format("Recreate a soft balance job"))
					else
						messages.debug(-1, players.admins(), "BALANCE", string.format("Still waiting for balancing (long term unbalanced)"))
					end
				end
			end
		end
	else
		-- one team has no players!
		-- immediately and hard balance!
		local switch_count = math.floor(diff / 2)
		balance.add_job(balance.HARD, toteam, switch_count, balance.CTF_PLAYER_COUNT)
		messages.debug(-1, players.admins(), "BALANCE", string.format("Balancing %d players (HARD) because one team has no players", switch_count))
	end
end

-- Unbalance Validator "CTF - Team player count"
balance.unbalance_validator[balance.CTF_PLAYER_COUNT] = function(job)
	local good_players = server.team_players("good")
	local evil_players = server.team_players("evil")
	local diff = math.abs(#good_players - #evil_players)
	if
		#good_players + #evil_players < tonumber(balance.option[balance.CTF_PLAYER_COUNT]["minplayers"]) or
		(job[1] == balance.SOFT and diff < 2) or
		(job[1] == balance.HARD and diff < 3)
	then
		-- job is no more valid
		return false
	else
		-- job is still valid
		return true
	end
end


-- Unbalance Detector "CTF - Team player skill"
balance.CTF_TEAM_SKILL = 2
balance.option[balance.CTF_TEAM_SKILL] = {}
balance.option[balance.CTF_TEAM_SKILL]["enabled"] = 0
balance.unbalance_detector[balance.CTF_TEAM_SKILL] = function()
	-- this balance check is only for ctf game modes!
	if
		tonumber(balance.option[balance.CTF_TEAM_SKILL]["enabled"]) == 0 or
		(maprotation.game_mode ~= "insta ctf" and maprotation.game_mode ~= "efficiency ctf" and maprotation.game_mode ~= "ctf")
	then
		return
	end
	local good_players = server.team_players("good")
	local evil_players = server.team_players("evil")
end

-- Unbalance Detector "CTF - Automatically unbalance game"
balance.AUTO_UNBALANCER = 3
balance.option[balance.AUTO_UNBALANCER] = {}
balance.option[balance.AUTO_UNBALANCER]["enabled"] = 0
balance.option[balance.AUTO_UNBALANCER]["maxdiff"] = 4
balance.unbalance_detector[balance.AUTO_UNBALANCER] = function()
	-- this balance check is only for ctf game modes!
	if
		tonumber(balance.option[balance.AUTO_UNBALANCER]["enabled"]) == 0 or
		(maprotation.game_mode ~= "insta ctf" and maprotation.game_mode ~= "efficiency ctf" and maprotation.game_mode ~= "ctf")
	then
		return
	end
	local good_players = server.team_players("good")
	local evil_players = server.team_players("evil")
	local diff = math.abs(#good_players - #evil_players)
	local team = ""
	if #good_players > #evil_players then
		team = "evil" -- inverse
	else
		team = "good" -- inverse
	end
	if diff < maxdiff then
		balance.add_job(balance.HARD, team, 1, balance.AUTO_UNBALANCER)
		messages.debug(-1, players.admins(), "BALANCE", string.format("magenta<Auto unbalance player>"))
	end
end

-- Unbalance Detector "CTF/Hold - Weaken better team"
balance.WEAKEN_BETTER = 4
balance.option[balance.WEAKEN_BETTER] = {}
balance.option[balance.WEAKEN_BETTER]["enabled"] = 0
balance.unbalance_detector[balance.WEAKEN_BETTER] = function()
	-- this balance check is only for ctf game modes!
	if
		tonumber(balance.option[balance.WEAKEN_BETTER]["enabled"]) == 0 or
		(maprotation.game_mode ~= "insta ctf" and maprotation.game_mode ~= "efficiency ctf" and maprotation.game_mode ~= "ctf" and
		 maprotation.game_mode ~= "insta hold" and maprotation.game_mode ~= "efficiency hold" and maprotation.game_mode ~= "hold")
	then
		return
	end
	
	local team = balance.get_best_team()
	balance.add_job(balance.SOFT, team, 1, balance.WEAKEN_BETTER)
end



