module("player.settingdata", package.seeall)

if not user_obj.storage_backend then
	user_obj.storage_backend = {}
end

user_obj.storage_backend.settingdata = class.new(nil, {
	init = function(self, user)
		self.user = user
		
		if not user.inited_settings then
			user:init_settings()
		end
	end,
	
	get = function(self, name)
		return user:option(name)
	end,
	
	exists = function(self, name)
		return pcall(function()
			return user:option(name)		
		end)
	end,
	
	set = function(self, name, value)
		error("not implemented", 2)
	end,
	
	new = function(self, name, value)
		error("not implemented", 2)
	end,

})
