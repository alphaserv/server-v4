module("as.timer", package.seeall)

local Timer = newclass("Timer")

Timer.time = 0
Timer.callback = function() end
Timer.once = false
Timer.running = false
Timer.id = ""

function Timer:setOnce(once)
	self.once = once
end

function Timer:run()
	self.running = true
	if not self.once then
		self.id = as.server.interval(self.time, function()
			self.running = false
			self:callback()
			if self.once then --cancelled
				return -1
			end
			self.running = true
		end)
	else
		self.id = as.server.sleep(self.time, function()
			self.running = false
			self:callback()
			if not self.once then --repeat
				self:run()
			end
		end)
	end
end

function Timer:pause()
	as.server.cancel_timer(self.id)
end

function Timer:resume()
	self:run()
end

function Timer:remove()
	if not once then
	
	end
end


function sleep(time, func)
	local timer = Timer()
	timer:setOnce(true)
	timer.time = time
	timer.callback = func
	timer:run()
	return timer
end

function interval(time, func)
	local timer = Timer()
	timer:setOnce(false)
	timer.time = time
	timer.callback = func
	timer:run()
	return timer
end
