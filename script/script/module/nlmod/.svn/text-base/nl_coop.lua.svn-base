--[[
	script/module/nl_mod/nl_coop.lua
	Hanack (Andreas Schaeffer)
	Created: 10-Mai-2012
	Last Change: 10-Mai-2012
	License: GPL3

]]



--[[
		API
]]

coop = {}
coop.autosend = 1

function coop.autosendmap(cn)
	-- todo: check for mapcrc
	-- if coop.autosend == 1 and server.player_mapcrc() == -1 then
		server.send_fake_editmode(-1, cn, 1)
		server.sendmap(cn)
		server.send_fake_editmode(-1, cn, 0)
	-- end
end



--[[
		COMMANDS
]]

function server.playercmd_getmap(cn)
	coop.autosendmap(cn)
end

function server.playercmd_fetchmap(cn, ocn)
	if not hasaccess(cn, admin_access) then return end
	if ocn == nil then return end
	ocn = tonumber(ocn)
	messages.info(cn, players.admins(), "COOP", string.format("Server fetching map from blue<%s>", server.player_displayname(ocn)))
	server.fetchmap(ocn)
end

function server.playercmd_editmode(cn, ocn, val)
	if not hasaccess(cn, admin_access) then return end
	if ocn == nil then return end
	if val == nil then
		val = ocn
		ocn = cn
	end
	val = tonumber(val)
	ocn = tonumber(ocn)
	if val < 0 or val > 2 then return end
	if val == 2 then
		server.send_fake_editmode(-1, ocn, 0)
		server.send_editmode(-1, ocn, 1)
		messages.info(cn, players.admins(), "COOP", string.format("blue<%s> started editing", server.player_displayname(ocn)))
	end
	if val == 1 then
		server.send_editmode(-1, ocn, 0)
		server.send_fake_editmode(-1, ocn, 1)
		messages.info(cn, players.admins(), "COOP", string.format("blue<%s> started fake editing", server.player_displayname(ocn)))
	end
	if val == 0 then
		server.send_editmode(-1, ocn, 0)
		server.send_fake_editmode(-1, ocn, 0)
		messages.info(cn, players.admins(), "COOP", string.format("blue<%s> stopped editing", server.player_displayname(ocn)))
	end
end

function server.playercmd_editvar(cn, editvar, value)
	if not hasaccess(cn, admin_access) then return end
	if editvar == nil or value == nil then return end
	for i,ocn in ipairs(players.all()) do
		server.editvar(cn, editvar, value)
	end
end

function server.playercmd_sendmap(cn, ocn, map)
	if not hasaccess(cn, admin_access) then return end
	if ocn == nil then
		ocn = cn
	end
	ocn = tonumber(ocn)
	server.player_freeze(ocn)
	server.send_editmode(-1, ocn, 1)
	if map == nil then
		messages.info(cn, {cn, ocn}, "COOP", string.format("Sending current map to blue<%s>", server.player_displayname(ocn)))
		server.sendmap(ocn)
	else
		messages.info(cn, {cn, ocn}, "COOP", string.format("Sending map orange<%s> to blue<%s>", map, server.player_displayname(ocn)))
		map_file = string.format("packages/base/%s.ogz", map)
		server.sendmap_from_file(ocn, map_file)
	end
	server.send_editmode(-1, ocn, 0)
	messages.info(cn, {cn, ocn}, "COOP", string.format("Map sent to blue<%s>", server.player_displayname(ocn)))
	server.player_unfreeze(ocn)
	-- server.player_changemap(ocn, map, "coop edit")
end

function server.playercmd_sentity(cn, id, x, y, z, type, attr1, attr2, attr3, attr4, attr5)
	if not hasaccess(cn, admin_access) then return end
	type = tonumber(type)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	attr1 = tonumber(attr1)
	attr2 = tonumber(attr2)
	attr3 = tonumber(attr3)
	attr4 = tonumber(attr4)
	attr5 = tonumber(attr5)
	server.send_entity(id, x, y, z, type, attr1, attr2, attr3, attr4, attr5)
end

function server.playercmd_editf(cn, x, y, z)
	server.editf(x, y, z)
end

-- test of the server side flag hack?
function server.playercmd_facecamper(cn)
	if not hasaccess(cn, admin_access) then return end
	maprotation.change_map("face-capture", "insta ctf", true)
	server.send_entity(103, 2432, 2928, 2256, 30, 179, 1, 0, 0, 0)
	server.send_entity(104, 2432, 1808, 2256, 30, 1, 2, 0, 0, 0)
	server.sleep(200, function()
		server.send_entity(103, 2432, 2928, 2256, 30, 179, 1, 0, 0, 0)
		server.send_entity(104, 2432, 1808, 2256, 30, 1, 2, 0, 0, 0)
	end)
end



--[[
		EVENTS
]]

server.event_handler("connect", coop.autosendmap)

server.event_handler("editvari", function(cn, the_var, value)
	messages.debug(cn, players.admins(), "COOP", string.format("%s edited map var %s to value %i", server.player_displayname(cn), the_var, value))
end)

server.event_handler("editvarf", function(cn, the_var, value)
	messages.debug(cn, players.admins(), "COOP", string.format("%s edited map var %s to value %f", server.player_displayname(cn), the_var, value))
end)

server.event_handler("editvars", function(cn, the_var, value)
	messages.debug(cn, players.admins(), "COOP", string.format("%s edited map var %s to value %s", server.player_displayname(cn), the_var, value))
end)

server.event_handler("editentpos", function(cn, id, type, x, y, z)
	messages.debug(cn, players.admins(), "COOP", string.format("%s edited entity red<%i> type: orange<%i> pos: orange<x: %i y: %i z: %i>", server.player_displayname(cn), id, type, x, y, z))
end)

server.event_handler("editentattr", function(cn, id, attr1, attr2, attr3, attr4)
	messages.debug(cn, players.admins(), "COOP", string.format("%s edited entity red<%i> attrs: orange<%i %i %i %i ?>", server.player_displayname(cn), id, attr1, attr2, attr3, attr4))
end)
