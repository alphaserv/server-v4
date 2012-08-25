
require "class"

--local print = print

local PluginClass = newclass("Plugin")

PluginClass.autoEnable = true
PluginClass.loaded = {}

function PluginClass:load(name)
	if not self.loaded[name] then
		local plugin = dofile ("script/plugin/" .. name .. "/plugin.lua")
	
		self.loaded[name] = plugin
	
		if self.autoEnable then
			plugin:enable()
		end
	
		return plugin
	else
		return self.loaded[name]
	end
end

function PluginClass:import(module, as)
	if type(module) ~= "table" then
		local as = as or module
		self.m[as] = {}--self:load(module):wrap()
	else
		for i, module in pairs(module) do
			self.m[module] = {}--self:load(module):wrap()
		end
	end
end

function PluginClass:export(list)
--	self.exported = table.merge(self.exported, list)
	self.exported = list
end

--[[!
	Wraps a class into an imported class
]]
function PluginClass:wrap()
	local e = newClass("WRAPPED")
	
	for _, name in pairs(self.exported) do
		e[name] = function(s, ...)
			return self[name](self, ...)
		end
	end
	
	return e()
end

--[[!
	Creates a new plugin
]]
function PluginClass:new(name, version)
	local p = PluginClass:subclass(tostring(name).."- v"..tostring(version))
	p.name = name
	p.version = version
	return p()
end

function PluginClass:log(level, msg)
	print(msg)
end

function PluginClass:enable()
	return true
end

function PluginClass:reload()
	return true
end

function PluginClass:disable()
	return true
end

function PluginClass:loadDir(dir)
	local dir = dir or "script/plugin/"
	
	--local filesystem = require("filesystem")
	
	for filetype, filename in filesystem.dir(dir) do
		if filename:sub(1, 1) ~= "." and filetype == filesystem.DIRECTORY then
			self:load(filename)
		end
	end
end

Plugin = PluginClass()
