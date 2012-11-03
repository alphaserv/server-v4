--[[
	script/module/nl_mod/nl_core.lua
	Derk Haendel
	20-Sep-2010
	License: GPL3
	
	Verwaltung der Modulübergreifenden Variablen

	function nl.NewGame()
		Setzt die Variablen der Tabelle nl_game

	function nl.EndGame()
		Macht die letzten Aktualisierungen der Spielvariablen
		und schmeisst stats.lua an

	function nl.createPlayer(cn)

		
	function nl.resetPlayer(cn)

	
	function nl.updatePlayer(cn, varname, varvalue, method)

	
	function nl.getPlayer(cn, varname)

]]

require "geoip"

nl_players = {}
nl = {}
local event = {}

nl.eventlog = io.open("log/event.log","a+")
function nl.log_event(msg)
--[[
			Schreibt in log/event.log
]]
	assert(msg ~= nil)
	nl.eventlog:write(os.date("[%a %d %b %X] ",os.time()))
	nl.eventlog:write(msg)
	nl.eventlog:write("\n")
	nl.eventlog:flush()
end

function nl.CreateGame()
--[[
			Wird bei einem neuen Spiel aufgerufen
]]
	nl_game = {
		datetime = os.time(),
		duration = server.timeleft,
		mode = server.gamemode,
		map = server.map,
		players = 0,
		bots = 0,
		finished = 0,
		committed = false,
		demofile = "empty"
	}
end

function nl.createPlayer(cn)
--[[
			Erzeugt eine neue Spielertabelle
]]
	
	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then
		if server.nl_stats_debug==1 then nl.log_stats(string.format("Spieler %s (id=%i) konnte nicht angelegt werden", server.player_displayname(cn), player_id)) end
		return
	end
	
	if nl_players[player_id] then 
		if server.nl_stats_debug==1 then nl.log_stats(string.format("Spieler %s (id=%i) schon vorhanden", server.player_displayname(cn), player_id)) end
		return
	end
	
	nl_players[player_id] = {
		name           = tostring(server.player_displayname(cn)),
		statsname      = tostring(server.player_name(cn)), -- Spielername (ohne Clantag, wenn registriert)
		ctfgame        = true,
		team           = tostring(server.player_team(cn)),
		team_id        = 0, --------------- Wird von stats.lua gesetzt
		game_id        = 0, --------------- Wird von stats.lua gesetzt
		playing        = false, ----------- True, wenn der Spieler aktiv ist
		finished       = false, ----------- True, wenn der Spieler das komplette Spiel gespielt hat
		flagholder     = false, ----------- True, wenn der Spieler die Flagge hat
		got_switched   = false, ----------- True, wenn der Spieler per Autobalance geswitched wurde
		switch         = false, ----------- True, wenn der Spieler beim nächsten Death geswitched werden soll
		slotpass       = "none", ---------- Enthält das versalzene Passwort vom Client für ein Rename
		country        = "", -------------- Enthält den Countrycode des Spielers
    ipaddr         = tostring(server.player_ip(cn)),
    ipaddrlong     = tostring(server.player_iplong(cn)),
		
    frags          = 0,
    deaths         = 0,
    suicides       = 0,
    misses         = 0,
    shots          = 0,
    hits_made      = 0,
    hits_get       = 0,
    tk_made        = 0,
    tk_get      	 = 0,
		flags_returned = 0,
		flags_stolen   = 0,
		flags_gone     = 0,
		flags_scored   = 0,
		total_scored   = 0,

    damage         = 0,
    damagewasted   = 0,
    accuracy       = 0,
    timeplayed     = 0,
    win            = 0,
    rank           = 0,
		botskill       = 0,
		playerweight   = 0, --------------- Nuck's Spielergewichtung

		con_status     = "try", ----------- "try" = connecting, "con" = connected, "dis" = disconnected
		show_banner    = true, ------------ shows the serverbanner and checks the nameprotection after first map is loaded
		nl_status      = "none", ---------- ("none"/"pending"/"protected"/"user"/"admin"/"blocked"/"banned")
		nl_greet       = "Greet", --------- Enthält die Greet-Message des Spielers
		registered     = 0, --------------- Enthält 1, wenn user oder admin
		bookmark       = false, ----------- Setzt ein Lesezeichen um das Demofile schneller zu finden
	}
	
	if server.nl_stats_debug==1 then nl.log_stats(string.format("Spieler %s (id=%i) angelegt (status=%s)", server.player_displayname(cn), player_id, nl_players[player_id].nl_status)) end
  return
end

