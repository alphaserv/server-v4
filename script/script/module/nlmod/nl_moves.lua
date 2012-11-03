--[[
	script/module/nl_mod/nl_moves.lua
	Author:			Hanack (Andreas Schaeffer)
	Created:		24-Jun-2011
	Last Modified:	12-Mai-2012
	License:		GPL3

	Funktionen:
		Erkennen von Moves und Events ausloesen.

	Commands:
		#move record <name> <timeout_ms>
		#move checkpoint
		#move setminz
		#move finish

	API-Methoden:
		cheater.xyz()
			xyz

	Konfigurations-Variablen:
		cheater.xyz
			xyz

	Datenbank:

		nl_moves
			moveid int autoincrement				-- ID des Moves
			map varchar(255)						-- Name der Map
			name varchar(255)						-- Name des Moves
			min_z int								-- Minimale Z-Koordinate des Moves
			timeout int								-- Maximale Zeit in Millisekunden

		nl_move_checkpoints
			moveid int
			no int									-- Der x.te Checkpoint 
			x int
			y int
			z int
			

]]



--[[
		API
]]

moves = {}
moves.moves = {}
moves.signals = {}
moves.recording = 0
moves.visualisation = 1
moves.new_record = {}
moves.interval = 100 -- 50
moves.tolerance = 12
moves.signals = {}
moves.nextcheckpoint = {}
moves.signals.entercheckpoint = server.create_event_signal("entercheckpoint")
moves.signals.movesucessful = server.create_event_signal("move")
moves.signals.movefailed = server.create_event_signal("movefailed")
moves.points_x = 0
moves.points_y = 0
moves.points_z = 20
moves.slots = {}

function moves.reset_checkpoints(cn)
	moves.nextcheckpoint[cn] = {}
	for i,move in ipairs(moves.moves) do
		moves.nextcheckpoint[cn][move["moveid"]] = 1
	end
end

