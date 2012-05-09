
module("master.server", package.seeall)
require "Json"
--server authentication keys

local server_secrets = alpha.settings.new_setting("server_secrets", {[9999] = "AAAAAAAAA"}, "The secrets of the servers")

local function generate_login_key(master_msg, server_id, server_key)
	return crypto.tigersum(string.format("%i %s %s", server_id, master_msg, server_key))
end

server_obj = class.new(nil, {
	server = nil,
	
	__init = function(self, ip, port)
		self.server, error_ = net.tcp_acceptor(ip, port)
		
		print(ip, port)
		
		if not self.server then
			error("Failed to open a listen socket on " .. ip .. ":" .. port .. ": " .. error_, 1)
		end
		
		self.server:listen()
		
		print("Masterserver listning on %(1)s:%(2)s" % { ip, port })
	end,
	
	accept = function(self)
		self.server:async_accept(function (server)
			remote = server:remote_endpoint(server)
			
			print(string.format("[Client] : (%s:%s) | accepted", remote.ip, remote.port))
			
			accepted_obj(server, remote):read()
			self:accept()
		end)
	end,
})

accepted_obj = class.new(nil, {
	connection = nil,
	remote = nil,
	rand_id = 0,
	auth_status = 0, --0 = not authed
					 --1 = sending authrequest
					 --2 reserved
					 --3 = authed
	
	__init = function(self, connection, remote)
		self.connection = connection
		self.remote = remote
	end,
	
	send = function(self, message, ...)
		message = message % {...} 
		
		if message == "" then
			return
		end
		
		print(string.format("[Client] : (%s:%s) | sending: %s", self.remote.ip, self.remote.port, message))
		self.connection:async_send(message.."\n", function(success) end)
	end,
	
	close_current = function(self)
		self.connection:close()
	end,
	
	send_serverlist = function(self)
		for i, server in pairs(master.servers or {ip = "localhost; echo [error :(]; echo ", port= "0"}) do
			self:send("addserver %(1)s %(2)i", server.ip, server.port)
		end
	end,
	
	read = function(self)
		self.connection:async_read_until("\n", function(data)
			if data and data ~= "" then
				print(string.format("[Client] : (%s:%s) | reading: %s", self.remote.ip, self.remote.port, data))
				
				if data[1] ~= "[" and data[1] ~= "{" then
					--strip \n
					data = data:gsub("\n", "")

					arguments = data:split(" ")
				
					--process the data
					print("calling: %(1)s" % {arguments[1]})
				
					--send serverlist
					if arguments[1] == "list" then
						self:send_serverlist()
						self:close_current()
						return
					elseif arguments[1] == "regserv" then
						--TODO
					end
				else
					local buff = Json.Decode(data)
					
					local sendbuff = {}
					
					local i = 0
					local function send(msg)
						i = i + 1
						sendbuff[i] = msg
						
						print("Send: "..table_to_string(msg))
					end
					
					local id
					for i, msg in pairs(buff) do
						if msg[1] == "id" then
							id = msg[2]
						elseif not id then
							self:error("protocol", "malformated message!")
							break
						elseif msg[1] == "init" then
							send({"serverauth", self.rand_id})
							break --we do not allow other messages afterwards
						elseif msg[1] == "serverauth" then
							if msg[2] ~= generate_login_key(self.rand_id, id, server_secrets:get()[id]) then
								self:error("serverauth", "auth failed!")
							else
								send({"serverauth_success", "Welcome"})
								self.auth_status = 3
							end
						elseif self.auth_status ~= 3 then
							self:error("protocol", "unauthed message!")
							break
						elseif msg[1] == "names" then
							send({"namelist", {"killme_nl"}})
						elseif msg[1] == "clans" then
							send({"clanlist", {"_nl"}})
						elseif msg[1] == "login" then
							local user = {{id = 0, name = "killme_nl", pass = "TEST" }}
							
							if msg[4] == crypto.tigersum(string.format("%i %i %s", msg[3], msg[2], user[1].pass)) then
								send({"login", msg[2], true, "aaa", {email = "a@b.com"}})
							else
								send({"login", msg[2], false})
							end
						end
					end
					
					self:send(
						Json.Encode(sendbuff)
					)
										
					buff = nil
					sendbuff = nil
				end
		
				self:read()
   		    else
   		        self:error("read", "data is empty")
   		    end
	    end)
	end,
	
	error = function(self, event, message, ...)
		print("error on %(1)s : %(2)s" % {event, message % {...}})
	end,
	
})

local master = server_obj("0.0.0.0", 28787)
master:accept()
