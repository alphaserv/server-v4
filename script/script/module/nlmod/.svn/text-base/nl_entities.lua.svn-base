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

entities = {}
entities.slot_min = 2000 -- first 2000 slots are reserved by maps
entities.slot_max = 8500 -- max slot number is 10000, but we leave some space for the maphack visualisation
entities.slots = {}
entities.dirty = {}
entities.update_interval = 50
entities.max_updates = 50
entities.types = {}
entities.types['light'] = 1
entities.types['mapmodel'] = 2
entities.types['playerstart'] = 3 
entities.types['envmap'] = 4
entities.types['particles'] = 5
entities.types['mapsound'] = 6
entities.types['spotlight'] = 7
entities.types['shells'] = 8
entities.types['bullets'] = 9
entities.types['rockets'] = 10
entities.types['rounds'] = 11
entities.types['grenades'] = 12
entities.types['cartridges'] = 13
entities.types['health'] = 14
entities.types['health boost'] = 15
entities.types['green armour'] = 16
entities.types['yellow armour'] = 17
entities.types['quad'] = 18
entities.types['teleport'] = 19
entities.types['teledest'] = 20
entities.types['monster'] = 21
entities.types['carrot'] = 22
entities.types['jumppad'] = 23
entities.types['base'] = 24
entities.types['respawnpoint'] = 25
entities.types['box'] = 26
entities.types['barrel'] = 27
entities.types['platform'] = 28
entities.types['elevator'] = 29
entities.types['flag'] = 30
entities.names = {
	'light',
	'mapmodel',
	'playerstart',
	'envmap',
	'particles',
	'mapsound',
	'spotlight',
	'shells',
	'bullets',
	'rockets',
	'rounds',
	'grenades',
	'cartridges',
	'health',
	'health boost',
	'green armour',
	'yellow armour',
	'quad',
	'teleport',
	'teledest',
	'monster',
	'carrot',
	'jumppad',
	'base',
	'respawnpoint',
	'box',
	'barrel',
	'platform',
	'elevator',
	'flag'
}


-- registers the next free slot
function entities.register()
	for slot = entities.slot_min, entities.slot_max, 1 do
		if entities.slots[slot] == nil then
			entities.slots[slot] = {}
			return slot
		end
	end
end

