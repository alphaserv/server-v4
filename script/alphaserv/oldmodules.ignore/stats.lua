stats = {}
stats.time = os.time()

stats.players = {}
function bool2number(a)
	if a then return 1 else return 0 end
end

function stats.save()
	if not alpha.save_stats then return false end

	stats.players = {} -- empty table
	local ids = {}
	for i, cn in pairs(players.all()) do
		if priv.has(cn, priv.USER) then
			--only save stats for registered users
			if ids[playervars.get(cn, "user_id")] ~= true then
			
				local player = {
					name = playervars.get(cn, "name"),
					user_id = playervars.get(cn, "user_id"),
					ip = playervars.get(cn, "ip"),
					country = playervars.get(cn, "country"),
					team = playervars.get(cn, "team"),
					playing = playervars.get(cn, "playing"),
					frags = playervars.get(cn, "frags"),
					deaths = playervars.get(cn, "deaths"),
					suicides = playervars.get(cn, "suicides"),
					misses = playervars.get(cn, "misses"),
					shots = playervars.get(cn, "shots"),
					hits_made = playervars.get(cn, "hits_made"),
					hits_get = playervars.get(cn, "hits_get"),
					tk_made = playervars.get(cn, "tk_made"),
					tk_get = playervars.get(cn, "tk_get"),
					flags_returned = playervars.get(cn, "flags_returned"),
					flags_stolen = playervars.get(cn, "flags_stolen"),
					flags_gone = playervars.get(cn, "flags_gone"),
					flags_scored = playervars.get(cn, "flags_scored"),
					total_scored = playervars.get(cn, "total_scored"),
					win = (server.player_win(cn) or false),
					rank = (server.player_rank(cn) or 0),
					team_id = -1
				}
				if server.player_timeplayed(cn) < 60 then
					debug.write(0, server.player_displayname(cn).." has too less played to be saved in stats")
				else
					table.insert(stats.players, player)
					ids[playervars.get(cn, "user_id")] = true
				end
			end
		elseif tonumber(config.get("stats:save_non_logged_in")) then
			if ids[server.player_ip(cn)] ~= true and not server.isbot(cn) then
				local player = {
					name = playervars.get(cn, "name"),
					user_id = -1,
					ip = playervars.get(cn, "ip"),
					country = playervars.get(cn, "country"),
					team = playervars.get(cn, "team"),
					playing = playervars.get(cn, "playing"),
					frags = playervars.get(cn, "frags"),
					deaths = playervars.get(cn, "deaths"),
					suicides = playervars.get(cn, "suicides"),
					misses = playervars.get(cn, "misses"),
					shots = playervars.get(cn, "shots"),
					hits_made = playervars.get(cn, "hits_made"),
					hits_get = playervars.get(cn, "hits_get"),
					tk_made = playervars.get(cn, "tk_made"),
					tk_get = playervars.get(cn, "tk_get"),
					flags_returned = playervars.get(cn, "flags_returned"),
					flags_stolen = playervars.get(cn, "flags_stolen"),
					flags_gone = playervars.get(cn, "flags_gone"),
					flags_scored = playervars.get(cn, "flags_scored"),
					total_scored = playervars.get(cn, "total_scored"),
					win = (server.player_win(cn) or false),
					rank = (server.player_rank(cn) or 0),
					team_id = -1
				}
				if server.player_timeplayed(cn) < 60 then
					debug.write(0, server.player_displayname(cn).." has too less played to be saved in stats")
				else
					table.insert(stats.players, player)
					ids[server.player_ip(cn)] = true
				end
			end
		end
	end
	
	if #ids < 1 then
		debug.write(1, "too less players to save stats")
	end
	
	local game = {}
	
	local addgame_sql = [[INSERT INTO stats_games (map, mode, datetime) VALUES (%q,%q,from_unixtime(%i))]]
	addgame_sql = string.format(addgame_sql, server.map, server.gamemode, stats.time)
	if db.query(addgame_sql) then
		if messages.debug then messages.debug(-1, players.admins(), "inserted game", false) end
	else
		error("could not insert game")
		return
	end


	local cur = assert (db.con:execute("SELECT last_insert_id()"))

	game.id = cur:fetch()
	
	if gamemodeinfo.teams then
		for _, teamname in ipairs(server.teams()) do
			team = {}
			team.name = teamname
			team.score = server.team_score(teamname)
			team.win = server.team_win(teamname)
			team.draw = server.team_draw(teamname)
			local addteam_sql = [[INSERT INTO stats_teams (game_id, name, score, win, draw) VALUES (%i,%q,%i,%i,%i)]]
			addteam_sql = string.format(
				addteam_sql,
				game.id,
				team.name,
				team.score,
				team.win,
				team.draw
			)
			if db.query(addteam_sql) then
				--ok
				debug.write(-1, "inserted team")
				local team_id = assert (db.con:execute("SELECT last_insert_id()"))
				team_id = team_id:fetch()
				for i, row in pairs(stats.players) do
					if row.team == team.name then
						stats.players[i].team_id = team_id
					end
				end
			else
				error("could not insert team to db")
				return
			end
		end
	end
	
	
	
	
	
	local sql = [[INSERT INTO stats_users (
					name,
					user_id,
					game_id,
					ip,
					country,
					team,
					team_id,
					playing,
					frags,
					deaths,
					suicides,
					misses,
					shots,
					hits_made,
					hits_get,
					tk_made,
					tk_get,
					flags_returned,
					flags_stolen,
					flags_gone,
					flags_scored,
					total_scored,
					win,
					rank
				)
				VALUES ]]
	local add_sql = [[(%q, %i, %i, %q, %q, %q, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i)]]


	for i, row in pairs(stats.players) do
		local filled_add_sql = string.format(
			add_sql,
			row.name,
			tonumber(row.user_id or 0),
			tonumber(game.id or 0),
			row.ip,
			row.country,
			row.team,
			tonumber(row.team_id),
			tonumber(bool2number(row.playing or true) or 0),
			tonumber(row.frags or 0),
			tonumber(row.deaths or 0),
			tonumber(row.suicides or 0),
			tonumber(row.misses or 0),
			tonumber(row.shots or 0),
			tonumber(row.hits_made or 0),
			tonumber(row.hits_get or 0),
			tonumber(row.tk_made or 0),
			tonumber(row.tk_get or 0),
			tonumber(row.flags_returned or 0),
			tonumber(row.flags_stolen or 0),
			tonumber(row.flags_gone or 0),
			tonumber(row.flags_scored or 0),
			tonumber(row.total_scored or 0),
			tonumber(bool2number(row.win or false)),
			tonumber(row.rank or 0)
		)
		local sql2 = sql..filled_add_sql
		if db.query(sql2) then --execute the query
			messages.debug(-1, players.admins(), "successfuly executed db query: "..messages.escape(sql2), true)
		else
			messages.debug(-1, players.admins(), "could not db query: "..messages.escape(filled_sql2), true)
			error("could not execute query: "..sql)
			return
		end
	end

	
	local totals_sql = [[UPDATE stats_totals SET
							frags = frags + %i,
							deaths = deaths + %i,
							suicides = suicides + %i,
							misses = misses + %i,
							shots = shots + %i,
							hits_made = hits_made + %i,
							hits_get = hits_get + %i,
							tk_made = tk_made + %i,
							tk_get = tk_get + %i,
							flags_returned = flags_returned + %i,
							flags_stolen = flags_stolen + %i,
							flags_gone = flags_gone + %i,
							flags_scored = flags_scored + %i,
							total_scored = total_scored + %i
							WHERE user_id = %i;
						]]
	for i, row in pairs(stats.players) do
		local filled_sql = string.format(
			totals_sql,
			row.frags,
			row.deaths,
			row.suicides,
			row.misses,
			row.shots,
			row.hits_made,		
			row.hits_get,
			row.tk_made,
			row.tk_get,
			row.flags_returned,		
			row.flags_stolen,
			row.flags_gone,
			row.flags_scored,
			row.total_scored,
			row.user_id
		)
		db.query(filled_sql)--execute the query
		
	end
end
server.event_handler("finishedgame", function()
  stats.save()
  stats.time = os.time() --get time
end)
--server.stats_save =   stats.save
