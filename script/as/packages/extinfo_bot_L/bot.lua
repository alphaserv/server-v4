require "net"
require "socket"

buff = class.new(nil, {
	string = "",
	i = 1,
	
	raw = function(self) return self.string or "" end,
	clear = function(self) self.string = ""; return self end,
	
	__init = function(self, string)
		self.string = string or ""
	end,
	
	left = function(self)
		local buffer = string.sub(self.string, self.i)
		return string.len(buffer)
	end,
		
	putint = function(self, n)
		n = tonumber(n)
		if not n then error("not a number", 1) end
		n = math.modf(n)
		
		if n > 2147483647 or n < -2147483648 then error("n is not a 32 bits integer", 1) end
		
		local posn = n
		
		if n < 0 then posn = n + 0x100000000 end
		
		local buffer = string.char(math.fmod(posn, 0x100))
		
		if n < 128 and n > -127 then
			self.string = self.string .. buffer
			return self
		end
		
		buffer = buffer .. string.char(math.fmod(math.modf(posn/0x100), 0x100))
		
		if n < 0x8000 and n >= -0x8000 then
			self.string = self.string .. string.char(0x80) .. buffer
			return self
		end
		
		self.string = self.string .. string.char(0x81) .. buffer .. string.char(math.fmod(math.modf(posn/0x10000), 0x100)) .. string.char(math.fmod(math.modf(posn/0x1000000), 0x100))
		
		return self
	 end,
	 
	 getint = function(self)
	 	--print("i", self.i)
	 	local buffer = string.sub(self.string, self.i)
	 	
		if type(buffer) ~= "string" or string.len(buffer) < 1 then error("not a buffer", 1) end
		
		local length, c = string.len(buffer), string.byte(buffer, 1)
		
		if c == 0x80 then
			if length < 3 then
				error("buffer too short", 1)
			end
			
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3) * 0x100

			self.i = self.i + 3
			
			if ret > 0x7F00 then
				return ret - 0x10000
			end
			
			return ret
			
		elseif c == 0x81 then
			if length < 5 then error("buffer too short", 1) end
			
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100 + string.byte(buffer, 4)*0x10000 + string.byte(buffer, 5)*0x1000000
			
			self.i = self.i + 5
			
			if ret > 0x7F000000 then
				return ret - 0x100000000
			end
			
			return ret
		end
		
		self.i = self.i + 1
		
		if c > 0x7F then
			return c - 0x100
		end
		
		return c
	 end,

	--use these, as lua strings aren't null terminated!
	sendstring = function(self, str)
		
		local i = 1
		while str[i] do
			self:putint(string.byte(str[i]))
			i = i + 1		
		end
		
		self:putint(0)
	
		--[[
		local null = string.find(str, "\0")
		if null then
			self.string = self.string .. string.sub(str, 1, null)
		else
			self.string = self.string .. str .. "\0"
		end]]
		
		return self
	end,
	
	getstring = function(self)
		--[[
		local buffer = string.sub(self.string, self.i)
		
		local null = string.find(buffer, "\0")
		if null then
			self.i = self.i + null
			return string.sub(buffer, 1, null-1)
		end
		self.i = self.i + string.len(buffer)
		return buffer
		--]]
		
		--[ [
		local buffer = '';
		
		repeat
			local char = self:getint()
			if char == 0 then
				return buffer
			end
			buffer = buffer .. string.char(char)
		until false
		--] ]
    end
})

--[[
    Client (we):
    -----
    A: 0 EXT_UPTIME
    B: 0 EXT_PLAYERSTATS cn #a client number or -1 for all players#
    C: 0 EXT_TEAMSCORE

    Server:  
    --------
    A: 0 EXT_UPTIME EXT_ACK EXT_VERSION uptime #in seconds#
    B: 0 EXT_PLAYERSTATS cn #send by client# EXT_ACK EXT_VERSION 0 or 1 #error, if cn was > -1 and client does not exist# ...
         EXT_PLAYERSTATS_RESP_IDS pid(s) #1 packet#
         EXT_PLAYERSTATS_RESP_STATS pid playerdata #1 packet for each player#
    C: 0 EXT_TEAMSCORE EXT_ACK EXT_VERSION 0 or 1 #error, no teammode# remaining_time gamemode loop(teamdata [numbases bases] or -1)

    Errors:
    --------------
    B:C:default: 0 command EXT_ACK EXT_VERSION EXT_ERROR
]]

