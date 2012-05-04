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
		self.was_speced_by_us = true
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

	for j, lock in ipairs(self.locks) do
		if not lock:is_locked(self) then
			table.remove(self.locks, j)
		end
	end
	
	server.msg("locks: "..#self.locks)
	
	if #self.locks ~= 0 and way == "0" then
		log_msg(LOG_DEBUG,"blocked (un)spec")
		self:spec()
	elseif self.was_speced_by_us and not self:is_locked() then
		self.was_speced_by_us = false
		server.sleep(500, function()
			self:unspec()
		end)
	end
end

--events = { spec = nil }

--[[events.spec =]] server.event_handler("spectator", function(cn, way)
	
	way = tostring(way)
	local user = user_from_cn(cn)
	user:check_locks(way)
	
	server.msg("way == "..way)
end)
