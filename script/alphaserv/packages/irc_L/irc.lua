module("irc", package.seeall)

user_obj = class.new(alpha.user.user_base_obj, {
	nick = "",
	joined_chans = {},
	
	channel_title = function(self, chan, title)
		self.joined_chans[chan] = title
	end,
	
	add_chan = function(self, name)
		if not self.joined_chans[name] then	
			self.joined_chans[name] = "none"
		end
	end,
	
	name = function(self)
		return self.nick
	end
})

networks = {}

function add_network(host, port)
	local network = network_obj(host, port)

	table.insert(networks, network)
	
	return network
end

local table = alpha.settings.new_setting("irc_networks", {
	{
		ip = "irc.gamesurge.net", 
		port = 6667,
		channels = {
			["#alphaserv-server"] = {
				join_msg = "",
			},
		},
		
		settings = {
			ignore_non_ops = false,
			nick = "testbot",
			username = "alpha-bot",
			flood_interval = 2000
		}
	}
}, "A hierachy of networks, channels and settings.")


server.event_handler("pre_started", function()
	local settings = table:get()
	
	local settings_possible = {
		ignore_non_ops = true,
		nick = true,
		username = true,
		flood_interval = true		
	}
	
	for i, network in pairs(settings) do
		local net = add_network(network.ip, network.port)
		
		if network.channels then
			for name, settings in pairs(network.channels) do
				if type(settings) == "string" then
					net:add_channel(settings)
				else
					local chan = channel_obj(name)
					
					if settings.join_msg then
						chan.join_msg = settings.join_msg
					end
					
					net:add_channel(chan)
				end
			end
		end
		
		if network.settings then
			for key, value in pairs(network.settings) do
				if settings_possible[key] then
					net[key] = value
				else
					log_msg(LOG_ERROR, "Unknown setting in network config array named: "..key)
				end
			end
		end

		print("[IRC] connectiong to network "..network.ip..":"..network.port)
		net:connect()
	end
end)

--used by message module
function send (message)
	for i, network in pairs(networks) do
		if network.connected then
			network:message("#alphaserv-server", message)
		end
	end
end
