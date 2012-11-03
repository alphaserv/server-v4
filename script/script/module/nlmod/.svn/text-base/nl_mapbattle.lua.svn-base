--[[
	script/module/nl_mod/nl_mapbattle.lua
	Hanack (Andreas Schaeffer)
	Created: 17-Okt-2010
	Last Modified: 23-Okt-2010
	License: GPL3

	Funktionen:
		Ein neuer Intermission Mode: MapBattle. Es treten zwei Maps gegeneinander an. Alle
		verbundenen Spieler (auch Spectators) dürfen innerhalb einer bestimmten Zeit ihr
		Votum für eine der beiden Maps abgeben. Es ist auch möglich sich gegen beide Maps
		auszusprechen. Bekommt eine der drei Optionen eine einfache Mehrheit (die meisten
		Stimmen, Enthaltungen werden nicht berücksichtigt), so wird entweder zur gewählten
		Map gewechselt oder es wird die nächste.
	

	API-Methoden:
		mapbattle.suggest_map
			wechselt sofort zu angebener map und mode

	Commands:
		#mapbattle <MAP1> <MAP2>
			Initiiere ein neue Mapbattle
		#1
			Stimme für die erste Map
		#2
			Stimme für die zweite Map
		#none
			Keine Stimme für irgendeine der beiden Maps 

	Laufzeit-Variablen:
		mapbattle.suggested_maps
			Tabelle, die die aktuellen Suggestions enthält:
			Key: cn
			Value: mapname
]]

require "math"



--[[
		API
]]

mapbattle = {}
mapbattle.voting = {}
mapbattle.voting.map1 = 0
mapbattle.voting.map2 = 0
mapbattle.voting.none = 0
mapbattle.voting.all = 0
mapbattle.names = {}
mapbattle.names.map1 = ""
mapbattle.names.map2 = ""
mapbattle.players = {}
mapbattle.players.map1 = -1
mapbattle.players.map2 = -1
mapbattle.sudden_death = 0
mapbattle.max_sudden_death = 2
mapbattle.remaining_seconds = 0
mapbattle.previous_intermission_mode = 3
--        playercount            1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
mapbattle.delay_players      = { 5,10,10,11,11,11,12,12,13,13,14,15,16,17,18,19,20,20,21,21,22,22,22,23,23,23,23,24,24,24,24,24,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,30,30 }
mapbattle.delay_sudden_death = { 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9,10,10,10,10,10,10,11,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15 }
mapbattle.suggested_maps = {}
mapbattle.suggestions = 0
mapbattle.lastmaps = {}


-- 1. Ablauf: Der Ablauf während eines MapBattles

maprotation.intermission_modes.MAPBATTLE = 4
maprotation.intermission[maprotation.intermission_modes.MAPBATTLE] = function()
	--[[
		intermission mode 4: mapbattle
		Es wird ein MapBATTLE initiiert
	]]
	mapbattle.remaining_seconds = mapbattle.delay_players[server.playercount] 
	messages.info(cn, players.all(), "MAPBATTLE", " " )
	messages.info(cn, players.all(), "MAPBATTLE", string.format(" red<VOTE NOW for a map:> %s yellow<(#1 from %s)> vs. %s yellow<(#2 from %s)>", mapbattle.names.map1, mapbattle.players.map1, mapbattle.names.map2, mapbattle.players.map2))
	messages.info(cn, players.all(), "MAPBATTLE", "   yellow<Commands are:> orange<#1 #2 #none>")
	mapbattle.update()
	server.is_intermission = 1
	server.intermissionmode = maprotation.intermission_mode
	server.opt1_item = mapbattle.names.map1
	server.opt1_extras = mapbattle.players.map1
	server.opt2_item = mapbattle.names.map2
	server.opt2_extras = mapbattle.players.map2
end

maprotation.intermission_break[maprotation.intermission_modes.MAPBATTLE] = function()
	--[[
		break intermission mapbattle
	]]
	mapbattle.reset_votes()
