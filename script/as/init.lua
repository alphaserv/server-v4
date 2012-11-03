

return function(configFiles)

	local alpha
	local server
	
	local function initServerTable()
		server = {}

		local properties = core.vars

		setmetatable(server,{
		
			__index = function(table, key)
				
				local value = core[key]
				
				if not value then
				    value = properties[key]
				    if type(value) == "function" then
				        value = value()
				    end
				end
				
				return value
			end,
		
			__newindex = function(table, key, value)
				
				local existing_property = properties[key]
				
				if existing_property and type(existing_property) == "function" then
				    existing_property(value)
				end
				
				core[key] = value
			end
		});
		
		require "as.core.event"
		
		server.event_handler = event_listener.add
		server.cancel_handler = event_listener.remove
		server.cancel_handlers = event_listener.clear_all
		server.create_event_signal = event_listener.create_event
		server.cancel_event_signal = event_listener.destroy_event
	end
	
	
	local function initConfig(configFiles)
		if type(configFiles) ~= "table" then
			configFiles = {configFiles}
		end
	
		table.insert(configFiles, "script/as/baseconf.lua")

		configFiles = table.reverse(configFiles)
		
		local conf = {}
		
		for i,v in pairs(configFiles) do
			conf = table.mergeRecursive(conf, dofile(v))
		end
		
		return conf
	end

	local trigger_start
	local trigger_ready
		
	local function initEvents()
		local trigger_start = server.create_event_signal("pre_started")
		local trigger_ready = server.create_event_signal("ready")

	end

	--!TODO move to module
	local function initGeoip()
		geoip = require("geoip")

		if geoip.load_geoip_database("./share/GeoIP.dat") then
			print(" |sucessfully loaded geoip db file")
		else
			if alpha.color then
				print(string.char(27).."[31m | could not load geoip db file"..string.char(27).."[0m")
			else
				print(" | could not load geoip db file")
			end
		end

		if geoip.load_geocity_database("./share/GeoCity.dat") then
			print(" |sucessfully loaded geocity db file")
		else
			if alpha.color then
				print(string.char(27).."[31m | could not load geocity db file"..string.char(27).."[0m")
			else
				print(" | could not load geocity db file")
			end
		end
	end

	local function initCore()
		--dofile('./script/alphaserv/utils.lua')
		--dofile('./script/alphaserv/utils/string.lua')
		--dofile(alpha.module_prefix.."loader.lua")
		
		--alpha.util = require "as.utils"

		--alpha.logging	= require ("as.core.logging")(alpha, server)
		alpha.package	= require ("as.core.package")(alpha, server)
		--alpha.user		= require "as.core.user"
		--require "as.core.auth.core"(alpha,server)
		
		--loaded all modules
		--trigger_start()
	end
	
	local function cleanup()
		server.cancel_event_signal("pre_started")
		server.cancel_event_signal("ready")
	end
	
	local function loadModules(conf)
		if not conf.modules then
			error("missing 'conf.modules' in config file!")
		end
		
		for name, info in pairs(conf.modules) do
			if not info.class then
				print ("missing '["..name.."].class'! not loading.")
			else
				alpha:loadClass(info):moduleInit(info)
			end
		end
	end

	local function initFunctions()
		function alpha:loadClass(info)
			local e
			info:gsub("^(.-):(.*)$", function(module, class)
				alpha:depend(module)
				e = _G
				local parts = class:split(".")
			
				for i, part in pairs(parts) do
					e = e[part]
				
					if not e then
						error("Invalid class: '"..class.."' !")
					end
				end
			
				if e.getInstance then
					e = e.getInstance()
				else
					e = e(info)
				end
			end)
		
			return e
		end
	
		function alpha:createComponent(info)
			return alpha:loadClass(info)
		end

		function alpha:run()

		end
		
		function alpha:depend(package_)
			self.package:loadPackage(package_)
		end
		
		function alpha:require(selfModule, name)
			name:gsub("^(.-):(.*)$", function(module, class)
				alpha:depend(module)
				require (class)	
			end)
		end
	end

	local function init()
		package.path = package.path .. ";script/package/?.lua;"
		package.path = package.path .. ";script/package/?/init.lua;"
		package.path = package.path .. ";script/?.lua;"
		package.cpath = package.cpath .. ";lib/lib?.so"
		
		require "class"
		require "utils"

		alpha = {}
		alpha.spamstartup = false --Default: false
		alpha.init_done = false
		alpha.color = true
		alpha.packages = {}
		
		initServerTable()
		initEvents()
		initFunctions()
		initCore()
				
--		initConfig(type(configFiles) == "table" and configFiles or {configFiles})
--		alpha.init_done = true				
	end

	init()
	
	alpha.package:loadPackage("example")
	
	return alpha, server
end
