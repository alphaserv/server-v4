--[[
	script/module/nl_mod/nl_veto.lua
	Hanack (Andreas Schaeffer)
	11-Sep-2010
	License: GPL3

	Funktionen:
		Ein neuer Intermission Mode, der es erlaubt, dass die nächste Map von den Spieler
		abgewählt werden kann.

	Commands:
		#veto
			Ein Veto gegen die nächste Map abgeben
		#noveto
			Eine Stimme für die nächste Map abgeben

]]



--[[
		API
]]

veto = {}
veto.map = ""
veto.mode = ""
veto.vetos = 0
veto.novetos = 0
veto.rounds = 0
veto.max_rounds = 3
veto.total_vetos = 0
veto.passed = 0
veto.remaining_seconds = 0
--    playercount       1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
veto.needed_vetos  = {  1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 10,10,10,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,12,13,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,16,16,16,16,17,17 }
veto.delay_players = { 10,10,10,11,11,11,12,12,13,13,14,15,16,17,18,19,20,20,21,21,22,22,22,23,23,23,23,24,24,24,24,24,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,30,30 }


maprotation.intermission_modes.VETO = 3
maprotation.intermission[maprotation.intermission_modes.VETO] = function()
	--[[
		intermission mode 3: veto
		Es wird eine VetoPhase initiiert
	]]
	veto.rounds = 0
	veto.new_veto_phase()
	veto.update()
end

maprotation.intermission_break[maprotation.intermission_modes.VETO] = function()
	--[[
		break intermission veto
	]]
	veto.rounds = 0
	veto.vetos = 0
	veto.novetos = 0
	veto.passed = 1
end

function veto.new_veto_phase()
	veto.rounds = veto.rounds + 1
	veto.mode = maprotation.get_next_mode()
	veto.map = maprotation.pull_map(veto.mode)
	veto.vetos = 0
	veto.novetos = 0
	veto.passed = 0
	veto.remaining_seconds = veto.delay_players[server.playercount]
	veto.total_vetos = 0
	local result = db.select("nl_veto", { "count(*) as anzahl" }, string.format("map='%s' AND mode='%s' GROUP BY map", veto.map, veto.mode))
	if result[1] ~= nil then
		if result[1]['anzahl'] ~= nil then
			veto.total_vetos = result['anzahl']
		end
	end
	-- reset player vetos and novetos
	for _,cn in pairs(players.all()) do
		nl.updatePlayer(cn, "veto", 0, "set")
		nl.updatePlayer(cn, "noveto", 0, "set")
	end
	-- output
	if veto.rounds == 1 then
		local needed_vetos = veto.get_needed_vetos() or 99
		local total_vetos = veto.total_vetos or 0
		messages.info(-1, players.all(), "VETO", " " )
		messages.info(-1, players.all(), "VETO", string.format(" Next map is "..white("%s on %s")..". You need "..white("%i vetos").." to skip %s (all time: %i vetos)", veto.map, veto.mode, needed_vetos, veto.map, total_vetos))
		messages.info(-1, players.all(), "VETO", orange("   Commands are: #veto #noveto") )
	else
		server.sleep(1000, function()
			local needed_vetos = veto.get_needed_vetos() or 99
			local total_vetos = veto.total_vetos or 0
			messages.info(-1, players.all(), "VETO", string.format(" Next map is "..white("%s on %s")..". You need "..white("%i vetos").." to skip %s (all time: %i vetos)", veto.map, veto.mode, needed_vetos, veto.map, total_vetos))
			messages.info(-1, players.all(), "VETO", red("   YOU CAN VOTE AGAIN NOW!")..orange(" Commands are: #veto #noveto") )
		end)
	end
end

function veto.update()
	-- Intermission abbrechen oder fortsetzen?

	-- Intermission abbrechen, wenn eine map gewaehlt wurde
	if veto.passed == 1 then
		return
	end

	-- Map pass, wenn Zeit abgelaufen ist
	if veto.remaining_seconds <= 0 then
		veto.pass()
		return
	end

	-- Map pass, sobald es nicht mehr moeglich ist, die benoetigten Vetos zu erreichen
	local vetos_count = veto.vetos + veto.novetos
	local remaining_possible_votes = server.playercount - vetos_count
	if remaining_possible_votes < veto.get_needed_vetos() - veto.vetos then
		veto.pass()
		return
	end

	veto.check()

	-- Intermission fortsetzen
	server.sleep(1000, function()
		veto.remaining_seconds = veto.remaining_seconds - 1
		veto.update()
	end)
end

function veto.push_time()
	if veto.remaining_seconds < 4 then
		veto.remaining_seconds = 4
	end
end

function veto.check()
	if veto.vetos >= veto.get_needed_vetos() and veto.passed == 0 then
		veto.next_map()
		return true
	end
	return false
