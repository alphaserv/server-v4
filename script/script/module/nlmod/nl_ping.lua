--[[
	script/module/nl_mod/nl_ping.lua
	Author:			Hanack (Andreas Schaeffer)
	Created:		27-Sep-2010
	Last Modified:	17-Jun-2012
	License:		GPL3

	Funktionen:
		* Überprüft den Ping jedes Spielers
		* Wenn der Ping über eine bestimmte Grenze kommt, werden Maluspunkte vergeben
		* Wenn der Ping unter eine bestimmte Grenze kommt, werden Maluspunkte verringert
		* Wenn er genügend Maluspunkte angesammelt hat, wird er gespeced
		* Wenn er einen konstant guten Ping hat, wird er wieder unspeced
	

	API-Methoden:
		ping.check_malus()
			Prueft die Maluspunkte aller Spieler
		ping.check_ping()
			Prueft den Ping aller Spieler
		ping.check_pj()
			Prueft den PJ aller Spieler

	Konfigurations-Variablen:

	Laufzeit-Variablen:


]]



--[[
		API
]]

ping = {}
ping.module_name = "PING"
ping.enabled = 1
ping.ping_interval = 750
ping.pj_interval = 100
ping.lastposupdate_interval = 100
ping.malus_interval = 100
ping.recording_interval = 5000
ping.check_delay_after_spawn = 5000
ping.check_delay_after_mapchange = 25000
ping.check_delay_after_connect = 25000
ping.median_ping = {}
ping.median_ping.level = {}
ping.median_ping.level[1] = {}
ping.median_ping.level[1].max_ping = 300
ping.median_ping.level[1].dyn_ping = 250
ping.median_ping.level[1].add_malus = 1
ping.median_ping.level[2] = {}
ping.median_ping.level[2].max_ping = 500
ping.median_ping.level[2].dyn_ping = 450
ping.median_ping.level[2].add_malus = 5
ping.median_pj = {}
ping.median_pj.level = {}
ping.median_pj.level[1] = {}
ping.median_pj.level[1].max_pj = 80
ping.median_pj.level[1].add_malus = 1
ping.median_pj.level[2] = {}
ping.median_pj.level[2].max_pj = 120
ping.median_pj.level[2].add_malus = 3
ping.lastposupdate = {}
ping.lastposupdate.level = {}
ping.lastposupdate.level[1] = {}
ping.lastposupdate.level[1].max_millis = 120
ping.lastposupdate.level[1].add_malus = 1
ping.lastposupdate.level[2] = {}
ping.lastposupdate.level[2].max_millis = 500
ping.lastposupdate.level[2].add_malus = 5
ping.malusmax = { 20, 40 }
ping.malus = {}
ping.level = {}
ping.lastspawn = {}
ping.ping_history = {}
ping.pj_history = {}
ping.ping_median_history = {}
ping.maxvalues = 10
ping.autodisabled = 0
ping.dynamic = 1



-- unspecs all players, that was put into spectator because of high ping/pj
function ping.unspec_highpingers()
	for i,cn in pairs(players.all()) do
		if ping.level[cn] == 2 then
			spectator.funspec(cn, "PING", ping.module_name)
		end
		ping.level[cn] = 0
		ping.malus[cn] = 0
	end
end

function ping.reset_pj_history(cn)
	ping.pj_history[cn] = {}
	for i = 1, ping.maxvalues, 1 do
		table.insert(ping.pj_history[cn], 30)
	end
end

-- maluspunkte auswerten / Zustandsänderungen
function ping.check_malus()
	if ping.enabled == 0 then return end
	for i,cn in pairs(players.all()) do
		if ping.malus[cn] == nil then
			ping.malus[cn] = 0
		end
		if ping.level[cn] == nil then
			ping.level[cn] = 0
		end

		if ping.malus[cn] < ping.malusmax[1] and ping.level[cn] > 0 then
			ping.level[cn] = 0
			ping.reset_pj_history(cn)
			spectator.funspec(cn, "PING", ping.module_name)
			messages.info(cn, {cn}, "PING", string.format("%s, Thank you for fixing your ping/pj!", server.player_displayname(cn)))
			messages.irc("PING", string.format("%s has fixed his ping/pj!", server.player_displayname(cn)))
		elseif ping.malus[cn] >= ping.malusmax[1] and ping.level[cn] == 0 then
			ping.level[cn] = 1
			messages.warning(cn, {cn}, "PING", string.format("WARNING: %s, Please fix your ping/pj NOW or you will be spec'ed!", server.player_displayname(cn)))
		elseif ping.malus[cn] >= ping.malusmax[2] and ping.level[cn] == 1 then
			ping.level[cn] = 2
			spectator.fspec(cn, "PING", ping.module_name)
			messages.error(cn, {cn}, "PING", string.format("%s, You have been spec'ed because your ping/pj is constantly too high!", server.player_displayname(cn)))
		end
	end
