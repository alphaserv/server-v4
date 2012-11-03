
module("master.client", package.seeall)
require "net"
require "crypto"
require "class"
require "utils"

connection = newclass("connection")
connection._client = nil

connection.ip = nil
connection.port = nil

connection.error = nil
connection._onError = function(connection, errorMessage) end

function connection:init(ip, port)
	ip = ip or "sauerbraten.org"
	port = port or 28787
	
	self._client = net.tcp_client()
	
	connection.ip = ip
	connection.port = port
end

function connection:bind(ip, port)
	port = port or 0
	
	self._client:bind(ip, port)
end

function connection:setErrorHandler(func)
	self._onError = func
end

function connection:_throwError(message)
	self:_onError(message)
	self.error = message
end

function connection:close()
	self._client:close()
end

function connection:connect(callback)
	callback = callback or function() end
	
	self._client:async_connect(self.ip, self.port, function(errorMessage)
		
		if errorMessage then
			self:_throwError(errorMessage)
			self:close()
			callback(false, errorMessage)
		else
			callback(true)
		end
	end)
end

function connection:send(msg, funct)
	table.print_r(table.pack(self._client:local_endpoint()))
	print(msg)
	self._client:async_send(msg, funct)
end

function connection:registerServer(port, callback)
	callback = callback or function() end
	
	self:send("regserv %(1)i\n"% {port}, function(errorMessage)
		if errorMessage then
			self:_throwError(errorMessage)
			self:close()
			callback(false, errorMessage)
		else
			self._client:async_read_until("\n", function(line, errorMessage)
				
				if line then
					local command, reason = line:match("([^ ]+)([ \n]*.*)\n")
					
					if command == "succreg" then
						callback(true)
					elseif command == "failreg" then
						errorMessage = "master server rejected registration"
					else
						errorMessage = "master server sent unknown reply: %(1)s" % {line}
					end
				else
					errorMessage = "Master server did not send reply"
				end
				
				if errorMessage then
					self:_throwError(errorMessage)
					self:close()
					callback(false, errorMessage)
				end
			end)
		end
	end)
end

function connection:getList(callback)
	callback = callback or function() end
	local function readList(connection, list)
		connection:async_read_until("\n", function(line, errorMessage)
			if line then
				local ip, port = line:match("addserv ([^ ]+) ([^ \n]+)\n")
				table.insert(list, {ip=ip, port=port})
				readList(connection, list)
			end
		end)
	end
	
	self._client:async_send("list\n", function(errorMessage)
		if errorMessage then
			self:_throwError(errorMessage)
			self:close()
			callback(false, errorMessage)
		else
			local list = {}
			readList(self._client, list)
			callback(true, list)
		end
	end)
end

function connect(ip, port)
	local con = connection(ip, port)
	con:connect()
	return con
end
