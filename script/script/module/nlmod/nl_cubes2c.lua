--[[
	cubes2c - a protocol for sending data from cube2 servers to cube2 clients
	-------------------------------------------------------------------------
	(c) 2010 by X35

	Modified Hanack
]]

cubes2c = {}

local text = {}

local STATE_REC = 0
local STATE_IDLE = 1
local STATE_REQREC = 2
local STATE_SENTREPEATDUMMY = 3
local STATE_IDLEREC = 4
local STATE_CLEARING = 5

local SIGNAL_ENDREC = 1000
local SIGNAL_STARTREC = 1001
local SIGNAL_EXEC = 1002
local SIGNAL_CLEAR = 1003
local SIGNAL_DUMMY = 1004

-- a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z "'" "^"" "_" "+" "-" "*" "/" "\" "[" "]" "(" ")" "=" "!" "$" "," "." "@" "&" "|" "?" ":" ";" "^" " " 0 1 2 3 4 5 6 7 8 9

local numbers = {
	["a"] = 0,
	["b"] = 1,
	["c"] = 2,
	["d"] = 3,
	["e"] = 4,
	["f"] = 5,
	["g"] = 6,
	["h"] = 7,
	["i"] = 8,
	["j"] = 9,
	["k"] = 10,
	["l"] = 11,
	["m"] = 12,
	["n"] = 13,
	["o"] = 14,
	["p"] = 15,
	["q"] = 16,
	["r"] = 17,
	["s"] = 18,
	["t"] = 19,
	["u"] = 20,
	["v"] = 21,
	["w"] = 22,
	["x"] = 23,
	["y"] = 24,
	["z"] = 25,
	["A"] = 26,
	["B"] = 27,
	["C"] = 28,
	["D"] = 29,
	["E"] = 30,
	["F"] = 31,
	["G"] = 32,
	["H"] = 33,
	["I"] = 34,
	["J"] = 35,
	["K"] = 36,
	["L"] = 37,
	["M"] = 38,
	["N"] = 39,
	["O"] = 40,
	["P"] = 41,
	["Q"] = 42,
	["R"] = 43,
	["S"] = 44,
	["T"] = 45,
	["U"] = 46,
	["V"] = 47,
	["W"] = 48,
	["X"] = 49,
	["Y"] = 50,
	["Z"] = 51,
	["'"] = 52,
	["\""] = 53,
	["_"] = 54,
	["+"] = 55,
	["-"] = 56,
	["*"] = 57,
	["/"] = 58,
	["\\"] = 59,
	["["] = 60,
	["]"] = 61,
	["("] = 62,
	[")"] = 63,
	["="] = 64,
	["!"] = 65,
	["$"] = 66,
	[","] = 67,
	["."] = 68,
	["@"] = 69,
	["&"] = 70,
	["|"] = 71,
	["?"] = 72,
	[":"] = 73,
	[";"] = 74,
	["^"] = 75,
	[" "] = 76,
	["0"] = 77,
	["1"] = 78,
	["2"] = 79,
	["3"] = 80,
	["4"] = 81,
	["5"] = 82,
	["6"] = 83,
	["7"] = 84,
	["8"] = 85,
	["9"] = 86
}

local function send(cn, sig)
	server.msg("server sending: " .. sig)
	server.send_fake_switchmodel(cn, cn, sig)
end

local function generatenum(text)
	local len = string.len(text)
	if numbers[text] then
		if numbers[text] <= 99 then
			return numbers[text]
		else
			return numbers[text]
		end
	else
		return numbers["?"]
	end
end

local function sendifnew(cn, i, num, len, force)
	if i.last == num and (not (len <= 4 and len >= 1)) and (not force) then
		i.beforestate = i.state
		i.state = STATE_SENTREPEATDUMMY
		i.realpack = {num=num, len=len}
		i.last = -1
		send(cn, SIGNAL_DUMMY)
	elseif i.last == num and (not force) then
		i.pos = i.pos + len
		num = num + (4 * (100 ^ len))
		send(cn, num)
		i.last = num
	else
		i.pos = i.pos + len
		send(cn, num)
		i.last = num
	end
