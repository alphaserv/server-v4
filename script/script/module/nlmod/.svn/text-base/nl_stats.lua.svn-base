--[[
	script/module/nl_mod/nl_stats.lua
	Derk Haendel
	20-Sep-2010
	License: GPL3
	
	Speichern der Statistiken in einer mySQL-Datenbank zum Ende eines Spiels
	
]]

local servername = server.stats_servername
local env
local con
local cur
local row
local sql_fmt
local sql
local anz

nl.statslog = io.open("log/stats.log","a+")
function nl.log_stats(msg)
--[[
			Schreibt in log/stats.log
]]
	assert(msg ~= nil)
	nl.statslog:write(os.date("[%a %d %b %X] ",os.time()))
	nl.statslog:write(msg)
	nl.statslog:write("\n")
	nl.statslog:flush()
end

local function escape_string(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, "%\"", "\\\"")
	s = string.gsub(s, "%'", "\\'")
	return s
end

function nl.EndGame()
--[[
			Wird bei Spielende aufgerufen
]]

	local function final_update(cn)
	
		-- local playerData = internal.updatePlayer(cn)
		nl.updatePlayer(cn, "team", tostring(server.player_team(cn)), "set")
		nl.updatePlayer(cn, "ipaddr", tostring(server.player_ip(cn)), "set")
		nl.updatePlayer(cn, "ipaddrlong", tostring(server.player_iplong(cn)), "set")
		nl.updatePlayer(cn, "country", tostring(geoip.ip_to_country_code(server.player_ip(cn))), "set")
		if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "admin" then nl.updatePlayer(cn, "registered", 1, "set") end
		nl.updatePlayer(cn, "damage", tonumber(server.player_damage(cn)), "set")
		nl.updatePlayer(cn, "damagewasted", tonumber(server.player_damagewasted(cn)), "set")
		nl.updatePlayer(cn, "accuracy", tonumber(server.player_accuracy(cn)), "set")
		nl.updatePlayer(cn, "timeplayed", tonumber(server.player_timeplayed(cn)), "set")
		nl.updatePlayer(cn, "finished", nl.getPlayer(cn, "playing"), "set")
		nl.updatePlayer(cn, "win", tonumber(server.player_win(cn)), "set")
		nl.updatePlayer(cn, "rank", tonumber(server.player_rank(cn)), "set")
--[[
		if auth_domain and playerData.auth_name then
			if server.stats_tell_auth_name == 1 then
				server.player_msg(cn, string.format("Saving your stats as %s@%s", playerData.auth_name, auth_domain))
			end
			if server.stats_overwrite_name_with_authname == 1 then
				playerData.player_name = playerData.name -- save the original name
				playerData.name = playerData.auth_name
			end
		end
]]		
	end

	-- Update stats for human players
	for _, cn in ipairs(server.players()) do
		final_update(cn)
	end
	
	-- Update stats for bot players
	for _, cn in ipairs(server.bots()) do
		final_update(cn)
	end

	local human_players = 0
	local bot_players = 0
	local unique_players = 0 -- human players
	local ipcount = {}

	-- Count the players
	for id, player in pairs(nl_players) do
		--irc_say(string.format("%s frags=%s", player.name, tostring(player.frags)))
		--irc_say(string.format("%s timeplayed=%s", player.name, tostring(player.timeplayed)))
		if (player.frags > 0 and player.timeplayed > 60) then -- Remove players that didn't contribute to the game
			if player.botskill == 0 then
				human_players = human_players + 1
				if not ipcount[player.ipaddrlong] then
					ipcount[player.ipaddrlong] = true
					unique_players = unique_players + 1
				end
			else
				bot_players = bot_players + 1
			end
		else
			-- irc_say(string.format("%s is not an active Player ...", player.name))
		end
	end

	if not nl_game then return end

	nl_game.players = human_players
	nl_game.bots = bot_players
	nl_game.duration = round(server.gamemillis / 60000)
	nl.commit()
end

local function constructTeamsTable()
    
	if not gamemodeinfo.teams then return end
	
	local teams = {}
	
	for _, teamname in ipairs(server.teams()) do
		team = {}
		team.name = teamname
		team.score = server.team_score(teamname)
		team.win = server.team_win(teamname)
		team.draw = server.team_draw(teamname)
		table.insert(teams, team)
	end
	
	return teams
end

