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
    
	Package: as.package
]]

module("as.package", package.seeall)

local package_path = "script/as/packages/"

--[[!
	Var: loaded
	a list of all the loaded packages
]]
local loaded = {}
	
--[[!
	var: trackDeps
	whether to track dependics
]]
local trackDeps = true

--[[!
	Function: loadPackage
	Closes one specific file

	Parameters:
	    name - The Package name.
	    version - The version of the package, defaults to latest (nothing appended).
]]

function loadPackage(self, name)
	local localPath = string.format("%s%s/", package_path, name)
	
	if loaded[name] then
		return true
	end
		
	loaded[name] = {}

	local infoFile = localPath .. "info.lua"
	
	if not server.file_exists(infoFile) then
		error(localPath.." is not a package!")
	end

	--change search paths temporarily, force usage of :depend
	local oldPath = package.path
	package.path = localPath .. "?.lua"

	--all packages depending on this one
	loaded[name].depending = {}
			
	--depending on these modules
	loaded[name].dependency = {}
	
	local info = dofile(infoFile)
	
	for _, dependic in pairs(info.dependics or {}) do
		if type(dependic) == "string" then
			dependic = {name = dependic}
		end
		
		loadPackage(dependic.name)
			
		--add search path
		package.path = string.format("%s;%s%s/?.lua", package.path, package_path, name)
			
		if trackDeps then
			table.insert(loaded[dependic.name].depending, name)
			table.insert(loaded[name].depending, dependic.name)
		end
	end

	print("~| Loading package: %(1)s" % { name })
	
	--load these files on init
	if info.load then
		local export = true	
		for _, file in pairs(info.load) do
			local as = alpha
			local ret = require (file)
			if info.export and info.export == file then
				export = ret
			end
		end
	
		if info.export then
			as.packages[name] = export
		end
	end
	
	--unload function
	loaded[name].unload = info.unload or function() end

	package.path = oldPath
	
	return true
end

function init()

end

