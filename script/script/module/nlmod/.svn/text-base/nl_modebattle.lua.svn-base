--[[
	script/module/nl_mod/nl_modebattle.lua
	Author:			Hanack (Andreas Schaeffer)
	Created:		22-Apr-2012
	Last Modified:	22-Apr-2012
	License:		GPL3
					WARNING: NEVER EVER REMOVE THE LICENSE OR AUTHOR(S)!

	Funktionen:
		Ein neuer Intermission Mode: modebattle. Es treten zwei Maps gegeneinander an. Alle
		verbundenen Spieler (auch Spectators) dürfen innerhalb einer bestimmten Zeit ihr
		Votum für eine der beiden Maps abgeben. Es ist auch möglich sich gegen beide Maps
		auszusprechen. Bekommt eine der drei Optionen eine einfache Mehrheit (die meisten
		Stimmen, Enthaltungen werden nicht berücksichtigt), so wird entweder zur gewählten
		Map gewechselt oder es wird die nächste.
	

	Commands:
		#modebattle <mode1> <mode2>
			Initiiere ein neue modebattle
		#1
			Stimme für die erste Map
		#2
			Stimme für die zweite Map
		#none
			Keine Stimme für irgendeine der beiden Maps 

	Laufzeit-Variablen:
		modebattle.suggested_modes
			Tabelle, die die aktuellen Suggestions enthält:
			Key: cn
			Value: modename
]]

require "math"



--[[
		API
]]

modebattle = {}
modebattle.voting = {}
modebattle.voting.mode1 = 0
modebattle.voting.mode2 = 0
modebattle.voting.none = 0
modebattle.voting.all = 0
modebattle.names = {}
modebattle.names.mode1 = ""
modebattle.names.mode2 = ""
modebattle.players = {}
modebattle.players.mode1 = -1
modebattle.players.mode2 = -1
modebattle.sudden_death = 0
modebattle.max_sudden_death = 2
modebattle.remaining_seconds = 0
modebattle.previous_intermission_mode = 3
--        playercount            1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
modebattle.delay_players      = { 5,10,10,11,11,11,12,12,13,13,14,15,16,17,18,19,20,20,21,21,22,22,22,23,23,23,23,24,24,24,24,24,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,30,30 }
modebattle.delay_sudden_death = { 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9,10,10,10,10,10,10,11,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15 }
modebattle.suggested_modes = {}
modebattle.suggestions = 0
modebattle.lastmodes = {}


-- 1. Ablauf: Der Ablauf während eines modebattles

maprotation.intermission_modes.MODEBATTLE = 6
maprotation.intermission[maprotation.intermission_modes.MODEBATTLE] = function()
	--[[
		intermission mode 6: modebattle
		Es wird ein modebattle initiiert
	]]
	modebattle.remaining_seconds = modebattle.delay_players[server.playercount] 
	messages.info(-1, players.all(), "MODEBATTLE", " " )
	messages.info(-1, players.all(), "MODEBATTLE", string.format(" red<VOTE NOW for a mode:> %s yellow<(#1 from %s)> vs. %s yellow<(#2 from %s)>", modebattle.names.mode1, modebattle.players.mode1, modebattle.names.mode2, modebattle.players.mode2))
	messages.info(-1, players.all(), "MODEBATTLE", "   yellow<Commands are:> orange<#1 #2 #none>")
	modebattle.update()
end

maprotation.intermission_break[maprotation.intermission_modes.MODEBATTLE] = function()
	--[[
		break intermission modebattle
	]]
	modebattle.reset_votes()
end