end

function veto.pass()
	-- block new vetos
	veto.passed = 1
	-- output
	messages.info(-1, players.all(), "VETO", " ")
	messages.info(-1, players.all(), "VETO", string.format("   "..white("%s was accepted. ").."There were only "..white("%i/%i vetos").." (%i novetos).", veto.map, veto.vetos, veto.get_needed_vetos(), veto.novetos))
	messages.info(-1, players.all(), "VETO", "Remember: you still can use "..orange("#mapsucks").." to lower the gametime!")
	-- transfer vetos and novetos to mapsucks and maploves
	mapsucks.game.sucks = 0
	mapsucks.game.loves = 0
	for _,cn in pairs(players.all()) do
		if nl.getPlayer(cn, "veto") == 1 then
			nl.updatePlayer(cn, "mapsucks", 1, "set")
			nl.updatePlayer(cn, "lovemap", 0, "set")
			mapsucks.game.sucks = mapsucks.game.sucks + 1
		end
		if nl.getPlayer(cn, "noveto") == 1 then
			nl.updatePlayer(cn, "mapsucks", 0, "set")
			nl.updatePlayer(cn, "lovemap", 1, "set")
			mapsucks.game.loves = mapsucks.game.loves + 1
		end
	end
	-- change map
	maprotation.change_map(veto.map, veto.mode)
end

function veto.next_map()
	if veto.rounds < veto.max_rounds then
		messages.error(-1, players.all(), "VETO", string.format("   "..white("%s").." didn't pass veto phase: %i/%i vetos (%i novetos).", veto.map, veto.vetos, veto.get_needed_vetos(), veto.novetos))
		veto.new_veto_phase()
	else
		local forced_mode = maprotation.get_next_mode()
		messages.warning(-1, players.all(), "VETO", string.format("   After "..white("%i").." maps were deselected, the server choose the next map "..white("%s on %s").." regularly", veto.max_rounds, maprotation.get_next_map(forced_mode), forced_mode))
		-- block new vetos
		veto.passed = 1
		maprotation.next_map(forced_mode)
	end
end

function veto.veto(cn)
	if maprotation.intermission_running == 0 then
		mapsucks.sucks(cn)
	else
		if veto.passed == 1 then
			if nl.getPlayer(cn, "veto") == 0 then
				if maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
					mapbattle.choose_none(cn)
				else
					messages.error(-1, {cn}, "VETO", string.format("Too late..."..white(" but your veto is counted as ")..orange("#mapsucks")..white(" instead!")))
					nl.updatePlayer(cn, "veto", 1, "set")
					mapsucks.sucks(cn, 1)
				end
				return
			else
				messages.error(-1, {cn}, "VETO", "Too late for changing your mind...")
				return
			end
		end
		if nl.getPlayer(cn, "veto") == 0 then
			-- veto abgeben
			veto.vetos = veto.vetos + 1
			nl.updatePlayer(cn, "veto", 1, "set")
			db.insert("nl_veto", { player=server.player_name(cn), map=veto.map, mode=veto.mode })
			if nl.getPlayer(cn, "noveto") == 0 then
				veto.push_time() -- push time nur fuer leute, die ihre meinung nicht staendig aendern :-)
				if not veto.check() then
					messages.info(-1, players.all(), "VETO", string.format(red("%i")..white("/%i vetos").." against  "..white("%s")..blue("  -- new veto by %s").."  --> Say "..orange("#veto").." if you don't like playing map "..white("%s"), veto.vetos, veto.get_needed_vetos(), veto.map, server.player_displayname(cn), veto.map))
				end
			else
				if nl.getPlayer(cn, "vchangemind") == 0 then
					nl.updatePlayer(cn, "vchangemind", 1, "set")
					messages.info(-1, players.all(), "VETO", string.format(red("%i")..white("/%i vetos").." against  "..white("%s").."  -- "..blue("%s").." changed his/her mind and don't like playing map "..white("%s"), veto.vetos, veto.get_needed_vetos(), veto.map, server.player_displayname(cn), veto.map))
					server.sleep(2500, function()
						veto.novetos = veto.novetos - 1
						nl.updatePlayer(cn, "noveto", 0, "set")
						nl.updatePlayer(cn, "vchangemind", 0, "set")
						veto.check()
					end)
				else
					messages.error(-1, {cn}, "VETO", "You are changing your mind really fast :-) Blocking your votes for 4 seconds now.")
				end
			end
		else
			messages.error(-1, {cn}, "VETO", string.format("You have already voted! Got "..white("%i/%i vetos").." against  "..white("%s"), veto.vetos, veto.get_needed_vetos(), veto.map))
		end
	end
end

