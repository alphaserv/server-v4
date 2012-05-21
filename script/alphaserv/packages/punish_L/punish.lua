
module("punish", package.seeall)

local default_punishment = alpha.settings.new_setting("default_punishment", {"spectate", 10000}, "Default punishment, {name, time} time in seconds")
local punishments = alpha.settings.new_setting("punishments", {edithack = {"ban", 10000}}, "Punishments for reasons reason = {punishment, time}  time in seconds")

storage_obj = class.new(nil, {
	set = function(self, ip, value)
	
	end,
	
	get = function(self, ip)
	
	end,
})

punishment_obj = class.new(nil, {
	punish = function(self, player)
	
	end,
	
	unpunish = function(self, player)
	
	end,
})

local storage = storage_obj()
punishments = {}

function punish(player, reason)
	local punishments = punishments:get()
	local name
	local time
	
	if not punishments[reason] then
		local default = default_punishment:get()
		name = default[1]
		time = default[2]
	else
		name = punishments[reason][1]
		time = punishments[reason][2]
	end
	
	punishments[name](punishments[name], player, reason)
	
	
	
	storage:set(player:ip(), 
end

user_obj.punish = punish

spectate = class.new(punishment_obj, {
	punish = function(self, player)
	
	end,
	
	unpunish = function(self, player)
	
	end,
})
