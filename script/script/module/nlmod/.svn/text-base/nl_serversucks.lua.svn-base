--[[
	script/module/nl_mod/nl_serversucks.lua
	
	Functionality:
		Players can state in game wheter or not they like the server
		If enough people dislike the server, the server will be shut down for a
		specified amount of time.
]]

serversucks = {}
serversucks.module_name = "SERVERSUCKS"

--- serversucks votes got here
serversucks.hateserver = {}

--- loveserver votes go here
serversucks.loveserver = {}

--- delay of the shutdown countdown
serversucks.countdown_delay = 4

--- duration of the shutdown countdown
serversucks.countdown_duration = 10

--- Database table for storing votes:
serversucks.db_table = "nl_serversucks"



--- Function to count the entries in a given table
-- @param t table that holds the entries
function count_table_entries(t)
	if t == nil then
		return 0
	end
	
	local count = 0
	for key, value in pairs(t) do
		count = count + 1
	end
	return count
end



--- Count the votes
function serversucks.vote_count()
	local hates = count_table_entries(serversucks.hateserver)
	local loves = count_table_entries(serversucks.loveserver)
	return hates - loves
end



--- Calculated the needed votes
function serversucks.needed_votes()
	local player_count = count_table_entries(players.all())
	if player_count < 2 then
		return 1
	else
		return player_count / 2
	end
end



-- Reset the votings
function serversucks.reset()
	serversucks.loveserver = {}
	serversucks.hateserver = {}
end



-- Shut down the server if the necessary amount of votes is reached
function serversucks.shutdown()
	local voted = serversucks.vote_count()
	local needed = serversucks.needed_votes()
	if voted < needed then
		return
	else
		messages.info(-1, players.all(), serversucks.module_name,
			string.format(
				"green<%d>/%d players in think that this server red<sucks>, "
				.."red<shutting down> the server.",
				voted, needed))
		for countdown = 0, serversucks.countdown_duration do
			server.sleep((countdown * 1000) + serversucks.countdown_delay * 1000,
				function()
					messages.info(-1, players.all(), serversucks.module_name,
						string.format(
						"The server will will be red<shut down> in %d seconds.",
						10 - countdown))
				end)
		end
		server.sleep((serversucks.countdown_duration * 1000) + serversucks.countdown_delay * 1000 + 250,
			function()
				messages.error(-1, players.all(), serversucks.module_name,
						"script/module/nlmod/nl_serversucks.lua:84: attempt to call global 'shutdown' (a nil value)"
						.."\nCall stack:"
						.."    script/module/nlmod/nl_serversucks.lua:84")
				-- TODO: Add shutdown command
			end)
	end
end



--- Notify all players about the current state of the votings
function serversucks.notify_players()
	local needed = serversucks.needed_votes()
	local voted = serversucks.vote_count()
	if voted < 0 then
		needed = needed - voted
		voted = 0
	end
	if voted >= needed then
		voted = string.format("green<%d>", voted)
	else
		voted = string.format("red<%d>", voted)
	end
	
	messages.info(-1, players.all(), serversucks.module_name,
		string.format(
			"Got %s of %d needed votes to red<shut down> blue<the server> at next map change.",
			voted, needed, team))
	messages.info(-1, players.all(), serversucks.module_name,
		"Use orange<#serversucks> if you think blue<this server> red<sucks>. ")
	messages.info(-1, players.all(), serversucks.module_name,
		"Use orange<#loveserver> if you green<love> blue<this server>.")
end


--- Store current voting state in the dtabase
function db_write()
	local votes = {}
	for cn, vote in pairs(serversucks.loveserver) do
		local name = server.player_name(cn)
		votes[name] = 0
	end
	for cn, vote in pairs(serversucks.hateserver) do
		local name = server.player_name(cn)
		votes[name] = 1
	end
	for name, vote in pairs(votes) do
		db.insert(serversucks.db_table, {player=name, vote=vote})
	end
end



--- Process a serversucks command issued by a player
-- If the player already voted, the vote will be discarded.
-- If the player previously stated tha he loves the server, this vote will be
-- changed.
-- @param cn CN (Client Number) of the player who issued the command
function process_serversucks(cn)
	if serversucks.hateserver[cn] == nil and serversucks.loveserver[cn] == nil then
		serversucks.hateserver[cn] = true
		messages.info(-1, players.all(), serversucks.module_name,
			string.format(
				"blue<%s> thinks that this server red<sucks>",
				server.player_name(cn)))
		serversucks.notify_players()
	elseif serversucks.hateserver[cn] == nil and serversucks.loveserver[cn] then
		serversucks.loveserver[cn] = nil
		serversucks.hateserver[cn] = true
		messages.info(-1, players.all(), serversucks.module_name,
			string.format(
				"blue<%s> changed his mind and now thinks that this server red<sucks>.",
				server.player_name(cn)))
		serversucks.notify_players()
	else
		messages.error(-1, cn, serversucks.module_name, "You already voted.")
	end
end



--- Process a serversucks command issued by a player
-- If the player already voted, the vote will be discarded.
-- If the player previously stated tha he loves the server, this vote will be
-- changed.
-- @param cn CN (Client Number) of the player who issued the command
function process_loveserver(cn)
	if serversucks.loveserver[cn] == nil and serversucks.hateserver[cn] == nil then
		serversucks.loveserver[cn] = true
		messages.info(-1, players.all(), serversucks.module_name,
			string.format(
				"blue<%s> green<loves> this server.",
				server.player_name(cn)))
		serversucks.notify_players()
	elseif serversucks.loveserver[cn] == nil and serversucks.hateserver[cn] then
		serversucks.hateserver[cn] = nil
		serversucks.loveserver[cn] = true
		messages.info(-1, players.all(), serversucks.module_name,
			string.format(
				"blue<%s> changed his mind and now green<loves> this server.",
				server.player_name(cn)))
		serversucks.notify_players()
	else
		messages.error(-1, cn, serversucks.module_name, "You already voted.")
	end
end



--- Player command for stating that the server sucks
-- @param cn CN (Client Number) of the player who thinks the server sucks
-- @param arg additional agument to pass more commands
function server.playercmd_serversucks(cn, arg)
	if arg == "info" then
		serversucks.notify_players()
	elseif arg == nil then
		process_serversucks(cn)
	else
		messages.error(-1, cn, serversucks.module_name, "Invalid argument.")
	end
end



--- Player command for stating that one loves the server
-- @param cn CN (Client Number) of the player who loves the server
function server.playercmd_loveserver(cn)
	process_loveserver(cn)
end



server.event_handler("intermission",
	function()
		serversucks.shutdown()
		serversucks.reset()
	end)