if not server.additional_veto_time then server.additional_veto_time = 5000 end
if not server.mapsucks_remaintime then server.mapsucks_remaintime = 1 end

server.default_gamemode = server.default_gamemode or "insta ctf"

maprotation = {}

if maprotation.allowed_modes == "" then maprotation.allowed_modes = nil end
maprotation.allowed_modes = maprotation.allowed_modes or {server.default_gamemode}

local votes = {}
local lastvotes = {}
local used_voted_map = false
local last_voted_map = false

local last_maps = {}
if not server.last_maps_list_len then server.last_maps_list_len = 4 end

maprotation_size_s = 8
maprotation_size_m = 16

signal_changingmap = server.create_event_signal("changingmap")

liveveto = {}
liveveto.vetos = -1
liveveto.text = "\f7MAP - VETOS/MAXVETOS vetos"
liveveto.maxmapnamelen = 9
liveveto.passed_text = "\f7MAP \f0passed"
liveveto.next_map = ""

maps = {}
maps["ctf"] = {
	"flagstone/L",
	"tempest/L",
	"capture_night/S",
	"reissen/M",
	"tejen/S",
	"shipwreck/L",
	"urban_c/L",
	"bt_falls/L",
	"l_ctf/M",
	"face-capture/S",
	"dust2/M",
	"mercury/M",
	"akroseum/M",
	"europium/L",
	"redemption/M",
	"damnation/M",
	"forge/M",
	"nitro/M",
	"core_refuge/L",
	"desecration/L",
	"core_transfer/L",
	"recovery/M",
}

maps["capture"] = {
	"urban_c/",
	"nevil_c/",
	"fb_capture/",
	"nmp9/",
	"c_valley/",
	"lostinspace/M",
	"fc3/",
	"face-capture/S",
	"nmp4/",
	"nmp8/",
	"hallo/M",
	"tempest/L",
	"monastery/",
	"ph-capture/L",
	"hades/",
	"fc4/",
	"relic/",
	"fc5/L",
	"abbey/",
	"venice/L",
	"paradigm/",
	"corruption/",
	"asteroids/",
	"ogrosupply/",
	"reissen/M",
	"akroseum/M",
	"duomo/",
	"frostbyte/",
	"c_egypt/",
	"caribbean/",
	"dust2/",
	"campo/",
	"killcore3/",
	"damnation/",
	"arabic/",
	"cwcastle/",
	"mercury/",
	"core_transfer/L",
	"forge/M",
	"tortuga/",
	"core_refuge/L",
	"infamy/",
	"tejen/",
	"capture_night/M",
	"river_c/L",
	"serenity/"
}

maps["ffa"] = {
	"complex/",
	"douze/",
	"ot/",
	"academy/",
	"metl2/",
	"metl3/",
	"justice/",
	"turbine/",
	"mbt2/",
	"fanatic_quake/",
	"dock/",
	"frozen/",
	"curvy_castle/",
	"duel8/",
	"nmp8/",
	"tartech/",
	"aard3c/",
	"industry/",
	"killfactory/",
	"pitch_black/",
	"alloy/",
	"ruine/",
	"mbt10/",
	"torment/",
	"duel7/",
	"oddworld/",
	"wake5/",
	"park/",
	"refuge/",
	"curvedm/",
	"kalking1/",
	"hog2/",
	"kffa/",
	"fragplaza/",
	"dune/",
	"pgdm/",
	"neondevastation/",
	"memento/",
	"neonpanic/",
	"shindou/",
	"sdm1/",
	"island/",
	"DM_BS1/",
	"shinmei1/",
	"osiris/",
	"injustice/",
	"akaritori/",
	"aqueducts/",
	"konkuri-to/",
	"moonlite/",
	"darkdeath/",
	"castle_trap/",
	"orion/",
	"katrez_d/",
	"thor/",
	"frostbyte/",
	"ogrosupply/",
	"ksauer1/",
	"kmap5/",
	"thetowers/",
	"guacamole/",
	"tejen/",
	"hades/",
	"orbe/",
	"paradigm/",
	"wdcd/",
	"stemple/",
	"corruption/",
	"lostinspace/",
	"shadowed/",
	"metl4/",
	"ruby/",
	"deathtek/"
}

