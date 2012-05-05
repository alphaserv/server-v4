--[[!
    File: script/alphaserv/core/logging.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file handles files to log to and manages debuging

    Package: alpha.log
]]

module("alpha.log", package.seeall)

printlogs = false
openedfiles = {}

--[[!
    Function: message
    Logs text to the default output.

    Parameters:
        text - The text to display, may be formated with %s, %i and %i.
        ... - Arguments for string.format.
    
    Return:
    	the formated message or true
    
    See Also:
    	<message_to>
]]

function message(message, ...)
	return message_to(message, 'server', unpack(arg))
end

--[[!
    Function: message_to
    Logs text to the specified output file.

    Parameters:
        text - The text to display, may be formated with %s, %i and %i.
        file - The file to write the message to.
        ... - Arguments for string.format.
    
    Return:
    	Without format arguments - true
    	With format arguments - the formated message
]]

function message_to(message, file, ...)
	if #arg < 1 then
		write_to(file..".log",os.date("[%a %d %b %X] ",os.time())..message.."\n")
		return true
	else
		returning = string.format(os.date("[%a %d %b %X] ",os.time())..message.."\n", unpack(arg))
		write_to(file..".log", returning)
		return returning
	end
end

--[[!
    Function: write_to
    Internally used to check if a file is opened and to write to a file.

    Parameters:
        file - The file to write the message to.
        message - The formated text.
]]

function write_to(file, message)
	checkopened(file)
	write_line(file, message)
end

--[[!
    Function: checkopened
    Internally used to check if a file is already opened for writing.
    automatically opens a file if not.

    Parameters:
        file - The filename to check.
]]

function checkopened(file)
	if openedfiles[file] then return end
	
	openedfiles[file] = io.open("log/" .. file,"a+")
	if not openedfiles[file] then error("could not open logfile for writing: "..file) end
end

--[[!
    Function: write_line
    Internally used to perform the actual writing.
    Also sends the output prefixed with "LOG:" the stdout

    Parameters:
        file - The filename of the file.
        message - The formated text.
]]

function write_line(file, message)
	openedfiles[file]:write(message)
	
	if printlogs then
		print("LOG:"..message)
	end
end

--[[!
    Function: close_all
    Internally used to close all files on shutdown.
]]

function close_all()
	server.sleep(1, function()
		for name, value in pairs(openedfiles) do
			close_file(name)
		end
	end)
end

--[[!
    Function: name
    Internal util to format a name from a cn.
    
    Format:
    	%s(%i)[%s][%s]
    	* name
    	* cn
    	* ip
    	* country

    Parameters:
        cn - Chanel of the connected player.

	Return:
		The formated String.

	Example Return:
		name(1)[127.0.0.1][unkown]
]]

function name(cn)
	return string.format("%s(%i)[%s][%s]", server.player_name(cn), cn, server.player_ip(cn), geoip.ip_to_country(server.player_ip(cn)) or "<unknown>")
end

--[[!
    Function: close_file
    Closes one specific file

    Parameters:
        name - The file to close.
]]

function close_file(name)
	openedfiles[name]:close()
end

server.event_handler("shutdown", close_all)

--[[!
    Variable: debuglevels
    An array containing the debuglevel ids that are available to log to.
    
    Note: these are alos available under the global scope prefixed with "LOG_"

	FATAL - Unrecoverable error
	ERROR - Unexpected behaviour that should not happen
	NOTICE - Errors that may cause bugs but can usally be ignored
	INFO - Informative messages
	DEBG - Messages that are usefull when debugging
]]

debuglevels = {
	FATAL = 0,
	ERROR = 1,
	NOTICE = 2,
	INFO = 3,
	DEBUG = 4
}

for i, level in pairs(debuglevels) do
	_G["LOG_"..i] = level
end

debuglevel_names = {
	[debuglevels.FATAL] = "fatal",
	[debuglevels.ERROR] = "error",
	[debuglevels.NOTICE] = "notice",
	[debuglevels.INFO] = "info",
	[debuglevels.DEBUG] = "debug",
}

debuglevel = debuglevels.DEBUG

--[[!
    Function: debug
    Logs messages that are selected to be logged to log/debug.log

    Parameters:
    	level - The level to log to,
        text - The formated text
	
	Possible Values for level:
		- LOG_FATAL note: this also trows up an error
    	- LOG_ERROR
    	- LOG_NOTICE
    	- LOG_INFO
    	- LOG_DEBUG
    
    Note:
    	This function is also available in the global scope named "log_msg"
]]

function debug(level, text)
	if level <= debuglevel then
		local name = debuglevel_names[level]
		local msg = message_to("DEBUG %s(%i): %s", "debug", name, level, text)
		
		if not alpha.init_done and alpha.spamstartup then
			print(msg)
		
		elseif level == debuglevels.ERROR then
			print("ERROR: "..text)
		
		--message module loaded
		elseif alpha.init_done and messages and messages.load then
			messages.load("DEBUG", "debug_"..name, {default_type = "debug", default_message = "DEBUG %(1)s(%(2)s): %(3)s"})
				:format(name, level, text)
				:send(server.players(), false)

		end

	
		if irc and irc.send then
			irc.send(text)
		end
		
		if level == debuglevels.FATAL then
			error(msg)
		end
	end
end

_G.log_msg = debug

--[[!
    Function: alpha.log_event
    Util function to log events on an easy way.

    Parameters:
        a - A string containing all the arguments
        	p - player's cn, will be transformed into a name using name(cn)
        	s - a string
        	i - a number
        name - The name of the event.
     	... - Arguments of the event.
     
     example:
     (code)
     	server.event_handler("connect", function(...) alpha.log_event("p", "connect", ...) end)
     (end)
]]

function _G.alpha.log_event(a, event_name, ...)
	local returning = "Event "..event_name
	local i = 1
	for i = 1, #a do
		local b = a:sub(i,i)
		if b == "p" then
			returning = returning.." ".. name(tonumber(arg[i]))
		elseif b == "s" then
			returning = returning.." ".. tostring(arg[i] or "<?>")
		elseif b == "i" then
			returning = returning.." ".. tonumber(arg[i] or 1/0)
		end					
		i = i + 1
	end
	debug(debuglevels.INFO, returning)
end

if server.reloaded then
    message("reloaded server scripts")
else
    message("server started")
end

