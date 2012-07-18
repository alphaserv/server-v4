--[[!
    File: script/as/component.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		Provide a base component class and a base module

	About: Package as.component
]]
local _G, setmetatable, class = _G, setmetatable, class
module("as.component")

--[[!
	Class: baseComponent
	The base class for all components, contains functions required to load them like initSettings()
]]

baseComponent = class.new(nil, {
	--[[!
		Property: import
		An array for providing direct access to other components by using self.name
		
		Example:
		(code)
			import = {
				db = MyDb,
				db2 = BackupDb,
				
				msg = messages,
			}
		(/code)
	]]

	import = {},

	--[[!
		Function: initSettings
		This function initializes the class by loading the settings
		and imports the components
			
		Parameters:
			self - 
			settings - an array of config settings for this component
	]]	
	initSettings = function(self, array)
		for key, value in pairs(array) do
			self[key] = value
		end
		
		--[[
			Provide shorthand linking to other components
		]]
		for as, dependic in pairs(self.import) do
			self[as] = _G.as.as[dependic]
		end
	end,

	--[[!
		Function: initDone
		Initializes the class, is called after initSettings
	]]		
	initDone = function(self)
	
	end,
})

--[[!
	Function: new
	this function is called by:
		module("my.name", package.seeall, as.component)
	
	this lets us extend components with internal functions
	
	Parameters:
		module - the module
	
	Return: the module
]]
function new(module)
	--give modules access to a shorter syntax
	module.as = _G.as.as
	module.component = baseComponent
	return module
end

setmetatable(_M, {
	__call = function(table, ...)
		return new(...)
	end,
})
