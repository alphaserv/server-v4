package.path = package.path .. ";script/package/?.lua;"
package.path = package.path .. ";script/stalkR/?.lua;"
package.path = package.path .. ";script/?.lua;"
package.cpath = package.cpath .. ";lib/lib?.so"

PREFIX = "script/stalkR/"

server = core
native_pcall = pcall

alpha = {}
alpha.fn = {} --extern accesable functions
alpha.standalone = true --is stalkR
alpha.spamstartup = false --Default: false

require "language.init"
require "event.init"

cubescript_library = require "cubescript_library"

local trigger_start = event.create_event("pre_started")
local trigger_started = event.create_event("started")--compatibility
local trigger_config = event.create_event("config_loaded")

alpha.module_prefix = "script/alphaserv/" --path to this directory
alpha.module_extention = ".lua" ----extention of the files

dofile(alpha.module_prefix..'utils'..alpha.module_extention)
dofile(alpha.module_prefix..'utils/string'..alpha.module_extention)
dofile(alpha.module_prefix.."loader"..alpha.module_extention)

local initmem = gcinfo()

--dofile(alpha.module_prefix..'core/package'..alpha.module_extention)
alpha.load.file("package", "core/package", "package manager")

alpha.load.file("settings", "core/settings", "settings library")
alpha.load.file("db", "core/db", "database")
--generate default config if file not found

--[[
alpha.settings._write_config("conf/defaults_stalkR.conf", "\n#############################\n# Default settings\n#############################\n# \n# Do NOT change,\n# they will be overwritten anyway.")--generate default config
alpha.settings.load("conf/defaults_stalkR.conf")
alpha.settings.load("conf/core.conf")
]]

trigger_config:trigger()
alpha.db:open("mysql")
alpha.db:connect()

--TODO: move to config
dofile('conf/stalkR_packages.lua')

event.event("started"):add_listner(function()
	local mem = gcinfo()
	
	alpha.log.message("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem)
	print(string.format("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem))
end)

trigger_start:trigger()
trigger_started:trigger()
trigger_start:remove()
trigger_started:remove()

--dofile(PREFIX.."web/init.lua")

dofile(PREFIX.."network.lua")
dofile(PREFIX.."master.lua")
dofile(PREFIX.."irc/main.lua")