local EXT_ACK                     =    -1
local EXT_VERSION                 =    105
local EXT_NO_ERROR                =    0
local EXT_ERROR                   =    1
local EXT_PLAYERSTATS_RESP_IDS    =    -10
local EXT_PLAYERSTATS_RESP_STATS  =    -11
local EXT_UPTIME                  =    0
local EXT_PLAYERSTATS             =    1
local EXT_TEAMSCORE               =    2

local EXT_HOPMOD                  =    -2 -- Case to identify Hopmod based servers
local EXT_HOPMOD_VERSION          =    1  -- bump when changing hopmod related extensions

local UPDATE_INTERVAL = 10

function handlepacket(rbuff, udp, server)
	local package = rbuff:getint()
	
	--serverinfo
	if package == 1 then
		--print("?", rbuff:getint())
		server.millis = rbuff:getint()
		server.numplayers = rbuff:getint()
		server.numattr = rbuff:getint()
		for attr = 1, 5 --[[server.numattr]] do
			server["attr " .. attr] = rbuff:getint()
		end
		server.map = rbuff:getstring()
		server.desc = rbuff:getstring()

	--extinfo
	elseif package == 0 then
		local package_type = rbuff:getint()
		
		if package_type == EXT_UPTIME then
			rbuff:getint() --ext ack
			rbuff:getint() --ext version
			server.uptime = rbuff:getint()
		elseif package_type == EXT_PLAYERSTATS then
			local cn = rbuff:getint()
			local cn1 = cn
			
			rbuff:getint() --ext ack
			rbuff:getint() --ext version
			
			local _error = rbuff:getint()
			if _error == 1 then --invalid cn
				error("invalid cn: "..tonumber(_error))
			end
			
			local stats_type = rbuff:getint()
			if stats_type == EXT_PLAYERSTATS_RESP_IDS then

				local cn
				while pcall(function()
					cn = rbuff:getint()
					-- server:add_player({cn = cn})
				end) do end 
			elseif stats_type == EXT_PLAYERSTATS_RESP_STATS then
				server:add_player({
					cn = rbuff:getint(),
					ping = rbuff:getint(),
					name = rbuff:getstring(),
					team = rbuff:getstring(),
					frags = rbuff:getint(),
					flags = rbuff:getint(),
					deaths = rbuff:getint(),
					teamkills = rbuff:getint(),
					acc = rbuff:getint(),
					health = rbuff:getint(),
					amour = rbuff:getint(),
					gun = rbuff:getint(),
					priv = rbuff:getint(),
					state = rbuff:getint(),
					ip = { rbuff:getint(), rbuff:getint(), rbuff:getint(), 255}
				})

			end
			
			--[[
			if cn == EXT_PLAYERSTATS_RESP_IDS then
				cn = rbuff:getint()
				server:add_player({cn = cn})
			elseif cn == EXT_PLAYERSTATS_RESP_STATS then
				cn = rbuff:getint()
				server:add_player({cn = cn}, true)
			else
			
				rbuff:getint() --ext ack
				rbuff:getint() --ext version
			
				if rbuff:getint() == EXT_ERROR then
					print('error: cn was invalid');
					return
				end
				server:add_player({cn = cn}, false)
			end]]
			
			--[[
			print("stats", package, package_type, cn1)
			
			while rbuff:left() do
				print('..', rbuff:getint())
			end]]
		elseif package_type == EXT_TEAMSCORE then
			rbuff:getint() --ext ack
			rbuff:getint() --ext version
			server.teammode = rbuff:getint() == 0
			server.gamemode = rbuff:getint()
			server.time_remaining = rbuff:getint()
			
			while rbuff:left() > 3 do
				local name = rbuff:getstring()
				local score = rbuff:getint()
				local bases = rbuff:getint()

				if bases ~= -1 then
					local numbases = rbuff:getint()
					bases = {}
					
					--[[
					for base = 1, numbases do
						table.insert(bases, rbuff:getint())
					end]]
				end

				server:updateteam({
					name = name,
					score = score,
					bases = bases
				})
			end			
			
			
			--EXT_TEAMSCORE EXT_ACK EXT_VERSION 0 or 1 #error, no teammode# remaining_time gamemode loop(teamdata [numbases bases] or -1)
		else
			print('unhandled:', package_type)

		end
	else
		print('unhandled:', package)
	end
