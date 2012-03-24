module("event", package.seeall)

events = {}
listners = {}

listner_obj = class.new(nil, {
	event,
	disabled = false,
	func = function() end,
	
	__init = function(self, event)
		if type(event) == "number" or type(event) == "string" then
			self.event = events[event]
		else
			self.event = event
		end
	end,
	
	set_listner = function(self, func)
		self.func = func
		
		return self
	end,
	
	trigger = function(self, ...)
		if self.disabled then return end
		self.func(...)
		
		return self
	end
})

event_obj = class.new(nil, {
	name = "",
	listners = {},
	disabled = false,
	
	__init = function(self, name)
		self.name = name
		events[name] = self
	end,
	
	trigger = function (self, ...)
		for i, listner in pairs(listners) do
			listner:trigger(...)
		end
		
		return self
	end,
	
	add_listner = function(self, func)
		local listner = listner_obj(self)
		listner:set_listner(func)
		
		self.listners[#self.listners+1] = self.listners
		
		return listner
	end,
	
	remove = function(self)
		self = nil --bb
	end,

})

function create_event(name)
	return event_obj(name)
end

function event(name)
	return events[name]
end
