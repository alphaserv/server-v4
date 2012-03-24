package.path = package.path .. ";script/package/?.lua;"
package.path = package.path .. ";script/?.lua;"
package.cpath = package.cpath .. ";lib/lib?.so"

putint = function(n)
		n = tonumber(n)
		if not n then error("not a number", 1) end
		n = math.modf(n)
		if n > 2147483647 or n < -2147483648 then error("n is not a 32 bits integer", 1) end
		local posn = n
		if n < 0 then posn = n + 0x100000000 end
		local buffer = string.char(math.fmod(posn, 0x100))
		if n < 128 and n > -127 then return buffer end
		buffer = buffer .. string.char(math.fmod(math.modf(posn/0x100), 0x100))
		if n < 0x8000 and n >= -0x8000 then return string.char(0x80) .. buffer end
		return string.char(0x81) .. buffer .. string.char(math.fmod(math.modf(posn/0x10000), 0x100)) .. string.char(math.fmod(math.modf(posn/0x1000000), 0x100))
	 end

getint = function(buffer)
		if type(buffer) ~= "string" or string.len(buffer) < 1 then error("not a buffer", 1) end
		local length, c = string.len(buffer), string.byte(buffer, 1)
		if c == 0x80 then
			if length < 3 then error("buffer too short", 1) end
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100
			if ret > 0x7F00 then return ret - 0x10000, 3 end
			return ret, 3
		end
		if c == 0x81 then
			if length < 5 then error("buffer too short", 1) end
			local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100 + string.byte(buffer, 4)*0x10000 + string.byte(buffer, 4)*0x1000000
			if ret > 0x7F000000 then return ret - 0x100000000, 5 end
			return ret, 5
		end
		if c > 0x7F then return c - 0x100, 1 end
		return c, 1
	 end

--use these, as lua strings aren't null terminated!
sendstring = function(str)
		local null = string.find(str, "\0")
		if null then return string.sub(buffer, 1, null) end
		return str .. "\0"
	     end

getstring = function(buffer)
		local null = string.find(buffer, "\0")
		if null then return string.sub(buffer, 1, null-1), null end
		return buffer, string.len(buffer)
	    end

--setup
socket = require("socket")
host = arg[1] or "psl.sauerleague.org"
port = arg[2] or 10001
udp = socket.udp()
udp:setpeername(host, port)
udp:settimeout(3)
--send
local sent, err = udp:send(putint(1))
if err then print(err) os.exit() end
--recv
local dgram, err = udp:receive()
if not dgram then print(err) os.exit() end
--dump
local i = 1
local dump =	function(desc, func)
			local thing, read = func(string.sub(dgram, i))
			print(desc .. ": " .. thing)
			i = i + read
			return thing
		end
dump("millis", getint)
dump("numplayers", getint)
numattr=dump("numattr", getint)
for attr = 1, numattr do dump("attr " .. attr, getint) end
dump("map", getstring)
dump("desc", getstring)
