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

module("alpha.core.package", package.seeall)

return function(as)
	local package_path = "script/alphaserv/packages/"

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

	local function loadPackage(name, version)
		local localPath

		if not version then
			localPath = string.format("%s%s/", package_path, name)
		else
			localPath = string.format("%s%s_%s/", package_path, name, version)
		end
	
		if loaded[string.format('%s_%s', name, version or "L")] then
			return true
		end

		local infoFile = localPath .. "info.lua"
	
		if not server.file_exists(infoFile) then
			error(localPath.." not a package")
		end
	
		local info = dofile(infoFile)
	
		for _, dependic in pairs(info.dependics or {}) do
			if type(dependic) == "string" then
				dependic = {name = dependic}
			end
		
			loadPackage(dependic.name, dependic.version or nil)
			
			if trackDeps then
				loaded[string.format('%s_%s', dependic.name, dependic.version or "L")].depends = {name, version}
			end
		end

		print("~| Loading package: %(1)s, version: %(2)s" % { name, version })
	
		local export = true	
		for _, file in pairs(info.load) do
			local ret = dofile(localPath..file)
			if info.export and info.export == file then
				export = ret
			end
		end
	
		if info.export then
			as[name] = export
		end
	
		loaded[string.format('%s_%s', name, version or "L")] = {
			unload = info.unload or function() end,
			
			--all packages depending on this one
			depends = {},
		}
	
		return true
	end
	
	return {
		loadPackage = loadPackage
	}
end