function nl.resetPlayer(cn)
--[[
			Setzt die "pro Spiel"-Spielervariablen zurück
]]

	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then return end
	
	if not nl_players[player_id] then
		nl.createPlayer(cn)
	end

	local player = nl_players[player_id]
	
	player.finished       = false
	player.flagholder     = false
	player.got_switched   = false
	player.switch         = false
	
	player.frags          = 0
	player.deaths         = 0
	player.suicides       = 0
	player.misses         = 0
	player.shots          = 0
	player.hits_made      = 0
	player.hits_get       = 0
	player.tk_made        = 0
	player.tk_get      	  = 0
	player.flags_returned = 0
	player.flags_stolen   = 0
	player.flags_gone     = 0
	player.flags_scored   = 0
	player.total_scored   = 0

	player.damage         = 0
	player.damagewasted   = 0
	player.accuracy       = 0
	player.timeplayed     = 0
	player.win            = 0
	player.rank           = 0
	player.playerweight   = 0 -- nl.playerweight(cn)

	if server.nl_stats_debug==1 then nl.log_stats(string.format("Spielervariablen %s zurueckgesetzt", player.name)) end
	return
end

function nl.updatePlayer(cn, varname, varvalue, method)
--[[
			Bringt eine Spielervariable auf den Stand der Dinge
]]

	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then return end
	
	if not nl_players[player_id] then
		irc_say(nl.createPlayer(cn))
	end

	local player = nl_players[player_id]
	
	-- if server.nl_stats_debug==1 then nl.log_stats(string.format("START Aktualisieren %s.%s=%s", player.name, varname, tostring(varvalue))) end

	if method == "set" then player[varname] = varvalue end
	if method == "add" then player[varname] = player[varname] + varvalue end
	if method == "sub" then player[varname] = player[varname] - varvalue end

	--if server.nl_stats_debug==1 then nl.log_stats(string.format("nl.updatePlayer %s.%s=%s", player.name, varname, tostring(player[varname]))) end
	return
end

function nl.getPlayer(cn, varname)
--[[
			gibt den Inhalt einer Spielervariablen zurück
]]

	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then return -1 end
	if not nl_players[player_id] then return -1 end

	local player = nl_players[player_id]
	if not player[varname] then return -1 end
	
	--if server.nl_stats_debug==1 then nl.log_stats(string.format("nl.getPlayer %s.%s=%s", player.name, varname, tostring(player[varname]))) end
	return player[varname]
end

--[[
      EVENT HANDLERS
]]

server.event_handler("request_addbot", function(cn)
	server.player_msg(cn, string.format(red("%s, bitte keine Bots ... "), server.player_displayname(cn)))
	return -1
end)

server.event_handler("connect", function(cn)
	if server.playercount == 1 then nl.CreateGame() end
end)

server.event_handler("maploaded", function(cn)
	nl.resetPlayer(cn)
	if nl_players[server.player_sessionid(cn)].show_banner then
		nl.set_player_status(cn)
		nl.updatePlayer(cn, "show_banner", false, "set")
	end
end)

server.event_handler("intermission", function()
	if nl_game then nl_game.finished = 1 end
end)

server.event_handler("mapchange", function(map, mode)
	nl.NewGame()
end)

server.event_handler("teamkill", function(cn, targetcn)
	nl.updatePlayer(cn, "tk_made", 1, "add")
	nl.updatePlayer(targetcn, "tk_get", 1, "add")
end)

server.event_handler("frag", function(targetcn, cn)
	nl.updatePlayer(cn, "frags", 1, "add")
	nl.updatePlayer(targetcn, "deaths", 1, "add")
end)

server.event_handler("shot", function(cn, gun, hit)
	nl.updatePlayer(cn, "shots", 1, "add")
	if tostring(hit)=="1" then
		nl.updatePlayer(cn, "hits_made", 1, "add")
	else
		nl.updatePlayer(cn, "misses", 1, "add")
	end
end)

server.event_handler("suicide", function(cn)
	nl.updatePlayer(cn, "suicides", 1, "add")
end)

server.event_handler("takeflag", function(cn, team)
	nl.updatePlayer(cn, "flags_stolen", 1, "add")
	nl.updatePlayer(cn, "flagholder", true, "set")
	for a, teamcn in pairs(server.team_players(team)) do
		nl.updatePlayer(teamcn, "flags_gone", 1, "add")
	end
end)

server.event_handler("dropflag", function(cn, team)
	nl.updatePlayer(cn, "flagholder", false, "set")
	nl_players[server.player_sessionid(cn)].flagholder = false
end)

server.event_handler("scoreflag", function(cn, team)
	nl.updatePlayer(cn, "flags_scored", 1, "add")
	nl.updatePlayer(cn, "flagholder", false, "set")
	if team == "evil" then oteam = "good" end
	if team == "good" then oteam = "evil" end
	for a, teamcn in pairs(server.team_players(oteam)) do
		nl.updatePlayer(teamcn, "total_scored", 1, "add")
	end
end)

server.event_handler("returnflag", function(cn, team)
	nl.updatePlayer(cn, "flags_returned", 1, "add")
end)

server.event_handler("damage", function(cn, actorcn, damage, gun)
	nl.updatePlayer(cn, "hits_get", 1, "add")
end)


