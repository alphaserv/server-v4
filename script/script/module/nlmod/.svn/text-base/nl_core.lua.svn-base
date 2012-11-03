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
nl_game = {}
nl = {}

nl.corelog = io.open("log/core.log","a+")
function nl.log_core(msg)
--[[
			Schreibt in log/event.log
]]
	assert(msg ~= nil)
	nl.corelog:write(os.date("[%a %d %b %X] ",os.time()))
	nl.corelog:write(msg)
	nl.corelog:write("\n")
	nl.corelog:flush()
end

function nl.createGame()
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
		do_balance = false,
		committed = false,
		demofile = "empty"
	}
	for id, player in pairs(nl_players) do
		if player.con_status == "dis" then
			nl_players[id] = nil
		end
	end
end

function nl.createPlayer(cn)
--[[
			Erzeugt eine neue Spielertabelle
]]
	
	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then
		if server.nl_stats_debug==1 then nl.log_core(string.format("Spieler %s (id=%i) konnte nicht angelegt werden", server.player_displayname(cn), player_id)) end
		return
	end
	
	if nl_players[player_id] then 
		if server.nl_stats_debug==1 then nl.log_core(string.format("Spieler %s (id=%i) schon vorhanden", server.player_displayname(cn), player_id)) end
		return
	end
	
	nl_players[player_id] = {
		name           = tostring(server.player_displayname(cn)), -- in Game Spielername (aendert sich bei Rename)
		statsname      = tostring(server.player_name(cn)), --------- Spielername (ohne Clantag, wenn registriert)
    ipaddr         = tostring(server.player_ip(cn)), ----------- ip-adresse des Spielers
    ipaddrlong     = tostring(server.player_iplong(cn)), ------- ip-adresse des Spielers (im langen Format)
		ctfgame        = true, ------------------------------------- Spiel geht um Flagge
		team           = tostring(server.player_team(cn)), --------- Teamname des Spielers
		playing        = false, ----------- True, wenn der Spieler aktiv ist
		fspec          = {}, -------------- Liste von Locks, aufgrund derer der Spieler den Spectator nicht mehr selber verlassen kann
		finished       = false, ----------- True, wenn der Spieler das komplette Spiel gespielt hat
		flagholder     = false, ----------- True, wenn der Spieler die Flagge hat
		got_switched   = false, ----------- True, wenn der Spieler per Autobalance geswitched wurde
		switch         = false, ----------- True, wenn der Spieler beim nächsten Death geswitched werden soll
		slotpass       = "none", ---------- Enthält das versalzene Passwort vom Client für ein Rename
		country        = "", -------------- Enthält den Countrycode des Spielers
		
		ts_mappack     = "",

    frags          = 0, --------------- Frags im aktuellen Spiel (RESET BEI SIGNAL MAPLOADED)
    deaths         = 0, --------------- Deaths im aktuellen Spiel (RESET BEI SIGNAL MAPLOADED)
    suicides       = 0, --------------- Suicides im aktuellen Spiel (RESET BEI SIGNAL MAPLOADED)
    misses         = 0, --------------- Misses im aktuellen Spiel (RESET BEI SIGNAL MAPLOADED)
    shots          = 0, --------------- Shots im aktuellen Spiel (RESET BEI SIGNAL MAPLOADED)
    hits_made      = 0, --------------- Wie oft hat der Spieler im aktuellen Spiel getroffen (RESET BEI SIGNAL MAPLOADED)
    hits_get       = 0, --------------- Wie oft wurde der Spieler im aktuellen Spiel getroffen (RESET BEI SIGNAL MAPLOADED)
    tk_made        = 0, --------------- Wie viele Teamkills hat der Spieler im aktuellen Spiel gemacht (RESET BEI SIGNAL MAPLOADED)
    tk_get      	 = 0, --------------- Wie oft wurde der Spieler im aktuellen Spiel von Teammates gefragt (RESET BEI SIGNAL MAPLOADED)
		flags_returned = 0, --------------- Wie viele Flaggen hat der Spieler im aktuellen Spiel resettet (RESET BEI SIGNAL MAPLOADED)
		flags_stolen   = 0, --------------- Wie viele Flaggen hat der Spieler im aktuellen Spiel gestohlen (RESET BEI SIGNAL MAPLOADED)
		flags_gone     = 0, --------------- Wie oft wurde dem Team des Spielers die Flagge gestohlen (RESET BEI SIGNAL MAPLOADED)
		flags_scored   = 0, --------------- Wie oft hat der Spieler für das aktuelle Team gescored (RESET BEI SIGNAL MAPLOADED)
		total_scored   = 0, --------------- Wie oft hat der Spieler im aktuellen Spiel gescored (RESET BEI SIGNAL MAPLOADED)

		team_id        = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
		game_id        = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      damage         = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      damagewasted   = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      accuracy       = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      timeplayed     = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      win            = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
      rank           = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
		botskill       = 0, --------------- Wird erst bei SIGNAL INTERMISSION gesetzt (RESET BEI SIGNAL MAPLOADED)
		
		playerweight   = 0, --------------- Nuck's Spielergewichtung wird bei SIGNAL MAPCHANGE berechnet und für das Teamshuffle verwendet

		con_status     = "try", ----------- "try" = connecting, "con" = connected, "dis" = disconnected
		show_banner    = true, ------------ shows the serverbanner and checks the nameprotection after first map is loaded
		nl_status      = "none", ---------- ("none"/"pending"/"protected"/"user"/"admin"/"blocked"/"banned")
		nl_greet       = "Greet", --------- Enthält dieeet-Message des Spielers
		registered     = 0, --------------- Enthält 1, wenn user oder admin
		bookmark       = false, ----------- Setzt ein Lesezeichen um das Demofile schneller zu finden
		
		loglevel       = 2, --------------- Das Loglevel für nl_messages (1=debug,2=info,3=warning,4=error)
		
		mapsucks       = 0, --------------- Spieler findet die aktuelle Map doof
		lovemap        = 0, --------------- Spieler findet die aktuelle Map gut
		
		mapbattle      = 0, --------------- Spieler hat beim mapbattle abgestimmt
		suggestmap     = 0, --------------- Spieler hat diese Map vorgeschlagen
		
		veto           = 0, --------------- Spieler hat ein Veto abgegeben
		noveto         = 0, --------------- Spieler hat ein No-Veto abgegeben
		vchangemind    = 0, --------------- Spieler hat seine Meinung innerhalb der letzten Sekunde geändert
		
		mapcontest     = 0, --------------- Spieler hat beim mapcontest abgestimmt

		-- cheaters
		repression     = 0, --------------- Spieler erleidet Repression
		stottern       = 0, --------------- Spieler stottert
		antirespawn    = 0, --------------- Spieler wird am Respawning gehindert
		antifragging   = 0, --------------- Spieler stirbt selbst beim frag
		protect        = 0, --------------- Spieler ist untoetbar
		rename         = 0, --------------- Spieler renames

		reconnect      = 0, --------------- Spieler reconnects

      -- !!! +++++++ aimbot detection ++++++++
      -- By: Nuck Chorris 
      -- Created: 01/feb/2011
      
      bad_credit    = 0,  -- if the value is outside of the standard deviation
      value_count   = 0,  -- Counts the number of values recorded

      accuracy_mean = 0,  -- The mean value of the accuracy at every shot
      accuracy_var  = 0,  -- The variance of the accuracy 
      
      d_misses      = 0,  -- previouse value of the misses
      d_misses_mean = 0,  -- The mean value of the misses between two shots
      d_misses_var  = 0,  -- The variance of the misses between two shots

      -- !!! +++++++ aimbot detection ++++++++
	}
	
	if server.nl_stats_debug==1 then nl.log_core(string.format("Spieler %s (id=%i) angelegt (status=%s)", server.player_displayname(cn), player_id, nl_players[player_id].nl_status)) end
  return