function veto.noveto(cn)
	if maprotation.intermission_running == 0 then
		mapsucks.loves(cn)
	else
		if veto.passed == 1 then
			if nl.getPlayer(cn, "noveto") == 0 then
				if maprotation.intermission_mode == maprotation.intermission_modes.MAPBATTLE then
					mapbattle.choose_none(cn)
				else
					messages.error(-1, {cn}, "VETO", string.format("Too late..."..white(" but your veto is counted as ")..orange("#lovemap")..white(" instead!")))
					nl.updatePlayer(cn, "noveto", 1, "set")
					mapsucks.loves(cn, 1)
				end
				return
			else
				messages.error(-1, {cn}, "VETO", "Too late for changing your mind...")
				return
			end
		end
		if nl.getPlayer(cn, "noveto") == 0 then
			-- noveto abgeben
			veto.novetos = veto.novetos + 1
			nl.updatePlayer(cn, "noveto", 1, "set")
			if nl.getPlayer(cn, "veto") == 0 then
				veto.push_time() -- push time nur fuer leute, die ihre meinung nicht staendig aendern :-)
				messages.info(-1, players.all(), "VETO", string.format(white("%i/")..red("%i")..white(" vetos").." against  "..white("%s")..blue("  -- %s likes this map!"), veto.vetos, veto.get_needed_vetos(), veto.map, server.player_displayname(cn)))
			else
				if nl.getPlayer(cn, "vchangemind") == 0 then
					nl.updatePlayer(cn, "vchangemind", 1, "set")
					messages.info(-1, players.all(), "VETO", string.format(white("%i/")..red("%i")..white(" vetos").." against  "..white("%s")..blue("  -- %s changed his/her mind and likes this map now!"), veto.vetos, veto.get_needed_vetos(), veto.map, server.player_displayname(cn)))
					server.sleep(2500, function()
						veto.vetos = veto.vetos - 1
						nl.updatePlayer(cn, "veto", 0, "set")
						nl.updatePlayer(cn, "vchangemind", 0, "set")
						veto.check()
					end)
				else
					messages.error(-1, {cn}, "VETO", "You are changing your mind really fast :-) Blocking your votes for 4 seconds now.")
				end
			end
		else
			messages.error(-1, {cn}, "VETO", string.format("You have already voted! Got "..white("%i/%i vetos").." against  "..white("%s"), veto.vetos, veto.get_needed_vetos(), veto.map))		
		end
	end
end

function veto.get_needed_vetos()
	if veto.novetos == nil or server.playercount == nil or veto.needed_vetos[server.playercount] == nil then return 99 end
	return veto.novetos + veto.needed_vetos[server.playercount]
end

function veto.is_veto_phase()
	if maprotation.intermission_running == 1 and maprotation.intermission_mode == maprotation.intermission_modes.VETO then
		return true
	else
		return false
	end
end



--[[
		COMMANDS
]]

function server.playercmd_veto(cn)
	veto.veto(cn)
end

function server.playercmd_noveto(cn)
	veto.noveto(cn)
end



--[[
		EVENTS
]]

server.event_handler("disconnect", function (cn)
	if nl.getPlayer(cn, "veto") == 1 then
		veto.vetos = veto.vetos - 1
		nl.updatePlayer(cn, "veto", 0, "set")
	end
	if nl.getPlayer(cn, "noveto") == 1 then
		veto.novetos = veto.novetos - 1
		nl.updatePlayer(cn, "noveto", 0, "set")
	end
end)

server.event_handler("mapvote", function (cn, map, mode)
	if veto.is_veto_phase() then
 		-- Es ist derzeit ein Vetoing am Start...
 		if map == veto.map then
 			veto.noveto(cn)
 		else
 			veto.veto(cn)
 			if map ~= maprotation.map then
				messages.warning(cn, {cn}, "VETO", string.format("Your map battle suggestion ("..white("%s").. ") is a concurrently a veto for "..white("%s"), map, veto.map))
				mapbattle.suggest_map(cn, map)
			end
 		end
	end
end)



--[[
		EXTRACTCOMMAND RULES
]]

extractcommand.register("veto", false, veto.veto)
extractcommand.register("v e t o", false, veto.veto)
extractcommand.register("o", false, veto.veto, veto.is_veto_phase)
extractcommand.register("mapsucks", false, veto.veto)
extractcommand.register("noveto", false, veto.noveto)
extractcommand.register("no veto", true, veto.noveto)
extractcommand.register("notveto", false, veto.noveto)
extractcommand.register("like map", true, veto.noveto)
extractcommand.register("like this map", true, veto.noveto)
extractcommand.register("greatmap", false, veto.noveto)
extractcommand.register("great map", true, veto.noveto)
extractcommand.register("maprules", true, veto.noveto)
extractcommand.register("maprulez", true, veto.noveto)
extractcommand.register("map rules", true, veto.noveto)
extractcommand.register("map rulez", true, veto.noveto)