-- frees a slot
function entities.free(slot)
	entities.slots[slot] = nil
	server.send_entity(slot, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

-- sends an entity to all clients
function entities.refresh(slot)
	if slot == nil or entities.slots[slot] == nil then return end
	server.send_entity(
		slot,
		math.floor(entities.slots[slot]['pos'][1]), math.floor(entities.slots[slot]['pos'][2]),
		math.floor(entities.slots[slot]['pos'][3]),
		entities.slots[slot]['type'],
		math.floor(entities.slots[slot]['attrs'][1]), math.floor(entities.slots[slot]['attrs'][2]),
		math.floor(entities.slots[slot]['attrs'][3]), math.floor(entities.slots[slot]['attrs'][4]),
		math.floor(entities.slots[slot]['attrs'][5])
	)
	--[[
	messages.debug(-1, players.admins(), "ENTITIES", string.format(
		"refreshing slot %i: x:%i y:%i z:%i type:%i a1:%i a2:%i a3:%i a4:%i a5:%i ",
		slot,
		math.floor(entities.slots[slot]['pos'][1]), math.floor(entities.slots[slot]['pos'][2]),
		math.floor(entities.slots[slot]['pos'][3]),
		entities.slots[slot]['type'],
		math.floor(entities.slots[slot]['attrs'][1]), math.floor(entities.slots[slot]['attrs'][2]),
		math.floor(entities.slots[slot]['attrs'][3]), math.floor(entities.slots[slot]['attrs'][4]),
		math.floor(entities.slots[slot]['attrs'][5])
	))
	]]
end

-- sends an entity to all clients
-- Also, we have to ensure, that the values are int!
function entities.player_refresh(cn, slot)
	if entities.slots[slot] == nil then return end
	server.player_send_entity(
		cn,
		slot,
		math.floor(entities.slots[slot]['pos'][1]), math.floor(entities.slots[slot]['pos'][2]),
		math.floor(entities.slots[slot]['pos'][3]),
		entities.slots[slot]['type'],
		math.floor(entities.slots[slot]['attrs'][1]), math.floor(entities.slots[slot]['attrs'][2]),
		math.floor(entities.slots[slot]['attrs'][3]), math.floor(entities.slots[slot]['attrs'][4]),
		math.floor(entities.slots[slot]['attrs'][5])
	)
end

-- set slot values
function entities.set(slot, type, x, y, z, attr1, attr2, attr3, attr4, attr5)
	if entities.slots[slot] == nil then
		entities.slots[slot] = {}
	end
	entities.slots[slot]['type'] = type
	entities.slots[slot]['pos'] = { x, y, z }
	entities.slots[slot]['attrs'] = { attr1, attr2, attr3, attr4, attr5 }
	table.insert(entities.dirty, slot)
	-- messages.debug(-1, players.admins(), "ENTITIES", "set new values for entity " .. slot)
end

function entities.set_pos(slot, x, y, z)
	entities.slots[slot]['pos'] = { x, y, z }
	table.insert(entities.dirty, slot)
end

function entities.set_x(slot, x)
	entities.slots[slot]['pos'] = {
		x,
		entities.slots[slot]['pos'][2],
		entities.slots[slot]['pos'][3]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_y(slot, y)
	entities.slots[slot]['pos'] = {
		entities.slots[slot]['pos'][1],
		y,
		entities.slots[slot]['pos'][3]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_z(slot, z)
	entities.slots[slot]['pos'] = {
		entities.slots[slot]['pos'][1],
		entities.slots[slot]['pos'][2],
		z
	}
	table.insert(entities.dirty, slot)
end

function entities.get_pos(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['pos']
end

function entities.set_type(slot, type)
	entities.slots[slot]['type'] = type
	table.insert(entities.dirty, slot)
end

function entities.get_type(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['type']
end

function entities.set_attrs(slot, attr1, attr2, attr3, attr4, attr5)
	entities.slots[slot]['attrs'] = { attr1, attr2, attr3, attr4, attr5 }
	table.insert(entities.dirty, slot)
end

function entities.set_attr1(slot, attr1)
	entities.slots[slot]['attrs'] = {
		attr1,
		entities.slots[slot]['attrs'][2],
		entities.slots[slot]['attrs'][3],
		entities.slots[slot]['attrs'][4],
		entities.slots[slot]['attrs'][5]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_attr2(slot, attr2)
	entities.slots[slot]['attrs'] = {
		entities.slots[slot]['attrs'][1],
		attr2,
		entities.slots[slot]['attrs'][3],
		entities.slots[slot]['attrs'][4],
		entities.slots[slot]['attrs'][5]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_attr3(slot, attr3)
	entities.slots[slot]['attrs'] = {
		entities.slots[slot]['attrs'][1],
		entities.slots[slot]['attrs'][2],
		attr3,
		entities.slots[slot]['attrs'][4],
		entities.slots[slot]['attrs'][5]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_attr4(slot, attr4)
	entities.slots[slot]['attrs'] = {
		entities.slots[slot]['attrs'][1],
		entities.slots[slot]['attrs'][2],
		entities.slots[slot]['attrs'][3],
		attr4,
		entities.slots[slot]['attrs'][5]
	}
	table.insert(entities.dirty, slot)
end

function entities.set_attr5(slot, attr5)
	entities.slots[slot]['attrs'] = {
		entities.slots[slot]['attrs'][1],
		entities.slots[slot]['attrs'][2],
		entities.slots[slot]['attrs'][3],
		entities.slots[slot]['attrs'][4],
		attr5,
	}
	table.insert(entities.dirty, slot)
end

function entities.get_attrs(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs']
end

function entities.get_attr1(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs'][1]
end

function entities.get_attr2(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs'][2]
end

function entities.get_attr3(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs'][3]
end

function entities.get_attr4(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs'][4]
end

function entities.get_attr5(slot)
	if entities.slots[slot] == nil then return end
	return entities.slots[slot]['attrs'][5]
end

function entities.clear()
	-- to implement
	-- for i, slot in ipairs(entities.dirty) do
end

-- updates all dirty slots
function entities.update()
	for i, slot in ipairs(entities.dirty) do
		entities.refresh(slot)
	end
	entities.dirty = {}
end

-- updates all slots for a single player
-- This function is limiting to max_updates per update_interval
function entities.player_update(cn, start_index)
	local max_index = start_index + entities.max_updates - 1
	if max_index > entities.slot_max then
		max_index = entities.slot_max
	end
	for slot = start_index, max_index, 1 do
		entities.player_refresh(cn, slot)
	end
	if max_index < entities.slot_max then
		server.sleep(entities.update_interval, function()
			entities.player_update(cn, max_index + 1)
		end)
	end
end







--[[
		EVENTS
]]

server.interval(entities.update_interval, entities.update)

server.event_handler("mapchange", function()
	entities.slots = {}
	entities.dirty = {}
end)

server.event_handler("connect", function(cn)
	-- update for a single player only
	entities.player_update(cn, entities.slot_min)
end)

