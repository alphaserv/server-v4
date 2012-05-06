module("acl", package.seeall)
require "Json"

local acl = {
	objects = {
		["world"] = {
			default = true
		},
		
		["command:excute"] = {
			default = false,
			parent = "world"
		}
	},
	
	groups = {
		world = {
			access = {
				["command:execute"] = true
			},
			parent = nil
		}
	},
	
	users = {

	}

}

--load
if server.file_exists("conf/acl.lua") then
	acl = dofile("conf/acl.lua")
end

local last = 0 - os.time()
local interval = 10

function write()
	if last + interval > os.time() then
		return
	end
	
	local file = io.open("conf/acl.lua", "w")
	
	file:write("--[[\n")
	file:write("Acl table, contains all the rules, objects and groups.\n")
	file:write("]]--\n")

	file:write("return "..alpha.settings.serialize_data(acl, 0))
	
	file:close()
end

write()


local current_init = user_obj.__init
user_obj.__init = function(self, ...)
	if current_init then
		current_init(self, ...)
	end
	self:reinit_acl()
end

user_obj.reinit_acl = function(self)
	if not acl.users[self.user_id] then
		acl.users[self.user_id] = {
			groups = { "world"}
		}
		
		write()
	end
	
	self.access = {}
	
	for i, group in pairs(acl.users[self.user_id].groups) do
		repeat
			for name, access in pairs(acl.groups[group].access) do
				self.access[name] = access
			end
			group = acl.groups[group.parent]
		until not group
	end
end

user_obj.load_groups = function(self) end

local parent_auth = user_obj.auth or function () end
user_obj.auth = function(self, user_id, ...)
	self.user_id = user_id
	parent_auth(self, user_id, ...)
	self:reinit_acl()
end
	
user_obj.has_permission = function(self, name, id)
	if id and id ~= -1 then
		name = name..':'..id
	end
	
	--log_msg(LOG_DEBUG, "Checking %(1)q "% {name})
	
	--log_msg(LOG_DEBUG, "Checking "..table_to_string(acl.objects))
	
	--[[
	for item, b in pairs(self.access) do
		log_msg(LOG_DEBUG, "Checking %(1)q" % {item})
	end
	
	-- [ [
	log_msg(LOG_DEBUG, "Checking "..tostring(type(self.access[name]) ~= "boolean") or "false")
	log_msg(LOG_DEBUG, "Checking "..tostring(type(acl.objects[name]) == "table"))
	log_msg(LOG_DEBUG, "Checking "..tostring(type(acl.objects[name].default) == "boolean"))]]
	
	--not found at all -> add
	if not acl.objects[name] then
		log_msg(LOG_DEBUG, "not set")
		acl.objects[name] = { parent = "world" }
		server.sleep(1, write)
	end
	
	--log_msg(LOG_DEBUG, ":"..type(self.access[name]))
	--log_msg(LOG_DEBUG, ":"..tostring(self.access[name]))
	
	if type(self.access[name]) == "boolean" then
		log_msg(LOG_DEBUG, "has access")
		return self.access[name]
	
	--is not set -> check for default value
	elseif type(self.access[name]) ~= "boolean" and type(acl.objects[name]) == "table" and type(acl.objects[name].default) == "boolean" then
		--log_msg(LOG_DEBUG, "Checking default value")
		self.access[name] = acl.objects[name].default
	
		return self.access[name]
	
	--is not set -> find parent
	elseif type(self.access[name]) == "nil" and acl.objects[name].parent then
		--log_msg(LOG_DEBUG, "finding parent "..acl.objects[name].parent)
		local res = self:has_permission(acl.objects[name].parent)
		self.access[name] = res
		return res
	end
	
	return false
end
