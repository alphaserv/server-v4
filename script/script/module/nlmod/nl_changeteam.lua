--[[
	script/module/nl_mod/nl_changeteam.lua
	Hanack (Andreas Schaeffer)
	Created: 12-Sep-2010
	Last Modified: 20-Nov-2010
	License: GPL3

	Funktionen:
		Regelt das Switchen zwischen den Teams.

	Commands:
		#ct
			Spieler wechselt das Team, wenn es im anderen Team weniger Spieler gibt
		#ct <CN>
			Ein Spieler wird in ein Team geschoben, wenn es im anderen Team weniger Spieler gibt

	API-Methoden:
		changeteam.changeteam(cn, team, slay)
			Der Spieler mit der CN cn soll ins Team team gewechselt werden. Wird slay auf true gestellt,
			stirbt der Spieler dabei. Der Befehl wird verweigert, wenn der Spieler die Flagge hat oder
			sich bereits in dem gewuenschten Team befindet.
		changeteam.move(cn, playerCN, force)
			Verschieben eines Spielers in das andere Team. Der Befehl wird verweigert, wenn das andere
			Team mehr Spieler hat. Wird force auf true gesetzt, dann wird der Befehl in jedem Fall
			ausgefuehrt. Der Spieler wird dabei sterben.
		changeteam.switch(cn)
			Wechseln des Teams

	Konfigurations-Variablen:
		changeteam.ctdiff
			Mit dieser Variable stellt man die Diffenenz der Anzahl der Teamspieler ein,
			die nötig ist, um einen Changeteam durchzuführen
]]



--[[
		API
]]

changeteam = {}
changeteam.ctdiff = 1
changeteam.has_flag = {}
changeteam.force_cn = nil
changeteam.allow = 0

function changeteam.changeteam(cn, team, slay)
	-- TODO: warum funktioniert das noch nicht
	if changeteam.has_flag[tonumber(cn)] == 1 then
		messages.error(-1, players.admins(), "CHANGETEAM", "The player has the flag and can't be switched to team "..team)
		return false
	else
		if server.player_team(cn) == team then
			messages.debug(-1, players.admins(), "CHANGETEAM", "The player "..server.player_displayname(cn).." is already in team "..team)
			return false
		else
			messages.debug(-1, players.admins(), "CHANGETEAM", "The player "..server.player_displayname(cn).." will be switched to team "..team)
			changeteam.force_cn = cn
			if slay then
				messages.debug(-1, players.admins(), "CHANGETEAM", "Slaying player "..server.player_displayname(cn))
				server.player_slay(cn)
			end
			server.changeteam(cn, team)
			return true
		end
	end
end

function changeteam.move(cn, playerCN, force)
	if server.player_status_code(tonumber(playerCN)) == server.SPECTATOR then
		messages.error(cn, {cn}, "CHANGETEAM", "You cannot move player " .. server.player_displayname(playerCN) .. " because he/she is spectator or doesn't exist!")
	else
		local team = server.player_team(playerCN)
		if force then
			if team == "good" then
				changeteam.changeteam(playerCN, "evil", true)
			else
				changeteam.changeteam(playerCN, "good", true)
			end
		else
			local goodPlayers = server.team_players("good")
			local evilPlayers = server.team_players("evil")
			if team == "good" then
				if #goodPlayers >= (#evilPlayers + changeteam.ctdiff) then
					changeteam.changeteam(playerCN, "evil", true)
				else
					messages.error(cn, {cn}, "CHANGETEAM", "Changeteam not possible because team good doesn't have more players!")
				end
			else
				if #evilPlayers >= (#goodPlayers + changeteam.ctdiff) then
					changeteam.changeteam(playerCN, "good", true)
				else
					messages.error(cn, {cn}, "CHANGETEAM", "Changeteam not possible because team evil doesn't have more players!")
				end
			end
		end
	end
end

