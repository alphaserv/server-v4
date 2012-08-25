

return function(config)

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
		
		require "core.event"
		
		server.event_handler = event_listener.add
		server.cancel_handler = event_listener.remove
		server.cancel_handlers = event_listener.clear_all
		server.create_event_signal = event_listener.create_event
		server.cancel_event_signal = event_listener.destroy_event
	end
	
	
	local function initConfig(config)
		if type(config) ~= "table" then
			config = {config}
		end
	
		table.insert(config, "script/alphaserv/baseconf.lua")

		local size = #config
		local reversed = {}
	 
		for i,v in ipairs ( config ) do
		    reversed[size-i] = v
		end
		
		local conf = {}
		
		for i,v in pairs(reversed) do
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

		if geoip.load_geocity_database("./share/GeoLiteCity.dat") then
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
		
		alpha.util = require "utils"

		alpha.logging = require ("core.logging")(alpha, server)
		alpha.package = require ("core.package")(alpha, server)
		alpha.user = require "core.user"
		require "core.auth.core"(alpha,server)
		
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
	end

	local function init()
		package.path = package.path .. ";script/package/?.lua;"
		package.path = package.path .. ";script/package/?/init.lua;"
		package.path = package.path .. ";script/alphaserv/?.lua;"
		package.cpath = package.cpath .. ";lib/lib?.so"
		
		require "class"

		alpha = {}
		alpha.spamstartup = false --Default: false
		alpha.init_done = false
		alpha.color = true

		alpha.module_prefix = "script/alphaserv/" --path to this directory
		alpha.module_extention = ".lua" ----extention of the files, deprecated
		
		initServerTable()
		initEvents()
		initFunctions()
		initGeoip()
		
		initCore()
		
		initConfig(type(config) == "table" and config or {config})
		alpha.init_done = true				
	end

	init()
	
	return alpha, server
end