end

function sendpacket(udp, buff)
	--send
	local sent, err = udp:send(buff:raw())
	if err then error(err) end
	
	buff:clear()
end

local queue = {}

server_obj = class.new(nil, {
	desc = "",
	players = {},
	teams = {},
	
	millis = 0,
	uptime = 0,
	
	map = "",
	mode = "",
	
	ip = {},
	port = 0,
	
	clean = function(self)
		self.desc = nil
		self.players = nil
		self.teams = nil
		self.millis = nil
		self.uptime = nil
		self.map = nil
		self.mode = nil
		self.ip = {nil, nil, nil, nil}
		self.ip = nil
		self.port = nil
		self = nil
	end,
	
	save = function(self)
		alpha.db:query([[
			UPDATE
				servers
			SET
				online = 1,
				updated_time = NOW(),
				name = ?,
				mode = ?,
				map = ?
			WHERE
				ip = ?
			AND
				port = ?
			]], self.desc, self.mode, self.map, self.ip, self.port)

		local res = alpha.db:query([[
			SELECT
				id
			FROM
				servers
			WHERE
				ip = ?
			AND
				port = ?
			]], self.ip, self.port)
		
		res = res:fetch()
		local id = res[1].id
		
		for cn, user in pairs(self.players) do
			local user_id = -1
			
			local res = alpha.db:query([[
				SELECT
					user_id
				FROM
					names
				WHERE
					name = ?
				AND
					status = 2
			]], user.name):fetch()
			
			if res and res[1] then
				user_id = res[1].user_id
			end

			local res2 = alpha.db:query([[
				SELECT
					id
				FROM
					online_player
				WHERE
					name = ?
				AND
					ip = ?
				AND
					end_time = ?
			]] , user.name, table.concat(user.ip, '.'), self.updated_time):fetch()
			
			if res2 and res2[1] then
				alpha.db:query([[
					UPDATE
						online_player
					SET
						end_time = NOW(),
						user_id = %(1)s
					WHERE
						id = ?
					]] % { user_id == -1 and "NULL" or tonumber(user_id)},
					 res2[1].id)
	
			else
				alpha.db:query([[
					INSERT INTO  online_player
					(
						name,
						user_id,
						server_id,
						ip,
						begin_time,
						end_time
					)
					VALUES
					(
						?,
						%(1)s,
						?,
						?,
						NOW(),
						NOW()
					)
				]] % { user_id == -1 and "NULL" or tonumber(user_id)},
					user.name, id, table.concat(user.ip, '.'))
			end
		end
	end,
	
	__init = function(self, ip, port)
		local res = alpha.db:query([[
			SELECT
				name,
				mode,
				map,
				updated_time
			FROM
				servers
			WHERE
				ip = ?
			AND
				port = ?
		]], ip, port)
		
		local row = res:fetch()[1]
		
		self.desc = row.name
		self.mode = row.mode
		self.map = row.mode
		
		self.updated_time = row.updated_time
		
		self.ip = ip
		self.port = port
	end,
	
	add_player = function(self, player, overwrite)
		--[[if overwrite then
			print("overwriting .. ", table_to_string(player))
		end]]
		
		self.players[player.cn] = player
	end,
	
	updateteam = function(self, team)
		self.teams[team.name] = team
	end
})

local servers = {}

