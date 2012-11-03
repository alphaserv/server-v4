
module("master.server", package.seeall)
require "Json"
--server authentication keys

local server_secrets = alpha.settings.new_setting("server_secrets", {AAAAAAAAA = true}, "The secrets of the servers")

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
	authed = false,
	remote = nil,
	
	__init = function(self, connection, remote)
		self.connection = connection
		self.remote = remote

		server.sleep(1000, function()
			self:send("req_serverauth")
		end)
	end,
	
	send = function(self, message, ...)
		message = message % {...} 
		
		print(string.format("[Client] : (%s:%s) | sending: %s", self.remote.ip, self.remote.port, message))
		self.connection:async_send(message.."\n", function(success) end)
	end,
	
	close_current = function(self)
		self.connection:close()
	end,
	
	send_serverlist = function(self)
		for i, server in pairs(master.servers) do
			self:send("addserver %(1)s %(2)s", server.ip, server.port)
		end
	end,
	
	read = function(self)
		self.connection:async_read_until("\n", function(data)
			if data then
				
				if data == "" then return end
				
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
				
				--send list of reserved names
				elseif arguments[1] == "names" then
					local msg = Json.Encode(alpha.db:query("SELECT name FROM names"):fetch())
					msg = msg:gsub("\n", "\\n")
					self:send("namelist %(1)s", msg)
				
				--send list of clantags
				elseif arguments[1] == "clans" then
					local msg = Json.Encode(alpha.db:query("SELECT tag FROM clans"):fetch())
					msg = msg:gsub("\n", "\\n")
					self:send("clanlist %(1)s", msg)
				
				--login request
				elseif arguments[1] == "auth" then
					--auth secret cn session_id hashed_password name
				
					local secret_table = server_secrets:get()
				
					if not secret_table[arguments[2]] then
						self:send("login_fail %(1)i incorrect secret", arguments[4])
					else
				
						local res = alpha.db:query([[
							SELECT
								users.id,
								users.name,
								users.pass,
								users.email
							FROM
								users,
								names
							WHERE
								names.user_id = users.id
							AND
								names.name = ?
							]], arguments[6])--name
					
						if res:num_rows() < 1 then
							self:send("login_fail %(1)i unkown name", arguments[4])
						elseif res:num_rows() > 1 then --should not be possible
							self:send("login_fail %(1)i ambigious", arguments[4])
						else
							local row = res:fetch()
							
							row = row[1]
						
							if crypto.tigersum(string.format("%i %i %s", arguments[3], arguments[4], row.pass)) == arguments[5] then
					
								self:send("login_success %(1)i %(2)s", arguments[4],  "aaa")
							else
								self:send("login_fail %(1)i incorrect password", arguments[4])
							end
						end
					end
				
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

local master = server_obj("0.0.0.0", 28787)
master:accept()
