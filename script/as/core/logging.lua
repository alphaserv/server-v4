--[[!
    File: script/alphaserv/core/logging.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file handles files to log to and manages debuging

    Package: alpha.log
]]

module("alpha.core.log", package.seeall)

local logLevel = {
	DEBUG = 0,
	INFO = 1,
	NOTICE = 2,
	WARNING = 3,
	ERROR = 4
}

local logNames = {
	[logLevel.DEBUG]	= "debug",
	[logLevel.INFO]		= "info",
	[logLevel.NOTICE]	= "notice",
	[logLevel.WARNING]	= "warning",
	[logLevel.ERROR]	= "error"
}

baseLogRoute = Object:subclass("baseLogRoute")
baseLogRoute.isClass = true
baseLogRoute.categories = {}
baseLogRoute.logLevels = {
	[logLevel.DEBUG]	= false,
	[logLevel.INFO]		= false,
	[logLevel.NOTICE]	= false,
	[logLevel.WARNING]	= false,
	[logLevel.ERROR]	= false
}
baseLogRoute.settings = {}

function baseLogRoute:init(settings)
	if type(settings[1]) ~= "table"
	or type(settings[2]) ~= "table"
	or type(settings[3]) ~= "table"
	then
		error("invalid arguments {{categories}, {loglevels}, {options}}")
	end
	
	self.settings = settings[3]
	
	self.categories = settings[1]
	
	for i, lvl in pairs(settings[2]) do
		if lvl == "debug" then
			self.logLevels[logLevel.DEBUG]	= true
		elseif lvl == "info" then
			self.logLevels[logLevel.INFO]	= true
		elseif lvl == "notice" then
			self.logLevels[logLevel.NOTICE]	= true
		elseif lvl == "warning" then
			self.logLevels[logLevel.WARNING]	= true
		elseif lvl == "error" then
			self.logLevels[logLevel.ERROR]	= true
		elseif lvl == "*" then
			self.logLevels = {
				[logLevel.DEBUG]	= true,
				[logLevel.INFO]		= true,
				[logLevel.NOTICE]	= true,
				[logLevel.WARNING]	= true,
				[logLevel.ERROR]	= true
			}
			break;
		end
	end
end

function baseLogRoute:log(lvl, category, message)
	if self.logLevels[lvl] ~= true then
		return false
	end
	
	local found = false
	for i, cat in pairs(self.categories) do
		if cat == category then
			found = true
			break;
		end
	end
	
	if not found then
		return false
	end
	
	self:logMessage(lvl, category, message)
end

function baseLogRoute:logMessage(lvl, category, message)
	print("%(4)s [%(1)s : %(2)s] %(3)s" % {logNames[lvl], category, message, os.date("[%a %d %b %X] ",os.time())})
end


return function(as, server)
	local logRoutes = {
		baseLogRoute {
			{"*"}, {"*"}, {}
		}
	}

	local function initConfig(config)
		for i, router in pairs(config) do
			if router.isClass then
				table.insert(logRoutes, router)
			else
				table.insert(logRoutes, as:createComponent(config))
			end				
		end
	end
	
	local function log(level, category, message, args)
		message = message % (args or {})
		
		for i, logRoute in pairs(logRoutes) do
			logRoute:log(level, category, message)
		end
	end
end
