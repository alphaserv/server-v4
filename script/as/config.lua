
module("as.config", package.seeall)

as.color = true
rawConfig = {}

function loadConfigFile(file)
	rawConfig = table.mergeRecursive(rawConfig, dofile (file))
end

--[[!
	This function allows simple section managament for core modules
]]
function loadSection(name, vars)
	local t = {}
	setmetatable(t, {
		__index = function(table, setting)
			if type(rawConfig[name]) == "table" and type(rawConfig[name][setting]) ~= "nil" then
				return rawConfig[name][setting]
			elseif type(vars[setting]) ~= "nil" then
				return vars[setting]
			elseif setting == "__list" then
				return rawConfig[name]
			else
				error("invalid setting", 1)
			end
		end,
		__newindex = function() error("Config section is readonly", 1) end,
	})
	
	return t
end

function loadConfig()
	local FILES = {
		"script/as/baseconf.lua",
		"config.lua"
	}
	
	for i,file in pairs(FILES) do
		loadConfigFile(file)
	end
end

load = loadConfig

function init()

end
