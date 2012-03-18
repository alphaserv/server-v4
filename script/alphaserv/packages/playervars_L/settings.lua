module("player.settings", package.seeall)

function load_user(user_id)
	local player = server.player({user_id = user_id})
	
	local result = alpha.db:query("SELECT module, name, data FROM user_data WHERE user_id = ? AND module <> \"WEB\";", user_id)
	
	if result and reult:num_rows() > 0 then
		player:load_settings(result:fetch())
	end	
end

--extend the player object:
player.settings = {}
player.load_defaults = function(self)
	local result = alpha.db:query("SELECT module, name, data FROM user_data WHERE user_id = -1 AND module <> \"WEB\";"):fetch()
	
	self:load_settings(result)
end

player.load_settings = function(self, settings)
	for _, row in pairs(settings) do
	
		--create module settings table if needed
		if not self.settings[row.module] then
			self.settings[row.module] = {}
		end
		
		self.settings[row.module][row.name] = row.data
	end	
end

player.option = function (self, module, name)

	if self.settings[module] == nil or self.settings[module][name] == nil then
		error("Could not find setting[%(1)s ; %(2)s]" % { module, name })
	end
	
	return self.settings[module][name]
end
