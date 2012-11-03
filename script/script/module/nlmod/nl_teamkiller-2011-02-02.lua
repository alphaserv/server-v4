--[[
	script/module/nl_mod/nl_teamkiller.lua
	Hanack (Andreas Schaeffer)
	Created: 18-Nov-2010
	Last Change: 18-Nov-2010
	License: GPL3

	Funktion:
		TK

	API-Methoden:
		xyz.xyz()
			xxx....

	Commands:
		#xyz
			xyz...
]]



--[[
		API
]]

teamkiller = {}
teamkiller.limit = server.teamkill_limit or 5
teamkiller.flag_tks = {}



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	teamkiller.flag_tks[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	teamkiller.flag_tks[cn] = 0
end)

server.event_handler("intermission", function(cn)
	for _,cn in pairs(players.all()) do
		teamkiller.flag_tks[cn] = 0
	end
end)

server.event_handler("scoreflag", function(cn)
	if (server.gamemillis - teamkiller.flag_tks[cn]) < 3000 then
		messages.warning(-1, players.admins(), "TEAMKILLER", string.format("%s has teamkilled for a score (tk and score within %f seconds)", server.player_displayname(cn), ((server.gamemillis - teamkiller.flag_tks[cn]) / 1000) ))
		teamkiller.flag_tks[cn] = 0
	end
end)


server.event_handler("teamkill", function(cn, victim)
	server.sleep(10, function()
		local actor_teamkills = server.player_teamkills(cn)

		if actor_teamkills == 1 then
			messages.warning(-1, {cn}, "TEAMKILLER", "This server has a teamkill limit, therefore you must pay attention when you shoot in order to stay on the server!")
		end

		if changeteam.has_flag[victim] == 1 then
			messages.warning(-1, players.all(), "TEAMKILLER", string.format("%s has teamkilled the flagholder %s", server.player_displayname(cn), server.player_displayname(victim)))
			teamkiller.flag_tks[cn] = server.gamemillis
		else
			if actor_teamkills == teamkiller.limit-1 then
				messages.warning(-1, {cn}, "TEAMKILLER", string.format("%s, watch your shot, one more teamkill and you will be kicked immediately!", server.player_displayname(cn)))
				messages.warning(-1, players.except(players.all(), cn), "TEAMKILLER", string.format("%s did %i teamkills!", server.player_displayname(cn), actor_teamkills))
			else
				messages.warning(-1, players.all(), "TEAMKILLER", string.format("%s did %i teamkills!", server.player_displayname(cn), actor_teamkills))
			end
		end

		if actor_teamkills > teamkiller.limit or actor_teamkills == teamkiller.limit then
			server.kick(cn, cheater.ban.time, -1, "teamkilling")
		end
	end)
end)

server.interval(2000, function()

end)
