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
	
	local i = 0
	for j, lock in pairs(self.locks) do
		if not lock:is_locked(self) then
			self.locks[j] = nil
		else
			i = i + 1
		end
	end
	
	return i > 0
end

user_obj.spec = function(self)
	if self:is_spectator() then
		--already spectator
		return
	end
	
	server.spec(self.cn)
	log_msg(LOG_INFO, "unspecing %(1)s" % {self.cn})
end

user_obj.unspec = function(self)
	if not self:is_spectator() then
		--already unspeced
		return
	end
	
	server.unspec(self.cn)
	log_msg(LOG_INFO, "unsepecing %(1)s" % {self.cn})
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
	
	self:check_locks()
	if not self:is_locked() then
		self:unspec()
	end
end

user_obj.check_locks = function(self, way)

	log_msg(LOG_INFO, "Checking locks for player %(1)s" % {self.cn})
	local i = 0
	for j, lock in pairs(self.locks) do
		if not lock:is_locked(self) then
			self.locks[j] = nil
		else
			i = i + 1
		end
	end
	
	server.msg("locks: "..i)
	
	if i ~= 0 and way == "0" then
		server.msg("blocked (un)spec")
		self:spec()
	end
end

events = { spec = nil }

events.spec = server.event_handler("spectator", function(cn, way)
	
	way = tostring(way)
	local user = user_from_cn(cn)
	user:check_locks(way)
	
	server.msg("way == "..way)
end)
