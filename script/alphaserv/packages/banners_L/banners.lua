
module("banners", package.seeall)

restart_timer = function() end

local running = false
local timer

alpha.settings.register_type("banner_var", class.new(alpha.settings.setting_obj, {
	set = function(self, value)
		self.setting = value
		
		if running then
			restart_timer()
		end
		
		return self
	end
}))

local banners = alpha.settings.new_setting("banners", {"Runnign green<alphaserv>"}, "The banner messages of the banner module", "banner_var")
local interval = alpha.settings.new_setting("interval", 30000, "The time between banner messages.", "banner_var")



i = 1

function send_next()
	local banners = banners:get()
	if not banners[i] then
		if #banners == 0 then
			running = false
			return -1
		end
		
		i = 1
		send_next()
		return
	end
	
	messages.load("banners", "banner", {default_type = "info", default_message = "blue<info %(1)i:> blue<%(2)s>" })
		:unescaped_format(i, banners[i])
		:send()
	
	i = i + 1
end

function start()
	timer = server.interval(interval:get(), send_next)
	running = true
end

function stop()
	if not running then return end
	server.cancel_timer(timer)
end

restart_timer = function()
	stop()
	start()
end

server.event_handler("started", start)
