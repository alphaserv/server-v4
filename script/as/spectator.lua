require "class"

module("as.spectator", package.seeall)

onLock = as.event.create("spectator.lock")
onUnlock = as.event.create("spectator.unlock")

as.user.User.spectatorLocks = {}
function as.user.User:addSpectatorLock(lock)
	local id = #self.spectatorLocks + 1
	lock:setUser(self, id)
	self.spectatorLocks[id] = lock
	--!TODO trigger event
	return id
end

function as.user.User:removeSpectatorLock(lock)
	--!TODO trigger event
	self.spectatorLocks[locl.id] = nil
end

function as.user.User.hasSpectatorLocks()
	local hasLocks = false
	for i, lock in pairs(self.spectatorLocks) do
		if lock:expired() then
			self:removeSpectatorLock(lock)
		else
			hasLocks = true
		end
	end
	
	return hasLocks
end

function as.user.User:checkSpectatorLocks()
	if self:getStatus() == as.server.SPECTATOR and not self:hasSpectatorLocks() then
		self:unSpect()
	elseif self:hasSpectatorLocks() and not self:getStatus() == as.server.SPECTATOR then
		self:forceSpec()
	end	
end

Lock = newclass("Lock")
Lock.id = -1
Lock.name = ""
Lock.time = -1

function Lock:expired()
	if self.time ~= -1 then
		return os.clock() > Lock.time
	end
end

function Lock:setTime(time)
	self.time = os.clock() + time
end

function Lock:setUser(user, id)
	self.id = id
end

--[[
as.user.onGetSessionVars:addListner(function(user, list)
	list.spectatorLocks or list.spectatorLocks = {}
	
	for id, lock in pairs(user.spectatorLocks) do
		if lock:hasSession() then
			table.insert(list.spectatorLocks, lock:getSessionVar())
		end
	end
end)

as.user.onSetSessionVars:addListner(function(user, list)
	list.spectatorLocks or list.spectatorLocks = {}
	
	for i, sessionVar in pairs(list.spectatorLocks) do
		if not sessionVar:isExpired(user) do
			local lock = sessionVar:restore()
			user:addSpectatorLock(lock)
		end
		
		sessionVar:remove()
	end
	user:checkLocks()
end)
]]
