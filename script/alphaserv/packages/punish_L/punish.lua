
module("punish", package.seeall)

local default_punishment = alpha.settings.new_setting("default_punishment", {"spectate", 10000}, "Default punishment, {name, time} time in seconds")
local punishments_setting = alpha.settings.new_setting("punishments", {edithack = {"ban", 10000}}, "Punishments for reasons reason = {punishment, time}  time in seconds")

storage_obj = class.new(nil, {
	table = {},
	
	set = function(self, ip, value)
		server.msg("setting ..")
		self.table[ip] = value
	end,
	
	get = function(self, ip)
		server.msg(table_to_string(self.table[ip]))
		return self.table[ip]
	end,
	
	add = function(self, ip, end_time, name)
		server.msg("adding")
		
		if not self.table[ip] then
			self.table[ip] = {}
		end
		
		table.insert(self.table[ip], {name = name, time = end_time })
	end,
})

punishment_obj = class.new(nil, {
	punish = function(self, player)
	
	end,
	
	unpunish = function(self, player)
	
	end,
	
	do_punish = function(self, player, time, reason)
		self:punish(player)
		
		server.msg("punish "..time.." "..reason)
		
		return self
	end,
	
	undo_punish = function(self, player)
		self:unpunish(player)
		
		return self
	end,
})

local storage = storage_obj()
punishments = {}

function punish(player, reason, override_punishment, override_time)
	--fetch the punishments
	local punishments_reasons = punishments_setting:get()
	
	local name
	local time
	
	--punishment object
	local punishment
	
	--unkown reason
	if not punishments[reason] then
		local default = default_punishment:get()
		name = default[1]
		time = default[2]
	else
		name = punishments[reason][1]
		time = punishments[reason][2]
	end
	
	punishment = punishments[name]:do_punish(player, time, reason)
	
	server.msg(server.enet_time_get())
	server.msg(server.enet_time_get() + time)
	storage:add(player:ip(), server.enet_time_get() + time, name)
	
	server.sleep(time, check_punishments)
end

function check_punishments()
	server.msg("checking punishments")
	for cn, user in pairs(alpha.user.users) do
		server.msg("checking punishment")
		user:check_punishments()
	end
end

user_obj.check_punishments = function(self)
	local user_punishments = storage:get(self:ip())
	
	for i, punishment in pairs(user_punishments) do
		server.msg(punishment.time.. " <= "..server.enet_time_get())
		if punishment.time <= server.enet_time_get() then
			punishments[punishment.name]:undo_punish(self)
			user_punishments[i] = nil
		end
	end
	
	storage:set(self:ip(), user_punishments)
end

user_obj.punish = punish

spectate = class.new(punishment_obj, {
	punish = function(self, player)
		local lock = class.new(spectator.lock.lock_obj, {
			is_locked = function(self, player) return true end,
			unlock = function(self, player) player:msg("Your speclock is over") end,
		})
		
		player:add_speclock("punish", lock())
	end,
	
	unpunish = function(self, player)
		server.msg("unspecing")
		player:remove_speclock("punish")
	end,
})

punishments.spectate = spectate()
