require "net"
require "Json"
module("as_master.client", package.seeall)
 
local host = alpha.settings.new_setting("as_master_server", "localhost", "The masterserver to use.")
local port = alpha.settings.new_setting("as_master_server_port", 28787, "The masterserver port to use.")

local key = alpha.settings.new_setting("as_master_key", "AAAAAAAAA", "The key of our server.")
local id = alpha.settings.new_setting("as_master_id", 9999, "The key of our server.")

local function generate_login_key(master_msg)
	return crypto.tigersum(string.format("%i %s %s", id:get(), master_msg, key:get()))
end

local authed
local client

local buffer

local function send(callback)
	if not buffer then
		return
	end
	
	local buff = {
		{"id", id:get()}
	}
	
	for i, row in pairs(buffer) do
		table.insert(buff, row)
	end
	
	client:async_send(
		Json.Encode(buff).."\n"
	, function(error_)
		if error_ then
			error(error_)
		else
			buffer = nil
		end
		
		if callback then
			callback()
		end
	end)	
end

function send_msg(msg)
	if not buffer then
		buffer = {}
		server.sleep(10, send)
	end
	
	table.insert(buffer, msg)
end

function init()
	client = net.tcp_client()

	if #server.serverip > 0 then
		client:bind(server.serverip, 0)
	end	
	
	client:async_connect(host:get(), port:get(), function(error_message)
		if error_message then
			error("could not register server, connecting failed: "..error_message)
			return
		end
		
		send_msg({"init", server.name}) --send message
		send(function() --push messages
			read()
		end)
	end)
end

local get_clans_callback
local get_names_callback
local try_login_callback

function read()
	client:async_read_until("\n", function(line, error_message)
		if not line then
			error("could not register server, "..error_message or "unable to read reply")
			return
		end
		
		log_msg(LOG_DEBUG, "input: "..tostring(line))
			
		local buff = Json.Decode(line)
			
		for i, msg in pairs(buff) do
			if msg[1] == "serverauth" then
				send_msg({"serverauth", generate_login_key(msg[2])})
			elseif msg[1] == "notice" then
				server.msg(msg[2])
			elseif msg[1] == "clanlist" then
				if get_clans_callback then
					get_clans_callback(msg[2])
				else
					log_msg(LOG_ERROR, "could not find callback! get_clans_callback")
				end
			elseif msg[1] == "namelist" then
				if get_names_callback then
					get_names_callback(msg[2])
				else
					log_msg(LOG_ERROR, "could not find callback! get_names_callback")
				end
			elseif msg[1] == "login" then
				if try_login_callback then
					for cn, user in pairs(alpha.user.users) do
						if user.sid == msg[2] then
							try_login_callback(user, msg[3], msg[4], msg[5])
							break
						end
					end
				else
					log_msg(LOG_ERROR, "could not find callback! try_login_callback")
				end				
			end
		end
		
		read()
	end)
end

server.event_handler("config_loaded", init)

function get_clans(callback)
	--callback = function(clans) end
	get_clans_callback = callback
	send_msg({"clans"})
end

function get_names(callback) 
	--callback = function(names) end
	get_names_callback = callback
	send_msg({"names"})
end

function try_login(user, hash, callback)
	--callback = function(user, success, key, extra) end
	try_login_callback = callback
	send_msg({"login", user.sid, user.cn, hash})
end


