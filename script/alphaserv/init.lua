alpha = {}
alpha.fn = {} --extern accesable functions
alpha.spamstartup = false --Default: false
alpha.init_done = false
geoip = require("geoip")

require "language.init"

local trigger_start = server.create_event_signal("pre_started")
local trigger_config = server.create_event_signal("config_loaded")
if geoip.load_geoip_database("./share/GeoIP.dat") then
        print("| sucessfully loaded geoip db file")
else
        print("| could not load geoip db file")
end

alpha.module_prefix = "script/alphaserv/" --path to this directory
alpha.module_extention = ".lua" ----extention of the files

dofile('./script/alphaserv/utils.lua')
dofile('./script/alphaserv/utils/string.lua')
dofile(alpha.module_prefix.."loader"..alpha.module_extention)

local initmem = gcinfo()
alpha.load.file("core/package")

alpha.load.file("core/settings")
alpha.load.file("core/general")

alpha.load.file("core/user")

alpha.load.file("core/db")
alpha.load.file("core/logging")

--alpha.load.file("wcp_connection", "core/wcp_connection", "connection with web control panel")

alpha.load.file("core/auth/core")

--generate default config if file not found
if not server.file_exists("conf/core.lua") then
	alpha.settings.write("conf/core.lua")
end

alpha.settings.write(
	"conf/defaults.lua",
	"-----------------------------\n"..
	"--[[\n"..
	"	Default settings\n"..
	"	Do NOT change,\n"..
	"	they will be overwritten anyway.\n"..
	"]]--\n"..
	"-----------------------------\n\n")--generate default config

alpha.load.file("conf/defaults.lua", true)
alpha.load.file("conf/core.lua", true)

exec("conf/server.conf")
trigger_config()

server.event_handler("started", function()
	local mem = gcinfo()
	
	alpha.log.message("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem)
	print(string.format("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem))
end)

trigger_start()
server.cancel_event_signal("pre_started")
server.cancel_event_signal("config_loaded")
alpha.init_done = true