maps["*"] = {
	"complex/S",
	"douze/S",
	"ot/S",
	"academy/S",
	"metl2/S",
	"metl3/S",
	"justice/S",
	"turbine/S",
	"mbt2/M",
	"fanatic_quake/M",
	"dock/S",
	"frozen/S",
	"curvy_castle/S",
	"duel8/M",
	"nmp8/L",
	"tartech/S",
	"aard3c/S",
	"industry/M",
	"killfactory/L",
	"pitch_black/M",
	"alloy/L",
	"ruine/M",
	"mbt10/M",
	"torment/S",
	"duel7/S",
	"oddworld/S",
	"wake5/M",
	"park/S",
	"refuge/S",
	"curvedm/M",
	"kalking1/S",
	"hog2/S",
	"kffa/S",
	"fragplaza/M",
	"dune/",
	"pgdm/M",
	"neondevastation/S",
	"memento/S",
	"neonpanic/S",
	"shindou/M",
	"sdm1/S",
	"island/M",
	"DM_BS1/M",
	"shinmei1/M",
	"osiris/L",
	"injustice/M",
	"akaritori/L",
	"aqueducts/L",
	"konkuri-to/L",
	"moonlite/M",
	"darkdeath/M",
	"castle_trap/M",
	"orion/M",
	"katrez_d/M",
	"thor/L",
	"frostbyte/L",
	"ogrosupply/L",
	"ksauer1/L",
	"kmap5/M",
	"thetowers/L",
	"guacamole/S",
	"tejen/M",
	"hades/M",
	"orbe/M",
	"paradigm/L",
	"wdcd/S",
	"stemple/M",
	"corruption/L",
	"lostinspace/M",
	"shadowed/M",
	"metl4/S",
	"ruby/L",
	"deathtek/L",
	"urban_c/L",
	"nevil_c/M",
	"fb_capture/L",
	"nmp9/",
	"c_valley/",
	"fc3/",
	"face-capture/S",
	"nmp4/",
	"hallo/L",
	"tempest/L",
	"monastery/",
	"ph-capture/",
	"fc4/",
	"relic/",
	"fc5/",
	"abbey/",
	"venice/L",
	"asteroids/",
	"reissen/M",
	"akroseum/M",
	"duomo/L",
	"c_egypt/",
	"caribbean/L",
	"dust2/M",
	"campo/M",
	"killcore3/L",
	"damnation/L",
	"arabic/",
	"cwcastle/",
	"mercury/",
	"core_transfer/L",
	"forge/M",
	"tortuga/",
	"core_refuge/",
	"infamy/",
	"capture_night/M",
	"river_c/L",
	"serenity/",
	"flagstone/L",
	"shipwreck/L",
	"authentic/M",
	"urban_c/L",
	"bt_falls/",
	"l_ctf/M",
	"valhalla/L",
	"mbt1/",
	"mach2/",
	"berlin_wall/L",
	"europium/L",
	"redemption/L",
	"nitro/M",
	"desecration/L",
	"sacrifice/L",
	"recovery/M",
}

local last_map = ""
local next_map = ""
local next_mode = ""

local state_intermission = false
local vetos = 0
local vetoed = {}
local forceveto = false
local mapsucks_voted = {}

local votes = {}

local function minvotes(div)
	local players = (server.playercount - server.speccount)
	local playermin = players
	if playermin < 1 then playermin = 1 end
	local minplayers = players / div
	if players < (div/2) then
		return playermin
	elseif players < div then
		return (playermin/2) + 1
	else
		return players/div
	end
end

