
require "net"

module("alpha.irc", package.seeall)

irc_bot_command_name = "#"
client = net.tcp_client()

_channel = {
	name = "#channel",
	title = "",
	users = {
	
	},
	
	new = function(name) channels[name] = _channel; channels[name].name = name end
}

function sendmsg(message, callback, ...)

	if not arg or #arg == 0 then arg = { "" } end
	
	local msg = message.." "..table.concat(arg, " ")
	print("[IRC] sending: '"..msg.."'")
	client:async_send(msg.."\n", function(errmsg)
		if errmsg then
			error(errmsg)
		else
			callback()
		end
	end)
end

function connect()
	client:close()
	client = net.tcp_client()
	
	if errmsg then
		error(errmsg)
		return
	end
		
	client:async_connect("irc.gamesurge.net", 6667, function(errmsg) 
		
		if errmsg then
			error(errmsg)
            return
        end
        
        local localAddress = client:local_endpoint()
		print(string.format("[IRC] : Local socket address %s:%s", localAddress.ip, localAddress.port))

		print("[IRC] setting nick to asbot")
		
		sendmsg("NICK", setusername, "asbot")
	end)


	function setusername()
	print("[IRC] : Setting username")
	--USER <username> <hostname> <servername> <realname>
	sendmsg("USER", read, "killmebot", "8", "*", "alphaserv_irc_bot")

	end
	
	function read()
		
		client:async_read_until("\n", function(data)
			if data then
				data = data:gsub("\r", "")--remove \r
				data = data:gsub("\n", "")--remove \n
				print("[IRC] data: "..data)
				
				if data.find(data,"PING") then
					local pong = string.gsub(data,"PING","PONG",1)
					client:async_send(pong, function() end)
				elseif data.find(data,"MODE") then
					client:async_send("NAMES #alphaserv\n", function() end)
				elseif data.find(data,"353") then
					print("[IRC] OPS: "..string.match(data,"%S* 353 (.*)"))
					ready()
				elseif data.find(data,"NOTICE") then
					server.sleep(10000, function()
						client:async_send("JOIN #alphaserv\n", function() end)
					end)
				elseif data.find(data,"Closing Link") then
					error("Link Closed")
				elseif string.match(data,":(.+)!.+ PRIVMSG (.+) :"..irc_bot_command_name.."(.+)") then
					local nick, channel, command = string.match(data,":(.+)!.+ PRIVMSG (.+) :"..irc_bot_command_name.."(.+)")
					
					if channel == "asbot" then
						channel = nick
					end
					
			        process_command(nick, channel, command)
				end				
				
            	read()
			else
				error("could not read")
			end
		end)
	
	end
	
end

local already_ready = false
function ready()
	if already_ready then return end
	
	already_ready = true
	say("#alphaserv", "Hi all.")

end
function say(chan, text)
	sendmsg("PRIVMSG", function() end, chan, ":"..text)
end

local commands = {}

function commands.say (nick, channel, command, data)
	say(channel, data)
end

function process_command(nick, channel, command)
	command:gsub("(.+?)[ ]?(.- )*", function(command, ...)
		command = tostring(command)

		if not commands[command] then
			say(channel, "Could not find the command %(1)q %(2)s." % { command, nick })
			return
		end
		commands[command](nick, channel, command, unpack(arg or {}))
	end)
end

connect()

