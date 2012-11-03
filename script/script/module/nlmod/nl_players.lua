--[[
	script/module/nl_mod/nl_players.lua
	Hanack (Andreas Schaeffer)
	Created: 23-Okt-2010
	Last Change: 23-Okt-2010
	License: GPL3

	Funktion:
		Stellt verschiedene Funktionen zur Verfügung, um auf Spielerlisten
		zu operieren - quasi wie Mengenoperationen auf Spielerlisten

	API-Methoden:
		players.all()
			Gibt eine Liste von CNs von allen verbundenen Clients zurück
		players.active()
			Gibt eine Liste von CNs von aktiv spielenden Clients zurück
		players.spectators()
			Gibt eine Liste von CNs von allen Spectators zurück
		players.bots()
			Gibt eine Liste von CNs von allen Bots zurück
		players.admins()
			Gibt eine Liste von CNs von allen Admins zurück
		players.masters()
			Gibt eine Liste von CNs von allen Masters zurück
		players.users()
			Gibt eine Liste von CNs von allen (registrierten) Benutzern zurück
		players.registered()
			Gibt eine Liste von CNs von allen registrierten Spielern (admin und user) zurück
		players.normal()
			Gibt eine Liste von CNs von allen (unregistrierten) Spielern zurück
		players.except(players, except_cn)
			Gibt eine Liste zurück, in der der Spieler mit der angegebenen CN entfernt wurde

]]


--[[
		API
]]

players = {}
players.all = server.clients
players.active = server.players
players.spectators = server.spectators
players.bots = server.bots

-- returns a table containing cns of all admins
players.admins = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.access(cn) >= admin_access then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all masters
players.masters = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.access(cn) < admin_access and server.access(cn) >= master_access then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all masters and admins
players.admins_and_masters = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.access(cn) >= master_access then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all users
players.users = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.access(cn) < master_access and server.access(cn) >= user_access then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all registered players
players.registered = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "serverowner" or nl.getPlayer(cn, "nl_status") == "masteradmin" or nl.getPlayer(cn, "nl_status") == "admin" or nl.getPlayer(cn, "nl_status") == "honoraryadmin" then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all users
players.normal = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.access(cn) < user_access then table.insert(newlist, cn) end
	end
	return newlist
end

-- removes a player from a given list
players.except = function(players, except_cn)
	local newlist = {}
	for _, cn in pairs(players) do
		if cn ~= except_cn then table.insert(newlist, cn) end
	end
	return newlist
end


