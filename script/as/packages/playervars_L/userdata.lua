module("player.userdata", package.seeall)

local instances = {}

user_obj.load_userdata = function(self)
	for name, backend in pairs(self.storage_backends) do
		if not instances[name] then
			instances[name] = backend()
		end
		
		if instances[name].init then
			instances[name]:init(self)
		end
		
		instances[name]:load(cn)
	end
end

user_obj.get_userdata = function(self, name)
	for i, instance in pairs(instances) do
		if instance:exists(name) then
			return instance:get(name)
		end
	end
end

user_obj.set_userdata = function(self, name, value, instance_name)
	if not instance_name then
		for name, instance in pairs(instances) do
			if instance:exists(name) then
				instance_name = name
				break
			end
		end
	end
	
	if not instance_name or not instances[instance_name]:exists(name) then
		error("variable %(1)q does not exist!" % { name }, 1)
	end
	
	instances[instance_name]:set(name, value)
end

user_obj.new_userdata = function(self, backend, name, default_value)
	instances[backend]:new(name, default_value)
end
--[[
local init = user_obj.__init
user_obj.__init = function(self, ...)
	self:load_userdata()
	init(self, ...)
end
]]
