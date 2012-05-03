local modules = alpha.settings.new_setting("modules", {"serverexec", "logging"}, "A list of modules to load.")

module("alpha.package", package.seeall)

local loaded = {}
local package_path = alpha.module_prefix.."packages/"

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