function changeteam.switch(cn)
	if server.player_status_code(cn) == server.SPECTATOR then
		messages.error(cn, {cn}, "CHANGETEAM", "You cannot switch team because you are a spectator!")
		return -1
	end
	local team = server.player_team(cn)
	local goodPlayers = server.team_players("good")
	local evilPlayers = server.team_players("evil")
	if team == "good" then
		if #goodPlayers >= (#evilPlayers + changeteam.ctdiff) then
			changeteam.changeteam(cn, "evil", true)
		else
			messages.error(cn, {cn}, "CHANGETEAM", "You cannot switch team because team good doesn't have more players!")
			return -1
		end
	else
		if #evilPlayers >= (#goodPlayers + changeteam.ctdiff) then
			changeteam.changeteam(cn, "good", true)
		else
			messages.error(cn, {cn}, "CHANGETEAM", "You cannot switch team because team evil doesn't have more players!")
			return -1
		end	
	end
	return 1
end




--[[
		COMMANDS
]]

function server.playercmd_changeteam(cn, playerCN, force)
	changeteam.allow = 1
	server.sleep(100, function()
		changeteam.allow = 0
	end)
	if not playerCN then
		changeteam.switch(cn)
	else
		if hasaccess(cn, changeteam_access) then
			if force then
				changeteam.move(cn, playerCN, true)
			else
				changeteam.move(cn, playerCN, false)
			end
		else
			if cn == playerCN then
				changeteam.switch(cn)
			else
				messages.error(cn, {cn}, "CHANGETEAM", "You have to be admin to switch other players!")
				return 0
			end
		end
	end
end
server.playercmd_ct = server.playercmd_changeteam



--[[
		EVENTS
]]

local ctblock = 0
server.event_handler("chteamrequest", function(cn, curteam, newteam)
	messages.debug(-1, players.admins(), "CHANGETEAM", "Event chteamrequest was fired")
	-- blocking concurrent access!
	if changeteam.allow == 1 then
		if ctblock == 0 then
			ctblock = 1
			messages.debug(-1, players.admins(), "CHANGETEAM", "Concurrency locked!")
			if changeteam.force_cn ~= nil then
				messages.debug(-1, players.admins(), "CHANGETEAM", "Force is set, will be unset now!")
				changeteam.force_cn = nil
				ctblock = 0
				return 1
			else
				messages.debug(-1, players.admins(), "CHANGETEAM", "Force is set, will be unset now!")
				local success = changeteam.switch(cn)
				ctblock = 0
				return success
			end
		else
			messages.debug(-1, players.admins(), "CHANGETEAM", "Cannot enter because of concurrency lock!")
			return -1
		end
	else
		irc_say(string.format( "------------- %s tries to switch", server.player_displayname(cn) ))
		return -1
	end
end)

server.event_handler("connect", function(cn)
	messages.debug(-1, players.admins(), "CHANGETEAM", "Player "..server.player_displayname(cn).." ("..cn..") lost flag!")
	changeteam.has_flag[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	messages.debug(-1, players.admins(), "CHANGETEAM", "Player "..server.player_displayname(cn).." ("..cn..") lost flag!")
	changeteam.has_flag[cn] = 0
end)

server.event_handler("scoreflag", function(cn)
	messages.debug(-1, players.admins(), "CHANGETEAM", "Player "..server.player_displayname(cn).." ("..cn..") lost flag!")
	changeteam.has_flag[cn] = 0
end)

server.event_handler("takeflag", function(cn)
	messages.debug(-1, players.admins(), "CHANGETEAM", "Player "..server.player_displayname(cn).." ("..cn..") has flag!")
	changeteam.has_flag[cn] = 1
end)

server.event_handler("dropflag", function(cn)
		server.sleep(50, function()
		if server.valid_cn(cn) then
			messages.debug(-1, players.admins(), "CHANGETEAM", "Player "..server.player_displayname(cn).." ("..cn..") lost flag!")
			changeteam.has_flag[cn] = 0
		end
	end)
end)

server.event_handler("mapchange", function()
	for i,cn in pairs(players.all()) do
		changeteam.has_flag[cn] = 0
	end
end)

server.event_handler("intermission", function()
	for i,cn in pairs(players.all()) do
		changeteam.has_flag[cn] = 0
	end
end)

