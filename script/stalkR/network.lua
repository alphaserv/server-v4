socket = require("socket")

module("network", package.seeall)

buffer_obj = class.new(nil, {
	buffer = "",
	i = 1,
	
	__init = function(self, buffer)
		if buffer then
			self.buffer = buffer
		end
	end,
	
	remaining = function(self)
		if string.sub(self.buffer, self.i) == '' then
			return false
		else
			return true
		end
	end,
	
	set_buffer = function(self, buffer)
		self.buffer = buffer
	end,
	
	append_buffer = function(self, add)
		self.buffer = self.buffer .. add
	end,
	
	putint = function(self, int)
		int = tonumber(int)
		
		if not int then
			error("putint expects argument 1 to be a number", 1)
		end
		
		int = math.modf(int)
		
		if int > 2147483647 or int < -2147483648 then
			error("putint expects argument 1 to be a 32 bits integer", 1)
		end
		
		local posn = int
		
		if int < 0 then posn = int + 0x100000000 end
		
		local buffer = string.char(math.fmod(posn, 0x100))
		
		if int < 128 and int > -127 then
			self:append_buffer(buffer)
			
			return self
		end
		
		buffer = buffer .. string.char(math.fmod(math.modf(posn/0x100), 0x100))
		
		if int < 0x8000 and int >= -0x8000 then
			self:append_buffer(string.char(0x80) .. buffer)
			
			return self
		end
		
		self:append_buffer(string.char(0x81) .. buffer .. string.char(math.fmod(math.modf(posn/0x10000), 0x100)) .. string.char(math.fmod(math.modf(posn/0x1000000), 0x100)))
		
		return self
	end,
	
	putstring = function(self, string)
		local null = string.find(str, "\0")
		
		if null then 
			self:append_buffer(string.sub(buffer, 1, null))
			
			return self
		end
		
		self:append_buffer(str.."\0")
		
		return self
	end,
	
	getint = function(self)
		local buffer = string.sub(self.buffer, self.i)
		
		if type(buffer) ~= "string" or string.len(buffer) < 1 then
			error("invalid buffer", 2)
		end
		
		local length, c = string.len(buffer), string.byte(buffer, 1)
		
		if c == 0x80 then
			if length < 3 then
				error("buffer too short", 1)
			end
			
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100
			
			if ret > 0x7F00 then return ret - 0x10000, 3 end
			
			self.i = self.i + 1
			
			return ret
		end
		
		if c == 0x81 then
			if length < 5 then
				error("buffer too short", 1)
			end
			
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100 + string.byte(buffer, 4)*0x10000 + string.byte(buffer, 4)*0x1000000
			
			if ret > 0x7F000000 then return ret - 0x100000000, 5 end
			
			self.i = self.i + 5
			
			return ret
		end
		
		if c > 0x7F then
			self.i = self.i + 1
			return c - 0x100
		end
		
		self.i = self.i + 1
		
		return c
	end,
	
	getstring = function(self)
		local buffer = string.sub(self.buffer, self.i)
		
		local null = string.find(buffer, "\0")
		
		if null then
			self.i = self.i + null
			return string.sub(buffer, 1, null-1)
		end
		
		self.i = self.i + string.len(buffer)
		
		return self.buffer
	end,
	
	raw = function(self)
		return self.buffer
	end,

})

extinfo = {
	socket = nil,
	server = nil,
	
	connect = function(self, ip, port, id)
		local newextinfo = {}
		for k, v in pairs(self) do newextinfo[k] = v end
		
		newextinfo:open(ip, port)
		
		return newextinfo
	end,
	
	open = function(self, ip, port, id)
		self.socket = assert(socket.udp())
		
		self.socket:setpeername(ip, port)
		self.socket:settimeout(nil)
		
		self.server = master.get_server(id)
	end,
	
	serverinfo = function(self)
		assert(self.socket:send(buffer_obj(""):putint(1):raw()))
		
		local data = assert(self.socket:receive())
		local buff = buffer_obj(data)

		data = {
			millis = buff:getint(),
			numplayers = buff:getint(),
		}
		
		local infos = {
			"version",
			"mode",
			"seconds_left",
			"max_players",
			"mastermode"
			
		}
	
		data.attr = {}
		for i = 1, buff:getint() do 
			data.attr[i] = buff:getint()
		end
		
		for i, attr in pairs(data.attr) do
			data[infos[i]] = attr
		end
			
		data.map = buff:getstring()
		data.desc = buff:getstring()
		
		return data
	end,
	
	read_extinfo  = function(self)
		self.socket:settimeout(nil)
	
		local data, error_ = self.socket:receive()
		
		if not data then
			if error_ == "timeout" then	
				print("timeout")
				return
			else
				error(error_)
			end
		end
		
		print("read")
		
		
		local buff = buffer_obj(data)

		local zero = buff:getint()
		
		if zero == 0 then
			--main package
			if buff:getint() == 1 then --EXT_PLAYERSTATS
				if buff:getint() ~= -1 --cn -> all players
					or buff:getint() ~= -1 --EXT_ACK
				then
					print("playerstats went wrong: protocol error (1)")
			
					buff.i = 0
			
					print("trace: ")
					print("0", 0, buff:getint())
					print("EXT_PLAERSTATS", 1, buff:getint())
					print("cn", -1, buff:getint())
					print("EXT_ACK", -1, buff:getint())
					return
				end
				
				local version = buff:getint()
				if version < 105 then
					print("older extinfo protocol")
					return
				elseif version > 105 then
					print("newer extinfo protocol")
					return
				elseif version == 105 then				
					if buff:getint() == 1 then	--EXT_ERROR
						print("EXT_SERVER_HIGH_ERROR could not find player with cn -1 (all players)")
						return
					end
			end
				
			elseif buff:getint() == 0 then --EXT_UPTIME
				
				
			elseif buff:getint() == 2 then --EXT_TEAMSCORE
			
			
			end
		elseif zero == -10 then --EXT_PLAYERSTATS_RESP_IDS
			repeat
				if not buff:remaining() then
					break
				end
				local player = buff:getint()
				print(player, buff:remaining())
				
				if not self.server.players[player] then
					self.server:add_player({cn = player})--TODO: player object
				end
			until (not player)
			
		elseif zero == -11 then --EXT_PLAYERSTATS_RESP_STATS
			local table = {
				cn = buff:getint(),
				ping = buff:getint(),
				
				name = buff:getstring(),
				team = buff:getstring(),
				
				frags = buff:getint(),
				flags = buff:getint(),
				deaths = buff:getint(),
				teamkills = buff:getint(),
				idk = buff:getint(),
				health = buff:getint(),
				armour = buff:getint(),
				gunselect = buff:getint(),
				
				privilege = buff:getint(),
				state = buff:getint(),
				
				ip = {
					getstring(),
					getstring(),
					getstring(),
				}
			}
				
			self.server:add_player(table)
		end
		
		self:read_extinfo()
	end,
	
	close = function(self)
		self.socket:close()
	end,
	
	get_players = function(self)
		local sendbuff = buffer_obj("")
		
		sendbuff:putint(0)		
		sendbuff:putint(1) --EXT_PLAYERSTATS 
		sendbuff:putint(-1) --all players
		
		--send to the server
		assert(self.socket:send(sendbuff:raw()))
	end,

}
