--[[
	script/module/nl_mod/nl_teamsucks.lua
	
	Functionality:
		Players can state in game wheter or not they like their team
		If enough people dislike their team, this team will be kicked after the
		map ended.
]]

teamsucks = {}
teamsucks.module_name = "TEAMSUCKS"

-- Vote table for hate votes
-- Contains sub tables for each team that has already been voted against.
-- Those sub tables contain the CNs (Client Numbers) of the players who voted.
-- @see teamsucks.loveteam
teamsucks.hateteam = {}

-- Vote table for love votes
-- Contains sub tables for each team that has already been voted for.
-- Those sub tables contain the CNs (Client Numbers) of the players who voted.
-- @see teamsucks.hateteam
teamsucks.loveteam = {}

-- Delay (in seconds) before starting the countdown to kick a team
-- should be long enough to ensure readability of the info message about the
-- upcoming kick
teamsucks.countdown_delay = 4

-- Duration of the countdown (in seconds) before a team gets kicked
teamsucks.countdown_duration = 10



--- Workaround for erratic table size behavior of Lua.
-- Counts the entries in a given table
--
-- @param table_to_count The table of which the entries are to be counted
-- @return the number of entries in the table given by table_to_count
function count_table_entries(table_to_count)
	if table_to_count == nil then
		return 0
	end
	entries = 0
	for key, value in pairs(table_to_count) do
		entries = entries + 1
	end
	return entries
end



--- Add a player's vote to a vote table
-- The vote table contains sub tables for each team. Which team to use is
-- determined from the player's team. If the team's sub table does not yet
-- exist, it is created. If a player already voted for his team, the vote is
-- discarded.
-- @param cn CN (Client Number) of the player who voted
-- @param votes The table containing the votes
-- @return true, if the vote was accepted, false, if the vote was discarded
function add_vote(cn, votes)
	local team = server.player_team(cn)
	if votes[team] == nil then
		votes[team] = {}
	end
	
	if votes[team][cn] == nil then
		votes[team][cn] = true
		return true
	else
		return false
	end
end



--- Remove a player's vote from a vote table.
-- The vote table contains sub tables for each team. Which team to use is
-- determined from the player's team. If the team's sub table does not yet
-- exist or the player didn't vote yet, the vote is discarded.
-- @param cn CN (Client Number) of the player who voted
-- @param votes The table containing the votes
-- @return true, if the vote was accepted, false, if the vote was discarded
function remove_vote(cn, votes)
	local team = server.player_team(cn)
	if votes == nil or votes[team] == nil or votes[team][cn] == nil then
		return false
	else
		votes[team][cn] = nil
		return true
	end
end



--- Reset the counters and votes for "teamsucks" voting
-- @see teamsucks.hateteam
-- @see teamsucks.loveteam
function teamsucks.reset()
	teamsucks.hateteam = {}
	teamsucks.loveteam = {}
end



--- Kick a team if it has enough "teamsucks" votes
-- @param team The team to kick
function teamsucks.kick_team(team)
	local team_size = count_table_entries(server.team_players(team))
	local votes_needed = teamsucks.needed_votes(team)
	local votes_given = teamsucks.vote_count(team)
	
	if votes_given < votes_needed then
		return
	elseif votes_given >= votes_needed then
		server.log(
			string.format("%s: Kicking team %s because got %d of %d needed votes",
				teamsucks.module_name, team, votes_given, votes_needed))
		
		messages.info(-1, server.team_players(team), teamsucks.module_name,
			string.format(
				"%d/%d players in team blue<%s> think that their team red<sucks>, "
				.."red<kicking> all players in team blue<%s>.",
				votes_given, votes_needed, team, team))
		
		for countdown = 0, teamsucks.countdown_duration do
			server.sleep((countdown * 1000) + teamsucks.countdown_delay * 1000,
				function()
					messages.info(-1, server.team_players(team), teamsucks.module_name,
						string.format(
						"All players of team blue<%s> will be red<kicked> in %d seconds.",
						team, 10 - countdown))
					-- TODO: Add kick command to kick every player of this team
				end)
		end
		server.sleep((teamsucks.countdown_duration * 1000) + teamsucks.countdown_delay * 1000 + 250,
			function()
				messages.error(-1, server.team_players(team), teamsucks.module_name,
						"script/module/nlmod/nl_teamsucks.lua:42: attempt to index global 'to_kick' (a nil value)"
						.."\nCall stack:"
						.."    script/module/nlmod/nl_teamsucks.lua:42")
			end)
	end
end



--- Notify all players of a team about the current vote count against a given team
-- @param team The team about which to inform the players
function teamsucks.notify_players(team)
	local voted = teamsucks.vote_count(team)
	local needed = teamsucks.needed_votes(team)
	
	if voted < 0 then
		needed = needed - voted
		voted = 0
	end
	
	server.log(
		string.format(
			"%s: Notifying players of team %s: votes: %d needed: %d",
			teamsucks.module_name, team, voted, needed))
	if voted >= needed then
		voted = string.format("green<%d>", voted)
	else
		voted = string.format("red<%d>", voted)
	end
	
	messages.info(-1, server.team_players(team) ,teamsucks.module_name,
		string.format(
			"Got %s of %d needed votes to red<kick> team blue<%s> at next map change.",
			voted, needed, team))
	messages.info(-1, server.team_players(team) ,teamsucks.module_name,
		"Use orange<#teamsucks> if you think blue<your team> red<sucks>. ")
	messages.info(-1, server.team_players(team) ,teamsucks.module_name,
		"Use orange<#loveteam> if you green<love> blue<your team>.")
