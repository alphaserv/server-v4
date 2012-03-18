
local user_instances = {}

local maxtimers = 3
local maxcalls = 10

local time = server.enet_time_get()

--call to a function
call_obj = class.new(nil, {
	_arguments = {},
	_function = nil,
	
	__init = function(self, func, arguments)
		self._function = func
		self._arguments = arguments
	end,
	
	execute = function(self)
		return self._function(self._arguments)
	end
})

--instance of an user
instance_obj = class.new(nil, {
	
	--parent
	user = nil,
	
	env = {},
	
	call_schedue = {},
	
	__init = function(self, user)
		self.user = user:identifier({offline = false})
		
		self.cs = table.deepcopy(lua_cubescript.cs)
		self.env = cs.env
		
		self.env["if"] = function(condition, true_body, false_body)
			return make_function({}, true_body)()
			lua_cubescript
		end
	end,
	
	set_var = function(self, name, value)
		self.variables[name] = value
	end,
	
	get_var = function(self, name)
		return self.variables[name]
	end,
	
	schedue_call = function(self, fname, arguments)
		table.insert(self.call_schedue, {name = fname, arguments = arguments})
	end,
	
	call = function(self, ...)
		self:schedue_call(unpack(arg))
	end,
	
	sleep = function(self, time_wait, func)
		local time_on_exec = time_wait + time
		table.insert(self.timers, {time = time_on_exec, func = func})
	end,
	
	update_timers = function(self)
		if #self.timers > 0 then
			for i, timer in ipairs(self.timers) do
				if i > maxtimers and not user:access("unlimited_timers", {default = false}) then
					break
				else
					if timer.time < time then
						--execute
						self:schedue_call(timer.func, {time})
					end
				end
			end
		end
	end,
	
	update_calls = function(self)
		if self.call_schedue > 0 then
			--execute commands
			for i, call in pairs(self.call_schedue) do
				if i > maxcalls and not user:access("unlimited_calls", {default = false}) then
					break
				else
					functions[call.name](self, unpack(call.arguments))
				end
			end
		end
	end,

	update = function(self)
		self:update_timers()
		self:update_calls()
	end,
	
})

local function update()
	--update time
	time = server.enet_time_get()
	
	for i, instance in pairs(user_instances) do
		local user = alpha.user(instance.user)
		
		--handle sleeps
		if #instance.timers > 0 then
			for i, timer in ipairs(instance.timers) do
				if i > maxtimers and not user:access("unlimited_timers", {default = false}) then
					break
				else
					if timer.time < time then
						--execute
						instance.call[#instance.call + 1] = call_obj(timer.func, {time, timer.arguments or {}})
					end
				end
			end
		end
		
		--TODO: events, intervals

	end
end