function moves.load(map)
	-- alle moves fuer diese map aus der db lesen
	moves.moves = db.select("nl_moves", { "moveid", "name", "min_z", "timeout" }, string.format("map='%s'", map) )
	for i,move in ipairs(moves.moves) do
		move.checkpoints = db.select("nl_move_checkpoints", { "moveid", "no", "x", "y", "z" }, string.format("moveid=%i", move["moveid"]), "no asc" )
	end
	messages.debug(cn, players.admins(), "MOVES", string.format("orange<loaded %i moves for map %s>", #moves.moves, map))
	for i,cn in ipairs(players.all()) do
		moves.reset_checkpoints(cn)
	end
	-- messages.debug(cn, players.admins(), "MOVES", "reseted all player checkpoints")
end

-- checkpoint ents entfernen
function moves.clear_points()
	for i,slot in ipairs(moves.slots) do
		entities.free(slot)
	end
	moves.slots = {}
end

-- checkpoint ents senden
function moves.send_points()
	if moves.visualisation ~= 1 then return end
	for i,move in ipairs(moves.moves) do
		for j,rsp in ipairs(move.checkpoints) do
			local slot = entities.register()
			entities.set(
				slot,
				entities.types['respawnpoint'],
				move.checkpoints[j]["x"],
				move.checkpoints[j]["y"],
				move.checkpoints[j]["z"],
				0, 0, 0, 0, 0
			)
			table.insert(respawn.slots, slot)
		end
	end
end


function moves.list_moves(cn, map)
	local _moves = db.select("nl_moves", { "moveid", "name", "min_z", "timeout" }, string.format("map='%s'", map) )
	messages.info(cn, {cn}, "MOVES", string.format("There are yellow<%i moves> at orange<%s>:", #_moves, map))
	for i,move in ipairs(_moves) do
		messages.info(cn, {cn}, "MOVES", string.format(" Move %i: orange<%s> (timeout: %i ms)", i, move["name"], move["timeout"]))
	end
end

function moves.check_first_checkpoints()
	-- prüfen, ob jemand in den ersten checkpoint laeuft, wenn ja: event ausloesen 
	-- TODO: wenn jemand ueber den ersten checkpoint laeuft waehrend er den gleichen move macht, faengt er wieder von vorn an?
	if server.paused ~= 1 and server.timeleft > 0 then
		for i,cn in ipairs(players.all()) do
			if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				local x, y, z = server.player_pos(cn)
				for j,move in ipairs(moves.moves) do
					if
						moves.nextcheckpoint[cn][move["moveid"]] == 1 and
						x < move.checkpoints[1]["x"] + moves.tolerance and
						x > move.checkpoints[1]["x"] - moves.tolerance and
						y < move.checkpoints[1]["y"] + moves.tolerance and
						y > move.checkpoints[1]["y"] - moves.tolerance and
						z < move.checkpoints[1]["z"] + moves.tolerance and
						z > move.checkpoints[1]["z"] - moves.tolerance
					then
						moves.signals.entercheckpoint(cn, move, 1, tonumber(move['timeout']))
					end
				end
			end
		end
	end
end

function moves.check_checkpoint(cn, move, checkpoint_no, timeleft)
	if checkpoint_no > #move.checkpoints then
		moves.signals.movesucessful(cn, move, timeleft)
	else
		local x, y, z = server.player_pos(cn)
		if
			x < move.checkpoints[checkpoint_no]["x"] + moves.tolerance and
			x > move.checkpoints[checkpoint_no]["x"] - moves.tolerance and
			y < move.checkpoints[checkpoint_no]["y"] + moves.tolerance and
			y > move.checkpoints[checkpoint_no]["y"] - moves.tolerance and
			z < move.checkpoints[checkpoint_no]["z"] + moves.tolerance and
			z > move.checkpoints[checkpoint_no]["z"] - moves.tolerance
		then
			moves.signals.entercheckpoint(cn, move, checkpoint_no, timeleft)
		else
			if
				z >= tonumber(move["min_z"]) and
				timeleft >= moves.interval and
				server.player_status_code(cn) == server.ALIVE and
				server.player_status(cn) ~= "spectator"
			then
				server.sleep(moves.interval, function()
					moves.check_checkpoint(cn, move, checkpoint_no, timeleft - moves.interval)
				end)
			else
				--[[
				if timeleft < moves.interval then
					messages.debug(cn, {cn}, "MOVES", "move failed: timeout "..timeleft.."<"..moves.interval)
				elseif z < tonumber(move["min_z"]) then
					messages.debug(cn, {cn}, "MOVES", "move failed: min_z "..z.."<"..tonumber(move["min_z"]))
				elseif server.player_status_code(cn) == server.ALIVE then
					messages.debug(cn, {cn}, "MOVES", "move failed: death")
				elseif server.player_status(cn) ~= "spectator" then
					messages.debug(cn, {cn}, "MOVES", "move failed: spectator")
				end
				]]
				moves.signals.movefailed(cn, move, checkpoint_no, timeleft)
			end
		end
	end
end


function moves.getpos(cn)
	local x, y, z = server.player_pos(cn)
	messages.info(cn, {cn}, "MOVES", string.format("your pos: x=%i y=%i z=%i", x, y, z))
	for i,move in ipairs(moves.moves) do
		for j,checkpoint in ipairs(move.checkpoints) do
			if
				x < checkpoint["x"] + moves.tolerance and
				x > checkpoint["x"] - moves.tolerance and
				y < checkpoint["y"] + moves.tolerance and
				y > checkpoint["y"] - moves.tolerance and
				z < checkpoint["z"] + moves.tolerance and
				z > checkpoint["z"] - moves.tolerance
			then
				messages.info(cn, {cn}, "MOVES", string.format(" hits checkpoint red<%i> of orange<%s>: x=%i y=%i z=%i", checkpoint["no"], move["name"], checkpoint["x"], checkpoint["y"], checkpoint["z"]))
			end
		end
	end
end


function moves.record_start(cn, name, timeout)
	moves.recording = 1
	moves.new_record[cn] = {}
	moves.new_record[cn]["map"] = maprotation.map
	moves.new_record[cn]["name"] = name
	moves.new_record[cn]["timeout"] = timeout
	moves.new_record[cn]["min_z"] = -10000
	moves.new_record[cn]["checkpointsno"] = 0
	moves.new_record[cn]["checkpoints"] = {}
	cheater.start_recording("moves")
	messages.info(cn, players.all(), "MOVES", string.format("%s starts recording of a new move", server.player_displayname(cn)))
	moves.send_points()
end

function moves.record_addcheckpoint(cn)
	if moves.new_record[cn] == nil then moves.new_record[cn] = {} end
	moves.new_record[cn]["checkpointsno"] = moves.new_record[cn]["checkpointsno"] + 1
	local x, y, z = server.player_pos(cn)
	local checkpoint = {}
	checkpoint["no"] = moves.new_record[cn]["checkpointsno"]
	checkpoint["x"] = x
	checkpoint["y"] = y
	checkpoint["z"] = z
	table.insert(moves.new_record[cn]["checkpoints"], checkpoint)
	messages.info(cn, players.all(), "MOVES", string.format("%s added checkpoint (%i, %i, %i)", server.player_displayname(cn), x, y, z))
	moves.send_points()
end

function moves.record_setminz(cn, arg1)
	if arg1 ~= nil then
		local z = tonumber(arg1)
		if moves.new_record[cn] == nil then moves.new_record[cn] = {} end
		moves.new_record[cn]["min_z"] = z
		messages.info(cn, players.admins(), "MOVES", string.format("%s set min z to %i", server.player_displayname(cn), z))
	else
		local x, y, z = server.player_pos(cn)
		moves.new_record[cn]["min_z"] = z
		messages.info(cn, players.admins(), "MOVES", string.format("%s set min z to %i", server.player_displayname(cn), z))
	end
end

function moves.record_settimeout(cn, timeout)
	moves.new_record[cn]["timeout"] = timeout
	messages.info(cn, players.admins(), "MOVES", string.format("%s set timeout to %i", server.player_displayname(cn), timeout))
end

function moves.record_setname(cn, name)
	moves.new_record[cn]["name"] = name
	messages.info(cn, players.admins(), "MOVES", string.format("%s set name to %i", server.player_displayname(cn), name))
end

function moves.record_save(cn)
	db.insert("nl_moves", { name=moves.new_record[cn]["name"], map=moves.new_record[cn]["map"], timeout=moves.new_record[cn]["timeout"], min_z=moves.new_record[cn]["min_z"] } )
	local result = db.select("nl_moves", { "moveid" }, "moveid > 0", "moveid desc")
	if result == nil or #result == 0 then
		-- oh oh nicht gespeichert
	else
		local moveid = result[1]["moveid"]
		for i,checkpoint in ipairs(moves.new_record[cn]["checkpoints"]) do
			db.insert("nl_move_checkpoints", { moveid=moveid, no=checkpoint["no"], x=checkpoint["x"], y=checkpoint["y"], z=checkpoint["z"] } )
		end
		messages.info(cn, players.all(), "MOVES", string.format("%s saved new move %s", server.player_displayname(cn), moves.new_record[cn]["name"]))
		moves.recording = 0
		moves.clear_points()
		cheater.stop_recording("moves")
		moves.load(maprotation.map)
	end
end

function moves.record_cancel(cn)
	messages.info(cn, {cn}, "MOVES", "canceled move recording")
	moves.recording = 0
	moves.clear_points()
	cheater.stop_recording("moves")
	moves.new_record[cn] = {}
end



--[[
		COMMANDS
]]

function server.playercmd_move(cn, command, arg1, arg2)
	if command ~= nil then
		if command == "list" then
			if arg1 ~= nil then
				moves.list_moves(cn, arg1)
			else
				moves.list_moves(cn, maprotation.map)
			end
		elseif command == "record" or command == "recording" then
			if not hasaccess(cn, admin_access) then return end
			if arg1 ~= nil and arg2 ~= nil then
				moves.record_start(cn, arg1, arg2)
			else
				-- argumente fehlen
			end
		elseif command == "checkpoint" or command == "addcheckpoint" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_addcheckpoint(cn)
		elseif command == "setminz" or command == "minz" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_setminz(cn, arg1)
		elseif command == "settimeout" or command == "timeout" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_settimeout(cn, tonumber(arg1))
		elseif command == "setname" or command == "name" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_setname(cn, arg1)
		elseif command == "save" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_save(cn)
		elseif command == "cancel" then
			if not hasaccess(cn, admin_access) then return end
			moves.record_cancel(cn)
		elseif command == "pos" then
			if not hasaccess(cn, admin_access) then return end
			moves.getpos(cn)
		elseif command == "reload" then
			if not hasaccess(cn, admin_access) then return end
			cheater.stop_recording("moves")
			moves.clear_points()
			moves.load(maprotation.map)
		elseif command == "show" then
			moves.send_points()
		elseif command == "hide" then
			moves.clear_points()
		elseif command == "interval" then
			if not hasaccess(cn, admin_access) then return end
			if arg1 ~= nil then
				moves.interval = tonumber(arg1)
			end
			messages.info(cn, {cn}, "MOVES", string.format("moves.interval=%i",moves.interval))
		elseif command == "help" then
			messages.info(cn, {cn}, "MOVES", "#move list pos record checkpoint setminz settimeout setname save cancel reload interval")
		end
	else
		moves.list_moves(cn, maprotation.map)
	end
end
server.playercmd_moves = server.playercmd_move



--[[
		EVENTS
]]

server.event_handler("move", function(cn, move, timeleft)
	moves.nextcheckpoint[cn][move["moveid"]] = 1
	local tookmillis = tonumber(move["timeout"])-timeleft
	messages.warning(cn, players.all(), "MOVES", string.format("%s did the %s (in %i ms)", server.player_displayname(cn), move["name"], tookmillis))
end)

server.event_handler("movefailed", function(cn, move, checkpoint_no, timeleft)
	moves.nextcheckpoint[cn][move["moveid"]] = 1
	messages.debug(cn, players.admins(), "MOVES", string.format("%s failed at checkpoint no.%i of %s (%i time left)", server.player_displayname(cn), checkpoint_no, move["name"], timeleft))
end)

server.event_handler("entercheckpoint", function(cn, move, checkpoint_no, timeleft)
	messages.debug(cn, players.admins(), "MOVES", string.format("%s entered checkpoint no.%i of %s (%i time left)", server.player_displayname(cn), checkpoint_no, move["name"], timeleft))
	moves.nextcheckpoint[cn][move["moveid"]] = checkpoint_no+1
	moves.check_checkpoint(cn, move, checkpoint_no+1, timeleft)
end)

server.event_handler("spawn", function(cn)
	moves.reset_checkpoints(cn)
end)

server.event_handler("connect", function(cn)
	moves.reset_checkpoints(cn)
end)

server.event_handler("mapchange", function(map, mode)
	moves.load(map)
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	server.sleep(20000, function()
		moves.load(maprotation.map)
	end)
end)

server.interval(moves.interval, moves.check_first_checkpoints)
