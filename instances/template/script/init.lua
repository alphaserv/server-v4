require "script.env"
require "as.core"

as.as({BASEPATH.."/base_config.lua", SERVERPATH.."/settings.lua"}, "server"):run()