end

function nl.resetPlayer(cn)
--[[
			Setzt die "pro Spiel"-Spielervariablen zurück
]]

	--local player_id = server.player_sessionid(cn)
	--if nl_players == nil or player_id == -1 then return end
	
	--if not nl_players[player_id] then
		--nl.createPlayer(cn)
	--end

	--local player = nl_players[player_id]
	
	nl.updatePlayer(cn, "finished", false, "set")
	nl.updatePlayer(cn, "flagholder", false, "set")
	nl.updatePlayer(cn, "got_switched", false, "set")
	nl.updatePlayer(cn, "switch", false, "set")
	
	nl.updatePlayer(cn, "frags", 0, "set")
	nl.updatePlayer(cn, "deaths", 0, "set")
	nl.updatePlayer(cn, "suicides", 0, "set")
	nl.updatePlayer(cn, "misses", 0, "set")
	nl.updatePlayer(cn, "shots", 0, "set")
	nl.updatePlayer(cn, "hits_made", 0, "set")
	nl.updatePlayer(cn, "hits_get", 0, "set")
	nl.updatePlayer(cn, "tk_made", 0, "set")
	nl.updatePlayer(cn, "tk_get", 0, "set")
	nl.updatePlayer(cn, "flags_returned", 0, "set")
	nl.updatePlayer(cn, "flags_stolen", 0, "set")
	nl.updatePlayer(cn, "flags_gone", 0, "set")
	nl.updatePlayer(cn, "flags_scored", 0, "set")
	nl.updatePlayer(cn, "total_scored", 0, "set")

	nl.updatePlayer(cn, "damage", 0, "set")
	nl.updatePlayer(cn, "damagewasted", 0, "set")
	nl.updatePlayer(cn, "accuracy", 0, "set")
	nl.updatePlayer(cn, "timeplayed", 0, "set")
	nl.updatePlayer(cn, "win", 0, "set")
	nl.updatePlayer(cn, "rank", 0, "set")
	nl.updatePlayer(cn, "botskill", 0, "set")

	--nl.updatePlayer(cn, "mapsucks", 0, "set")
	--nl.updatePlayer(cn, "lovemap", 0, "set")
	
	nl.updatePlayer(cn, "mapbattle", 0, "set")

	nl.updatePlayer(cn, "veto", 0, "set")
	nl.updatePlayer(cn, "noveto", 0, "set")
	nl.updatePlayer(cn, "vchangemind", 0, "set")
	
	nl.updatePlayer(cn, "rename", 0, "set")
   
   nl.updatePlayer(cn, "d_misses", 0, "set")

	messages.debug(cn, players.admins(), "nl_core", string.format("Spielervariablen fuer %s zurueckgesetzt",server.player_name(cn)) )
	return