end


function mapbattle.update()
	-- Intermission abbrechen oder fortsetzen?
	
	-- Abbruch, wenn Zeit abgelaufen ist
	if mapbattle.remaining_seconds <= 0 then
		mapbattle.check_winner()
		return
	end
	
	local remaining_possible_votes = server.playercount - mapbattle.voting.all
	messages.debug(-1, players.admins(), "MAPBATTLE", string.format("blue<votes:> %s  --  blue<remaining possible votes:> %s", mapbattle.voting.all, remaining_possible_votes))

	-- Abbruch, wenn Map1, Map2 oder None uneinholbar werden
	if remaining_possible_votes < math.abs(mapbattle.voting.map1 - mapbattle.voting.map2) then
		messages.debug(-1, players.admins(), "MAPBATTLE", "blue<Abbruch: map1 oder map2 sind nicht mehr einholbar>")
		mapbattle.check_winner()
		return
	end
	if remaining_possible_votes < math.abs(mapbattle.voting.map1 - mapbattle.voting.none) then
		messages.debug(-1, players.admins(), "MAPBATTLE", "blue<Abbruch: map1 oder none sind nicht mehr einholbar>")
		mapbattle.check_winner()
		return
	end
	if remaining_possible_votes < math.abs(mapbattle.voting.map2 - mapbattle.voting.none) then
		messages.debug(-1, players.admins(), "MAPBATTLE", "blue<Abbruch: map2 oder none sind nicht mehr einholbar>")
		mapbattle.check_winner()
		return
	end

	-- Intermission fortsetzen
	server.sleep(1000, function()
		mapbattle.remaining_seconds = mapbattle.remaining_seconds - 1
		mapbattle.update()
	end)
end

function mapbattle.push_time()
	if mapbattle.remaining_seconds < 4 then
		mapbattle.remaining_seconds = 4
	end
end

function mapbattle.check_winner()
	if mapbattle.voting.map1 >= mapbattle.voting.none or mapbattle.voting.map2 >= mapbattle.voting.none then
		if mapbattle.voting.map1 > mapbattle.voting.map2 then
			-- winner: map1
			messages.warning(-1, players.all(), "MAPBATTLE", "orange<WINNER:> "..mapbattle.names.map1)
			maprotation.push_map(mapbattle.names.map1)
			mapbattle.reset()
			maprotation.next_map(maprotation.game_mode)
		elseif mapbattle.voting.map1 < mapbattle.voting.map2 then
			-- winner: map2
			messages.warning(-1, players.all(), "MAPBATTLE", "orange<WINNER:> "..mapbattle.names.map2)
			maprotation.push_map(mapbattle.names.map2)
			mapbattle.reset()
			maprotation.next_map(maprotation.game_mode)
		else
			-- tie
			mapbattle.sudden_death = mapbattle.sudden_death + 1
			mapbattle.voting.all = 0
			if mapbattle.sudden_death <= mapbattle.max_sudden_death then
				-- sudden death starten/weiterführen
				messages.warning(-1, players.all(), "MAPBATTLE", "orange<SUDDEN DEATH!>  red<YOU CAN VOTE AGAIN NOW!  VOTE FAST!>")
				mapbattle.reset_votes()
				-- messages.info(-1, players.all(), "MAPBATTLE", "remaining seconds old: " .. mapbattle.remaining_seconds)
				-- messages.info(-1, players.all(), "MAPBATTLE", "delay_sudden_deaths for " .. server.playercount .. " players: " .. mapbattle.delay_sudden_death[server.playercount])
				server.sleep(2000, function()
					mapbattle.remaining_seconds = mapbattle.delay_sudden_death[server.playercount]
					messages.debug(-1, players.admins(), "MAPBATTLE", "blue<remaining seconds new:> " .. mapbattle.remaining_seconds)
					mapbattle.update()
				end)
			else
				-- sudden death bringt kein neues ergebnis, abbruch
				messages.warning(-1, players.all(), "MAPBATTLE", "orange<TIE AFTER SUDDEN DEATH!>  green<Starting new normal voting phase now.>")
				mapbattle.reset()
				maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			end
		end
	else
		if mapbattle.voting.map1 == 0 and mapbattle.voting.map2 == 0 then
			-- winner: 0:0
			mapbattle.reset()
			maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			messages.warning(-1, players.all(), "MAPBATTLE", "orange<TIE>  0 : 0  ")
		else
			-- winner: none
			mapbattle.reset()
			maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			messages.warning(-1, players.all(), "MAPBATTLE", "orange<NO MAP WINS.>  red<Most players dont want playing these maps.>  green<Starting new normal voting phase now.>")
		end
	end
