--[[!
    File: script/alphaserv/packages/chan_obj.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file contains the channel object wich represents events wich can happen in a channel and functions.

    Package: irc
]]

module("irc", package.seeall)

--[[!
	Class: channel_obj
]]

channel_obj = class.new(nil, {
	--[[!
		Property: name
		the name of the channel prefixed with a #
		
		Example:#alphaserv
	]]
	
	name = "",
	
	--[[!
		Property: joined_channel
		A boolean wich represents the joining state
	]]
		
	joined_channel = false,
	
	--[[!
		Property: joined_msg
		A message wich will be sent to the channel after join.
	]]
	join_msg = "",
	
	
	--[[!
		Property: users
		A table containing the users in a channel
	]]
	users = {},
	
	--[[!
		Property: network
		the network in wich this channel is available
	]]
	network = nil,
	
	--[[!
		Function: __init
		Initialises the channel object by setting the name
		
		Parameters:
			self -
			name - the name of the channel containing a #
	]]
	__init = function(self, name)
		if name[1] ~= "#" then
			error("invalid channel, channels start with a #")
			return
		end
		
		self.name = name
	end,
	
	--[[!
		Function: set_network
		sets the network
		
		Parameters:
			self -
			network - the network object
	]]
	set_network = function(self, network)
		self.network = network
	end,
	
	--[[
		Function: join
		Joines the channel if not already joined,
		sends JOIN #<name> to the network
		
		Parameters:
			self -
	]]
	join = function(self)
		if self.joined_channel then
			return
		end
		
		self.network:send("JOIN %(1)s", function() end, self.name)
		self.joined_channel = true
	end,
	
	joined = function(self)
		self.joined_channel = true
	end,
	
	after_join = function(self)
		if self.join_msg ~= "" and not self.sent_joinmessage then
			self.network:send("PRIVMSG %(1)s :%(2)s", function() end, self.name, self.join_msg)
			self.sent_joinmessage = true
		end
		
		self.network:send("NAMES %(1)s", function() end, self.name)
	end,
	
	disconnect = function(self)
		self.joined_channel = false
	end,
	
	add_user = function(self, nick, title)
		if not self.users then
			self.users = {} --why ?
		end
	
		if not self.network.users then
			self.network.users = {} --why ?
		end
	
		if not self.network.users[nick] then
			self.network.users[nick] = user_obj(name, "op")
		end

		self.network.users[nick]:channel_title(self.name, title)
		self.users[nick] = self.network.users[nick]
	end,
	
	--[[!
		function: update_users
		Updates the currently connected users from a string
		
		Parameters:
			self -
			userstring - A string containing all users
		
	]]
	update_users = function(self, userstring)
		for i, name in pairs(userstring:split(" ")) do
			
			if name[1] == "+" then
				name = name:sub(2)
				self:add_user(name, "voice")
			elseif name[1] == "@" then
				name = name:sub(2)
				self:add_user(name, "op")
			else
				self:add_user(name, "none")
			end
			
			log_msg(LOG_INFO, "detected user %(1)q" % { name })
		end
	end,
	
	check = function(self)
	
	end,
	
	sendto = function(self)
	
	end,
})