local function get_needed_mode(mode)
	if string.find(mode, "ctf") or string.find(mode, "protect") then return "ctf"
	elseif string.find(mode, "hold") or string.find(mode, "capture") then return "capture"
	elseif string.find(mode, "teamplay") or string.find(mode, "ffa") then return "ffa"
	elseif string.find(mode, "insta") then return "instagib"
	elseif string.find(mode, "effic") or string.find(mode, "tactics") then return "*"
	else return "ffa" end
end

local function isnewmap(map)
	if not map then return false end
	for _, map_ in pairs(last_maps) do
		if map_ == map then return false end
	end
	return true
end

server.maprotation_isnewmap = isnewmap
	
local function appendmap(map_)
	if not map_ then return end
	last_maps_ = {}
	last_maps_[1] = map_
	for i, map in pairs(last_maps) do
		if (i+1) > server.last_maps_list_len then break end
		last_maps_[i+1] = map
	end
	last_maps = last_maps_
end
	
server.maprotation_appendmap = appendmap

local function most_voted_map()
	if not votes then return end
	local mapvotes = {}
	for cn, map in pairs(votes) do
		if cn == 1337 then return map, -1 end
		if not mapvotes[map] then mapvotes[map] = 0 end
		mapvotes[map] = mapvotes[map] + 1
	end
	local most_votes = 0
	local most_map = false
	for map, votes_ in pairs(mapvotes) do
		if votes_ > most_votes then
			most_votes = votes_
			most_map = map
		end
	end
	return most_map, most_votes
end

local function get_voted_map(noappend)
	local most_map, most_votes = most_voted_map()
	if (not most_map) or (not most_votes) then return end
	if (most_votes >= minvotes(4)) or (most_votes == -1) then
		if not noappend then appendmap(most_map) end
		return most_map
	end
	return
end

local function most_voted_mode()
	if not votes then return end
	local modevotes = {}
	for cn, mode in pairs(votes) do
		if cn == 1337 then return mode, -1 end
		if not modevotes[mode] then modevotes[mode] = 0 end
		modevotes[mode] = modevotes[mode] + 1
	end
	local most_votes = 0
	local most_mode = false
	for mode, votes_ in pairs(modevotes) do
		if votes_ > most_votes then
			most_votes = votes_
			most_mode = mode
		end
	end
	return most_mode, most_votes
end

local function get_voted_mode(noappend)
	local most_mode, most_votes = most_voted_mode()
	if (not most_mode) or (not most_votes) then return end
	if (most_votes >= minvotes(4)) or (most_votes == -1) then
		if not noappend then appendmap(most_map) end
		return most_mode
	end
	return
end

local function resetvotes()
	votes = {}
end

local function setupgame(now, mode, vetoed)
	next_map = false
	next_mode = false
	if not used_voted_map then
		next_map = get_voted_map()
		next_mode = mode or get_voted_mode()
		resetvotes()
		used_voted_map = true
	end
	local randinfo
	if not next_map then
		randinfo = get_random_map()
		next_map = randinfo.map
	end
	next_mode = next_mode or get_random_mode()
	if not is_valid_map(next_map, next_mode, true) then
		if randinfo then
			next_mode = randinfo.mode
		else
			randinfo = get_random_map()
			next_map = randinfo.map
			next_mode = randinfo.mode
		end
	end		
	if server.display_next_map and (not now) then
		if vetoed then
			local msg = getmsg("got {1} vetos, map canceled, next suggested map is {2} ({3}), type {4} to vote against it!", vetos, next_map, next_mode, "#veto")
			server.msg(msg)
			server.sleep(10000, check_vetos)
		elseif forceveto then
			server.msg(getmsg("map veto was forced, next suggested map is {2} ({3}), type {4} to vote against it!", vetos, next_map, next_mode, "#veto"))
			server.sleep(10000, check_vetos)
			forceveto = false
		else
			state_intermission = true
			vetos = 0
			local msg = getmsg("next map is {1} ({2}) so far, type {3} to vote against it!", next_map, next_mode, "#veto")
			server.sleep(1000, function() server.msg(msg) end)
			server.sleep(1000, function() -- wait one sec so other event-functions of intermission can set the intermission time first.
				server.intermission = server.intermission + server.additional_veto_time
				server.sleep(server.intermission - server.gamemillis - 2000, check_vetos)
			end)
			liveveto.check()
		end
	elseif now then
		server.changemap(next_map, next_mode)
	end
