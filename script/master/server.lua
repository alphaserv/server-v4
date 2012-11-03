
require "net"
require "crypto"
require "class"
require "utils"
require "master.client"

module("master.server", package.seeall)

command = newclass("command")
command.requireAuthorisation = false
function command:run(self, client, remoteEndpoint, clientInfo)

end

server = newclass("master")
server.acceptor = nil
function server:accept (ip, port)
	local acceptorError
	self.acceptor, acceptorError = net.tcp_acceptor(ip, port)
	
	if not self.acceptor then
		error("Could not connect: %(1)s" % {acceptorError})
	else
		self.acceptor:listen()
		self:asyncAccept()
		print ("Listning on %(1)s:%(2)i" % {ip, port})
		print "*ready*"
	end
	
	--init
	if not self.commands then
		self.commands = {}
	end
end

function server:asyncAccept()
	local m_self = self
    self.acceptor:async_accept(function(client)
        local remoteEndpoint = client:remote_endpoint()
        print ("[Input]  | (%(1)s:%(2)s) : Connection accepted" % {remoteEndpoint.ip, remoteEndpoint.port})
        local clientInfo = {}
		
		local function readData()
			client:async_read_until("\n", function(data)
				if data then
				    self:processData(client, data, remoteEndpoint, clientInfo)
				    
				    if not clientInfo.cancelReading then
						readData()
					end
				else
				    server:OnError("Read error")
				end
			end)
		end
		readData()
        m_self:asyncAccept(self.server)
    end)
end

function server:processData(client, data, remoteEndpoint, clientInfo)
	data = data:gsub("([\r\n])", "")
	local args = data:split(" ")
	local name = table.pull(args)
	print (string.format("[Input] | (%s:%s) : %s", remoteEndpoint.ip, remoteEndpoint.port, data))
	if self.commands[name] then
		local cmd = self.commands[name]
		
		if cmd.requireAuthorisation and not clientInfo.authorized then
			self:sendData(client, "error notAuthorized", remoteEndoint)
		else
			cmd:run(self, client, remoteEndpoint, clientInfo)
		end
	else
		self:sendData(client, "error invalidCommand", remoteEndpoint)
	end
end

function server:sendData(client, data, remoteEndpoint)
	print (string.format("[Output] | (%s:%s) : %s", remoteEndpoint.ip, remoteEndpoint.port, data))
	client:async_send(data .. "\n", function(success) end)
end

function server:OnError(errorMsg)
	print ("Error: %(1)s (reconnecting)" % { errorMsg })
	self:reconnect()
end

function server:reconnect()
	self:disconnect()
	self:connect()
end

function server:disconnect()
	if self.acceptor then
	
	end
end

function server:addCommand(name, command)
	if not self.commands then
		self.commands = {}
	end
	self.commands[name] = command
end

local instance = server()
instance:accept("0.0.0.0", 28787)
instance:addCommand("list", {
	run = function(self, server, client, remoteEndpoint, clientInfo)
		server:sendData(client, "addserver \"localhost\" 10000", remoteEndpoint)
		
		local connection = master.client.connect()
		connection:getList(function(res, list)
			print (res, list)
		end)

		connection:registerServer(10000, function(res, list)
			print (res, list)
		end)

		
		clientInfo.cancelReading = true
		client:close()
	end
})
