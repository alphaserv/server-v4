if not alpha then error("trying to load 'settings2.lua' before alpha init."); return end
module("alpha.settings", package.seeall)


local writers
function serialize_data (data, level)
	return writers[type(data)](data, level)
end

function writetabs (level)
	local string = ""
	
	for i = 1, level do
		string = string .. "\t"
	end
	
	return string
end

writers = {
	["nil"] = function (item)
		return "nil"
	end,
	
	["number"] = function (item)
		return tostring(item)
	end,
	
	["string"] = function (item)
		return string.format("%q", item)
	end,
	
	["boolean"] = function (item)
		if item then
			return "true"
		else
			return "false"
		end
	end,
	
	["table"] = function (item, level)
		local string = ""
		
		string = string .. "{\n"
		
		for k, v in pairs(item) do
			string = string .. writetabs(level+1)
			string = string .. "["
			string = string .. serialize_data(k, level + 1)
			string = string .. "] = "
			
			string = string	.. serialize_data(v, level + 1)
			
			string = string .. "\n"
		end
		
		string = string .. writetabs(level) .. "}"

		return string
	end,

	--Works only on lua functions without upvalues!	
	["function"] = function (item)
		local dInfo = debug.getinfo(item, "uS");
		if dInfo.nups > 0 then
			return "nil --[[ upvalues not supported ]]"
		elseif dInfo.what ~= "Lua" then
			return "nil --[[ non-lua function not supported ]]"
		else
			local r, s = pcall(string.dump,item);
			
			if r then
				return "loadstring(%(1)q)" % {s}
			else
				return "nil --[[function could not be dumped]]"
			end
		end
	end,
	
	["thread"] = function (item)
		return "nil --[[thread]]\n";
	end,
	
	["userdata"] = function (item)
		return "nil --[[userdata]]\n"
	end
}

setting_obj = class.new(nil, {
	setting = "",
	description = "",
	
	__init = function(self, value, description)
		self.setting = value
		self.description = description
	end,
	
	write = function(self, name)
		local string = 
		"----------------------------\n"..
		"--[[\n"..
		"%(1)s"..
		"]]--\n"..
		"----------------------------\n\n"
		
		local info_string =
		"#Name: %(1)s\n"..
		"#Description: %(2)s\n"
		
		string = string % { info_string % {name, self.description}}
		
		string = string ..
		"alpha.settings.set (%(1)q, %(2)s)\n\n\n"

		string = string % { tostring(name), serialize_data(self.setting, 0) }
		
		self.description = nil --we don't need this anymore
		
		return string
	end,
	
	get = function(self)
		return self.setting
	end,
	
	set = function(self, value)
		self.setting = value
		
		return self
	end
})

local types = { default = setting_obj }

settings = {}

function register_type(name, type)
	types[name] = type
end

function find_setting(name)
	return settings[name] or error("Cannot find setting %(1)s" % {name}, 2)
end

function new_setting(name, value, description, type)
	if not type then
		type = "default"
	end
	
	settings[name] = types[type](value, description)
	
	return settings[name]
end

--function init_setting(name, default_value, type, description)
--	new_setting(name, default_value, description)
--end

function get(name)
	if not settings[name] then
		error("Could not find setting %(1)s" % {name}, 2)
	end
	
	return settings[name]
end

function set(name, value)
	if not settings[name] then
		error("Could not find setting %(1)s" % {name}, 2)
	end
	settings[name]:set(value)
end

function write(filename, header)
	local file = io.open(filename, "w")
	
	if header and header ~= "" then
		file:write(header)
	end
	
	for i, setting in pairs(settings) do
		file:write(setting:write(i))
	end
	
	file:close()
end
