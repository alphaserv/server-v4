--[[
	script/module/nl_mod/nl_entities.lua
	
	Author:			Hanack (Andreas Schaeffer)
	Created:		12-Mai-2012
	Last Modified:	12-Mai-2012
	License:		GPL3

	Funktionen:
		Framework für Entities.
		Es gibt Slots für jedes Entitiy.
		Das Framework speichert alle Werte.

]]



--[[
		API
]]

serverstartgame = {}
serverstartgame.ended = 0
serverstartgame.startmapdelay = 100
serverstartgame.initdelay = 500
serverstartgame.pickups = {}
serverstartgame.x_base = 212
serverstartgame.x_mul = 600
serverstartgame.x_push = 30
serverstartgame.y_base = 212
serverstartgame.y_mul = 600
serverstartgame.y_push = 30
serverstartgame.z_base = 512
serverstartgame.z_mul = 80
serverstartgame.z_push = 40
serverstartgame.z_spawn = 680

function serverstartgame.init()
	-- init spawn points
	for i = 1, 20, 1 do
		local id = entities.register()
		local x_pos = serverstartgame.x_base + math.floor(math.random() * serverstartgame.x_mul)
		local y_pos = serverstartgame.y_base + math.floor(math.random() * serverstartgame.y_mul)
		entities.set(id, entities.types['playerstart'], x_pos, y_pos, serverstartgame.z_spawn, 0, 0, 0, 0, 0)
	end
	-- init jumppads
	for i = 1, 40, 1 do
		local id = entities.register()
		local x_pos = serverstartgame.x_base + math.floor(math.random() * serverstartgame.x_mul)
		local y_pos = serverstartgame.y_base + math.floor(math.random() * serverstartgame.y_mul)
		local x_push = math.floor(math.random() * serverstartgame.x_push) - (serverstartgame.x_push / 2)
		local y_push = math.floor(math.random() * serverstartgame.y_push) - (serverstartgame.y_push / 2)
		local z_push = math.floor(math.random() * serverstartgame.z_push)
		entities.set(id, entities.types['jumppad'], x_pos, y_pos, serverstartgame.z_base, z_push, y_push, x_push, 0, 0)
		local id2 = entities.register()
		entities.set(id2, entities.types['mapmodel'], x_pos, y_pos, serverstartgame.z_base, 0, 13, 0, 0, 0)
	end
	-- init pickup entities
	for i = 1, 300, 1 do
		local id = entities.register()
		local ent_type = math.floor(math.random() * 10) + entities.types['shells']
		local x_pos = serverstartgame.x_base + math.floor(math.random() * serverstartgame.x_mul)
		local y_pos = serverstartgame.y_base + math.floor(math.random() * serverstartgame.y_mul)
		local z_pos = serverstartgame.z_base + math.floor(math.random() * serverstartgame.z_mul)
		entities.set(id, ent_type, x_pos, y_pos, z_pos, 0, 0, 0, 0, 0)
	end
end

function serverstartgame.finish()
	serverstartgame.ended = 1
	local winner_cn = -1
	local winner_pickups = 0
	for i,cn in ipairs(players.all()) do
		if serverstartgame.pickups[cn] > winner_pickups then
			winner_cn = cn
			winner_pickups = serverstartgame.pickups[cn]
		end 
	end
	if winner_cn >= 0 then
		for i,cn in ipairs(players.all()) do
			server.send_fake_text(cn, winner_cn, string.format("  >>>>> WINS (%i pickup items collected)", winner_pickups))
		end
	end
end

function serverstartgame.pickup(cn, i, type)
	if serverstartgame.ended == 1 then return end
	type = tonumber(type)
	if type >= entities.types['shells'] and type <= entities.types['quad'] then
		if serverstartgame.pickups[cn] == nil then
			serverstartgame.pickups[cn] = 1
		else
			serverstartgame.pickups[cn] = serverstartgame.pickups[cn] + 1
		end
		server.send_fake_text(cn, cn, string.format(" [ %i ]", serverstartgame.pickups[cn]))
	end
end


--[[
		EVENTS
]]

server.event_handler("pickup", serverstartgame.pickup)

server.event_handler("started", function()
	local random_map_name = ""
	for i = 1, 10, 1 do
		random_map_name = random_map_name .. tostring(math.floor(math.random()*10))
	end
	server.sleep(serverstartgame.startmapdelay, function()
		server.changemap(random_map_name, "ffa")
	end)
	server.sleep(serverstartgame.initdelay, serverstartgame.init)
	server.sleep((maprotation.intermission_startdelay) * 1000, serverstartgame.finish)
end)
