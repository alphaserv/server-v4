--[[
	script/module/nl_mod/nl_particles.lua
	
	Author:			Hanack (Andreas Schaeffer)
	Created:		12-Mai-2012
	Last Modified:	12-Mai-2012
	License:		GPL3

	Funktionen:

]]



--[[
		API
]]

particles = {}
particles.enabled = 1
particles.types = {}
particles.types['lightning'] = 7
particles.slots = {}
particles.lightning = {}

function particles.clear()
	for i, slot in ipairs(particles.slots) do
		entities.free(slot)
	end
end

function particles.create(type, x, y, z, attr1, attr2, attr3, attr4)
	if particles.enabled ~= 1 then return end
	local slot = entities.register()
	entities.set(
		slot,
		entities.types['particles'],
		x, y, z,
		type,
		attr1,
		attr2,
		attr3,
		attr4
	)
	table.insert(particles.slots, slot)
	return slot
end

function particles.update_type(slot, type)
	entities.set_attr1(slot, type)
end

function particles.lightning.create(x, y, z, dir, length, color)
	return particles.create(particles.types['lightning'], x, y, z, dir, length, color, 0)
end

function particles.lightning.update(slot, x, y, z, dir, length, color)
	entities.set(slot, entities.types['particles'], x, y, z, particles.types['lightning'], dir, length, color, 0)
end

function particles.lightning.update_dir(slot, dir)
	entities.set_attr2(slot, dir)
end

function particles.lightning.update_length(slot, length)
	entities.set_attr3(slot, length)
end

function particles.lightning.update_color(slot, color)
	entities.set_attr4(slot, color)
end



--[[
		COMMANDS
]]

function server.playercmd_particles(cn, command, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#maphack <CMD> [<ARG>]"
	else
		if arg1 == nil then
			if command == "info" then
				messages.info(cn, {cn}, "PARTICLES", "particles.enabled = " .. particles.enabled)
			end
			if command == "clear" then
				particles.clear()
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "PARTICLES", "particles.enabled = " .. particles.enabled)
			end
		else
			if command == "enabled" then
				particles.enabled = tonumber(arg1)
				messages.info(cn, {cn}, "PARTICLES", "particles.enabled = " .. particles.enabled)
			end
			if command == "create" then
				if arg1 == "lightning" then
					slot = particles.lightning.create(arg2, arg3, arg4, arg5, arg6, arg7)
				end
			end
		end
	end

end



--[[
		EVENTS
]]

server.event_handler("mapchange", function()
	particles.slots = {}
end)