function modebattle.update()
	-- Intermission abbrechen oder fortsetzen?
	
	-- Abbruch, wenn Zeit abgelaufen ist
	if modebattle.remaining_seconds <= 0 then
		modebattle.check_winner()
		return
	end
	
	local remaining_possible_votes = server.playercount - modebattle.voting.all
	messages.debug(-1, players.admins(), "MODEBATTLE", string.format("blue<votes:> %s  --  blue<remaining possible votes:> %s", modebattle.voting.all, remaining_possible_votes))

	-- Abbruch, wenn Mode1, Mode2 oder None uneinholbar werden
	if remaining_possible_votes < math.abs(modebattle.voting.mode1 - modebattle.voting.mode2) then
		messages.debug(-1, players.admins(), "MODEBATTLE", "blue<Abbruch: mode1 oder mode2 sind nicht mehr einholbar>")
		modebattle.check_winner()
		return
	end
	if remaining_possible_votes < math.abs(modebattle.voting.mode1 - modebattle.voting.none) then
		messages.debug(-1, players.admins(), "MODEBATTLE", "blue<Abbruch: mode1 oder none sind nicht mehr einholbar>")
		modebattle.check_winner()
		return
	end
	if remaining_possible_votes < math.abs(modebattle.voting.mode2 - modebattle.voting.none) then
		messages.debug(-1, players.admins(), "MODEBATTLE", "blue<Abbruch: mode2 oder none sind nicht mehr einholbar>")
		modebattle.check_winner()
		return
	end

	-- Intermission fortsetzen
	server.sleep(1000, function()
		modebattle.remaining_seconds = modebattle.remaining_seconds - 1
		modebattle.update()
	end)
end

function modebattle.push_time()
	if modebattle.remaining_seconds < 4 then
		modebattle.remaining_seconds = 4
	end
end

function modebattle.check_winner()
	if modebattle.voting.mode1 >= modebattle.voting.none or modebattle.voting.mode2 >= modebattle.voting.none then
		if modebattle.voting.mode1 > modebattle.voting.mode2 then
			-- winner: mode1
			messages.warning(-1, players.all(), "MODEBATTLE", "orange<WINNER:> "..modebattle.names.mode1)
			modebattle.reset()
			maprotation.next_map(modebattle.names.mode1)
		elseif modebattle.voting.mode1 < modebattle.voting.mode2 then
			-- winner: mode2
			messages.warning(-1, players.all(), "MODEBATTLE", "orange<WINNER:> "..modebattle.names.mode2)
			modebattle.reset()
			maprotation.next_map(modebattle.names.mode2)
		else
			-- tie
			modebattle.sudden_death = modebattle.sudden_death + 1
			modebattle.voting.all = 0
			if modebattle.sudden_death <= modebattle.max_sudden_death then
				-- sudden death starten/weiterführen
				messages.warning(-1, players.all(), "MODEBATTLE", "orange<SUDDEN DEATH!>  red<YOU CAN VOTE AGAIN NOW!  VOTE FAST!>")
				modebattle.reset_votes()
				-- messages.info(-1, players.all(), "MODEBATTLE", "remaining seconds old: " .. modebattle.remaining_seconds)
				-- messages.info(-1, players.all(), "MODEBATTLE", "delay_sudden_deaths for " .. server.playercount .. " players: " .. modebattle.delay_sudden_death[server.playercount])
				server.sleep(2000, function()
					modebattle.remaining_seconds = modebattle.delay_sudden_death[server.playercount]
					messages.debug(-1, players.admins(), "MODEBATTLE", "blue<remaining seconds new:> " .. modebattle.remaining_seconds)
					modebattle.update()
				end)
			else
				-- sudden death bringt kein neues ergebnis, abbruch
				messages.warning(-1, players.all(), "MODEBATTLE", "orange<TIE AFTER SUDDEN DEATH!>  green<Starting new normal voting phase now.>")
				modebattle.reset()
				maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			end
		end
	else
		if modebattle.voting.mode1 == 0 and modebattle.voting.mode2 == 0 then
			-- winner: 0:0
			modebattle.reset()
			maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			messages.warning(-1, players.all(), "MODEBATTLE", "orange<TIE>  0 : 0  ")
		else
			-- winner: none
			modebattle.reset()
			maprotation.intermission[tonumber(maprotation.intermission_mode)]()
			messages.warning(-1, players.all(), "MODEBATTLE", "orange<NO MODE WINS.>  red<Most players dont want playing these modes.>  green<Starting new normal voting phase now.>")
		end
	end
end

