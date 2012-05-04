alpha = {}
alpha.fn = {} --extern accesable functions
alpha.spamstartup = false --Default: false
alpha.init_done = false
alpha.color = true

geoip = require("geoip")

require "language.init"

local trigger_start = server.create_event_signal("pre_started")
local trigger_config = server.create_event_signal("config_loaded")

if geoip.load_geoip_database("./share/GeoIP.dat") then
	print(" |sucessfully loaded geoip db file")
else
	if alpha.color then
		print(string.char(27).."[31m | could not load geoip db file"..string.char(27).."[0m")
	else
		print(" | could not load geoip db file")
	end
end

alpha.module_prefix = "script/alphaserv/" --path to this directory
alpha.module_extention = ".lua" ----extention of the files, deprecated

dofile('./script/alphaserv/utils.lua')
dofile('./script/alphaserv/utils/string.lua')
dofile(alpha.module_prefix.."loader.lua")

local initmem = gcinfo()

alpha.load.file("core/logging")

alpha.load.file("core/settings")
alpha.load.file("core/general")

alpha.load.file("core/package")

alpha.load.file("core/user")

--for authkey auth TODO: module
alpha.load.file("core/auth/core")

--generate default config if file not found
if server.file_exists("conf/core.lua") then
	alpha.load.file("conf/core.lua", true)
end

trigger_config()

--force proper configuration scheme
alpha.settings.write("conf/core.lua")

server.event_handler("started", function()
	local mem = gcinfo()
	
	alpha.log.message("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem)
	print(string.format("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem))
end)

trigger_start()
server.cancel_event_signal("pre_started")
server.cancel_event_signal("config_loaded")
alpha.init_done = true