end

function check_vetos()
	local livevetocheck = false
	local livevetocheckpassed = false
	if server.timeleft <= 0 then
		vetos = vetos or 0
		if vetos >= minvotes(4) then
			server.intermission = server.intermission + 10000
			setupgame(nil, nil, true)
			state_intermission = true
			livevetocheck = true
		elseif forceveto then
			server.intermission = server.intermission + 10000
			setupgame()
			state_intermission = true
			livevetocheck = true
		else
			server.msg(getmsg("map passed ({1} vetos)", vetos))
			state_intermission = false
			livevetocheck = true
			livevetocheckpassed = true
		end
	else
		state_intermission = false
		livevetocheck = true
	end
	vetos = 0
	vetoed = {}
	if livevetocheck then liveveto.check(livevetocheckpassed) end
end

function is_valid_map(reqmap, mode, cmd)
	if server.no_invalid_maps and (not cmd) then return true end
	if not maps[mode] then
		if server.parse_mode(mode) and maps[server.parse_mode(mode)] then
			mode = server.parse_mode(mode)
		elseif get_needed_mode(mode) and maps[get_needed_mode(mode)] then
			mode = get_needed_mode(mode)
		elseif get_needed_mode(server.parse_mode(mode)) and maps[get_needed_mode(server.parse_mode(mode))] then
			mode = get_needed_mode(server.parse_mode(mode))
		else
			mode = "*"
		end
	end
	for _, map_ in ipairs(maps[mode]) do
		local map = string.match(map_, "(%S+)/.*") or map_
		if map == reqmap then return true end
	end
	return false
end

function is_valid_mode(reqmode)
	reqmode = server.parse_mode(reqmode)
	for _, mode in pairs(maprotation.allowed_modes) do
		if reqmode == server.parse_mode(mode) then return true end
	end
	return false
end

local function getsize(req_map)
	for _, map_ in ipairs(maps["*"]) do
		if string.find(map_, "/") then
			map, size = string.match(map_, "(%S+)/(%S*)")
		else
			map = map_
			size = ""
		end
		if map == req_map then return size end
	end
	return ""
end

local function sizenumber(size)
	if size == "S" then return 1
	elseif size == "M" then return 2
	elseif size == "L" then return 3
	else return -1 end
end

local function sizematching(size, wanted_size)
	diff = sizenumber(wanted_size) - sizenumber(size)
	if diff >= 2 then return false
	else return (sizenumber(size) <= (sizenumber(wanted_size) + 1)) end
end

local function len(table)
	local i = 0
	for _, _ in pairs(table) do i = i + 1 end
	return i
end