end

-- Get the median of a table.
function ping.median(t)
	local temp = {}
	-- deep copy table so that when we sort it, the original is unchanged, also weed out any non numbers
	for k,v in pairs(t) do
		if type(v) == 'number' then
			table.insert( temp, v )
		end
	end
	table.sort( temp )
	-- If we have an even number of table elements or odd.
	if math.fmod(#temp,2) == 0 then
		-- return mean value of middle two elements
		return ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
	else
		-- return middle element
		return temp[math.ceil(#temp/2)]
	end
end

function ping.get_median_ping(cn)
	local p = server.player_ping(cn)
	table.insert(ping.ping_history[cn], p)
	if #ping.ping_history[cn] > ping.maxvalues then
		local m = ping.median(ping.ping_history[cn])
		table.remove(ping.ping_history[cn], 1) -- das hier ist teuer und kann man noch mit einem ringpuffer optimieren
		return m
	else
		return p
	end
end

function ping.get_median_pj(cn)
	local p = server.player_lag(cn)
	table.insert(ping.pj_history[cn], p)
	if #ping.pj_history[cn] > ping.maxvalues then
		local m = ping.median(ping.pj_history[cn])
		table.remove(ping.pj_history[cn], 1) -- das hier ist teuer und kann man noch mit einem ringpuffer optimieren
		return m
	else
		return p
	end
end

function ping.get_ping_limit()
	if ping.dynamic == 1 then
		if next(ping.ping_median_history) == nil then -- check if there are no values in the ping median history (the table is empty) 
			return { ping.median_ping.level[1].max_ping, ping.median_ping.level[2].max_ping }
		else
			local median_all = ping.median(ping.ping_median_history)
			return { median_all + ping.median_ping.level[1].dyn_ping, median_all + ping.median_ping.level[2].dyn_ping }
		end
	else
		return { ping.median_ping.level[1].max_ping, ping.median_ping.level[2].max_ping }
	end
end

function ping.check_ping()
	if ping.enabled == 0 or maprotation.game_mode == "coop edit" then return end
	local ping_limit = ping.get_ping_limit()
	for i,cn in pairs(players.all()) do
		local median_ping = ping.get_median_ping(cn)
		ping.ping_median_history[cn] = median_ping
		if server.player_status_code(cn) ~= server.SPECTATOR then
			messages.debug(-1, players.admins(), "PING", string.format("orange<%s (%i): malus: %i ping: %i median: %i limit1: %i limit2: %i>", server.player_name(cn), cn, ping.malus[cn], server.player_ping(cn), median_ping, ping_limit[1], ping_limit[2]))
		end
		-- maluspunkte sammeln
		if
			ping.malus[cn] >= ping.median_ping.level[1].add_malus and
			median_ping < ping_limit[1]
		then
			-- spieler hat maluspunkte und ist unter dem schwellwert zu level 1: maluspunkte werden verringert
			ping.malus[cn] = ping.malus[cn] - ping.median_ping.level[1].add_malus
		elseif
			median_ping >= ping_limit[1] and
			median_ping < ping_limit[2] and
			server.player_status_code(cn) ~= server.SPECTATOR
		then
			-- spieler ist zwischen den schwellwerten von level 1 und level 2: maluspunkte werden erhöht (level 1)
			ping.malus[cn] = ping.malus[cn] + ping.median_ping.level[1].add_malus
		elseif
			median_ping >= ping_limit[2] and
			server.player_status_code(cn) ~= server.SPECTATOR
		then
			-- spieler ist über dem schwellwert von level 2: maluspunkte werden schneller erhöht (level 2)
			ping.malus[cn] = ping.malus[cn] + ping.median_ping.level[2].add_malus
		end
    end
end

function ping.check_pj()
	if ping.enabled == 0 or maprotation.game_mode == "coop edit" then return end
	for i,cn in pairs(players.all()) do
		local median_pj = ping.get_median_pj(cn)
		if server.player_status_code(cn) ~= server.SPECTATOR then
			-- messages.debug(-1, players.admins(), "PING", string.format("magenta<%s: median: %i pj: %i>", server.player_displayname(cn), median_pj, server.player_lag(cn)))
		end
		-- maluspunkte sammeln
		if
			median_pj >= ping.median_pj.level[1].max_pj and
			median_pj < ping.median_pj.level[2].max_pj and
			server.player_status_code(cn) == server.ALIVE and
			server.player_status_code(cn) ~= server.SPECTATOR and
			(server.gamemillis - ping.lastspawn[cn]) > ping.check_delay_after_spawn
		then
			-- spieler ist zwischen den schwellwerten von level 1 und level 2: maluspunkte werden erhöht (level 1)
			ping.malus[cn] = ping.malus[cn] + ping.median_pj.level[1].add_malus
		elseif
			median_pj >= ping.median_pj.level[2].max_pj and
			server.player_status_code(cn) == server.ALIVE and
			server.player_status_code(cn) ~= server.SPECTATOR and
			(server.gamemillis - ping.lastspawn[cn]) > ping.check_delay_after_spawn
		then
			-- spieler ist über dem schwellwert von level 2: maluspunkte werden schneller erhöht (level 2)
			ping.malus[cn] = ping.malus[cn] + ping.median_pj.level[2].add_malus
		end
    end
end

function ping.check_lastposupdate()
	if ping.enabled == 0 or maprotation.game_mode == "coop edit" then return end
	for i,cn in pairs(players.all()) do
		local lastposupdate = server.player_lastposupdate(cn)
		if
			server.player_status(cn) ~= "spectator" and
			server.player_status_code(cn) == server.ALIVE and
			(server.gamemillis - ping.lastspawn[cn]) > ping.check_delay_after_spawn
		then
			if server.gamemillis > (lastposupdate + ping.lastposupdate.level[2].max_millis) then
				messages.warning(cn, {cn}, "PING", string.format("%s, You are sending position updates not fast enough!", server.player_displayname(cn)))
				ping.malus[cn] = ping.malus[cn] + ping.lastposupdate.level[2].add_malus
			elseif server.gamemillis > (lastposupdate + ping.lastposupdate.level[1].max_millis) then
				messages.warning(cn, {cn}, "PING", string.format("%s, your the position updates are to late!", server.player_displayname(cn)))
				ping.malus[cn] = ping.malus[cn] + ping.lastposupdate.level[1].add_malus
			end
		end
	end
end

-- automatically disables ping checks on recording sessions
function ping.check_isrecording()
	if cheater.is_recording() then
		if ping.enabled == 1 then
			ping.enabled = 0
			ping.autodisabled = 1
			messages.info(cn, players.all(), "PING", "Automatically disabled ping checks")
			ping.unspec_highpingers()
		end
	else
		if ping.enabled == 0 and ping.autodisabled == 1 then
			ping.enabled = 1
			ping.autodisabled = 0
			messages.info(cn, players.all(), "PING", "Automatically enabled ping checks")
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_ping(cn, cmd, arg, arg2, arg3)
	if not hasaccess(cn, admin_access) then return end
	if arg == nil then
		if cmd == "info" then
			messages.info(cn, {cn}, "PING", string.format("ping.enabled = %i", ping.enabled))
			messages.info(cn, {cn}, "PING", string.format("ping.autodisabled = %i", ping.autodisabled))
			messages.info(cn, {cn}, "PING", string.format("ping.dynamic = %i", ping.dynamic))
			messages.info(cn, {cn}, "PING", string.format("ping.maxvalues = %i", ping.maxvalues))
		end
		if cmd == "enabled" then
			messages.info(cn, {cn}, "PING", string.format("ping.enabled = %i", ping.enabled))
		end
		if cmd == "maxvalues" then
			messages.info(cn, {cn}, "PING", string.format("ping.maxvalues = %i", ping.maxvalues))
		end
		if cmd == "dynamic" then
			messages.info(cn, {cn}, "PING", string.format("ping.dynamic = %i", ping.dynamic))
		end
		if cmd == "reset" then
			ping.unspec_highpingers()
			messages.warning(cn, {cn}, "PING", "The ping checks were resetted!")
		end
	else
		if cmd == "enabled" then
			ping.enabled = tonumber(arg)
			messages.info(cn, {cn}, "PING", string.format("ping.enabled = %i", ping.enabled))
		end
		if cmd == "maxvalues" then
			ping.maxvalues = tonumber(arg)
			messages.info(cn, {cn}, "PING", string.format("ping.maxvalues = %i", ping.maxvalues))
		end
		if cmd == "dynamic" then
			ping.dynamic = tonumber(arg)
			messages.info(cn, {cn}, "PING", string.format("ping.dynamic = %i", ping.dynamic))
		end
		if cmd == "ping" then
			if arg == "dyn" and arg2 ~= nil and arg3 ~= nil then
				ping.median_ping.level[1].dyn_ping = tonumber(arg2)
				ping.median_ping.level[2].dyn_ping = tonumber(arg3)
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[1].dyn_ping = %i", ping.median_ping.level[1].dyn_ping))
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[2].dyn_ping = %i", ping.median_ping.level[2].dyn_ping))
			elseif arg == "max" and arg2 ~= nil and arg3 ~= nil then
				ping.median_ping.level[1].max_pingt = tonumber(arg2)
				ping.median_ping.level[2].max_pingt = tonumber(arg3)
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[1].max_ping = %i", ping.median_ping.level[1].max_ping))
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[2].max_ping = %i", ping.median_ping.level[2].max_ping))
			else
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[1].dyn_ping = %i", ping.median_ping.level[1].dyn_ping))
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[2].dyn_ping = %i", ping.median_ping.level[2].dyn_ping))
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[1].max_ping = %i", ping.median_ping.level[1].max_ping))
				messages.info(cn, {cn}, "PING", string.format("ping.median_ping.level[2].max_ping = %i", ping.median_ping.level[2].max_ping))
			end
		end
		if cmd == "pj" then
			if arg ~= nil and arg2 ~= nil then
				ping.median_pj.level[1].max_pj = tonumber(arg)
				ping.median_pj.level[2].max_pj = tonumber(arg2)
				messages.info(cn, {cn}, "PING", string.format("ping.median_pj.level[1].max_pj = %i", ping.median_pj.level[1].max_pj))
				messages.info(cn, {cn}, "PING", string.format("ping.median_pj.level[2].max_pj = %i", ping.median_pj.level[2].max_pj))
			else
				messages.info(cn, {cn}, "PING", string.format("ping.median_pj.level[1].max_pj = %i", ping.median_pj.level[1].max_pj))
				messages.info(cn, {cn}, "PING", string.format("ping.median_pj.level[2].max_pj = %i", ping.median_pj.level[2].max_pj))
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	ping.malus[cn] = 0
	ping.level[cn] = 0
	ping.lastspawn[cn] = server.gamemillis + ping.check_delay_after_connect
	ping.ping_history[cn] = {}
	ping.pj_history[cn] = {}
	ping.ping_median_history[cn] = 100
end)

server.event_handler("disconnect", function(cn)
	ping.malus[cn] = 0
	ping.level[cn] = 0
	ping.lastspawn[cn] = 0
	ping.ping_history[cn] = {}
	ping.pj_history[cn] = {}
	ping.ping_median_history[cn] = nil
end)

server.event_handler("mapchange", function()
	-- pj check is disabled for 5 seconds after mapchange 
	for i,cn in pairs(players.all()) do
		ping.lastspawn[cn] = server.gamemillis + ping.check_delay_after_mapchange
		ping.ping_history[cn] = {}
		ping.pj_history[cn] = {}
	end
	ping.ping_median_history = {}
end)

server.event_handler("spawn", function(cn)
	ping.lastspawn[cn] = server.gamemillis
end)

server.interval(ping.ping_interval, ping.check_ping)
server.interval(ping.pj_interval, ping.check_pj)
server.interval(ping.lastposupdate_interval, ping.check_lastposupdate)
server.interval(ping.malus_interval, ping.check_malus)
server.interval(ping.recording_interval, ping.check_isrecording)
