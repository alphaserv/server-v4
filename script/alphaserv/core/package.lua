--[[!
    File: script/alphaserv/core/package.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file handles loading of modules and their dependics.

    About: Settings
    	modules - A list of modules to load, these are loaded on the "config_loaded" event.

    Section: Alphaserv Core
    
	Package: alpha.package
]]

local modules
if not alpha.standalone then
	modules = alpha.settings.new_setting("modules", {"serverexec", "logging"}, "A list of modules to load.")
else
	modules = alpha.settings.new_setting("modules", {"irc", "quote", "serverexec"}, "A list of modules to load.")
end

module("alpha.package", package.seeall)

local loaded = {}
local package_path = alpha.module_prefix.."packages/"

--[[!
    Function: loadpackage
    Closes one specific file

    Parameters:
        name - The Package name.
        version - The version of the package, defaults to latest (L).
]]

function loadpackage(name, version)
	if not version or version == nil then
		version = "L"
	end
	
	if loaded[string.format('%s_%s', name, version)] then
		return true
	end

	print("~| Loading package: %(1)s, version: %(2)s" % { name, version })
	
	local info = dofile(string.format(package_path.."%s_%s/info.lua", name, version))
	
	for _, dependic in pairs(info.dependics or {}) do
		if type(dependic) == "string" then dependic = {name = dependic} end
		depend(dependic.name, dependic.version or "")
	end
	
	local_package_path = string.format("%s%s_%s/", package_path, name, version)
	
	for _, file in pairs(info.load) do
		alpha.load.file(local_package_path..file, true)
	end
	
	loaded[string.format('%s_%s', name, version)] = true
	
	return true
end

--[[!
    Function: depend
    Internally used to recursively load dependics

    Parameters:
        name - The Package name.
        version - The version of the package, defaults to latest (L).
]]

function depend(name, version)
	if not loadpackage(name) and false then
		error("could not find dependic %(1)q version: %(2)q" % { name, version })
	end
end

local event
event = server.event_handler("config_loaded", function()
	for i, module in pairs(modules:get()) do
		if type(module) == "table" then
			loadpackage(module.name, module.version)
		else
			loadpackage(module)
		end			
	end
	server.cancel_event_signal("config_loaded")
	event = nil
end)
