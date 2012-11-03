--[[
	script/module/nl_mod/nl_killcounter.lua
	Hanack (Andreas Schaeffer)
	Created: 02-Feb-2011
	Last Modified: 02-Feb-2011
	License: GPL3

	Funktionen:
	API-Methoden:
	Konfigurations-Variablen:
	Laufzeit-Variablen:

]]

killcounter = {}
killcounter.kills = {}
killcounter.enabled = {}



function server.playercmd_killcounter(cn)
	if killcounter.enabled[cn] == nil then
		killcounter.enabled[cn] = true
	else
		if killcounter.enabled[cn] then
			killcounter.enabled[cn] = false
			messages.info(cn, {cn}, "KILLCOUNTER", string.format("%s, your killcounter is red<disabled>!", server.player_displayname(cn)))
		else
			killcounter.enabled[cn] = true
			messages.info(cn, {cn}, "KILLCOUNTER", string.format("%s, your killcounter is green<enabled>!", server.player_displayname(cn)))
		end
	end
end
server.playercmd_kc = server.playercmd_killcounter

--[[
		EVENTS
]]

server.event_handler("frag", function(targetCN, actorCN)
	if killcounter.kills[actorCN] == nil then killcounter.kills[actorCN] = 0 end
	if killcounter.enabled[actorCN] == nil then killcounter.enabled[actorCN] = false end
	if killcounter.enabled[actorCN] then
		killcounter.kills[actorCN] = killcounter.kills[actorCN] + 1
		messages.info(actorCN, {actorCN}, "KILLCOUNTER", string.format("Kill no. magenta<%d>", killcounter.kills[actorCN]))
	end
end)

server.event_handler("teamkill", function(targetCN, actorCN)
	if killcounter.kills[targetCN] == nil then killcounter.kills[targetCN] = 0 end
	if killcounter.enabled[targetCN] == nil then killcounter.enabled[targetCN] = false end
	if killcounter.enabled[targetCN] then
		killcounter.kills[targetCN] = killcounter.kills[targetCN] - 1
		messages.info(targetCN, {targetCN}, "KILLCOUNTER", string.format("Kill no. magenta<%d> (-1)", killcounter.kills[targetCN]))
	end
end)

server.event_handler("spawn", function(cn)
	if killcounter.kills[cn] == nil then killcounter.kills[cn] = 0 end
	if killcounter.enabled[cn] == nil then killcounter.enabled[cn] = false end
	if killcounter.enabled[cn] then
		killcounter.kills[cn] = 0
		messages.info(cn, {cn}, "KILLCOUNTER", "Kills magenta<resetted>")
	end
end)

server.event_handler("connect", function(cn)
	killcounter.kills[cn] = 0
	killcounter.enabled[cn] = false
end)

server.event_handler("disconnect", function(cn)
	killcounter.kills[cn] = nil
	killcounter.enabled[cn] = nil
end)

server.event_handler("mapchange", function()
	for i,cn in pairs(players.all()) do
		killcounter.kills[cn] = 0
	end
end)


