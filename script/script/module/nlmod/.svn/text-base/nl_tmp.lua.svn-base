
local io = io
local string = string

local connection
local host
local port
local channel
local nickname
local messages = {
     ptr = 0, 
     size = -1
}

function initialize(settings)
     host = settings.host
     port = settings.port
     nickname = settings.nickname
     channel = settings.channel
     connection = socket.tcp()
     connection:settimeout(1)
end

function connect()
     if connection == nil then
             connection = socket.tcp()
             connection:settimeout(1)
     end
     connection:connect(host, port)
     send("NICK "..nickname)
     send("USER Awesome 0 * :awesome-git")
end

function disconnect()
     if connection ~= nil then
             connection:close()
     end
     connection = nil
end

function read()
     local buffer, err
     local prefix, cmd, param, param1, param2
     local user, userhost
     err = nil
     if connection ~= nil then
             while not err do
                     buffer, err = connection:receive("*l")
                     if not err then
                             if string.sub(buffer,1,4) == "PING" then
                                     send(string.gsub(buffer,"PING","PONG",1))
                             else
                                     prefix, cmd, param = string.match(buffer, "^:([^ ]+) ([^ ]+)(.*)$")
                                     if param ~= nil then
                                             param = string.sub(param,2)
                                             param1, param2 = string.match(param,"^([^:]+) :(.*)$")
                                             if cmd == "PRIVMSG" then
                                                     user, userhost = string.match(prefix,"^([^!]+)!(.*)$")
                                                     messages.size = messages.size + 1
                                                     messages[messages.size] = {}
                                                     messages[messages.size].nick = user
                                                     messages[messages.size].message = param2
                                             end
                                     end
                             end
                     end
             end
     end
     return buffer, err
end

function send(data)
     if connection ~= nil then
             connection:send(data.."\r\n")
     end
end

function message()
     local ptr = messages.ptr
     if ptr > messages.size then 
             return nil 
     end
     local message = messages[ptr]
     messages[ptr] = nil
     messages.ptr = ptr + 1
     return message
end

function messages_size()
     return messages.size
end
