socket = require("socket")


--network module, thanks to Superpisto

module("network", package.seeall)
dofile(PREFIX.."network/getint.lua")
dofile(PREFIX.. "network/putint.lua")
dofile(PREFIX.. "network/sendstring.lua")
dofile(PREFIX.. "network/getstring.lua")

--buffer table, thanks to killme 
buffer = {
	_buffer = "",
	i = 1,
	
	new = function(self, buffer)
		local newbuff = {}
		for k, v in pairs(self) do newbuff[k] = v end
		
		newbuff:set_buffer(buffer)
		
		return newbuff
	end,
	
	remaining = function(self)
		if string.sub(self._buffer, self.i) == '' then
			return false
		else
			return true
		end
	end,
	
	set_buffer = function(self, buffer)
		self._buffer = buffer
	end,
	
	append_buffer = function(self, add)
		self._buffer = self._buffer .. add
	end,
	
	putint = function(self, int)
		self:append_buffer(putint(int))
	end,
	
	putstring = function(self, string)
		self:append_buffer(sendstring(string))
	end,
	
	get = function(self, func)
		local thing, read = func(string.sub(self._buffer, self.i))
		self.i = self.i + read
		print(string.sub(self._buffer, self.i))
		return thing
	end,
	
	getint = function(self)
		return self:get(getint)
	end,
	
	getstring = function(self)
		return self:get(getint)
	end,
	
	raw = function(self)
		return self._buffer
	end,

}

extinfo = {
	socket = nil,
	
	connect = function(self, ip, port)
		local newextinfo = {}
		for k, v in pairs(self) do newextinfo[k] = v end
		
		newextinfo:open(ip, port)
		
		return newextinfo
	end,
	
	open = function(self, ip, port)
		self.socket = socket.udp()
		
		self.socket:setpeername(ip, port)
		self.socket:settimeout(3)
	end,
	
	serverinfo = function(self)
		assert(self.socket:send(putint(1))) --too lazy to use buffer for this
		
		local data = assert(self.socket:receive())
		local buff = buffer:new(data)
		
		return {
			millis = buff:getint(),
			numplayers = buff:getint(),
			
			--attr
			numattr = buff:getint(),
			version = buff:getint(),
			mode = buff:getint(),
			seconds_left = buff:getint(),
			max_players = buff:getint(),
			mastermode = buff:getint(),
			--attr
			
			map = buff:getstring(),
			desc = buff:getstring(), 
		}
	end,
	
	get_players = function(self, hopmod, h_pass)
	
		local sendbuff = buffer:new(putint(0))
		
		sendbuff:putint(1); --EXT_PLAYERSTATS 
		sendbuff:putint(-1); --all players
		
		if hopmod then
			sendbuf:putint(1); --is hopomd request
			
			if h_pass then
				sendbuff:putstring(h_pass)
			end
		end
		
		--send to the server
		assert(self.socket:send(sendbuff:raw()))
		
		local data = assert(self.socket:receive())
		local buff = buffer:new(data)
		
		print(tostring(buff._buffer))
	end,

}

local connection = extinfo:connect("psl.sauerleague.org", 10001)

if false then
local info = connection:serverinfo()
print("millis", info.millis)
print("numplayers", info.numplayers)

print("num", info.numattr)
print(info.version)
print(info.mode)
print(info.seconds_left)
print(info.max_players)
print(info.mastermode)

print("map", info.map)
print("description", info.desc)
end

if true then
connection:get_players(false)
end