local function insert_game()

	-- fix: prevent executing sql query if vars are not initialized!
	if nl_game == nil then return end
	if nl_game.datetime == nil then return end
	if nl_game.duration == nil then return end
	if nl_game.mode == nil then return end
	if nl_game.map == nil then return end
	if nl_game.players == nil then return end
	if nl_game.bots == nil then return end
	if nl_game.finished == nil then return end
	if nl_game.demofile == nil then return end

	sql_fmt = [[INSERT INTO nl4_games SET
		servername='%s',
		datetime=from_unixtime(%i),
		duration=%i,
		gamemode='%s',
		mapname='%s',
		players=%i,
		bots=%i,
		finished=%i,
		demo='%s']]
	
	sql = string.format(
		sql_fmt,
		escape_string(servername),
		nl_game.datetime,
		nl_game.duration,
		nl_game.mode,
		nl_game.map,
		nl_game.players,
		nl_game.bots,
		nl_game.finished,
		nl_game.demofile)

	nl.log_stats(sql)

	cur = assert (con:execute(sql))
	cur = assert (con:execute("SELECT last_insert_id()"))

	return cur:fetch()
end

local function insert_team(game_id, team)

	sql_fmt = [[INSERT INTO nl4_teams SET
		game_id=%i,
		name='%s',
		score=%i,
		win=%i,
		draw=%i]]
	
	sql = string.format(
		sql_fmt,
		game_id,
		escape_string(team.name),
		team.score,
		team.win,
		team.draw)

	nl.log_stats(sql)

	cur = assert (con:execute(sql))
	cur = assert (con:execute("SELECT last_insert_id()"))

	return cur:fetch()
end

local function insert_player(game_id, player)

	sql_fmt = [[INSERT INTO nl4_players SET
		game_id=%i,
		team_id=%i,
		name='%s',
		statsname='%s',
		ipaddr='%s',
		country='%s',
		registered=%i,
		frags=%i,
		deaths=%i,
		suicides=%i,
		misses=%i,
		shots=%i,
		hits_made=%i,
		hits_get=%i,
		tk_made=%i,
		tk_get=%i,
		flags_returned=%i,
		flags_stolen=%i,
		flags_scored=%i,
		damage=%i,
		damagewasted=%i,
		accuracy=%i,
		timeplayed=%i,
		finished=%i,
		win=%i,
		rank=%i,
		ctfgame=%i,
		botskill=%i,
		playerweight=%i,
		bookmark=%i]]
		
	sql = string.format(
		sql_fmt,
		game_id,
		player.team_id,
		escape_string(player.name),
		escape_string(player.statsname),
		player.ipaddr,
		player.country,
		player.registered,
		player.frags,
		player.deaths,
		player.suicides,
		player.misses,
		player.shots,
		player.hits_made,
		player.hits_get,
		player.tk_made,
		player.tk_get,
		player.flags_returned,
		player.flags_stolen,
		player.flags_scored,
		player.damage,
		player.damagewasted,
		player.accuracy,
		player.timeplayed,
		player.finished and 1 or 0,
		player.win,
		player.rank,
		player.ctfgame and 1 or 0,
		player.botskill,
		player.playerweight,
		player.bookmark and 1 or 0)

	nl.log_stats(sql)
	
	cur = assert (con:execute(sql))
end