function modebattle.choose_mode1(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		if nl.getPlayer(cn, "modebattle") == 1 then
			messages.error(cn, {cn}, "MODEBATTLE", "red<You have already voted!>")
		else
			modebattle.voting.mode1 = modebattle.voting.mode1 + 1
			modebattle.voting.all = modebattle.voting.all + 1
			nl.updatePlayer(cn, "modebattle", 1, "set")
			modebattle.push_time()
			server.msg(string.format(orange("  [ MODEBATTLE ]  %s (#1)") .. " %i : %i " .. orange("%s (#2)") .. blue(" -- %s voted for %s"), modebattle.names.mode1, modebattle.voting.mode1, modebattle.voting.mode2, modebattle.names.mode2, server.player_displayname(cn), modebattle.names.mode1))
		end
	else
		messages.error(cn, {cn}, "MODEBATTLE", "red<Currently there is no MODE BATTLE!>")
	end
end

function modebattle.choose_mode2(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		if nl.getPlayer(cn, "modebattle") == 1 then
			messages.error(cn, {cn}, "MODEBATTLE", "red<You have already voted!>")
		else
			modebattle.voting.mode2 = modebattle.voting.mode2 + 1
			modebattle.voting.all = modebattle.voting.all + 1
			nl.updatePlayer(cn, "modebattle", 1, "set")
			modebattle.push_time()
			server.msg(string.format(orange("  [ MODEBATTLE ]  %s (#1)") .. " %i : %i " .. orange("%s (#2)") .. blue(" -- %s voted for %s"), modebattle.names.mode1, modebattle.voting.mode1, modebattle.voting.mode2, modebattle.names.mode2, server.player_displayname(cn), modebattle.names.mode2))
		end
	else
		messages.error(cn, {cn}, "MODEBATTLE", "red<Currently there is no MODE BATTLE!>")
	end
end

function modebattle.choose_none(cn)
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		if nl.getPlayer(cn, "modebattle") == 1 then
			messages.error(cn, {cn}, "MODEBATTLE", "red<You have already voted!>")
		else
			modebattle.voting.none = modebattle.voting.none + 1
			modebattle.voting.all = modebattle.voting.all + 1
			nl.updatePlayer(cn, "modebattle", 1, "set")
			modebattle.push_time()
			server.msg(string.format(orange("  [ MODEBATTLE ]  %s (#1)") .. red(" %i : %i ") .. orange("%s (#2)") .. blue(" -- %s wants neither of them (%s)"), modebattle.names.mode1, modebattle.voting.mode1, modebattle.voting.mode2, modebattle.names.mode2, server.player_displayname(cn), modebattle.voting.none))
		end
	else
		messages.error(cn, {cn}, "MODEBATTLE", "red<Currently there is no MODE BATTLE!>")
	end
end

function modebattle.choose_namedmode(cn, mode)
	if mode == modebattle.names.mode1 then
		modebattle.choose_mode1(cn)
	elseif mode == modebattle.names.mode2 then
		modebattle.choose_mode2(cn)
	end
end



-- 2. Prüfen und initieren von modebattles

function modebattle.reset()
	modebattle.reset_votes()
	maprotation.intermission_mode = modebattle.previous_intermission_mode
end

function modebattle.reset_votes()
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "modebattle", 0, "set")
	end
end

function modebattle.init(mode1playername, mode1name, mode2playername, mode2name)
	-- modus auf modebattle stellen
	if maprotation.intermission_mode ~= maprotation.intermission_modes.MODEBATTLE then
		modebattle.previous_intermission_mode = maprotation.intermission_mode
		maprotation.intermission_mode = maprotation.intermission_modes.MODEBATTLE
		modebattle.voting.mode1 = 0
		modebattle.voting.mode2 = 0
		modebattle.voting.none = 0
		modebattle.voting.all = 0
		modebattle.names.mode1 = mode1name
		modebattle.names.mode2 = mode2name
		modebattle.players.mode1 = mode1playername
		modebattle.players.mode2 = mode2playername
		modebattle.sudden_death = 0
		modebattle.reset_votes()
	end
end

function modebattle.force_init(cn, mode1, mode2)
	if maprotation.intermission_running == 0 and maprotation.intermission_mode ~= maprotation.intermission_modes.MODEBATTLE then
		if maprotation.is_valid_mode(mode1) then
			if maprotation.is_valid_mode(mode2) then
				modebattle.init(server.player_displayname(cn), mode1, server.player_displayname(cn), mode2)
				messages.info(cn, players.admins(), "MODEBATTLE", string.format("blue<%s> green<has initiated a new modebattle:> red<%s> vs. red<%s>", server.player_displayname(cn), mode1, mode2))
			else
				if mode2 ~= nil then
					messages.error(cn, {cn}, "MODEBATTLE", string.format("red<Mode> %s red<is not a valid mode!", mode2))
				else
					messages.error(cn, {cn}, "MODEBATTLE", string.format("red<No Mode selected!>"))
				end
			end
		else
			if mode1 ~= nil then
				messages.error(cn, {cn}, "MODEBATTLE", string.format("red<Mode> %s red<is not a valid mode!>", mode1))
			else
				messages.error(cn, {cn}, "MODEBATTLE", string.format("red<No mode selected>"))
			end
		end
 	else
		if maprotation.intermission_running == 1 then
 			messages.error(cn, {cn}, "MODEBATTLE", "red<Suggesting a mode battle is not possible during intermission!>")
		else
 			messages.error(cn, {cn}, "MODEBATTLE", string.format("red<There is already a mode battle:> %s blue<(%s)> vs. %s blue<(%s)>", modebattle.names.mode1, modebattle.players.mode1, modebattle.names.mode2, modebattle.players.mode2))
		end
	end
end

function modebattle.get_modebattle_info()
	if maprotation.intermission_running == 0 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		messages.info(cn, {cn}, "MODEBATTLE", string.format("red<The next modebattle is:> %s blue<(%s)> vs. %s blue<(%s)>", modebattle.names.mode1, modebattle.players.mode1, modebattle.names.mode2, modebattle.players.mode2))
	end
end

function modebattle.check_next_battle()
	-- hier wird geprüft, ob ein neues modebattle ansteht
	if maprotation.intermission_running == 0 and maprotation.intermission_mode ~= maprotation.intermission_modes.MODEBATTLE then
		-- sind zwei modes verfuegbar?
		if modebattle.suggestions >= 2 then
			local cns = {}
			local modes = {}
			for cn, mode in pairs(modebattle.suggested_modes) do
				table.insert(cns, cn)
				table.insert(modes, mode)
			end
			local n1 = math.random(#cns)
			local n2 = math.random(#cns)
			while n1 == n2 do
				n2 = math.random(#cns)
			end
			modebattle.init(server.player_displayname(cns[n1]), modes[n1], server.player_displayname(cns[n2]), modes[n2])
			modebattle.suggested_modes[cns[n1]] = nil
			modebattle.suggested_modes[cns[n2]] = nil
			modebattle.suggestions = modebattle.suggestions - 2
			nl.updatePlayer(cns[n1], "suggestmode", 0, "set")
			nl.updatePlayer(cns[n2], "suggestmode", 0, "set")
			messages.info(-1, players.admins(), "MODEBATTLE", string.format("green<There is a new modebattle:> %s blue<(%s)> vs. %s blue<(%s)>", modes[n1], server.player_displayname(cns[n1]), modes[n2], server.player_displayname(cns[n2]) ))
			messages.info(-1, { cns[n1], cns[n2] }, "MODEBATTLE", string.format("green<You have initiated a new modebattle:> %s blue<(%s)> vs. %s blue<(%s)>", modes[n1], server.player_displayname(cns[n1]), modes[n2], server.player_displayname(cns[n2]) ))
		end
 	end
end



-- 3. Vorschlagen von Modes für ein modebattle

function modebattle.suggest_mode(cn, mode)
	if maprotation.is_valid_mode(mode) then
		if modebattle.has_already_suggested(mode) then
			messages.error(cn, {cn}, "MODEBATTLE", string.format("red<Sorry, someone has already suggested mode> %s red<for a modebattle.> Please try another mode.", mode))
		else
			if modebattle.has_recently_played(mode) then
				messages.error(cn, {cn}, "MODEBATTLE", string.format("red<Sorry, %s has been recently played>. Please try another mode.", mode))
			else
				if nl.getPlayer(cn, "suggestmode") == 0 then
					messages.info(cn, {cn}, "MODEBATTLE", string.format("green<Your mode vote> %s green<was accepted for a modebattle.>", mode))
					modebattle.suggested_modes[cn] = mode
					modebattle.suggestions = modebattle.suggestions + 1
					nl.updatePlayer(cn, "suggestmode", 1, "set")
					modebattle.check_next_battle()
				else
					messages.error(cn, {cn}, "MODEBATTLE", "red<You have already suggested a mode for a modebattle!>")
				end
			end
		end
	else
		messages.error(cn, {cn}, "MODEBATTLE", string.format("red<You cannot choose mode> %s red<on this server!>", mode))
	end
end

function modebattle.remove_suggestion(cn)
	if nl.getPlayer(cn, "suggestmode") == 1 then
		modebattle.suggested_modes[cn] = nil
		modebattle.suggestions = modebattle.suggestions - 1
		nl.updatePlayer(cn, "suggestmode", 0, "set")
	end
end

function modebattle.has_already_suggested(reqmode)
	for cn, mode in pairs(modebattle.suggested_modes) do
		if reqmode == mode then
			return true
		end
	end
	return false
end

function modebattle.has_recently_played(reqmode)
	for i,mode in ipairs(modebattle.lastmodes) do
		if reqmode == mode then
			return true
		end
	end
	return false
end

function modebattle.is_modebattle_phase()
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		return true
	else
		return false
	end
end


--[[
		COMMANDS
]]

function server.playercmd_modebattle(cn, mode1, mode2)
	if mode1 ~= nil and mode2 ~= nil then
		if not hasaccess(cn, modebattle_access) then return end
		modebattle.force_init(cn, mode1, mode2)
	else
		if mode1 ~= nil then
			if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
		 		-- Es wird derzeit ein modebattle durchgeführt
 				if mode1 == modebattle.names.mode1 then
		 			modebattle.choose_mode1(cn)
 				elseif mode1 == modebattle.names.mode2 then
		 			modebattle.choose_mode2(cn)
 				else
					messages.error(cn, {cn}, "MODEBATTLE", string.format("red<You cannot vote for> %s red<because it is not valid in this modebattle.>", mode1))
 				end
		 	else
				if mode1 ~= maprotation.game_mode and maprotation.intermission_running == 0 then
					modebattle.suggest_mode(cn, mode1)
				end
			end
		else
			modebattle.get_modebattle_info()
		end
	end
end

function server.playercmd_mode1(cn)
	modebattle.choose_mode1(cn)
end
-- server.playercmd_1 = server.playercmd_mode1

function server.playercmd_mode2(cn)
	modebattle.choose_mode2(cn)
end
-- server.playercmd_mode2 = server.playercmd_2

--[[
function server.playercmd_none(cn)
	modebattle.choose_none(cn)
end
server.playercmd_0 = server.playercmd_none
server.playercmd_3 = server.playercmd_none
server.playercmd_4 = server.playercmd_none
server.playercmd_5 = server.playercmd_none
server.playercmd_6 = server.playercmd_none
server.playercmd_7 = server.playercmd_none
server.playercmd_8 = server.playercmd_none
server.playercmd_9 = server.playercmd_none
]]


--[[
		EVENTS
]]

--[[ server.event_handler("mapvote", function (cn, map, mode)
 	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.MODEBATTLE then
 		-- Es wird derzeit ein modebattle durchgeführt
 		if mode == modebattle.names.mode1 then
 			modebattle.choose_mode1(cn)
 		elseif mode == modebattle.names.mode2 then
 			modebattle.choose_mode2(cn)
 		else
			messages.error(cn, {cn}, "MODEBATTLE", string.format("red<You cannot vote for> %s red<because it is not valid in this modebattle.>", mode))
 		end
 	else
		if mode ~= maprotation.game_mode and maprotation.intermission_running == 0 then
			modebattle.suggest_mode(cn, mode)
		end
	end
end)
]]

server.event_handler("disconnect", function (cn)
	modebattle.remove_suggestion(cn)
end)

server.event_handler("mapchange", function(map, mode)
	if modebattle.lastmodes[2] ~= nil then modebattle.lastmodes[3] = modebattle.lastmodes[2] end
	if modebattle.lastmodes[1] ~= nil then modebattle.lastmodes[2] = modebattle.lastmodes[1] end
	modebattle.lastmodes[1] = mode
end)

server.interval(2000, function()
	modebattle.check_next_battle()
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep((maprotation.intermission_startdelay+maprotation.intermission_predelay)*1200, function()
		--[[
				EXTRACTCOMMAND RULES
		]]
		extractcommand.register("1", false, modebattle.choose_mode1, modebattle.is_modebattle_phase, false)
		extractcommand.register("2", false, modebattle.choose_mode2, modebattle.is_modebattle_phase, false)
		extractcommand.register("0", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("3", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("4", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("5", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("6", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("7", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("8", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("9", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("mode1", false, modebattle.choose_mode1, modebattle.is_modebattle_phase, false)
		extractcommand.register("mode2", false, modebattle.choose_mode2, modebattle.is_modebattle_phase, false)
		extractcommand.register("none", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
		extractcommand.register("n", false, modebattle.choose_none, modebattle.is_modebattle_phase, false)
	end)
end)