end

function mapbattle.choose_map1(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		if nl.getPlayer(cn, "mapbattle") == 1 then
			messages.error(cn, {cn}, "MAPBATTLE", "red<You have already voted!>")
		else
			mapbattle.voting.map1 = mapbattle.voting.map1 + 1
			mapbattle.voting.all = mapbattle.voting.all + 1
			nl.updatePlayer(cn, "mapbattle", 1, "set")
			mapbattle.push_time()
			server.msg(string.format(orange("  [ MAPBATTLE ]  %s (#1)") .. " %i : %i " .. orange("%s (#2)") .. blue(" -- %s voted for %s"), mapbattle.names.map1, mapbattle.voting.map1, mapbattle.voting.map2, mapbattle.names.map2, server.player_displayname(cn), mapbattle.names.map1))
			server.set_imodeoption(cn, 1)
		end
	else
		messages.error(cn, {cn}, "MAPBATTLE", "red<Currently there is no MAP BATTLE!>")
	end
end

function mapbattle.choose_map2(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		if nl.getPlayer(cn, "mapbattle") == 1 then
			messages.error(cn, {cn}, "MAPBATTLE", "red<You have already voted!>")
		else
			mapbattle.voting.map2 = mapbattle.voting.map2 + 1
			mapbattle.voting.all = mapbattle.voting.all + 1
			nl.updatePlayer(cn, "mapbattle", 1, "set")
			mapbattle.push_time()
			server.msg(string.format(orange("  [ MAPBATTLE ]  %s (#1)") .. " %i : %i " .. orange("%s (#2)") .. blue(" -- %s voted for %s"), mapbattle.names.map1, mapbattle.voting.map1, mapbattle.voting.map2, mapbattle.names.map2, server.player_displayname(cn), mapbattle.names.map2))
			server.set_imodeoption(cn, 2)
		end
	else
		messages.error(cn, {cn}, "MAPBATTLE", "red<Currently there is no MAP BATTLE!>")
	end
end

function mapbattle.choose_none(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		if nl.getPlayer(cn, "mapbattle") == 1 then
			messages.error(cn, {cn}, "MAPBATTLE", "red<You have already voted!>")
		else
			mapbattle.voting.none = mapbattle.voting.none + 1
			mapbattle.voting.all = mapbattle.voting.all + 1
			nl.updatePlayer(cn, "mapbattle", 1, "set")
			mapbattle.push_time()
			server.msg(string.format(orange("  [ MAPBATTLE ]  %s (#1)") .. red(" %i : %i ") .. orange("%s (#2)") .. blue(" -- %s wants neither of them (%s)"), mapbattle.names.map1, mapbattle.voting.map1, mapbattle.voting.map2, mapbattle.names.map2, server.player_displayname(cn), mapbattle.voting.none))
			server.set_imodeoption(cn, 3)
		end
	else
		messages.error(cn, {cn}, "MAPBATTLE", "red<Currently there is no MAP BATTLE!>")
	end
end

function mapbattle.choose_namedmap(cn, map)
	if map == mapbattle.names.map1 then
		mapbattle.choose_map1(cn)
	elseif map == mapbattle.names.map2 then
		mapbattle.choose_map2(cn)
	end
end



-- 2. Prüfen und initieren von MapBattles

function mapbattle.reset()
	mapbattle.reset_votes()
	maprotation.intermission_mode = mapbattle.previous_intermission_mode
	server.is_intermission = 0
	server.intermissionmode = maprotation.intermission_mode
	server.opt1_item = ""
	server.opt1_extras = ""
	server.opt2_item = ""
	server.opt2_extras = ""
end

function mapbattle.reset_votes()
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "mapbattle", 0, "set")
	end
end

function mapbattle.init(map1playername, map1name, map2playername, map2name)
	-- modus auf mapbattle stellen
	if maprotation.intermission_mode ~= maprotation.intermission_modes.MAPBATTLE then
		mapbattle.previous_intermission_mode = maprotation.intermission_mode
		maprotation.intermission_mode = maprotation.intermission_modes.MAPBATTLE
		mapbattle.voting.map1 = 0
		mapbattle.voting.map2 = 0
		mapbattle.voting.none = 0
		mapbattle.voting.all = 0
		mapbattle.names.map1 = map1name
		mapbattle.names.map2 = map2name
		mapbattle.players.map1 = map1playername
		mapbattle.players.map2 = map2playername
		mapbattle.sudden_death = 0
		mapbattle.reset_votes()
	end
end

function mapbattle.force_init(cn, map1, map2)
	if maprotation.intermission_running == 0 and maprotation.intermission_mode ~= maprotation.intermission_modes.MAPBATTLE then
		if maprotation.is_valid_map(map1, maprotation.game_mode) then
			if maprotation.is_valid_map(map2, maprotation.game_mode) then
				mapbattle.init(server.player_displayname(cn), map1, server.player_displayname(cn), map2)
				messages.info(cn, players.admins(), "MAPBATTLE", string.format("%s green<has initiated a new mapbattle:> %s vs. %s", server.player_displayname(cn), map1, map2))
			else
				if map2 ~= nil then
					messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Map> %s red<is not a valid map! It has to be a> %s red<map.> Registered users can see a list of available maps: orange<#nm list>",map2, maprotation.game_mode))
				else
					messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Map> ? red<is not a valid map! It has to be a> %s red<map.> Registered users can see a list of available maps: orange<#nm list>", maprotation.game_mode))
				end
			end
		else
			if map1 ~= nil then
				messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Map> %s red<is not a valid map! It has to be a> %s red<map.> Registered users can see a list of available maps: orange<#nm list>",map1, maprotation.game_mode))
			else
				messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Map> ? red<is not a valid map! It has to be a> %s red<map.> Registered users can see a list of available maps: orange<#nm list>", maprotation.game_mode))
			end
		end
 	else
		if maprotation.intermission_running == 1 then
 			messages.error(cn, {cn}, "MAPBATTLE", "red<Suggesting a map battles is not possible during intermission!>")
		else
 			messages.error(cn, {cn}, "MAPBATTLE", string.format("red<There is already a map battle:> %s blue<(%s)> vs. %s blue<(%s)>", mapbattle.names.map1, mapbattle.players.map1, mapbattle.names.map2, mapbattle.players.map2))
		end
	end
end

function mapbattle.get_mapbattle_info()
	if maprotation.intermission_running == 0 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		messages.info(cn, {cn}, "MAPBATTLE", string.format("red<The next mapbattle is:> %s blue<(%s)> vs. %s blue<(%s)>", mapbattle.names.map1, mapbattle.players.map1, mapbattle.names.map2, mapbattle.players.map2))
	end
end

function mapbattle.check_next_battle()
	-- hier wird geprüft, ob ein neues mapbattle ansteht
	if maprotation.intermission_running == 0 and maprotation.intermission_mode ~= maprotation.intermission_modes.MAPBATTLE then
		-- sind zwei maps verfügbar?
		if mapbattle.suggestions >= 2 then
			local cns = {}
			local maps = {}
			for cn, map in pairs(mapbattle.suggested_maps) do
				table.insert(cns, cn)
				table.insert(maps, map)
			end
			local n1 = math.random(#cns)
			local n2 = math.random(#cns)
			while n1 == n2 do
				n2 = math.random(#cns)
			end
			mapbattle.init(server.player_displayname(cns[n1]), maps[n1], server.player_displayname(cns[n2]), maps[n2])
			mapbattle.suggested_maps[cns[n1]] = nil
			mapbattle.suggested_maps[cns[n2]] = nil
			mapbattle.suggestions = mapbattle.suggestions - 2
			nl.updatePlayer(cns[n1], "suggestmap", 0, "set")
			nl.updatePlayer(cns[n2], "suggestmap", 0, "set")
			messages.info(cn, players.admins(), "MAPBATTLE", string.format("green<There is a new mapbattle:> %s blue<(%s)> vs. %s blue<(%s)>", maps[n1], server.player_displayname(cns[n1]), maps[n2], server.player_displayname(cns[n2]) ))
			messages.info(cn, { cns[n1], cns[n2] }, "MAPBATTLE", string.format("green<You have initiated a new mapbattle:> %s blue<(%s)> vs. %s blue<(%s)>", maps[n1], server.player_displayname(cns[n1]), maps[n2], server.player_displayname(cns[n2]) ))
		end
 	end
end



-- 3. Vorschlagen von Maps für ein MapBattle

function mapbattle.suggest_map(cn, map)
	if maprotation.is_valid_map(map, maprotation.game_mode) then
		if mapbattle.has_already_suggested(map) then
			messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Sorry, someone has already suggested map> %s red<for a mapbattle.> Please try another map.", map))
		else
			if mapbattle.has_recently_played(map) then
				messages.error(cn, {cn}, "MAPBATTLE", string.format("red<Sorry, %s has been recently played>. Please try another map.", map))
			else
				if nl.getPlayer(cn, "suggestmap") == 0 then
					messages.info(cn, {cn}, "MAPBATTLE", string.format("green<Your map vote> %s green<was accepted for a mapbattle.>", map))
					mapbattle.suggested_maps[cn] = map
					mapbattle.suggestions = mapbattle.suggestions + 1
					nl.updatePlayer(cn, "suggestmap", 1, "set")
					mapbattle.check_next_battle()
				else
					messages.error(cn, {cn}, "MAPBATTLE", "red<You have already suggested a map for a mapbattle!>")
				end
			end
		end
	else
		messages.error(cn, {cn}, "MAPBATTLE", string.format("red<%s, you cannot choose map> %s red<on this server! It has to be a> %s red<map.> Registered users can see a list of available maps: orange<#nm list>", server.player_displayname(cn), map, maprotation.game_mode))
	end
end

function mapbattle.remove_suggestion(cn)
	if nl.getPlayer(cn, "suggestmap") == 1 then
		mapbattle.suggested_maps[cn] = nil
		mapbattle.suggestions = mapbattle.suggestions - 1
		nl.updatePlayer(cn, "suggestmap", 0, "set")
	end
end

function mapbattle.has_already_suggested(reqmap)
	for cn, map in pairs(mapbattle.suggested_maps) do
		if reqmap == map then
			return true
		end
	end
	return false
end

function mapbattle.has_recently_played(reqmap)
	for i,map in ipairs(mapbattle.lastmaps) do
		if reqmap == map then
			return true
		end
	end
	return false
end

function mapbattle.is_mapbattle_phase()
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		return true
	else
		return false
	end
end


--[[
		COMMANDS
]]

function server.playercmd_mapbattle(cn, map1, map2)
	if map1 ~= nil and map2 ~= nil then
		if not hasaccess(cn, mapbattle_access) then return end
		mapbattle.force_init(cn, map1, map2)
	else
		if map1 ~= nil then
			if map1 == "cancel" then
				messages.warning(cn, players.admins(), "MAPBATTLE", string.format("%s canceled the upcoming mapbattle", server.player_name(cn)))
				mapbattle.reset()
				-- maprotation.intermission_mode = maprotation.intermission_defaultmode
				return
			end
			if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
		 		-- Es wird derzeit ein MapBattle durchgeführt
 				if map1 == mapbattle.names.map1 then
		 			mapbattle.choose_map1(cn)
 				elseif map1 == mapbattle.names.map2 then
		 			mapbattle.choose_map2(cn)
 				else
					messages.error(cn, {cn}, "MAPBATTLE", string.format("red<You cannot vote for> %s red<because it is not valid in this mapbattle.>", map1))
 				end
		 	else
				if map1 ~= maprotation.map and maprotation.intermission_running == 0 then
					mapbattle.suggest_map(cn, map1)
				end
			end
		else
			mapbattle.get_mapbattle_info()
		end
	end
end

function server.playercmd_1(cn)
	mapbattle.choose_map1(cn)
end
server.playercmd_map1 = server.playercmd_1

function server.playercmd_2(cn)
	mapbattle.choose_map2(cn)
end
server.playercmd_map2 = server.playercmd_2

function server.playercmd_none(cn)
	mapbattle.choose_none(cn)
end
server.playercmd_0 = server.playercmd_none
server.playercmd_3 = server.playercmd_none
server.playercmd_4 = server.playercmd_none
server.playercmd_5 = server.playercmd_none
server.playercmd_6 = server.playercmd_none
server.playercmd_7 = server.playercmd_none
server.playercmd_8 = server.playercmd_none
server.playercmd_9 = server.playercmd_none



--[[
		EVENTS
]]

server.event_handler("mapvote", function (cn, map, mode)
 	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE and maprotation.game_mode ~= "coop edit" then
 		-- Es wird derzeit ein MapBattle durchgeführt
 		if map == mapbattle.names.map1 then
 			mapbattle.choose_map1(cn)
 		elseif map == mapbattle.names.map2 then
 			mapbattle.choose_map2(cn)
 		else
			messages.error(cn, {cn}, "MAPBATTLE", string.format("red<You cannot vote for> %s red<because it is not valid in this mapbattle.>", map))
 		end
 	else
		if map ~= maprotation.map and maprotation.intermission_running == 0 then
			mapbattle.suggest_map(cn, map)
		end
	end
end)

server.event_handler("disconnect", function (cn)
	mapbattle.remove_suggestion(cn)
end)

server.event_handler("mapchange", function(map, mode)
	if mapbattle.lastmaps[2] ~= nil then mapbattle.lastmaps[3] = mapbattle.lastmaps[2] end
	if mapbattle.lastmaps[1] ~= nil then mapbattle.lastmaps[2] = mapbattle.lastmaps[1] end
	mapbattle.lastmaps[1] = map
end)

server.interval(2000, function()
	mapbattle.check_next_battle()
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep((maprotation.intermission_startdelay+maprotation.intermission_predelay)*1200, function()
		--[[
				EXTRACTCOMMAND RULES
		]]
		extractcommand.register("1", false, mapbattle.choose_map1, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("2", false, mapbattle.choose_map2, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("0", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("3", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("4", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("5", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("6", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("7", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("8", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("9", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("map1", false, mapbattle.choose_map1, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("map2", false, mapbattle.choose_map2, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("none", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		extractcommand.register("n", false, mapbattle.choose_none, mapbattle.is_mapbattle_phase, false)
		if maprotation ~= nil and maprotation.maps ~= nil and maprotation.maps[server.default_gamemode] ~= nil then
			for k,v in pairs(maprotation.maps[server.default_gamemode]) do
				extractcommand.register(v, false, mapbattle.choose_namedmap, mapbattle.is_mapbattle_phase, true)
			end
		end
	end)
end)