end

local function send_next(cn)
	local i = text[cn]
	if i then
		local num = generatenum(string.sub(i.text, i.pos, i.pos))
		if i.state == STATE_IDLEREC then
			return
		elseif i.state == STATE_CLEARING then
			send(cn, SIGNAL_CLEAR)
		elseif i.state == STATE_SENTREPEATDUMMY then
			sendifnew(cn, i, i.realpack.num, i.realpack.len, true)
			i.realpack = nil
			i.state = i.beforestate
			i.beforestate = nil
		elseif num ~= SIGNAL_DUMMY then
			if i.pos > i.len then
				send(cn, SIGNAL_EXEC)
				i.state = STATE_IDLEREC
			elseif (i.pos+3) <= i.len then
				num = (100*num) + generatenum(string.sub(i.text, i.pos+1, i.pos+1))
				num = (100*num) + generatenum(string.sub(i.text, i.pos+2, i.pos+2))
				num = (100*num) + generatenum(string.sub(i.text, i.pos+3, i.pos+3))
				num = num + 400000000
				sendifnew(cn, i, num, 4)
			elseif (i.pos+2) <= i.len then
				num = (100*num) + generatenum(string.sub(i.text, i.pos+1, i.pos+1))
				num = (100*num) + generatenum(string.sub(i.text, i.pos+2, i.pos+2))
				num = num + 3000000
				sendifnew(cn, i, num, 3)
			elseif (i.pos+1) <= i.len then
				num = (100*num) + generatenum(string.sub(i.text, i.pos+1, i.pos+1))
				num = num + 20000
				sendifnew(cn, i, num, 2)
			else
				sendifnew(cn, i, num+100, 1)
			end
		else
			send(cn, num)
			i.pos = i.pos + 1
		end
	end
end

local function startrecord(cn)
	send(cn, SIGNAL_STARTREC)
	text[cn].state = STATE_REQREC
end

local function stoprecord(cn)
	send(cn, SIGNAL_ENDREC)
	text[cn].state = STATE_IDLE
end

local function clear(cn)
	send(cn, SIGNAL_CLEAR)
end

local function newinfo(text_)
	return {text=text_, pos=1, len=string.len(text_), next=send_next, last = -1, state=STATE_IDLE, realpack=nil, beforestate=nil}
end

local function send_text(cn, text_)
	text[cn] = text[cn] or newinfo(text_)
	if text[cn].state == STATE_IDLE then
		server.msg("new client..")
		startrecord(cn)
	elseif text[cn].state == STATE_IDLEREC then
		server.msg("old client..")
		text[cn] = newinfo(text_)
		text[cn].state = STATE_REC
		clear(cn)
	else
		server.msg("busy client.. (state: " .. tostring(text[cn].state) .. ")")
		return false
	end
	return true
end

function cubes2c.send_cubescript(cn, text)
  send_text(cn, text)
end

function server.playercmd_sendtext(pcn, cn, text)
	if not hasaccess(pcn, owner_access) then return end
	send_text(tonumber(cn), text)
end

server.event_handler("setmaster", function(cn, hash, set)
	if set and hash == server.hashpassword(cn, "cubes2c_gotit") then
		local i = text[cn]
		if i then
			i.next(cn)
		end
		return -1
	elseif set and hash == server.hashpassword(cn, "cubes2c_accepted") then
		local i = text[cn]
		if i then
			if i.state == STATE_REQREC then
				i.state = STATE_REC
				i.next(cn)
			end
		end
		return -1
	elseif set and hash == server.hashpassword(cn, "cubes2c_norec") then
		local i = text[cn]
		if i then
			if i.state == STATE_REC then
				i.pos = 1
				startrecord(cn)
			end
		end
		return -1
	end
end)
