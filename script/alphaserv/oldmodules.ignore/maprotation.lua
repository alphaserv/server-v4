--[[
an verry simple maprotation
]]

--######################--
--####     VARS     ####--
--######################--
maprotation = {}
maprotation.intermissionmodes = {}
maprotation.intermissionmode = 5 --mode on intermission
maprotation.intermissionmode_DEFAULT = 0
maprotation.intermissionmode_FAST = 1
maprotation.intermissionmode_SLOW = 2
maprotation.intermissionmode_VETO = 3
maprotation.intermissionmode_MAPBATTLE = 4
maprotation.intermissionmode_AUTO_MAPBATTLE = 5
maprotation.intermissionmode_RANDOM = 6
maprotation.intermissionmode_DO_NOTHING = 999
maprotation.mapcode = 1
maprotation.reduce_maps = true
maprotation.intermission = false
maprotation.intermission_delay = 0
maprotation.intermission_max_delay = 10

--######################--
--####  FUNCTIONS   ####--
--######################--
maprotation.intermissionmodes[maprotation.intermissionmode_DEFAULT] = function (map1, map2, gamemode) 
	if not maprotation.intermission then return end
	messages.info("mapriotation", players.all(), string.format(config.get("maprotation:next_map"),messages.escape(map1), 4), false)
	server.sleep(4000, function()
		server.changemap(map1, gamemode)
	end)
end
maprotation.intermissionmodes[maprotation.intermissionmode_FAST] = function (map1, map2, gamemode)
	if not maprotation.intermission then return end
	messages.info("mapriotation", players.all(), string.format(config.get("maprotation:next_map"),messages.escape(map1), 2), false)
	server.sleep(2000, function()
		server.changemap(map1, gamemode)
	end)
end
maprotation.intermissionmodes[maprotation.intermissionmode_SLOW] = function (map1, map2, gamemode)
	if not maprotation.intermission then return end
	messages.info("mapriotation", players.all(), string.format(config.get("maprotation:next_map"),messages.escape(map1), 8), false)
	server.sleep(8000, function()
		server.changemap(map1, gamemode)
	end)
end
maprotation.intermissionmodes[maprotation.intermissionmode_DO_NOTHING] = function (map1, map2, gamemode) end
maprotation.intermissionmodes[maprotation.intermissionmode_RANDOM] = function (map1, map2, gamemode)
	messages.info("mapriotation", players.all(), string.format(config.get("maprotation:next_map"), "an random map", 4), false)
	server.sleep(4000, function()
		--get an working mode also on fatal errors
		if mode == nil then mode = server.gamemode or "ffa" end
		--load the mapvar
    		local mapvar = maps[mode.." reduced"] or maps[mode]
		--if not reduced
		if not maprotation.reduce_maps then
			mapvar = maps[mode]
		end
		server.changemap(mapvar[math.random(#mapvar)], gamemode)
	end)
end

function maprotation.delay_intermission(i)
	if not maprotation.intermission then return end
	if not i then i = 0 end
	debug.write(-1, "delaying intermission")
	if i < 40 then
		server.sleep(500, function()
			i = i + 1
			maprotation.delay_intermission(i)
		end)
	else
		if not maprotation.intermission then return end
		messages.info("mapriotation", players.all(), config.get("maprotation:long_intermission"), false)
		maprotation.mapcode = maprotation.mapcode + 1
		maprotation.intermissionmodes[maprotation.intermissionmode_DEFAULT](maprotation.getnextmap(1), maprotation.getnextmap(2), server.gamemode)
		return
	end
--	server.intermission = server.intermission + 1000 -- this is not working yet :( ):

end

function maprotation.getnextmap(num, mode)
	--get an working mode also on fatal errors
    if mode == nil then mode = server.gamemode or "ffa" end
	--load the mapvar
    local mapvar = maps[mode.." reduced"] or maps[mode]
	--if not reduced
    if not maprotation.reduce_maps then
        mapvar = maps[mode]
    end
	--how many maps are availible
    local countmaps = #mapvar or 0
	--are we playing on the last map? then go to first map
    if maprotation.mapcode == countmaps then maprotation.mapcode = 0 end
	--get this map + num
    local nextmap = mapvar[maprotation.mapcode+num]
	--return the var
    return nextmap or "reissen" --on fatal errors still get an working map
end

--what to do on intermission
function maprotation.intermission()
	--intermission is running
	maprotation.intermission = true
	if #players.all() > 0 then
		maprotation.delay_intermission(0)
		server.sleep(1000, function()
			alpha.pause(-1)
			local map1 = maprotation.getnextmap(1) --next map after this
			local map2 = maprotation.getnextmap(2) --map after the next map
			local intermissionmode = maprotation.intermissionmode
			if not intermissionmode then intermissionmode = maprotation.intermissionmode_DEFAULT end --get the intermissionmode
			local func = maprotation.intermissionmodes[intermissionmode]
			if not func then func = maprotation.intermissionmodes[maprotation.intermissionmode_DEFAULT] end
			func(map1, map2, server.gamemode) --execute the intermission mode
			--set the last played map to the next one
			maprotation.mapcode = maprotation.mapcode + 1

		end)
	else
		alpha.pause(-1)
	end
end

function maprotation.mapchange()
	--intermisssion ended
	maprotation.intermission = false
end

function maprotation.setintermissionmode(name, num)
	if num then
		maprotation.intermissionmode = tonumber(num)
	else
		maprotation.intermissionmode = maprotation["intermissionmode_"..string.upper(tostring(name))] or maprotation.intermissionmode_DEFAULT
	end
end


function maprotation.connect()
	server.sleep(1000, function()
		if #players.all() < 2 then
			if not string.find(server.gamemode, "coop") then
				server.changemap(server.map, server.gamemode)
			end
		end
	end)
end
--######################--
--####    EVENTS    ####--
--######################--
server.event_handler("intermission", maprotation.intermission)
server.event_handler("connect", maprotation.connect)
server.event_handler("mapchange", maprotation.mapchange)

local function onempty()
	local mode = config.get("maprotation:empty_default_mode")
	local map = config.get("maprotation:empty_default_map")
	if (mode == "") and (map == "") then
		return -- nothing to change
	end
	if (mode == "") then
		mode = server.gamemode
	end
	if (map == "") then
		map = server.map
	end
	server.changemap(map, mode)
end
server.sleep(1000, onempty)
server.event_handler("alpha:empty", onempty)

