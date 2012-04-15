module("spectator.lock", package.seeall)

lock_obj = class.new(nil, {
	is_locked = function(self, player) end,
	try_unspec = function(self, player) end
})

user_obj.locks = {}

user_obj.is_spectator = function(self)
	return server.player_status_code(self.cn) == server.SPECTATOR
end

user_obj.is_locked = function(self)
	return #self.locks > 0
end

user_obj.spec = function(self)
	if self:is_spectator() then
		--already spectator
		return
	end
end

user_obj.unspec = function(self)
	if not self:is_spectator() then
		--already unspeced
		return
	end
end

user_obj.add_speclock = function(self, lock)
	lock.on = { unlock = function() self:check_locks() end}
	table.insert(self.locks, lock)
	
	if not self:is_spectator() then
		self:spec()
	end
end

user_obj.check_locks = function(self)

	for i, lock in pairs(self.locks) do
		if not lock:is_locked(self) then
			self.locks[i] = nil
		end
	end
	
	if not self.is_locked() then
		self.unspec()
	end
end

events = { spec = nil }

events.spec = server.event_handler("spectator", function()
	user_obj({cn = cn}):check_locks()
end)