--[[
local strformat, strmatch, tinsert, tremove = string.format, string.match, table.insert, table.remove

local botnick, lbotnick, server, port, password, owner, connected, identified
local MessageHandlers, ChannelTextParsers = {},{}

local chans,ops = {},{}
local lastPing

local SendQueue, JoinQueue = {}, {}

--[ [-------------------------------------------------------------------
-- [Package] for you, ma'am
--] ]

local tcp = require("socket").tcp()

--[ [-------------------------------------------------------------------
-- [Local Function]alionization
--] ]

local lastSend = 0 -- we'll use this to help avoid flooding
local function send(text)
    local amountSent, errorCode = tcp:send(text)
    if amountSent ~= string.len(text) then
        return false, errorCode or "UNKNOWN ERROR"
    end
    lastSend = os.time()
    return true
end

--[ [-------------------------------------------------------------------
-- All your [Namespace] are belong to us
--] ]

local IrcBot = IrcBot
local irc = IrcBot:RegisterModule("irc")
local config = IrcBot:GetModule("config")


--[ [-------------------------------------------------------------------
-- [Semi-Privates]
--] ]

local function handleMessage(self, sender, hostmask, recp, text)
    if not sender or not hostmask or sender:lower() == lbotnick then
        return -- make sure we don't handle our own messages!
    end

    local returnto = sender
    local ltext = text:lower()
    local addressed
    if recp:lower() ~= lbotnick then -- if so, then private message to bot
        local lmatch = strmatch(ltext, string.lower("^(" .. botnick .. "[,%s]+)"));
        if not lmatch then -- public (channel)
            returnto = recp
            local _, nick_addressed = string.find(ltext, lbotnick .. "%s?[:,%-]%s?", 1)
            if nick_addressed then -- if addressed, skip our nick length
                text, addressed = text:sub(nick_addressed+1), true
                if not text then return true end
                if text:sub(1,1) == "!" then
                    self:Msg(sender, "You do not need to give ! when addressing me.")
                    text = text:sub(2)
                end
            end
            if not addressed then
                if text:sub(1,1) ~= "!" then -- ! is our trigger
                    for k,v in pairs(ChannelTextParsers) do
                        local ok, result = pcall(v, sender, recp, text)
                        if not ok then
                            self:Print("Channel Text Parser for [" .. k .. "] erred: " .. result, "ERROR")
                        elseif result then
                            return true
                        end
                    end
                    return true
                else -- skip the !
                    text = text:sub(2)
                end
            end
        else -- rare channel message type
        text,returnto = text:sub(#lmatch+1), recp
        end
    elseif text:sub(1,1) == "!" then -- this is a private message, and we don't need !
        self:Msg(sender, "You do not need to give the ! at the front when messaging me.")
        text = text:sub(2)
    end

    self:Print(strformat("Got [ [%s] ] from <%s> through %s", text, sender .. hostmask, recp))

    -- muted/mustaddress handle
    if returnto == recp then
        if self:IsMutedChannel(channel) and (not self:IsOp(channel, sender) or sender:lower() ~= owner:lower()) then
            self:Msg(sender, "Sorry, but I'm currently muted in " .. channel .. ". Ask an op, halfop, channel owner, ircop, or " .. owner .. " himself to unmute me by using !unmute in the channel.")
            return true
        elseif not addressed and self:GetMustBeAddressedInChannel(channel) then
            return true
        end
    end

    for k, v in pairs(MessageHandlers) do
        local ok, result = pcall(v, sender, hostmask, origin, text, returnto)
        if not ok then
            self:Print("Handler for [" .. k .. "] erred: " .. result, "ERROR")
        elseif result then
            return true
        end
    end

    return true
end

local function processData(self, data)
    self:Print(data, "ALL")
    local chan,mnicks = strmatch(data, "^:%S+ 353 %S+ [@=] (#%S+) :(.+)") -- bot has joined channel
    if chan and mnicks then -- original nick list for channel
        chan,mnicks = chan:lower(), mnicks:lower()
        if not chans[chan] then
            chans[chan] = { nicks={},ops={} }
            self:Print("Added " .. chan .. " to channel list.", "NOTIFY")
        end
        local op
        for mnick in string.gmatch(mnicks, "(%S+)") do
            if strmatch(mnick, "^[@~%%*!]") then
                mnick = mnick:sub(2)
                self:Print("Added " .. mnick .. " to ops for " .. chan, "TRACE")
                chans[chan].ops[mnick] = true
            end
            self:Print("Added " .. mnick .. " to " .. chan, "TRACE")
            chans[chan].nicks[mnick] = true
        end
        return true
    end
    local mnick,mchans = strmatch(data, "^:(%S+)!%S+ JOIN :(.+)") -- nick has joined channel(s)
    if mnick and mchans then
        mnick,mchans = mnick:lower(), mchans:lower()
        for chan in string.gmatch(mchans,"(#%S+)") do
            if not chans[chan] then
                chans[chan] = { nicks={},ops={} }
                self:Print("Added " .. chan .. " to channel list.", "NOTIFY")
            end
            self:Print("Added " .. mnick .. " to " .. chan, "TRACE")
            chans[chan].nicks[mnick] = true
        end
        return true
    end
    mnick,mchans = strmatch(data, "^:(%S+)!%S+ PART :(.+)") -- nick has left channel(s)
    if mnick and mchans then
        mnick,mchans = mnick:lower(), mchans:lower()
        for chan in string.gmatch(mchans,"(#%S+)") do
            if not chans[chan] then
                chans[chan] = { nicks={},ops={} }
                self:Print("Added " .. chan .. " to channel list.", "NOTIFY")
            end
            self:Print("Removed " .. mnick .. " from " .. chan, "TRACE")
            chans[chan].nicks[mnick],chans[chan].ops[mnick] = nil,nil
        end
        return true
    end
    mnick = strmatch(data, "^:(%S+)!%S+ QUIT") -- nick has quit
    if mnick then
        mnick = mnick:lower()
        for chan,t in pairs(chans) do
            self:Print("Removed " .. mnick .. " from " .. chan, "TRACE")
            t.nicks[mnick],t.ops[mnick] = nil,nil
        end
        return true
    end

    -- additional ops (nick mode change)
    local op,mode
    chan,mode,op,mnicks = string.match(data, ":%S+ MODE (#%S+) ([+%-])([oph]) (.+)")
    if chan and mode and op and mnicks then
        chan,mnicks = chan:lower(), mnicks:lower()
        if not chans[chan] then
            chans[chan] = { nicks={},ops={} }
            self:Print("Added " .. chan .. " to channel list.", "NOTIFY")
        end
        for mnick in string.gmatch(mnicks, "(%S+)") do
            if mode == "+" then
                self:Print("Added " .. mnick .. " to ops for " .. chan, "TRACE")
                chans[chan].ops[mnick] = true
            elseif mode == "-" then
                self:Print("Removed " .. mnick .. " from ops for " .. chan, "TRACE")
                chans[chan].ops[mnick] = nil
            end
        end
        return true
    end

    if strmatch(data, "PING") then
        self:Print(data, "TRACE")
        lastPing = os.time()
    elseif lastPing and os.time() - lastPing > 600 then
        lastPing = nil
        self:Print("Possibly latency or connection issue!", "NOTIFY")
    end

    local origin, command, recp, param = strmatch(data, "^:(%S+) (%S+) (%S+)[^:]*:(.+)")
    if not origin then origin, command, param = strmatch(data, "^:(%S+) (%S+)[^:]*:(.+)") end
    if not origin then command, param = strmatch(data, "^:([^:]+ ):(.+)") end
    if not command then
        self:Print("Unparsed: " .. data, "TRACE")
        return true
    end
    if param then param:gsub("[\r\n]", "") end

    if command == "PING" or strmatch(data, "^PING") then
        self:Print(" <<<< PONG!")
        return send(strformat("PONG %s\r\n", param or ""))
    elseif command == "NOTICE" then
        if password then
            if (param == "This nickname is owned by someone else" or
                param == "This nickname is registered and protected.  If it is your") then
                    self:Print("Identified as " .. botnick .. ", waiting for confirmation...", "STATUS")
                    return send(strformat("NS :IDENTIFY %s\r\n", password))
            elseif param == "Password accepted - you are now recognized" then
                identified = true
                self:Print("Nick registration complete.", "STATUS")
            elseif strmatch(origin:lower(), "nickserv") and strmatch(param, botnick .. ".-has been killed") then
                self:Print("Nick ghosted, switching...")
                return send("NICK " .. botnick .. "\r\n")
            end
        end
    elseif password and command == "443" and param == "Nickname is already in use." then
        self:Print("Nick in use, trying to ghost...");
        if not send("NICK " .. botnick .. "_\r\n") then return false end
        return send(strformat("PRIVMSG NickServ :GHOST %s %s\r\n", botnick, password))
    elseif command == "MODE" and param == "+e" then
        self:Print("Login successful.", "STATUS")
        connected = true
    elseif command == "KILL" then
        self:Print("Killed by server.")
        return false
    elseif command == "PRIVMSG" then
        if strmatch(param, "[^%w]?VERSION[^%w]?") and recp:lower() == lbotnick then
            return self:Msg(origin, IrcBot.core .. " r" .. IrcBot.rev)
        else
            local sender,hostmask = strmatch(origin,"^(%S+)!(%S+)")
            return handleMessage(self, sender, hostmask, recp, param)
        end
    else
            self:Print("Unhandled: [Command: " .. command .. "] [Nick: " .. tostring(nick) .. "] [Origin: " .. tostring(origin) .. "] [Param: " .. param .. "]", "ALL")
    end

    return true
end


--[ [-------------------------------------------------------------------
-- [Method] Man
--] ]

--[ [----------- Main Loop -------------------------------------------] ]
-- irc loop #1 -- receive and process data
function irc:Receive()
    local data, err = tcp:receive("*l")
    if not data and err and #err > 0 and err ~= "timeout" then
        self:Print(strformat("Lost connection to %s:%d: %s", server, port, err), "ERROR")
        return false
    elseif not data then
        return true
    end
    return processData(self, data)
end

-- irc loop #2 -- process queue'd up actions
function irc:ProcessQueue()
    if SendQueue[1] and os.time() - lastSend > (#SendQueue / 2) then
        return send(tremove(SendQueue,1))
    end
    if connected and identified and JoinQueue[1] then
        self:Print("Joining channel " .. JoinQueue[1], "NOTIFY")
        return self:JoinChannel(tremove(JoinQueue,1))
    end
    return true
end

--[ [----------- Server Interaction ----------------------------------] ]
function irc:Connect()
    tcp:settimeout(1,"t")
    tcp:settimeout(1,"b") -- only block for 1 second, then let us go back into Lua

    server,port,botnick,password,owner = config.server, config.port or 6667, config.botnick, config.password, config.owner
    lbotnick = botnick:lower()

    local status, err = tcp:connect(server, port)
    if not status then
        self:Print(strformat("Connection to %s:%d failed: %s ", server, port, err or ""), "ERROR")
        return false
    end

    local login
    if not password then
        identified = true
        login = strformat("NICK %s\r\nUSER %s %s %s :Tag\r\n", botnick, botnick, botnick, server)
    else
        login = strformat("NICK %s\r\nPASS %s\r\nUSER %s %s %s :Tag\r\n", botnick, password, botnick, botnick, server)
    end

    status, err = send(login)
    if not status then
        self:Print(strformat("Connection to %s:%d suceeded, but sending login failed: %s ", server, port, err or ""), "ERROR")
        return false
    end

    if password then
        self:Print(strformat("Connected to %s:%d, waiting for identify request...", server, port), "STATUS");
    end

    -- queue up channels to join
    if config.chans then
        for chan,settings in pairs(config.chans) do
            tinsert(JoinQueue,chan)
            if type(settings) == "string" then
                for func in string.gmatch(settings, "%S+") do
                    if self[func] then
                        self[func](chan, true)
                        self:Print("Calling " .. func .. " for channel " .. chan, "NOTIFY")
                    end
                end
            end
        end
    end
    return true
end

function irc:Quit(msg)
    return send(strformat("QUIT :%s\r\n", msg or "Client leaving server"))
end

function irc:Msg(recp, text, multisend)
    text = text:gsub("[\r\n]", "")
    local msg = strformat("PRIVMSG %s :%s\r\n", recp, text)
    local maxlen,multisendQueued = 420,0
    local qlen = #SendQueue
    if #msg >= maxlen then
        local sub = (type(multisend) == "string" and
                     text:sub(1,maxlen):match(multisend)) or -- pattern to tell us where to split
                     text:sub(1,maxlen)
        msg = strformat("PRIVMSG %s :%s\r\n", recp, sub)
        if multisend then -- we want to split a long string up and queue it into multiple messages
            if qlen > 0 then tinsert(SendQueue,msg) end
            while sub and #sub < maxlen do
                local len = #sub
                sub = (type(multisend) == "string" and
                        text:sub(len+1,maxlen):match(multisend)) or -- pattern to tell us where to split
                        text:sub(len+1,maxlen)

                tinsert(SendQueue,
                        strformat("PRIVMSG %s :%s\r\n", recp, sub))
                multisendQueued = multisendQueued + 1
            end
        end
    end

    if qlen == 0 or qlen == multisendQueued then
        return send(msg)
    elseif SendQueue[qlen] ~= msg then
        tinsert(SendQueue,msg)
    end
end

--[ [----------- Addon Management ------------------------------------] ]
function irc:RegisterMessageHandler(obj, handler)
    MessageHandlers[obj] = handler
end
function irc:RemoveMessageHandler(obj)
    MessageHandlers[obj] = nil
end
function irc:RegisterChannelTextParser(obj,handler)
    ChannelTextParsers[obj] = handler
end
function irc:RemoveChannelTextParser(obj)
    ChannelTextParsers[obj] = nil
end

--[ [----------- Channel Management ----------------------------------] ]
-- Below could be extended to a "channel" prototype.
function irc:JoinChannel(channel)
    return send("JOIN " .. channel .. "\r\n")
end
function irc:LeaveChannel(channel)
    return send(strformat("PART %s\r\n", channel))
end
function irc:IsOp(channel,mnick)
    channel = channel:lower()
    return chans[channel] and chans[channel].ops[mnick:lower()]
end
function irc:IsInChannel(channel,mnick)
    channel = channel:lower()
    return chans[channel] and chans[channel].nicks[mnick:lower()]
end
function irc:MuteChannel(channel, v)
    channel = channel:lower()
    if not chans[channel] then
        chans[channel] = { nicks={},ops={} }
        self:Print("Needed to add " .. channel .. " to channel list due to mute request.", "DEBUG")
    end
    chans[channel].muted = v
end
function irc:IsMutedChannel(channel)
    channel = channel:lower()
    return chans[channel] and chans[channel].muted
end
function irc:SetMustBeAddressedInChannel(channel,v)
    channel = channel:lower()
    if not chans[channel] then
        chans[channel] = { nicks={},ops={} }
        self:Print("Needed to add " .. channel .. " to channel list due to MustBeAddressed request.", "DEBUG")
    end
    chans[channel].mustbeaddressed = v
end
function irc:GetMustBeAddressedInChannel(channel)
    channel = channel:lower()
    return chans[channel] and chans[channel].mustbeaddressed
end

-- It's a toss-up between Garibaldi and Londo. G'kar was also good in the
-- later seasons.]]
