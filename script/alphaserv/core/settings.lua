--[[!
    File: script/alphaserv/core/settings.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file stores all settings in objects, and manages writing settings to files.

    Package: alpha.settings
]]

module("alpha.settings", package.seeall)

--[[!
    Variable: writers
    An array containing a key - value list of available writers.
    
    nil - returns "nil"
    number - returns tonumber(number)
    string - returns tostring(string)
    boolean - returns "true" or "false"
    table - returns the table as a string
    function - returns the function
]]

local writers

--[[!
	Function: serialize_data
	Executes the writer from the writers table wich suites the type
	
	Parameters
		data - the data to write
		level - the number of tabs for outline
	
	Return:
		the result of the writer
]]

function serialize_data (data, level)
	return writers[type(data)](data, level)
end

--[[!
	Function: writetabs
	Writes a specified number of tabs
	
	Parameters
		level - number of tabs
	
	Return:
		a string containing the tabs
]]

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
		local isindex = function(k) 
			if type(k) == "number" and k > 0 then
				if math.floor(k) == k then
					return true
				end
			end
			return false
		end
		
		local need_keys = function(t)
			for k,v in pairs(t) do
				if not isindex(k) then
					return true
				end
			end
			return false
		end
		
		local require_keys = need_keys(item)		
		local string = ""
		
		string = string .. "{\n"
		
		for k, v in pairs(item) do
			string = string .. writetabs(level+1)
			
			if require_keys then
				string = string .. "["
				string = string .. serialize_data(k, level + 1)
				string = string .. "] = "
			end
			
			string = string	.. serialize_data(v, level + 1)
			
			string = string .. ",\n"
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

--[[!
	Class: setting_obj
	A setting
]]

setting_obj = class.new(nil, {
	--[[!
		Property: written
		Already written to a file
	]]

	written = false,
	--[[!
		Property: setting
		The setting value
	]]
	setting = "",
	
	--[[!
		Property: description
		The description to write in a comment when write() is executed
		
		Note: this value will be cleared after <write>
	]]
	description = "",
	
	--[[!
		Property: setting_name
		The name of the setting
	]]
	
	setting_name = "",
	
	--[[!
		Function: __init
		initializes the class by setting the properties setting, description and name
		
		Parameters:
			self - 
			value - the value of the setting
			description - the description of the setting
			name - the name of the setting
	]]
	
	__init = function(self, value, description, name)
		self.setting = value
		self.description = description
		self.setting_name = name
	end,
	
	--[[!
		Function: write
		Creates a string containing the description in a comment and the setting as a function
		
		Parameters:
			self -
			name - the name of the setting
		
		Todo:
			*use the name from the object
			
		Return:
			a string containing the parsed string
		
		Example Return:
		(code)
			--------------
			--\[\[
			#Name: name
			#Description: description ...
			\]\]--
			-------------
			alpha.settings.set("name", "value")
		(end)
	]]
	
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

		string = string % { tostring(name), serialize_data(self:get(), 0) }
		
		self.description = nil --we don't need this anymore
		
		return string
	end,
	
	--[[!
		Function: get
		Returns the value of the setting
	
		Parameters
			self - 
	
		Return:
			the setting
	]]
	get = function(self)
		return self.setting
	end,
	
	--[[!
		Function: set
		Sets the setting value
	
		Parameters
			self -
			value - The value of the setting
	
		Return:
			self
	]]
	set = function(self, value)
		self.setting = value
		
		return self
	end
})

--[[!
	Section: alpha.settings
]]

--[[!
    Variable: types
    An array containing all the setting classes
	only contains setting_obj by default
	
	Note: this is a local variable
	
	setting types are inserted with <register_type>
]]
local types = { default = setting_obj }

--[[!
    Variable: settings
    An array containing all settings
]]

settings = {}

--[[!
	Function: register_type
	Register new types
	
	Parameters
		name - the name of the type
		type - the type class
	
]]
function register_type(name, type)
	types[name] = type
end

--[[!
	Function: Find setting
	Find a setting by name
	
	Note:
		deprecated
	
	Parameters
		name - the name of the setting
	
]]

function find_setting(name)
	return settings[name] or error("Cannot find setting %(1)s" % {name}, 2)
end

--[[!
	Function: new_setting
	creates a new setting
	
	Parameters
		name - the name of the setting
		value - the default value of the setting
		description - the description of the setting
		type - the type of the message, defaults to "default"
	
	Returns:
		the newly created setting
	
]]

function new_setting(name, value, description, type)
	if not type then
		type = "default"
	end
	
	settings[name] = types[type](value, description, name)
	
	return settings[name]
end

--[[!
	Function: get
	Return the setting by name
	
	Parameters
		name - the name of the setting
	
	Returns:
		the setting
	
]]

function get(name)
	if not settings[name] then
		error("Could not find setting %(1)s" % {name}, 2)
	end
	
	return settings[name]
end

--[[!
	Function: set
	set a setting to a specefic value, this is mostly used in the generated configuration files.
	
	Parameters
		name - the name of the setting
		value - the value of the setting
]]

function set(name, value)
	if not settings[name] then
		log_msg(LOG_ERROR, "Could not find setting %(1)s" % {name}, 2)
		return
	end
	settings[name]:set(value)
end

--[[!
	Function: write
	Writes all the settings to a configuration file.
	
	Parameters
		filename - The name of the file to write to
		header - additional content to write before the rest
]]

function write(filename, header)
	local file = io.open(filename, "w")
	
	if header and header ~= "" then
		file:write(header)
	end
	
	for i, setting in pairs(settings) do
		if not setting.written then
			file:write(setting:write(i))
			setting.written = true
		end
	end
	
	file:close()
end
