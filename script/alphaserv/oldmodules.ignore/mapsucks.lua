mapsucks = {}
--        playercount     1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
mapsucks.needed_votes = { 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,10,10,10,10,11,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23,23,24,24,24,25,25 }

--module to use in messages
mapsucks.module = "mapsucks"
mapsucks.votes = { sucks = 0, loves = 0, change = ""}
mapsucks.map = ""
mapsucks.mode = ""
playervars.set_default("mapvoted", 0)

function mapsucks.reset()
	for i, cn in pairs(players.all()) do
		playervars.set(cn, "mapvoted", 0)
	end
	mapsucks.votes = { sucks = 0, loves = 0, change = ""}
	mapsucks.map = server.map
	mapsucks.mode = server.gamemode
end

server.event_handler("mapchange", mapsucks.reset)

--messages.info(module, to, msg, private)

function mapsucks.vote(cn, bool)
	if playervars.get(cn, "mapvoted") == 1 then
		messages.warning(mapsucks.module, {cn}, string.format(config.get("messages__already"), cn, "mapvoted"), true)
		return
	end
	playervars.set(cn, "mapvoted", 1)
	if bool then
		mapsucks.addvote("sucks")
	else
		mapsucks.addvote("loves")
	end
	
end
function mapsucks.addvote(vote)
	if mapsucks.map ~= server.map or mapsucks.mode ~= mapsucks.mode then
		mapsucks.reset()
	end
	if vote == "sucks" then
		--count as veto
		db.query('UPDATE `maps` SET `vetos` = `vetos` + 1 WHERE name = '..db.escape(mapsucks.map)..';')
	elseif vote=="loves" then
		db.query('UPDATE `maps` SET `novetos` = `novetos` + 1 WHERE name = '..db.escape(mapsucks.map)..';')
	else
		debug.write(1, "type: "..tostring(vote).." not recognised")
		return
	end
	mapsucks.votes[vote] = (mapsucks.votes[vote] or 0) + 1
	mapsucks.votes["change"] = vote
	mapsucks.checkvotes()
end
function mapsucks.checkvotes()
	local needed = mapsucks.needed_votes[#players.active()] + mapsucks.votes["loves"]
	if needed <= mapsucks.votes["sucks"] then
		--lower gametime
		return mapsucks.lowertime()
	else
		if mapsucks.votes["change"] == "sucks" then
			messages.info(mapsucks.module, players.all(), string.format(config.get("mapsucks:current"), "yellow<"..mapsucks.votes["sucks"]..">", needed), false)
		else
			messages.info(mapsucks.module, players.all(), string.format(config.get("mapsucks:current"), mapsucks.votes["sucks"], "yellow<"..needed..">"), false)
		end
	end
end

function mapsucks.lowertime()
	local lower_to = 12000
	if server.timeleft < 2 then
		--game is shorter than 1 min ingnore
		messages.debug(mapsucks.module, players.admins(), "time too short to lower gametime", true)
		return false
	else
		lower_to = 60000
	end
	server.changetime(lower_to)
	lower_to = lower_to/1000
	messages.info(mapsucks.module, players.all(), string.format(config.get("messages_mapsucks"), lower_to), true)
end

function mapsucks.sucks(cn)
	mapsucks.vote(cn, true)
end

function mapsucks.love(cn)
	mapsucks.vote(cn, false)
end