end

function nl.updatePlayer(cn, varname, varvalue, method)
--[[
			Bringt eine Spielervariable auf den Stand der Dinge
]]

	local player_id = server.player_sessionid(cn)
	if nl_players == nil or player_id == -1 then return end
	
	if not nl_players[player_id] then
		irc_say("FATAL: nl.updatePlayer >> nl.createPlayer(cn)")
	end

	local player = nl_players[player_id]
	
	-- if server.nl_stats_debug==1 then nl.log_core(string.format("START Aktualisieren %s.%s=%s", player.name, varname, tostring(varvalue))) end

	if method == "set" then player[varname] = varvalue end
	if method == "add" then player[varname] = player[varname] + varvalue end
	if method == "sub" then player[varname] = player[varname] - varvalue end

	--irc_say(string.format("nl_players[%i].%s = %s",player_id,varname,tostring(varvalue)))

	--if server.nl_stats_debug==1 then nl.log_core(string.format("nl.updatePlayer %s.%s=%s", player.name, varname, tostring(player[varname]))) end
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
	
	--if server.nl_stats_debug==1 then nl.log_core(string.format("nl.getPlayer %s.%s=%s", player.name, varname, tostring(player[varname]))) end
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
	if server.playercount == 1 then nl.createGame() end
end)

server.event_handler("maploaded", function(cn)
	-- server.log_error(string.format("maploaded cn=%i with %i players ...", cn, tonumber(server.playercount)))
	nl.resetPlayer(cn)
	if nl.getPlayer(cn, "show_banner") == true then
		nl.set_player_status(cn)
		nl.updatePlayer(cn, "show_banner", false, "set")
	end
end)

server.event_handler("intermission", function()
	if nl_game then nl_game.finished = 1 end
end)

server.gc_enabled = 0
function server.playercmd_gc(cn)
	if server.gc_enabled == 0 then
		server.gc_enabled = 1
		messages.info(cn, {cn}, "CORE", "Garbagecollection enabled")
	else
		server.gc_enabled = 0
		messages.info(cn, {cn}, "CORE", "Garbagecollection disabled")
	end
end
server.event_handler("mapchange", function(map, mode)
	-- Garbagecollection durchführen
	if server.gc_enabled == 1 then
		local gc_count
		gc_count = collectgarbage("count")
		server.log("Garbagecollection count before collection = "..gc_count.." KB")
		collectgarbage("collect")
		gc_count = collectgarbage("count")
		server.log("Garbagecollection count after collection = "..gc_count.." KB")
	end
	-- Varieblen für ein neues Spiel setzen
	nl.createGame()
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
	if team == nil then return end
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

server.event_handler("rename", function(cn, oldname, newname)
	nl.updatePlayer(cn, "name", newname, "set")
end)

server.event_handler("reteam", function(cn, oldteam, newteam)
	nl.updatePlayer(cn, "team", newteam, "set")
end)

server.event_handler("spectator", function(cn, val)
	if val==0 then
	  nl.updatePlayer(cn, "playing", true, "set")
	end
	if val==1 then
	  nl.updatePlayer(cn, "playing", false, "set")
	end
end)

server.event_handler("disconnect", function(cn, oldteam, newteam)
	nl.updatePlayer(cn, "con_status", "dis", "set")
end)

server.event_handler("reconnect", function(cn, connects)
	local number_of_connects = #connects
	nl.updatePlayer(cn, "reconnects", number_of_connects, "set")
end)
