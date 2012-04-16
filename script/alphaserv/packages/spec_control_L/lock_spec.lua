module("spectator.lock", package.seeall)

lock_obj = class.new(nil, {
	is_locked = function(self, player) end,
	try_unspec = function(self, player) end,
	unlock = function(self, player) self = nil end
})

user_obj.locks = {}

user_obj.is_spectator = function(self)
	return server.player_status_code(self.cn) == server.SPECTATOR
end

user_obj.is_locked = function(self)
	if not self.locks then self.locks = {} end
	return #self.locks > 0
end

user_obj.spec = function(self)
	if self:is_spectator() then
		--already spectator
		return
	end
	
	server.spec(self.cn)
	server.msg("spec")
end

user_obj.unspec = function(self)
	if not self:is_spectator() then
		--already unspeced
		return
	end
	
	server.unspec(self.cn)
	server.msg("unspec")
end

user_obj.add_speclock = function(self, module, lock)
	if not self.locks then self.locks = {} end
	--lock.on = { unlock = function(self) self:check_locks() end}
	self.locks[module] = lock
	
	if not self:is_spectator() then
		self:spec()
	end
end

user_obj.remove_speclock = function(self, module)
	if not self.locks then self.locks = {} end
	if not self.locks[module] then return end
	self.locks[module]:unlock(self)
	self.locks[module] = nil
	
	--auto unspec
	self:check_locks()
end

user_obj.check_locks = function(self)

	local i = 0
	for i, lock in pairs(self.locks) do
		if not lock:is_locked(self) then
			self.locks[i] = nil
		else
			i = i + 1
		end
	end
	
	if i == 0 then
		self:unspec()
	end
end

events = { spec = nil }

events.spec = server.event_handler("spectator", function(cn)
	user_from_cn(cn):check_locks()
end)
