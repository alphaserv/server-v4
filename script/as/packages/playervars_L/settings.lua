module("player.settings", package.seeall)

--extend the player object:
user_obj.settings = {}
--[[user_obj.load_defaults = function(self)
	local result = alpha.db:query("SELECT module, name, data FROM user_data WHERE user_id = -1 AND module <> \"WEB\";"):fetch()
	
	self:load_settings(result)
end]]

user_obj.load_settings = function(self, settings)
	for _, row in pairs(settings) do
	
		--create module settings table if needed
		if not self.settings[row.module] then
			self.settings[row.module] = {}
		end
		
		self.settings[row.module][row.name] = row.data
	end	
end

user_obj.option = function (self, module, name)

	if self.settings[module] == nil or self.settings[module][name] == nil then
		error("Could not find setting[%(1)s ; %(2)s]" % { module, name })
	end
	
	return self.settings[module][name]
end


user_obj.init_settings = function(self)
	
	local result = alpha.db:query("SELECT module, name, data FROM user_data WHERE user_id = ? AND module <> \"WEB\";", user_id)
	
	if result and reult:num_rows() > 0 then
		self:load_settings(result:fetch())
	end
	
	user.inited_settings = true
end
--[[
local init = user_obj.__init
user_obj.__init = function(self, ...)
	self:init_settings()
	init(self, ...)
end]]