end



--- Calculates the amount of teamsucks votes against a given team
-- The loveteam votes are subtracted from the teamsucks votes
-- @param team Team for which the votes are to be calulated
-- @return The amount of votes against the team
-- @see teamsucks.hateteam
-- @see teamsucks.loveteam
-- @see server.playercmd_teamsucks
-- @see server.playercmd_loveteam
function teamsucks.vote_count(team)
	local hates = count_table_entries(teamsucks.hateteam[team])
	local loves = count_table_entries(teamsucks.loveteam[team])
	server.log(
		string.format(
			"%s: Vote count for team %s: %d hates, %d loves (%d score)",
			teamsucks.module_name, team, hates, loves, hates - loves))
	return hates - loves
end



--- Calculates the votes against a given team needed to kick the team
-- @param team The team for which the votes needed for kick are to be calculated
-- @return the amount of votes needed to kick the team
-- @see server.playercmd_teamsucks
-- @see server.playercmd_loveteam
function teamsucks.needed_votes(team)
	local team_size = count_table_entries(server.team_players(team))
	if team_size <= 2 then
		return 1
	else
		return team_size / 2
	end
end



--- Handle a teamsucks vote given by a player
-- Adds the player's CN to his team's hateteam vote table, if not already added.
-- Removes the player's CN from his team's loveteam vote table, if present.
-- Sends a notification to inform all players about the vote.
-- If the player already gave a teamsucks vote for his current team, the vote
-- is discarded and the player gets an error message
-- @param cn CN (Client Number) of the player who gave the teamsucks vote
function teamsucks.process_teamsucks(cn)
	local sucks_successful = add_vote(cn, teamsucks.hateteam)
	local voted_love = remove_vote(cn, teamsucks.loveteam)
	
	local player = server.player_name(cn)
	local team = server.player_team(cn)
	
	if sucks_successful and not voted_love then
		-- Player voted the first time for this team
		messages.info(-1, server.team_players(team), teamsucks.module_name,
			string.format(
				"blue<%s> thinks that team blue<%s> red<sucks>.\n",
				player, team))
		teamsucks.notify_players(team)
	elseif sucks_successful and voted_love then
		-- Player changed his mind
		messages.info(-1, server.team_players(team), teamsucks.module_name,
			string.format(
				"blue<%s> changed his mind and now thinks that team blue<%s> red<sucks>.\n",
				player, team))
		teamsucks.notify_players(team)
	else
		-- Player already voted for this team
		messages.error(-1, {cn}, teamsucks.module_name, "You already voted.")
	end
end



--- Process a loveteam vote given by a player
-- Adds the player's CN to his team's loveteam vote table, if not already added.
-- Removes the player's CN from his team's hateteam vote table, if present.
-- Sends a notification to inform all players about the vote.
-- If the player already gave a loveteam vote for his current team, the vote
-- is discarded and the player gets an error message
-- @param cn CN (Client Number) of the player who gave the vote
function teamsucks.process_loveteam(cn)
	local love_successful = add_vote(cn, teamsucks.loveteam)
	local voted_sucks = remove_vote(cn, teamsucks.hateteam)
	
	local player = server.player_name(cn)
	local team = server.player_team(cn)
	local voted = teamsucks.vote_count(team)
	local needed = teamsucks.needed_votes(team)
	
	if love_successful and not voted_sucks then
		-- Player voted the first time for this team
		messages.info(-1, server.team_players(team), teamsucks.module_name,
			string.format(
				"blue<%s> green<loves> team blue<%s>.\n",
				player, team))
		teamsucks.notify_players(team)
	elseif love_successful and voted_sucks then
		-- Player changed his mind
		messages.info(-1, server.team_players(team), teamsucks.module_name,
			string.format(
				"blue<%s> changed his mind and now green<loves> team blue<%s>.",
				player, team))
		teamsucks.notify_players(team)
	else
		-- Player already voted for this team
		messages.error(-1, {cn}, teamsucks.module_name, "You already voted.")
	end
end



--- Playercommand #teamsucks
-- Vote to kick a whole team.
-- @param cn The CN (Client umber of the player who issued the command)
-- @see server.playercmd_loveteam
function server.playercmd_teamsucks(cn, arg)
	if arg == "info" then
		teamsucks.notify_players(server.player_team(cn))
	elseif arg == nil then
		teamsucks.process_teamsucks(cn)
	else
		messages.error(-1, {cn}, teamsucks.module_name, "Invalid argument.")
	end
end


--- Playercommand #loveteam
-- Vote to express a player's love for his own team.
-- Lowers the vote count of #teamsucks
-- @param cn The CN (Client umber of the player who issued the command)
-- @see server.playercmd_teamsucks
function server.playercmd_loveteam(cn)
	teamsucks.process_loveteam(cn)
end



server.event_handler("intermission",
	function()
		server.log(
			string.format("%s: Entering intermission handler",
				teamsucks.module_name))
		for team, votes in pairs(teamsucks.hateteam) do
			teamsucks.kick_team(team)
		end
		teamsucks.reset()
	end)
