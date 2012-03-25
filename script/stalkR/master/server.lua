
module("master.server", package.seeall)
server_obj = class.new(nil, {
	server = nil,
	accepted_server = nil,
	
	remote = {ip = "", port = ""},
	
	__init = function(self, ip, port)
		self.server, error_ = net.tcp_acceptor(ip, port)
		
		if not self.server then
			error("Failed to open a listen socket on " .. ip .. ":" .. port .. ": " .. error_, 1)
		end
		
		self.server:listen()
		
		print("Masterserver listning on %(1)s:%(2)s" % { ip, port })
		
		self:accept()
	end,
	
	accept = function(self)
		self.server:async_accept(function (server)
			self.remote = server:remote_endpoint(server)
			
			master.debug("[Client] : (%s:%s) | accepted", self.remote.ip, self.remote.port)
			
			self.accepted_server = server
			self:read()
		end)
	end,
	
	send = function(self, message, ...)
		message = message % {...} 
		
		master.debug("[Client] : (%s:%s) | sending: %s", self.remote.ip, self.remote.port, message)
		self.accepted_server:async_send(message.."\n", function(success) end)
	end,
	
	close_current = function(self)
		self.accepted_server:close()
	end,
	
	send_serverlist = function(self)
		for i, server in pairs(master.servers) do
			self:send("addserver %(1)s %(2)s", server.ip, server.port)
		end
	end,
	
	read = function(self)
	
		self.accepted_server:async_read_until("\n", function(data)
			if data then
				
				if data == "" then return end
				
				data = data:gsub("\n", "")
				
				arguments = data:split(" ")
				
				--process the data
				print("calling: %(1)s" % {arguments[1]})
				
				if arguments[1] == "list" then
					self:send_serverlist()
					self:close_current()
				elseif arguments[1] == "reqauth" and false then
										
						-- ReqAuth Handler
						if string.match(data,"reqauth %d+ %w+ .*") then
							local arguments = _.to_array(string.gmatch(data, "[^ \n]+"))
							local request_id, name, domain = tonumber(arguments[2]), arguments[3]:lower(), (arguments[4] or "")
							if not users[domain] then conoutf.debug(string.format("[Auth]   | (%s:%s) : auth nÂ°%s: Domain '%s' doesn't exist!", remote_endpoint.ip, remote_endpoint.port, request_id, domain)) return end
							if not users[domain][name] or not users[domain][name][1] then conoutf.debug(string.format("[Auth]   | (%s:%s) : auth nÂ°%s: User '%s' doesn't exist in domain '%s' !", remote_endpoint.ip, remote_endpoint.port, request_id, name, domain)) return end
							challenges[request_id] = generate_challenge(users[domain][name][1])
							local challenge_str = challenges[request_id]:to_string()
							conoutf.debug("[Auth]   | (%s:%s) : Attempting auth nÂ°%d for %s@%s", remote_endpoint.ip, remote_endpoint.port, request_id, name, domain or '')
							sendmsg(string.format("chalauth %i %s", request_id, challenge_str))
						end
		
						-- ConfAuth Handler
						if string.match(data, "confauth %d+ .+") then
							local arguments = _.to_array(string.gmatch(data, "[^ \n]+"))
							local request_id, answer = tonumber(arguments[2]), arguments[3]
							if not challenges[request_id] then return end
							local challenge_expected_answer = challenges[request_id]:expected_answer(answer)
							if challenge_expected_answer then 
								conoutf.debug(string.format("[Auth]   | (%s:%s) : Succeded auth nÂ°%d with answer %s", remote_endpoint.ip, remote_endpoint.port, request_id, answer))
								sendmsg(string.format("succauth %d", request_id))
							else
								conoutf.debug(string.format("[Auth]   | (%s:%s) : Failed auth nÂ°%d with answer %s", remote_endpoint.ip, remote_endpoint.port, request_id, answer))
								sendmsg(string.format("failauth %d", request_id))
							end
							table.remove(challenges, request_id)
						end
		
						-- QueryId Handler
						if string.match(data, "QueryId %d+ %w+ .*") then
							local arguments = _.to_array(string.gmatch(data, "[^ \n]+"))
							local request_id, name, domain = tonumber(arguments[2]), arguments[3]:lower(), (arguments[4] or "")
							if not users[domain] then 
								conoutf.debug(string.format("[Auth]   | (%s:%s) : auth nÂ°%s: Domain '%s' doesn't exist!", remote_endpoint.ip, remote_endpoint.port, request_id, domain))
								sendmsg(string.format("DomainNotFound %d", request_id))
								return 
							end
							if not users[domain][name] or not users[domain][name][1] then
								conoutf.debug(string.format("[Auth]   | (%s:%s) : auth nÂ°%s: User '%s' doesn't exist in domain '%s' !", remote_endpoint.ip, remote_endpoint.port, request_id, name, domain))
								sendmsg(string.format("NameNotFound %d", request_id))
								return 
							end
							conoutf.debug(string.format("[Auth]   | (%s:%s) : auth nÂ°%s: User '%s' found in domain '%s' with '%s' rights", remote_endpoint.ip, remote_endpoint.port, request_id, name, domain, users[domain][name][2]))
							sendmsg(string.format("FoundId %d %s", request_id, users[domain][name][2]))
						end
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

local master = server_obj(alpha.settings:get("master_ip"), alpha.settings:get("master_port"))
master:accept()