function query_server(host, port)

	local udp
	
		--setup
		host = tostring(host) or "psl.sauerleague.org"
		port = tonumber(port) or 1000
		port = port + 1
		udp = socket.udp()
		
		assert(udp:setpeername(host, port), "host = "..host .. "port = "..port)
		udp:settimeout(1)
	
	local send_buf = buff()

	send_buf:putint(1)
	sendpacket(udp, send_buf)
	
	--[[
	send_buf:putint(0)
	send_buf:putint(EXT_UPTIME)
	
	sendpacket(udp, send_buf)

	send_buf:putint(0)
	send_buf:putint(EXT_TEAMSCORE)
	
	sendpacket(udp, send_buf)]]
	
	
	send_buf:putint(0)
	send_buf:putint(EXT_PLAYERSTATS)
	send_buf:putint(-1)
	
	sendpacket(udp, send_buf)
	
	send_buf = nil
	
	
	udp:settimeout(3)
	
	local s = server_obj(host, port-1)
	
	function read()
		if not udp then
			print("udp has gone away ..")
			return
		end
		
		udp:settimeout(0)
	
		local i = 0
		repeat
			local data, msg = udp:receive()
			
			i = i + 1
			if data then
				local rbuff = buff(data)
				handlepacket(rbuff, udp, s)
				rbuff:clear()
			elseif msg ~= 'timeout' then 
				error("Network error: "..tostring(msg))
			elseif i == 1 then
				print("No response?")
			end
		until not data 

		udp:close()
		udp = nil
		
		s:save()
		
		for i, player in pairs(s.players) do
			print(player.name, s.desc, s.map)
		end

		s:clean()
		s = nil
		
		fcfs(query_server, {host, port})
	end

	server.sleep(1, read)


	
end

function handle_queue()
	print('Go!')
	
	for i, task in pairs(queue) do
		
		if type(task) == "table" then
			local result, error_ = pcall(task[1], unpack(task[2] or {}))
			
			if not result then
				print("error", table_to_string(error_))
			end
		end
		
		queue[i] = nil
	end

	--if #queue == 0 then
		server.sleep(3000, handle_queue)
	--else
		--handle_queue()
	--end
end

function fcfs(func, args)
	table.insert(queue, {func, args or {}})
end

function update_servers()
	
    local client = net.tcp_client()
        
    if #server.serverip > 0 then
        client:bind(server.serverip, 0)
    end
    
    
    
    client:async_connect("sauerbraten.org", 28787, function(error_message)

        if error_message then
                error("could not receive server list, connecting failed")
            return
        end
        
        client:async_send("list\n", function(error_message)
            
            --stop querying
            queue = {}
            
            alpha.db:query([[
            	UPDATE
            		servers
            	SET
            		online = 0
            	WHERE
            		external = 1
            ]])
            
            if error_message then
                error("could not register server, regserv failed")
                return
            end
            
            function read()
            	client:async_read_until("\n", function(line, error_message)
            		if not line or error_message then
            			print("closing")
       					client:close()
            			return
            		end
            		
            		line = line:gsub("\n", "")
            		
		        	print("[READING]", line)
					local server = line:split(" ");
					fcfs(query_server, {server[2], server[3]})   
					
					if alpha.db:query([[
				    	SELECT id FROM
				    		servers
				    	WHERE
				    		ip = ?
				    	AND
				    		port = ?
				    ]], server[2], server[3]):num_rows() == 0 then
				    	--new server				    
				    	alpha.db:query([[
				    		INSERT INTO
				    			servers
				    			(
				    				name,
				    				ip,
				    				port,
				    				external,
				    				mode,
				    				map,
				    				updated_time,
				    				online
				    			)
				    		VALUES
				    			(
				    				'updating',
				    				?,
				    				?,
				    				1,
				    				'',
				    				'',
				    				NOW(),
				    				1
				    			)
				    	]], server[2], server[3])
				    else
				    	alpha.db:query([[
							UPDATE
								servers
							SET
								online = 1,
								updated_time = NOW()
							
							WHERE
								ip = ?
							AND
								port = ?
							]], server[2], server[3])
				    end
					
					read()
		        end)
			end
			read()
        end)
    end)
	
end

server.event_handler("pre_started", handle_queue)
update_servers()

server.interval(30*60*1000, update_servers) -- every 30 min

