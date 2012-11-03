--module("init", package.seeall)
print "Starting the server ..."

require "script.env"
require "class"
require "utils"

require "as.config"
as.config.load()

require "as.server"
require "as.event"

local preStarted = as.event.createEvent("preStarted")

require "as.package"
require "as.serverexec"
require "as.cubescript"
require "as.auth.core"

require "as.user"
require "as.timer"
require "as.spectator"
require "as.auth"

require "luarocks.loader"

require "as.database"

as.config.init()
as.server.init()

as.event.init()
as.package.init()
as.serverexec.open()

as.user.init()
as.auth.init()

preStarted:addListner(function()
	print ("Starting server on port: "..as.server.serverport)
	print ("Starting server on port: "..tostring(core.vars.serverport()))

end)

preStarted:trigger()
preStarted:destroy()
