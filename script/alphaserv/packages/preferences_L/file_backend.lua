module("preferences.backends.file", package.seeall)

local preferences = {
	DEFAULT = {}
}

function read()
	if server.file_exists("conf/user_preferences.lua") then
		preferences = dofile("conf/user_preferences.lua")
	end
	
	preferences.DEFAULT = preferences.DEFAULT or {}
end

read()

function write()
	local file = io.open("conf/user_preferences.lua", "w")
	
	file:write("--[[\n")
	file:write("A table containing all the preferences of the users.\n")
	file:write("]]--\n")

	file:write("return "..alpha.settings.serialize_data(preferences, 0))
	
	file:close()
end

backend_obj = class.new(preferences.backend_obj, {

	__init = read,
	
	set = function(self, user, preference, value)
		if user.user_id == -1 then
			return false, "please login to change your prefences."
		end

		if not preferences[user.user_id] then
			preferences[user.user_id] = {}
		end

		preferences[user.user_id][preference] = value
		
		write()
		return true
	end,
	
	get = function(self, user, preference)
		server.msg("getting "..preference)
	
		if preferences[user.user_id] and type(preferences[user.user_id][preference]) ~= "nil" then
			return preferences[user.user_id][preference]
		elseif type(preferences.DEFAULT[preference]) ~= "nil" then
			return preferences.DEFAULT[preference]
		else
			return nil
		end
	end,
	
	init = function(self, preference, default_value)
		server.msg("setting "..preference.." "..alpha.settings.serialize_data(value, 0))
		preferences.DEFAULT[preference] = default_value
		write()
	end,
})

	
_G.preferences.register_backend("file", backend_obj)

server.event_handler("started", write)
