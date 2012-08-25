
local plugin = Plugin:new("DemoPlugin", 0.01)
module("DemoPlugin")
plugin.m = _M

plugin:import("event", "ev")
plugin:import({
	"message"
})
--[[
ev.addListner("connecting", function (event)
	if event.user.name == "unnamed" then
		Message:new("DemoPlugin.deny", "Noobs are not allowed on this server!"):send(event.user)
		event.cancel();
	end
end)]]

--overide enable function
function plugin:enable(...)
	self:log("info", "Enabling DemoPlugin")
	self:log("info", self.super.enable)
	return 	--self.super:enable(...)
end

--public callable function, cool
function plugin:cool()
	self:error("none")
end

-- assign public callable functions
plugin:export({
	"cool"
})

return plugin