function get_random_map(mode, players)
	players = players or (server.playercount - server.speccount) or -1
	--mode = mode or server.gamemode or server.default_gamemode or "ffa"
	local modes
	if mode then
		modes = { mode }
	else
		modes = maprotation.allowed_modes
	end

	-- getting wanted size
	local wanted_size
	if players == "-1" then wanted_size = "*"
	elseif players <= maprotation_size_s then wanted_size = "S"
	elseif players >= maprotation_size_s and players <= maprotation_size_m then wanted_size = "M"
	else wanted_size = "L" end

	--[[
	-- getting needed mode
	if maps[mode] == nil then
		if server.parse_mode(mode) and maps[server.parse_mode(mode)] then
			mode = server.parse_mode(mode)
		elseif get_needed_mode(mode) and maps[get_needed_mode(mode)] then
			mode = get_needed_mode(mode)
		elseif get_needed_mode(server.parse_mode(mode)) and maps[get_needed_mode(server.parse_mode(mode))] then
			mode = get_needed_mode(server.parse_mode(mode))
		else
			mode = "*"
		end
	end
	]]

	-- preparing matching maps
	local matching_maps = {}
	local i = 0
	local modecnt = 0
	for _, mode in pairs(modes) do
		local a = 1
		if not matching_maps[mode] then matching_maps[mode] = {}; a = 1 end
		for __, map in ipairs(maps[get_needed_mode(mode)]) do
			local size
			if string.find(map, "/") then
				map, size = string.match(map, "(%S+)/(%S*)")
				if size == "" then size = getsize(map) end
				if size == "" then size = "*" end
			else size = "*" end
			if sizematching(size, wanted_size) or wanted_size == "*" or size == "*" then matching_maps[mode][a] = {map=map, mode=mode}; a = a + 1; i = i + 1 end
		end
		modecnt = modecnt + 1
	end
	
	local next_map = "reissen"
	local next_mode = "insta ctf"
	local mode
	
	if i > 0 then
		next_map = last_map[(#last_map - 1)]
		local mode = modes[math.random(len(matching_maps))]
		local count = 0
		while (not isnewmap(next_map)) and count <= 50 do
			local rand_index = math.random(#matching_maps[mode])
			next_map = matching_maps[mode][rand_index].map
			next_mode = matching_maps[mode][rand_index].mode
			count = count + 1
		end
		appendmap(next_map)
		return {map = next_map, mode = next_mode}
	else
		appendmap("reissen")
		return {map = "reissen", mode = server.default_gamemode}
	end
end

function get_random_mode()
	local gm = maprotation.allowed_modes
	return maprotation.allowed_modes[math.random( #gm )]
end

function server.playercmd_veto(cn)
	if server.player_status(cn) == "spectator" then
		server.player_msg(cn, cmderr("spectators can not vote"))
		return
	end
	if state_intermission then
		if not vetoed[cn] then
			vetos = vetos + 1
			vetoed[cn] = true
			server.player_msg(cn, getmsg("your vote was accepted, we have {1} vetos already", vetos))
			liveveto.check()
		else
			server.player_msg(cn, cmderr("you voted already"))
		end
	else
		server.playercmd_mapsucks(cn)
	end
end

function server.playercmd_forceveto(cn)
	if not hasaccess(cn, forceveto_access) then return end
	forceveto = true
	server.player_msg(cn, getmsg("forced map veto"))
end

function server.playercmd_mapsucks(cn)
	if state_intermission then server.playercmd_veto(cn); return end
	if server.player_status(cn) == "spectator" then
		server.player_msg(cn, cmderr("spectators can not vote"))
		return
	end
	count = 0
	for _, has in pairs(mapsucks_voted) do
		if has then count = count + 1 end
	end
	if (server.timeleft * 60 * 1000) < ((server.mapsucks_remaintime * 60 * 1000) + 1) then server.player_msg(cn, cmderr("maptime too low already")); return end
	if not mapsucks_voted[cn] then
		mapsucks_voted[cn] = true
		count = count + 1
		if count >= minvotes(3) then
			server.changetime(server.mapsucks_remaintime * 60 * 1000)
			server.msg(getmsg("{1} thinks that this map would suck, got {2} mapsucks-votes now, remaintime lowered to {3} seconds!", server.player_displayname(cn), count, (server.mapsucks_remaintime * 60)))
			mapsucks_voted = {}
		else
			server.msg(getmsg("{1} thinks that this map would suck, use {2} to agree! (got {3} of {4} needed votes)", server.player_displayname(cn), "#mapsucks", count, minvotes(3)))
		end
	else
		server.player_msg(cn, getmsg("got {1} of {2} needed votes {3}", count, minvotes(3), "(you voted already)"))
	end
end

local function addmapvote(cn, map, mode, votemode)
	if (not map) and (not mode) then return end
	map = map or false
	mode = server.parse_mode(mode) or server.gamemode
	if server.player_status(cn) == "spectator" then
		server.player_msg(cn, cmderr("spectators can not vote"))
		return
	end
	if is_valid_map(map, mode) and is_valid_mode(mode) then
		if not lastvotes[cn] then lastvotes[cn] = server.uptime - 10000 end
		if lastvotes[cn] + 10000 <= server.uptime then
			votes[cn] = {map = map, mode = mode}
			if votemode == "agree" then
				if (map) and (not mode) then
					server.msg(getmsg("{1} agreed to map {2}, use {3} to agree or {4} to vote", server.player_displayname(cn), map, "#agree", "#vote <map>"))
				elseif (not map) and (mode) then
					server.msg(getmsg("{1} agreed to mode {2}, use {3} to agree or {4} to vote", server.player_displayname(cn), mode, "#agree", "#vote <map>"))
				else
					server.msg(getmsg("{1} agreed to map {2} ({3}), use {4} to agree or {5} to vote", server.player_displayname(cn), map, mode, "#agree", "#vote <map>"))
				end
			else
				if (map) and (not mode) then
					server.msg(getmsg("{1} suggests map {2}, use {3} to agree or {4} to vote", server.player_displayname(cn), map, "#agree", "#vote <map>"))
				elseif (not map) and (mode) then
					server.msg(getmsg("{1} suggests mode {2}, use {3} to agree or {4} to vote", server.player_displayname(cn), mode, "#agree", "#vote <map>"))
				else
					server.msg(getmsg("{1} suggests map {2} ({3}), use {4} to agree or {5} to vote", server.player_displayname(cn), map, mode, "#agree", "#vote <map>"))
				end
			end
			last_voted_map = map or last_voted_map
			last_voted_mode = mode or last_voted_mode
		else
			server.player_msg(cn, cmderr("voting too fast"))
		end
		lastvotes[cn] = server.uptime
	else
		server.player_msg(cn, cmderr("invalid map / mode"))
	end
end

function server.playercmd_vote(cn, map, mode)
	if cn == "HELP" then return "#vote <map>", "vote for a map, like using /map <map>" end
	if map == "*" then map = nil end
	if mode == "*" then mode = nil end
	if (not map) and (not mode) then
		if last_voted_map then
			addmapvote(cn, last_voted_map, last_voted_mode, "agree")
		else
			server.player_msg(cn, cmderr("missing map"))
		end
	else
		addmapvote(cn, map, mode)
	end
end

function server.playercmd_forcevote(cn, map, mode)
	if not hasaccess(cn, forceveto_access) then return end
	mode = mode or false
	map = map or false
	if (not map) and (not mode) then
		server.player_msg(cn, cmderr("missing map / mode"))
	else
		votes[1337] = {map = map, mode = mode} -- cn 1337 is 'force-cn' (see most_voted_map)
		server.player_msg(cn, getmsg("force voted for map {1} ({2})", map or "*", mode or "*"))
	end
end

function server.playercmd_agree(cn)
	if cn == "HELP" then return "#agree", "vote for the last map voted for" end
	if last_voted_map or last_voted_map then
		addmapvote(cn, last_voted_map, last_voted_mode, "agree")
	else
		server.player_msg(cn, badmsg("nobody voted yet, please use {1}", "#vote"))
	end
end

function maprotation.next_map()
	local most_map, most_votes = most_voted_map()
	if most_votes and most_map and most_votes == -1 then
		return most_map, most_votes
	elseif voted_map then
		return get_voted_map(true), 0
	elseif most_map and most_votes then
		return most_map, most_votes
	else
		return
	end
end

function liveveto.check(passed)
	if not server.use_liveveto then return end
	local maxvetos_part = tostring(minvotes(4))
	if maxvetos_part == "0" then maxvetos_part = "1" end
	if state_intermission and (liveveto.vetos ~= vetos or liveveto.next_map ~= next_map) then
		local mapname = next_map
		if string.len(next_map) >= liveveto.maxmapnamelen then
			mapname = string.sub(mapname, 1, (liveveto.maxmapnamelen - 2)) .. ".."
		end
		desc.sendall(
			string.gsub(
				string.gsub(
					string.gsub(
						liveveto.text, "MAP", mapname
					), "MAXVETOS", maxvetos_part
				), "VETOS", tostring(vetos)
			)
		)
		liveveto.vetos = vetos
	elseif passed then
		local mapname = next_map
		if string.len(next_map) >= liveveto.maxmapnamelen then
			mapname = string.sub(mapname, 1, (liveveto.maxmapnamelen - 2)) .. ".."
		end
		desc.sendall(
			string.gsub(
				string.gsub(
					string.gsub(
						liveveto.passed_text, "MAP", mapname
					), "MAXVETOS", maxvetos_part
				), "VETOS", tostring(vetos)
			)
		)
	elseif not state_intermission then
		liveveto.reset()
	end
end

function liveveto.reset()
	liveveto.vetos = -1
	desc.sendall(server.servername)
end

server.event_handler("intermission", function()
	setupgame()
end)

server.event_handler("setnextgame", function()
	if next_map and next_mode then
		signal_changingmap(next_map, next_mode)
		server.changemap(next_map, next_mode)
	else
		local randinfo =  get_random_map()
		signal_changingmap(randinfo.map, randinfo.mode)
		server.changemap(randinfo.map, randinfo.mode)
	end
end)

server.event_handler("mapchange", function(map)
	state_intermission = false
	vetos = 0
	vetoed = {}
	next_map = ""
	used_voted_map = false
	mapsucks_voted = {}
	if server.standard_gametime then
		server.changetime(server.standard_gametime * 60 * 1000)
	end
end)

server.event_handler("disconnect", function(cn)
	if server.is_bot(cn) then return end
	if not server.isvisible(cn) then return end
	vetoed[cn] = nil
	mapsucks_voted[cn] = nil
	votes[cn] = nil
	lastvotes[cn] = nil
	if server.playercount + server.speccount <= 0 then
		setupgame(true, server.default_gamemode)
		server.pausegame(true)
	end
end)

server.event_handler("allowedconnect", function(cn, name, ip)
	if server.is_bot(cn) then return end
	if not server.isvisible then return end
	if server.playercount + server.speccount <= 1 then
		server.pausegame(false)
	end
	votes[cn] = nil
	lastvotes[cn] = nil
end)

server.event_handler("started", function()
	if server.uptime > 1 then return end -- don't exec if the server was reloaded!
	setupgame(true, server.default_gamemode)
end)

local function checktext(cn, text)
	if string.match(text, "^#.*") then return end
	if string.match(text, "^!mapsucks.*") then return end
	if (string.find(text, "map") and (string.find(text, "suck") or string.find(text, "shit") or string.find(text, "crap") or string.find(text, "stupid") or string.find(text, "fuck") or string.find(text, "scheiss") or string.find(text, "weird"))) then
		if (server.timeleft * 60 * 1000) >= ((server.mapsucks_remaintime * 60 * 1000) + 1) then server.sleep(10, function() server.msg(getmsg("you don't like the map? type {1}!", "#mapsucks")) end) end
		if not server.player_pvar(cn, "sent_mapsucks_notice") then
			server.send_fake_text(cn, cn, " [ INFO (only you can see this message) ] you dont like the map? type #mapsucks!")
			server.player_pvar(cn, "sent_mapsucks_notice", true)
		end
	end
end

server.event_handler("text", checktext)
server.event_handler("sayteam", checktext)

server.event_handler("mapvote", function(cn, map, mode)
	addmapvote(cn, map)
	return -1
end)

