
module("banners", package.seeall)

banner_obj = class.new(nil, {

	banner_name = "banner",
	banner_default_message = "",
	banner_default_msg_type = "info",
	
	__init = function(self, name, default_message, msg_type)
		self.banner_name = name
		self.banner_default_message = default_message
		self.banner_default_msg_type = msg_type or "info"
	end,
	
	send = function(self, id)
		messages.load("banner", self.banner_name, {default_type = self.banner_default_msg_type, default_message = self.banner_default_message})
			:format(id)
			:send(players.groups.all(), false)
	end,
	
	save = function(self)
		--push to database
	
	end,
})

banners = {}
show_interval = 10000

function add_banner(banner_obj)
	banners[#banners+1] = banner_obj
	return banner_obj
end

function create_banner(name, default_message, msg_type)
	return add_banner(banner_obj(name, default_message, msg_type))
end

function update()
	--fetch from db
end

function send_banner(id)
	banners[id]:send(id)
end

local i = 1
function send_next_banner()

	if not banners[i] then
		i = 1
	else
		send_banner(i)
		i = i + 1
	end
end

local auto_banner = false
function start_auto_banner()
	if not auto_banner then
		auto_banner = true
		
		print("starting auto banner")
		
		server.interval(show_interval, function()
			if not auto_banner then
				print("stopping auto banner ...")
				return -1
			end
			
			print("sending autobanner message")
			send_next_banner()
		end)
	else
		print("already started!")
	end
end

function stop_auto_banner()
	auto_banner = false
end

function set_interval(secs)

	local old_interval = show_interval
	show_interval = secs * 1000
	
	if auto_banner then
		stop_auto_banner()
	end
	
			
	--make shure that the banner kills itself before restarting
	server.sleep(old_interval + 1000, start_auto_banner)
end
