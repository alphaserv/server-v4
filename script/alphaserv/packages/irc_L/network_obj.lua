--[[!
	File: script/alphaserv/packages/network_obj.lua

	About: Author
		Killme

	About: Copyright
		Copyright (c) 2012 Alphaserv project

	About: Purpose
		This file contains the network object wich handles connections with the server and the channels.

	Package: irc
]]

module("irc", package.seeall)

require "net"

--[[!
	Class: network_obj
]]

network_obj = class.new(nil, {

	--[[!
		Property: channel
		An array containing all channel objects
	]]
	channels = {},

	--[[!
		Property: Users
		An array containing all user objects
	]]
	user = {},
	
	--[[!
		Property: client
		The net tcp socket handler
	]]
	client = nil,
	
	--[[!
		Property: nick
		The nickname of the bot
	]]
	nick = "testbot",
	
	--[[!
		Property: username
		The username of the bot
	]]
	username = "me-testbot",
	
	--[[!
		Property: host
		The host of the irc network
	]]
	host = "",
	
	--[[!
		Property: port
		The port of the irc network
	]]
	port = nil,
	
	--[[!
		Property: lastsend
		The last time that we sent a message to the irc network,
		used to prevent flooding.
		
		Note: this uses os.clock() not os.time()
	]]
	lastsend = 0-os.clock(),
	
	--[[!
		Property: flood_interval
		The interval between sending messages to the network
	]]
	flood_interval = 500,
	
	--[[!
		Propery: adress
		the local adress
	]]
	adress = {ip = "", port = ""},
	
	--[[!
		Property: connected
		A boolean wich represents the connection state since we only connect when <connect> is called
	]]
	connected = false,
	
	--[[!
		Function: __init
		Initializes the client, host and port.
		
		Note: doesn't actual connect
		
		Parameters:
			self -
			host - the hostname of the irc network
			port - the port of the irc network
	]]
	__init = function(self, host, port)
		self.client = net.tcp_client()
		
		self.host = host
		self.port = port
	end,
	
	--[[!
		Function: send
		Sends a message to the irc network
		
		Note: the message is not directly sent, it will be cached locally to prevent flooding
		See Also: <flood_interval>
		
		Property:
			self -
			command - the string to send, may contain %(*)s wich will be replaced with ...
			callback - the function to call when the send is completed
			... - arguments for %{}
	]]
	
	send = function(self, command, callback, ...)
		command = command % arg
		
		print("[IRC] send request: %(1)q" % { command })
		
		--prevent foold disconnects
		if os.clock() > self.flood_interval + self.lastsend then
			print("[IRC] Buffering: %(1)q %(2)s + %(3)i" % { command, os.time(), self.flood_interval })
			server.sleep(self.flood_interval, function()
				self:send(command, callback)
			end)
		else
			self.lastsend = os.time()
			print("[IRC] sending: %(1)q" % { command })
		
			self.client:async_send(command.."\n", function(errmsg)
				if errmsg then
					error(errmsg)
					return
				else
					callback(self, command)
				end
			end)
		end
	end,
	
	--[[!
		Function: message
		sends a colored PRIVMSG to the network.
		
		Available colors:
			*white<>
			*black<>
			*navy<>
			*green<>
			*red<>
			*brown<>
			*mahenta<>
			*orange<>
			*yellow<>
			*brigt_green<>
			*light_blue<>
			*neon<>
			*blue<>
			*pink<>
			*grey<>
			*light_grey<>
		
		Parameters:
			self -
			to - The channel or the nickname to send the message to
			msg - the message to send, may be formated with *color*<> codes
	]]
	message = function(self, to, msg)
		msg = msg or "red<Internal Error>"
		msg = msg:gsub("white<(.-)>",		function(word) return string.format("\0030%s\003", word) end)
		msg = msg:gsub("black<(.-)>",		function(word) return string.format("\0031%s\003", word) end)
		msg = msg:gsub("navy<(.-)>",		function(word) return string.format("\0032%s\003", word) end)
		msg = msg:gsub("green<(.-)>",		function(word) return string.format("\0033%s\003", word) end)
		msg = msg:gsub("red<(.-)>",			function(word) return string.format("\0034%s\003", word) end)
		msg = msg:gsub("brown<(.-)>",		function(word) return string.format("\0035%s\003", word) end)
		msg = msg:gsub("magenta<(.-)>",		function(word) return string.format("\0036%s\003", word) end)
		msg = msg:gsub("orange<(.-)>",		function(word) return string.format("\0037%s\003", word) end)
		msg = msg:gsub("yellow<(.-)>",		function(word) return string.format("\0038%s\003", word) end)
		msg = msg:gsub("bright_green<(.-)>",function(word) return string.format("\0039%s\003", word) end)
		msg = msg:gsub("light_blue<(.-)>",	function(word) return string.format("\00310%s\003", word) end)
		msg = msg:gsub("neon<(.-)>",		function(word) return string.format("\00311%s\003", word) end)
		msg = msg:gsub("blue<(.-)>",		function(word) return string.format("\00312%s\003", word) end)
		msg = msg:gsub("pink<(.-)>",		function(word) return string.format("\00313%s\003", word) end)
		msg = msg:gsub("grey<(.-)>",		function(word) return string.format("\00314%s\003", word) end)
		msg = msg:gsub("light_grey<(.-)>",	function(word) return string.format("\00315%s\003", word) end)
		
		self:send("PRIVMSG %(1)s :%(2)s", function() end, to, msg)
	end,
	
	--[[!
		Function: add_channel
		Adds a channel to the channel table.
		
		Note: this allso will call <set_network> on the channel_obj
		
		Parameters:
			self -
			channel - The name of the chan containing a # or an instance of channel_obj
		
		Return:
			the channel object instance
	]]
	add_channel = function(self, channel)
		if type(channel) == "string" then
			channel = channel_obj(channel)
		end
		
		channel:set_network(self)
		
		self.channels[channel.name] = channel
		
		return channel
	end,
	
	--[[!
		Function: join_channels
		Joins the channels in the channel table by calling <join>.
		
		Parameters:
			self -
	]]		
	join_channels = function(self)
	
		for i, channel in pairs(self.channels) do
			if not channel.joined_channel then
				channel:join()
			end
		end
	end,
	
	--[[!
		Function: Connect
		Conntects to the irc network.
		
		Note: this will also automatically set the nick by calling <updatenick> and it's username by calling <updateusername>
		
		Parameters:
			self -
	]]
	
	connect = function(self)
		self.client:async_connect(self.host, self.port, function(errmsg) 
		
			if errmsg then
				error(errmsg)
				return
			else
				self.connected = true
				self.adress = self.client:local_endpoint()
				print("[IRC] : Local socket address %(1)s:%(2)s" % { self.adress.ip, self.adress.port })
				
				self:updatenick(function() self:updateusername() end)
			end
		end)
	end,
	
	--[[!
		Function: updatenick
		Sends the current nickname to the irc network.
		
		Parameters:
			self -
			callback - A function that will be executed when the message is sent.
	]]
	
	updatenick = function(self, callback)
		self:send("NICK %(1)s", callback or function() end, self.nick)
	end,
	
	--[[!
		Function: updateusername
		Sends the current username to the irc network.
		
		Parameters:
			self -
	]]
	
	updateusername = function(self)
		self:send("USER %(1)s 8 * %(2)s", function() self:startreading() end, self.username, "8", "*", "alphaserv_irc_bot")
	end,
	
	--[[!
		Function: startreading
		Starts the reading process.
	]]
	
	startreading = function(self)
		print("[IRC] Start reading")
		self:read()
	end,
	
	--[[!
		Function: onready_func
		The function that will be executed when we successfully are connected to the network, and or nickname is set.
		
		Note:
			this calls <join_channels> by default.
		
		Parameters:
			network - the irc network object instance
	]]
	onready_func = function(network)
		network:join_channels()
	end,
	
	--[[!
		Function: ready
		calls the ready function and replaces it with an empty one
	]]
	
	ready = function(self)
		self.ready = function() end
		
		self:onready_func()
		
	end,
	
	--[[!
		Function: onready
		Sets the <onready_func> function
		
		Parameters:
			self -
			func - the function to be executed when the server connected.
	]]
	onready = function(self, func)
		self.onready_func = func
	end,
	
	--[[
		Function: command
		Parses commands from messages and executes them using the command module.
		
		Parameters:
			self -
			nick - the nickname of the user
			channel - the channel name, or the nickname of the user
			command_msg - the message wich the user has sent
	]]
	command = function(self, nick, channel, command_msg)
		if command_msg[1] == "#" or nick == channel then
			if nick ~= channel then
				command_msg = command_msg:sub(2)
			elseif command_msg:find("^auth") then
				local cmd = command_msg:gsub("^([^ ]) ")
				cmd = cmd:split(" ")
				
				local username
				local pwd
				
				if #cmd == 1 then
					username = nick
					pwd = cmd[1]
				elseif #cmd == 2 then
					username = cmd[1]
					pwd = cmd[2]
				else
					self:message(channel, "Could not authenticate: too many or too little arguments, usage: auth <pass>")
					return
				end
				
				if not auth then
					self:message(channel, "Could not authenticate: authentication module not loaded, please contact the bot owner")
					return
				end
				
				local result, messages = auth.checkall("auth", self.users[nick], pwd)
				
				for i, msg in pairs(messages) do
					self:message(channel, msg)
				end
				
			end
			
			command_msg = command_msg:split(" ")
			local result = pack(command.execute_command(self.users[nick], unpack(command_msg)))
			
			if result[1] == false then
				if result[2] == true then --nextgen messages
					self:message(channel, result[4].default_message % result[3])
					return
				end
			elseif result[1] == true then
				if result[2] == true then --nextgen messages
					self:message(channel, result[4].default_message % result[3])
				end
			end
			
			if not result[1] then
				self:message(channel, "command failed:")
			end
			
			if type(result[2]) == "table" then
				for i, message in pairs(result[2]) do
					self:message(channel, message)
				end
			elseif type(result[2]) == "string" then
				self:message(channel, result[2])
			end
		end
	end,
	
	--[[
		Function: read
		The main read loop wich processes all data from the network
		
		Parameters:
			self - 
	]]	
	read = function(self)
		self.client:async_read_until("\n", function(data)
			if data then
				data = data:gsub("\r", "")--remove \r
				data = data:gsub("\n", "")--remove \n
				print("[IRC] data: "..data)
				
				if data.find(data,"PING") then
					local pong = string.gsub(data,"PING","PONG",1)
					self:send(pong, function() end)

				--:*!~*@* INVITE alphabot #...
				elseif data:match("^(.-)!.+ INVITE "..self.nick.." #(.*)") then				
					local nick, cn = data:match("^(.-)!.+ INVITE "..self.nick.." #(.*)")
					print(nick.." invites us. joining #"..cn)
					self:add_channel("#"..cn)
					self:join_channels()
					
				--:nick!~...@... JOIN :#...
				elseif data:match("^:"..self.nick.."!~"..self.username.."@.- JOIN :#(.-)") then
					local channel = data:match("^:"..self.nick.."!~"..self.username.."@.- JOIN :#(.+)")
					
					print(channel)
					
					if not self.channels["#"..channel] then
						print("server sent join on a non-existing channel")
						print(table_to_string(self.channels))
					else
						self.channels["#"..channel]:joined()
					end
				
				--:ChanServ!ChanServ@Services.GameSurge.net MODE #... +v alphabot
				elseif data:match("^:.-!.-@.- MODE #(.-) (.-) "..self.nick) then
					local channel, mode = data:match("^:.-!.-@.- MODE #(.-) (.-) "..self.nick)
					
					if not self.channels["#"..channel] then
						print("server sent MODE on a non-existing channel")
						print(table_to_string(self.channels))
					else
						self.channels["#"..channel]:after_join(mode)
					end
				
				
				--:ChanServ!ChanServ@Services.GameSurge.net KICK #... alphabot :...
				elseif data:match("^:(.-)!.-@.- KICK #(.-) "..self.nick.." :(.*)") then
					local user, channel, message = data:match("^:(.-)!.-@.- KICK #(.-) "..self.nick.." :(.*)")
					
					if not self.channels["#"..channel] then
						print("server sent KICK on a non-existing channel")
						print(table_to_string(self.channels))
					else
						print("[IRC] [KICKED] we were kicked from #%(1)s by %(2)s (%(3)s)" % { channel, user, message })
						--rejoin
						self.channels["#"..channel]:disconnect("kick")
						self.channels["#"..channel]:join()
					end
					
				--:GameConnect.NL.EU.GameSurge.net 353 alphabot @ #... :alphabot @killme_nl @... +CIA-4 @ChanServ
				elseif data:match("^:.- 353 "..self.nick.." @ #(.-) :(.*)") then
					local channel, ops = data:match("^:.- 353 "..self.nick.." @ #(.-) :(.*)")
										
					if not self.channels["#"..channel] then
						print("server sent KICK on a non-existing channel")
						print(table_to_string(self.channels))
					else
						print("[IRC] OPS: "..ops)

						self.channels["#"..channel]:update_users(ops)
					end
			
				elseif data:match("NOTICE "..self.nick) then
					self:ready()
				elseif data.find(data,"Closing Link") then
					error("Link Closed")
				elseif string.match(data,"^:(.-)!.+ PRIVMSG (.-) :(.*)") then
					local nick, channel, command = string.match(data,"^:(.-)!.+ PRIVMSG (.-) :(.*)")
					
					if not self.users then
						self.users = {} --why ?
					end
					
					if not self.users[nick] then
						self.users[nick] = user_obj()
						self.users[nick]:add_chan(channel)
					end
					
					if command[1] == ""
					or command == "VERSION"
					then
						--TODO: implement
						print("no CTCP")
					else

						if channel == self.nick then
							channel = nick
						end
						
						local res, error = native_pcall(function()
						   self:command(nick, channel, command)
						end)
						
						if not res then
							log_msg(LOG_ERROR, "error on command execution: "..error)
							self:message(channel, "Internal error: "..error)
						end
					end
				end				
				
				self:read()
			else
				error("EOF from server")
			end
		end)
	end,
})
