module ("as.event", package.seeall)

local connections = {}
local add_listener, remove_listener

local function addListener(event_id, listener_function)
	
	local listeners = event[event_id]

	if not listeners then
		error("Event "..event_id.." does not exist", 1)
	end
	
	listeners[#listeners + 1] = listener_function
	
	connections[#connections + 1] = {listeners, #listeners}
	
	local connection_id = #connections
	
	return {
		remove = function()
			return _M.remove_listener(connection_id)
		end,
	}
end

local function removeListener(connection_id)

	if type(connection_id) == "function" then
		local disconnector = connection_id
		disconnector()
		return
	end
	
	local connection = connections[connection_id]
	if not connection then return end
	table.remove(connection[1], connection[2])
	connections[connection_id] = nil
end

local function clearListeners()
	for connection_id in pairs(connections) do
		removeListener(connection_id) 
	end
end

local function triggerEvent(event_id, ...)

	local listeners = event[event_id]
	if not listeners then return end
	
	local prevent_default = false
	
	for _, listener in pairs(listeners) do
		local pcall_status, result = pcall(listener, unpack(arg))
		if not pcall_status then
			if server.log_event_error then
				server.log_event_error(event_id, result or "unknown error")
			else
				print("ERROR:", event_id, result)
			end
		else
			prevent_default = prevent_default or (result == true)
		end
	end
	
	return prevent_default
end

local function destroyEvent(event_id)
	event[event_id] = nil	
end

function findEvent(event_id)
	return {
		trigger = function(self, ...)
			print ("trigger ", event_id)
			triggerEvent(event_id, unpack(arg))
		end,
		
		destroy = function()
			destroyEvent(event_id)
		end,
		
		clearListners = function()
			clearListners(event_id)
		end,
		
		addListner = function(self, ...)
			addListener(event_id, ...)
		end,
	}
end

function createEvent(event_id)
	
	event[event_id] = {}
	
	return findEvent(event_id)
end

create = createEvent

function init()
	local EVENTS = {
		"shutdown",
		"connect",
		"disconnect",
		"mapvote",
		"setmaster",
		"rename",
		"connecting"
	}
	
	for i, event in pairs(EVENTS) do
		local name = "on"..event:sub(1,1):upper()..event:sub(2)
		as.server[name] = findEvent(event)
	end
end



