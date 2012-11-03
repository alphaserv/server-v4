--[[
	script/module/nl_mod/nl_irc.lua
	Hankus (Derk Haendel)
	Created: 01-Jan-2011
	Last Modified: 01-Jan-2011
	License: GPL3

	Funktionen:
		Kommunikation zwischen den Sauerbraten-Servern und dem IRC-Server
		Setzen und Ueberwachen der Berechtigungen von IRC-Usern

]]

local geoip = require("geoip")
local socket = require("socket")

local irc = {}

irc.irclog = io.open("log/testirc.log","w+")
function irc.log_irc(msg)
--[[
			Schreibt in log/testirc.log
]]
	assert(msg ~= nil)
	irc.irclog:write(os.date("[%a %d %b %X] ",os.time()))
	irc.irclog:write(msg)
	irc.irclog:write("\n")
	irc.irclog:flush()
end

local function connect()
	local nickname = "BlahFasel"
	irc.connection = socket.tcp()
  irc.connection:settimeout(1)
	irc.connection:connect(server.irc_network, server.irc_network_port)
	irc.log_irc("send NICK")
	irc.connection:send("NICK "..nickname.."\n")
	irc.log_irc("send USER")
	irc.connection:send("USER BlahFasel 0 * : NoobBot\n")
	--send("NICK "..nickname)
	--send("USER Awesome 0 * :awesome-git")
end

local function disconnect()
	if irc.connection ~= nil then
		irc.connection:close()
	end
	irc.connection = nil
end

local function readdata()
	local buffer, err
	err = nil
	buffer, err = irc.connection:receive("*l")
	if not err then
		irc.log_irc(buffer)
		if string.sub(buffer,1,4) == "PING" then
			irc.log_irc("send "..string.gsub(buffer,"PING","PONG",1))
			irc.connection:send(string.gsub(buffer,"PING","PONG",1).."\n")
		end
		readdata()
	else
		irc.log_irc(err)
	end
end

connect()

readdata()
--server.sleep(1000, readdata)

server.sleep(10000, function()
	-- irc.connection:send("OPER NL4-Bot superdillgurke\n", noop)
	irc.log_irc("send JOIN")
	irc.connection:send("JOIN #gstf\n", noop)
end)

--[[
server.sleep(20000, function()
	irc.log_irc("diconnect")
	disconnect()
end)
]]
