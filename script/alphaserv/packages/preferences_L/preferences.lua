module("preferences", package.seeall)

backend_obj = class.new(nil, {
	set = function(self, user, preference, value) error("Not implemented") end,
	get = function(self, user, preference) error("Not implemented") end,
	init = function(self, preference, default) error("Not implemented") end,
})

local backends = {}
backend = backend_obj()

function register_backend(name, backend)
	if backends[name] then
		error("duplicate preference backend name")
	else
		backends[name] = backend
	end
end

init_preferences = {}
function new(name, value)
	server.msg("new: "..name.." = ".. tostring(value))
	if init_preferences then
		init_preferences[name] = value
	else
		backend:init(name, value)
	end
end

user_obj.preference = function(self, variable, value)
	--set
	if type(value) ~= "nil" then
		return backend:set(self, variable, value)	
	--get
	elseif variable then
		return backend:get(self, variable)
	else
		error("variable is nil")
	end
end

local backend_setting = alpha.settings.new_setting("preference_backend", "file", "the name of the backend to use to store preferences")

server.event_handler("pre_started", function()
	local backend_setting = backend_setting:get()
	
	if not backends[backend_setting] then
		log_msg(LOG_ERROR, "invalid backend name, using file fallback")
		backend_setting = "file"
	end
	
	backend = backends[backend_setting]()
	backends = nil --clean up
	
	if init_preferences then
		for name, value in pairs(init_preferences) do
			backend:init(name, value)
		end
	
		init_preferences = nil
	end
end)
