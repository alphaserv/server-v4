
module("stats", package.seeall)

block_saving = false

local save_stats = alpha.settings.new_setting("save_stats", true, "save stats database.")
local server_id = alpha.settings.new_setting("stats_server_id", 0, "id of the server in the database.")
local min_time_played = alpha.settings.new_setting("stats_min_time_played", -1, "minimum time played before saving player in the stats.")
local only_logged_in = alpha.settings.new_setting("stats_ony_logged_in", false, "only save stats for players wich are logged in.")
local min_players = alpha.settings.new_setting("stats_min_players", -1, "minimum playercount to save stats.")

--the time when the game started
local start_time = os.time()

function save()
	if block_saving or not save_stats:get() then
		return false
	end

	--players wich played in this game
	local players = {}
	
	--save stats also for players wich aren't logged in
	local save_all_players = not only_logged_in:get()

	all_obj_user():foreach(function(player)
		log_msg(LOG_INFO, "checking if %(1)s will be saved." % {player:get_stat("name")})
		if --[[frags > 0 and deaths > 0 and]] server.player_timeplayed(player.cn) > min_time_played:get() then
			if player.user_id ~= -1 or save_all_players then
			
				--stats wich are updated at the end of the game, TODO: move to stats.lua
				player:update_stat("game_id", "set", -1)
				player:update_stat("team_id", "set", -1)
				player:update_stat("timeplayed", "set",server.player_timeplayed(player.cn))
				player:update_stat("rank", "set", server.player_rank(player.cn))
				player:update_stat("win", "set", server.player_win(player.cn))
				
				players[player.cn] = player
				log_msg(LOG_INFO, "%(1)s will be saved." % {player:get_stat("name")})
			else
				log_msg(LOG_INFO, "%(1)s isn't logged in so wasn't saved." % {player:get_stat("name")})
			end
		else
			log_msg(LOG_INFO, "%(1)s didn't play long enough to be saved" % {player:get_stat("name")})
		end
	end)
	
	if #players < min_players:get() then
		log_msg(LOG_INFO, "too less players to save")
		return false
	end
	
	log_msg(LOG_INFO, "saving stats")
	
	local game_id = -1

	if not alpha.db:query([[
		INSERT INTO
			stats_games
			(
				map,
				mode,
				datetime
			)
		VALUES
			(
				?,
				?,
				from_unixtime(%(1)i)
			)]] % {	start_time }, server.map, server.gamemode) then--TODO: map_id
		error("Error while saving stats: could not insert game")
	end

	local res = alpha.db:query("SELECT last_insert_id() AS id")
	res = res:fetch()
	game_id = res[1].id
	
	log_msg(LOG_INFO, "saved game (id=%(1)s)" % {tostring(game_id)})

	--gamemode has teams
	if server.get_gamemode_info().teams then
		for _, name in ipairs(server.teams()) do
			if not alpha.db:query([[
				INSERT INTO
					stats_teams
					(
						game_id,
						name,
						score,
						win,
						draw
					)
				VALUES
					(
						?,
						?,
						?,
						?,
						?
					)
			]], game_id, name, server.team_score(name), server.team_win(name), server.team_draw(name)) then
				error("Error while saving stats: could not save teams ("..name..")")
			end

			local res = alpha.db:query("SELECT LAST_INSERT_ID() AS id")
			res = res:fetch()
			log_msg(LOG_INFO, "insert id return: "..table_to_string(res, true))
			local team_id = res.id

			for i, player in pairs(players) do
				if player:get_stat("team") == name then
					player:update_stat("team_id", "set", team_id)
				end
			end
			
			log_msg(LOG_INFO, "saved team (id=%(1)i)" % {team_id})
		end
	else
		log_msg(LOG_INFO, "not a team mode, skiped")
	end
	
	for i, user in pairs(players) do
		if not alpha.db:query([[
			INSERT INTO
				stats_users
				(
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
			VALUES
				(
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?,
					?
				)
			]], 
				user:get_stat("name"),
				tonumber(user.user_id or -1),
				tonumber(game_id or -1),
				user:get_stat("ip"),
				user:get_stat("country"),
				user:get_stat("team"),
				user:get_stat("team_id") or -1,
				1, --playing
				user:get_stat("frags"),
				user:get_stat("deaths"),
				user:get_stat("suicides"),
				user:get_stat("misses"),
				user:get_stat("shots"),
				user:get_stat("hits_made"),
				user:get_stat("hits_get"),
				user:get_stat("tk_made"),
				user:get_stat("tk_get"),
				user:get_stat("flags_returned"),
				user:get_stat("flags_stolen"),
				user:get_stat("flags_gone"),
				user:get_stat("flags_scored"),
				user:get_stat("total_scored"),
				user:get_stat("win"),
				user:get_stat("rank")
		) then error("Could not save user stats for user ".. user:get_stat("name")) end
	
		log_msg(LOG_INFO, "saved stats_user (name=%(1)s)" % {user:get_stat("name")})
		
		if user.user_id ~= -1 then
			if not apha.db:query([[
				UPDATE
					stats_totals
				SET
					frags = frags + ?,
					deaths = deaths + ?,
					suicides = suicides + ?,
					misses = misses + ?,
					shots = shots + ?,
					hits_made = hits_made + ?,
					hits_get = hits_get + ?,
					tk_made = tk_made + ?,
					tk_get = tk_get + ?,
					flags_returned = flags_returned + ?,
					flags_stolen = flags_stolen + ?,
					flags_gone = flags_gone + ?,
					flags_scored = flags_scored + ?,
					total_scored = total_scored + ?
				WHERE
					user_id = ?
				]],
				user:get_stat("frags"),
				user:get_stat("deaths"),
				user:get_stat("suicides"),
				user:get_stat("misses"),
				user:get_stat("shots"),
				user:get_stat("hits_made"),
				user:get_stat("hits_get"),
				user:get_stat("tk_made"),
				user:get_stat("tk_get"),
				user:get_stat("flags_returned"),
				user:get_stat("flags_stolen"),
				user:get_stat("flags_gone"),
				user:get_stat("flags_scored"),
				user:get_stat("total_scored"),
				user.user_id
			) then error("Could not update totalstats for user ".. user:get_stat("name")) end
			
			log_msg(LOG_INFO, "updated total user stats (id=%(1)i)" % {user.user_id})
		else
			log_msg(LOG_INFO, "user not logged in, skiping")
		end
	end --/for i, player in pairs(players) do

	if as_master.client.send_msg then
		log_msg(LOG_INFO, "saving to external stats database")
		
		as_master.client.send_msg({"add_stats", "game", { start_time = start_time, map = server.map, mode = server.gamemode}})
		if server.get_gamemode_info().teams then
			for _, name in ipairs(server.teams()) do
				as_master.client.send_msg({"add_stats", "team", {name = name}})
			end
		else
			as_master.client.send_msg({"add_stats", "noteam"})
		end
		
		for i, user in pairs(players) do
			if user.authedwith == "as_ext_auth" and user.ext_key then
				as_master.client.send_msg({"add_stats", "user", {
					name = user:get_stat("name"),
					user_id = user.user_id,
					key = user.ext_key,
					ip = user:get_stat("ip"),
					country = user:get_stat("country"),
					team = user:get_stat("team"),
					
					frags = user:get_stat("frags"),
					deaths = user:get_stat("deaths"),
					suicicdes = user:get_stat("suicides"),
					misses = user:get_stat("misses"),
					shots = user:get_stat("shots"),
					hits_made = user:get_stat("hits_made"),
					hits_get = user:get_stat("hits_get"),
					tk_made = user:get_stat("tk_made"),
					tk_get = user:get_stat("tk_get"),
					flags_returned = user:get_stat("flags_returned"),
					flags_stolen = user:get_stat("flags_stolen"),
					flags_gone = user:get_stat("flags_gone"),
					flags_scored = user:get_stat("flags_scored"),
					total_scored = user:get_stat("total_scored"),
					win = user:get_stat("win"),
					rank = user:get_stat("rank")
				
				}})
			end
		end
	end
end

server.event_handler("finishedgame", function()
	save()
	start_time = os.time() --get time
end)
