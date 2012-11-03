--[[
	script/module/nl_mod/nl_fastscores.lua
	Hanack (Andreas Schaeffer)
	Created: 05-Mai-2012
	Last Modified: 05-Mai-2012
	License: GPL3

	Funktionen:
		Erkennen von MapHackern mit Teleportern an jeder Flag (FastScores)

]]



--[[
		API
]]

fastscores = {}
fastscores.pbox = 1
fastscores.ban = 1
fastscores.minflagrunmills = 3000
fastscores.good = {}
fastscores.good.dropped = 0
fastscores.good.takeflagmillis = 0
fastscores.evil = {}
fastscores.evil.dropped = 0
fastscores.evil.takeflagmillis = 0
fastscores.level = {}

function cheater.check_toofastscores(cn)
	if server.nl_clanserver == 1 then return end -- erspare den clanservern die false positives
	if server.player_team(cn) == "good" then
		if fastscores.good.takeflagmillis == nil then
			fastscores.good.takeflagmillis = 0
		end
		local flagrunmillis = server.gamemillis - fastscores.good.takeflagmillis
		messages.debug(cn, players.admins(), "CHEATER", string.format("Flagrun took %s ms", flagrunmillis))
		if flagrunmillis < fastscores.minflagrunmills and fastscores.good.dropped == 0 then
			fastscores.level[cn] = fastscores.level[cn] + 1
			if fastscores.level[cn] < fastscores.ban then
				if fastscores.level[cn] < fastscores.pbox then
					messages.warning(cn, players.admins(), "CHEATER", string.format("blue<%s (%i)> red<is scoring too fast. Flagrun took %i ms!>", server.player_displayname(cn), cn, flagrunmillis))
				else
					penaltybox.penalty(cn, cheater.pbox.time, "Scoring too fast")
					messages.error(cn, players.admins(), "CHEATER", string.format("blue<%s (%i)> red<got a penalty because of scoring too fast. Flagrun took %i ms!>", server.player_displayname(cn), cn, flagrunmillis))
				end
			else
				cheater.autokick(cn, "Server", "Scoring Too Fast")
				messages.error(cn, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of scoring too fast (flagrun took %i ms)!", server.player_displayname(cn), cn, flagrunmillis))
			end
		end
		fastscores.good.dropped = 0
	elseif server.player_team(cn) == "evil" then
		if fastscores.evil.takeflagmillis == nil then
			fastscores.evil.takeflagmillis = 0
		end
		local flagrunmillis = server.gamemillis - fastscores.evil.takeflagmillis
		messages.debug(cn, players.admins(), "CHEATER", string.format("Flagrun took %s ms", flagrunmillis))
		if flagrunmillis < fastscores.minflagrunmills and fastscores.evil.dropped == 0 then
			fastscores.level[cn] = fastscores.level[cn] + 1
			if fastscores.level[cn] < fastscores.ban then
				if fastscores.level[cn] < fastscores.pbox then
					messages.warning(cn, players.admins(), "CHEATER", string.format("blue<%s (%i)> red<is scoring too fast. Flagrun took %i ms!>", server.player_displayname(cn), cn, flagrunmillis))
				else
					penaltybox.penalty(cn, cheater.pbox.time, "Scoring too fast")
					messages.error(cn, players.admins(), "CHEATER", string.format("blue<%s (%i)> red<got a penalty because of scoring too fast. Flagrun took %i ms!>", server.player_displayname(cn), cn, flagrunmillis))
				end
			else
				cheater.autokick(cn, "Server", "Scoring Too Fast")
				messages.error(cn, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of scoring too fast (flagrun took %i ms)!", server.player_displayname(cn), cn, flagrunmillis))
			end
		end
		fastscores.evil.dropped = 0
	end
end

--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	fastscores.level[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	fastscores.level[cn] = 0
end)

server.event_handler("scoreflag", function(cn)
	cheater.check_toofastscores(cn)
end)

server.event_handler("takeflag", function(cn)
	if server.player_team(cn) == "good" then
		fastscores.good.takeflagmillis = server.gamemillis
	elseif server.player_team(cn) == "evil" then
		fastscores.evil.takeflagmillis = server.gamemillis
	end
end)

server.event_handler("dropflag", function(cn)
	if server.player_team(cn) == "good" then
		fastscores.good.dropped = 1
	elseif server.player_team(cn) == "evil" then
		fastscores.evil.dropped = 1
	end
end)

server.event_handler("resetflag", function(cn)
	if cn == nil then
		if fastscores.good.dropped == 1 and fastscores.evil.dropped == 0 then
			fastscores.good.dropped = 0
		else
			if fastscores.good.dropped == 0 and fastscores.evil.dropped == 1 then
				fastscores.evil.dropped = 0
			end
		end
	elseif utils.is_numeric(cn) then
		if server.player_team(tonumber(cn)) == "good" then
			fastscores.good.dropped = 0
		elseif server.player_team(tonumber(cn)) == "evil" then
			fastscores.evil.dropped = 0
		end
	else
		if cn == "good" then
			fastscores.evil.dropped = 0
		elseif cn == "evil" then
			fastscores.good.dropped = 0
		end
	end
end)

server.event_handler("mapchange", function()
	fastscores.good.dropped = 0
	fastscores.evil.dropped = 0
	-- NEW: @Hanack 23-apr-2011
	fastscores.good.takeflagmillis = 0
	fastscores.evil.takeflagmillis = 0
	-- NEW: @Hanack 19-mai-2011
	for _, cn in ipairs(players.all()) do
		fastscores.level[cn] = 0
	end
end)
