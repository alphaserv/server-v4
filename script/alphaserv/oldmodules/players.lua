--[[players = {}

local vars = {}
local default = {}
default.priv = funmod.players.priv_NORMAL

function players.vars(cn) return vars[server.player_sessionid(cn) end
function players.save_vars(cn, vars)
    vars[server.player_sessionid(cn)] = vars
end
function players.save_var(cn, var, vars)
    vars[server.player_sessionid(cn)][var] = vars
end
function players.add_var(var, val)
    default[var] = val
end
function players.add_player(cn)
    vars[server.player_sessionid(cn)] = default
end
players.set_var = players.save_var

]]
--copied from noobmod
--changed the priveleges
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
	for _, cn in pairs(players.all()) do
		if server.player_priv_code(cn)  > server.PRIV_MASTER then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all masters
players.masters = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.player_priv_code(cn) < server.PRIV_ADMIN and server.player_priv_code(cn) >= server.PRIV_MASTER then table.insert(newlist, cn) end
	end
	return newlist
end

-- returns a table containing cns of all users
players.normal = function()
	local newlist = {}
	for _, cn in pairs(server.clients()) do
		if server.player_priv_code(cn) < server.PRIV_MASTER then table.insert(newlist, cn) end
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


