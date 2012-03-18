alpha = {}
alpha.fn = {} --extern accesable functions
alpha.spamstartup = false --Default: false
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
--alpha.load.file("utils", "utils", "util function")

alpha.load.file("package", "core/package", "package manager")

alpha.load.file("settings", "core/settings", "settings library")
alpha.load.file("general", "core/general", "generel serverwide used settings")

alpha.load.file("user", "core/user", "user api")

alpha.load.file("db", "core/db", "database abstraction layer")
alpha.load.file("logging", "core/logging", "log events to file")

--alpha.load.file("wcp_connection", "core/wcp_connection", "connection with web control panel")

alpha.load.file("authkey", "core/auth/core", "authkey auth hopmod implementation")
alpha.load.file("auth", "core/auth", "authenticate users and masterkey owners")

--alpha.load.file("acl", "core/acl", "access contro list, not finished.")
alpha.load.file("playervars", "core/playervars", "settings/state variables bound to specific players.")
alpha.load.file("messages", "core/messages", "send messages to players.")
--alpha.load.file("master", "core/master", "registration on masterserver.") --use module for this?

alpha.settings._write_config("conf/core.conf")--generate default config
alpha.settings._write_config("conf/defaults.conf", "\n#############################\n# Default settings\n#############################\n# \n# Do NOT change,\n# they will be overwritten anyway.")--generate default config
alpha.settings.load("conf/defaults.conf")
alpha.settings.load("conf/core.conf")
trigger_config()

--TODO: move to config
alpha.package.loadpackage("serverexec")
alpha.package.loadpackage("cd")
alpha.package.loadpackage("messages")
alpha.package.loadpackage("ban")

server.event_handler("started", function()
	local mem = gcinfo()
	
	alpha.log.message("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem)
	print(string.format("=> memory usage: %iKb (%iKb on init) diff: %iKb", mem, initmem, mem - initmem))
end)

trigger_start()
server.cancel_event_signal("pre_started")
server.cancel_event_signal("config_loaded")

