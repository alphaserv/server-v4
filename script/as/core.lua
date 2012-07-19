--[[!
    File: script/as/core.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This provides the core application class and intializes the alphaserv system classess.

	About: Package as.core
]]

module('as', package.seeall)

--[[!
    Class: as
    An Object containing the alphaserv root app object
]]
as = {
	--[[!
		Property: components
		An array containing instances of loaded components
	]]
	components = {},
	
	--[[!
		Property: Loaded
		A list containing the classes loaded
	]]
	loaded = {},

	--[[!
		Property: autoloadComponents
		An array containing classnames and settings for components wich will be autoloaded when first accessed
	]]
	autoloadComponents = {},

	--[[!
		Property: app
		An instance of the App (eithed as.consoleApplication or as.serverApplication) class
	]]
	app = {},

	--[[!
		Property: debugConfig
		Setting: when set to true this will print the settings that are loaded
	]]	
	debugConfig = false,

	--[[!
		Property: debugConfigVars
		Setting: when set to true this will print the settings that are assigned
	]]
	debugConfigVars = false,

	--[[!
		Property: debugComponents
		Setting: when set to true this will print the components that are pre/autoloaded
	]]	
	debugComponents = false,
	
	--[[!
		Function: __get
		Magic method for getting properties of the app or application components
		
		Parameters:
			self -
			name - the name of the variable requested
			
		Return:
			the found variable or nil
	]]
	__get = function(self, name, ...)
		-- Note we use type here so that we can return "false"
		if type(rawget(self, name)) ~= "nill" then
			return rawget(self, name)
		elseif type(self.app[name]) ~= "nil" then
			return self.app[name]		
		elseif type(self.components[name]) ~= "nil" then
			return self.components[name]			
		elseif type(self.autoloadComponents[name]) ~= "nil" then
			self:initComponent(name, self.autoloadComponents[name])
			return self.components[name]
		else
			return self[name]
		end
	end,
	
	--[[!
		Function: __set
		Magic method used to add event handlers
		
		Parameters:
			self -
			name - name of the event prepended by On
			value - value to set
	]]
	__set = function(self, name, value)
		if name:sub(0,2) == "On" then
			self[event]:addListner(name, value)
		
		--assume we're intializing a new as.* module
		elseif type(self[name]) == "nil" then
			self.components[name] = value
		else
			rawset(self, name, value)
		end
	end,
	
	--[[!
		Function: init
		Initializes the application by loading the app and config
				
		Parameters:
			self -
			configuration - either a table or a string with the path to the config file(s)
			appType - the type of the application, defaults to serverapplication
	]]
	
	init = function(self, configuration, appType)
		if appType == "console" then
			self.app = new "as.consoleApplication"
		elseif not appType or appType == "server" then
			self.app = new "as.serverApplication"
		else
			self.app = new (appType)
		end
		
		self.app:init()
		self:loadConfiguration(configuration)
		self.app:load()
		
		return self
	end,

	--[[!
		Function: run
		Runs the application
				
		Parameters:
			self -
	]]
	run = function(self)
		self.app:run()
	end,


	--[[!
		Function: load
		Autoloads a class and instantiates it
				
		Parameters:
			self -
			name - path to the class
			... - more arguments for the class
	]]	
	load = function(self, name, ...)
		return self:loadStatic(name)(...)
	end,

	--[[!
		Function: load
		Autoloads a class and returns
				
		Parameters:
			self -
			name - path to the class
			last - set the classname prepended by .
	]]		
	loadStatic = function(self, name, last)
		self:loadClass(name)
				
		local last = last or "."..name:gsub("(.*%.).-", "")
		
		return assert(loadstring("return _G."..name..last))() or self:log("as.core", "error", "Could not load class %(1)s (%(1)s%(2)s)", name, last)
	end,
	
	--[[!
		Function: loadClass
		Autoloads a class
		
		Parameters:
			self -
			name -
	]]
	loadClass = function (self, name)
		if not self.loaded[name] then
			require (name)
		end
	end,
	
	--[[!
		Function: log
		Logs a string to the logrouter when loaded
				
		Parameters:
			self -
			level - the config level, can be: debug, trace, info, notice, error, fatal
			category - the type of message
			string - the string
			... - additional parameters for formatting
		
		Note:
			just prins the messages to the screen now, no logrouter made
	]]
	log = function(self, level, category, string, ...)
		string = string % {...}
		print("[LOG]", string)
		return string
	end,
	
	--[[!
		Function: loadConfiguration
		Loads the config files, recursively merges them
				
		Parameters:
			self -
			config - a table or array containing the config files
	]]
	loadConfiguration = function(self, files)
		if type(config) ~= "table" then
			config = {config}
		end
		
		local config = {}
		
		for i, file in pairs(files) do
			local result = dofile(file)
			self:log("info", "as.core", "loading config file: %(1)s, %(2)s", file, tostring(result))
			_G.table.insert(config, result)
		end

		local settings = {}
		
		for i, file in pairs(config) do
			settings = table.merge(settings, file)
		end
		
		if self.debugConfig then
			table.table.print_r(settings)
		end
		
		self:initConfiguration(settings)
	end,
	
	--[[!
		Function: initConfiguration
		runs the config settings table
		
		Parameters:
			self -
			config - the configuration array
	]]
	initConfiguration = function(self, config)
		local preloading = {}
		
		local types = {
			components = function(self, value)
				
				if self.debugComponents then
					for name, _ in pairs(value) do
						self:log("info", "as.core", "Initializing %(1)s for autoload.", name)
					end
				end
				
				self.autoloadComponents = value
			end,
			
			preload = function(self, value)
				for i, name in pairs(value) do
					if self.debugComponents then
						self:log("debug", "as.core", "Setting %(1)s for preload", name)
					end
					
					_G.table.insert(preloading, name)
				end
			end,
		
			_default_ = function(self, value, key)
				if type(self) == "nil" then
					self.app:initConfigVar(key, value)
				else
					self[key] = value
				end
			end
		}
	
		for key, value in pairs(config) do
			if self.debugConfigVars then
				print ("config var", key, value)
			end
			
			if types[key] then
				types[key](self, value)
			else
				types._default_(self, value, key)
			end
		end
		
		--make shure preloading is done last
		for _, name in pairs(preloading) do
			if not self.autoloadComponents[name] then
				self:log("error", "as.core", "Cannot autoload component %(1)s ! component not found in the components table.", name)
			else
				self:initComponent(name,  self.autoloadComponents[name])
			end
		end
	end,

	--[[!
		Function: run
		runs the app
		
		Parameters:
			self -
	]]
	
	run = function(self)
		self:log("info", "as.core", "Starting server ...")
		self.app:run()
	end,
	
	
	--[[!
		Function: initComponent
		initializes a component
		
		Parameters:
			self -
			name - component name
			settings - component settings
	]]
	
	initComponent = function(self, name, settings)
		if self.debugComponents then
			print ("initcomponent", name, settings)
		end
		self.components[name] = new(settings.class)
		self.components[name]:initSettings(settings)
		self.components[name]:initDone()
		
		--cleanup
		self.autoloadComponents[name] = nil
		
		return self.components[name]
	end
	
}

setmetatable(as, {
	__call = function(table, ...)
		return table:init(...)
	end,
	
	__index = as.__get,
	__newindex = as.__set
})

--[[!
	Helper functions
]]
_G.new = function(...) return as:load(...) or error(("Could not load class %s"):format(...))  end
_G.static = function(...) return as:loadStatic(...) or error(("Could not load class %s"):format(...)) end
_G.depend = function(...) return as:loadClass(...) end

--[[
	Start loading other classess
	after core is loaded
]]

require "as.init"