function nl.commit()
	
	-- irc_say("nl.commit")
	
	local game_id
	local team_id
	local player_id

	env = assert (luasql.mysql())
	con = assert (env:connect(server.stats_mysql_database, server.stats_mysql_username, server.stats_mysql_password, server.stats_mysql_hostname, server.stats_mysql_port));

	game_id = insert_game()
	
	local teams = constructTeamsTable()

	for id, player in pairs(nl_players) do
		player.game_id = game_id
	end
	
	for i, team in ipairs(teams or {}) do
		local team_id = insert_team(game_id, team)
		
		if not team_id then
			return false
		end
		
		for id, player in pairs(nl_players) do
			if player.team == team.name then player.team_id = team_id end
		end
	end

	for id, player in pairs(nl_players) do
		if (player.frags > 0 and player.timeplayed > 60) then
			insert_player(game_id, player)
		end
	end

	if not con:close() then server.log_error("con:close failed in nl.checkname") end
	if not env:close() then server.log_error("env:close failed in nl.checkname") end

	-- Create the teamtable if needed
	--[[
	if gamemodeinfo.teams then
		local nl_teams = {}
		for _, teamname in ipairs(server.teams()) do
			team = {}
			team.name = teamname
			team.score = server.team_score(teamname)
			team.win = server.team_win(teamname)
			team.draw = server.team_draw(teamname)
			table.insert(nl_teams, team)
		end
	end
	]]
	--[[
	nl.log_stats(string.format("nl.commit()"))
	nl.log_stats(string.format("nl_game.datetime=%s", tostring(nl_game.datetime)))
	nl.log_stats(string.format("nl_game.duration=%s", tostring(nl_game.duration)))
	nl.log_stats(string.format("nl_game.mode=%s", tostring(nl_game.mode)))
	nl.log_stats(string.format("nl_game.map=%s", tostring(nl_game.map)))
	nl.log_stats(string.format("nl_game.finished=%s", tostring(nl_game.finished)))
	nl.log_stats(string.format("nl_game.demofile=%s", tostring(nl_game.demofile)))
	]]
	--[[
	for id, nl_player in pairs(nl_players) do
		nl.log_stats(string.format("nl_player.name=%s", tostring(nl_player.name)))
		nl.log_stats(string.format("nl_player.playing=%s", tostring(nl_player.playing)))
		nl.log_stats(string.format("nl_player.timeplayed=%s", tostring(nl_player.timeplayed)))
		nl.log_stats(string.format("nl_player.finished=%s", tostring(nl_player.finished)))
		nl.log_stats(string.format("nl_player.win=%s", tostring(nl_player.win)))
		nl.log_stats(string.format("nl_player.rank=%s", tostring(nl_player.rank)))
		nl.log_stats(string.format("nl_player.country=%s", tostring(nl_player.country)))
		nl.log_stats(string.format("nl_player.registered=%s", tostring(nl_player.registered)))
		nl.log_stats(string.format("nl_player.flags_stolen=%s", tostring(nl_player.flags_stolen)))
		nl.log_stats(string.format("nl_player.flags_scored=%s", tostring(nl_player.flags_scored)))
		nl.log_stats(string.format("nl_player.flags_returned=%s", tostring(nl_player.flags_returned)))
		nl.log_stats(string.format("nl_player.skillpoints=%s", tostring(nl_player.skillpoints)))
		nl.log_stats(string.format("nl_player.botskill=%s", tostring(nl_player.botskill)))
		nl.log_stats(string.format("nl_player.ctf=%s", tostring(nl_player.ctf)))
		nl.log_stats(string.format("nl_player.teamkills=%s", tostring(nl_player.teamkills)))
		nl.log_stats(string.format("nl_player.score=%s", tostring(nl_player.score)))
		nl.log_stats(string.format("nl_player.frags=%s", tostring(nl_player.frags)))
		nl.log_stats(string.format("nl_player.death=%s", tostring(nl_player.death)))
		nl.log_stats(string.format("nl_player.suicides=%s", tostring(nl_player.suicides)))
		nl.log_stats(string.format("nl_player.hits=%s", tostring(nl_player.hits)))
		nl.log_stats(string.format("nl_player.misses=%s", tostring(nl_player.misses)))
		nl.log_stats(string.format("nl_player.shots=%s", tostring(nl_player.shots)))
		nl.log_stats(string.format("nl_player.damage=%s", tostring(nl_player.damage)))
		nl.log_stats(string.format("nl_player.damagewasted=%s", tostring(nl_player.damagewasted)))
		nl.log_stats(string.format("nl_player.timeplayed=%s", tostring(nl_player.timeplayed)))
		nl.log_stats(string.format("nl_player.nl_status=%s", tostring(nl_player.nl_status)))
		nl.log_stats(string.format("nl_player.statsname=%s", tostring(nl_player.statsname)))
		nl.log_stats(string.format("nl_player.disconnected=%s", tostring(nl_player.disconnected)))
	end
	]]
	--[[
	for id, nl_team in pairs(nl_teams) do
		nl.log_stats(string.format("nl_team.name=%s", tostring(nl_team.name)))
		nl.log_stats(string.format("nl_team.score=%s", tostring(nl_team.score)))
		nl.log_stats(string.format("nl_team.win=%s", tostring(nl_team.win)))
		nl.log_stats(string.format("nl_team.draw=%s", tostring(nl_team.draw)))
	end
	]]
end

server.event_handler("finishedgame", function()
  nl.EndGame()
end)
