require "net"
require "Json"
module("as_master.client", package.seeall)

handlers = {}


local function call_handler(name, ...)
	if handlers[name] then
		local res, error_msg = native_pcall(handlers[name], ...)
		
		if not res then
			log_msg(LOG_WARNING, 'error on "'..name..'" :'..error_msg)
		end
	else
		log_msg(LOG_NOTICE, 'no event handler for "'..name..'" ')
	end
end
 
local enabled = alpha.settings.new_setting("as_register_server", true, "enable alphaserv master registration")
local host = alpha.settings.new_setting("as_master_server", "localhost", "The masterserver to use.")
local port = alpha.settings.new_setting("as_master_server_port", 28787, "The masterserver port to use.")
key = alpha.settings.new_setting("as_master_key", "AAAAAAAAA", "The key of our server.")

local client

function init()

	if not enabled:get() then return false, "registering server is not enabled in the config file" end
	
	client = net.tcp_client()
	
	if #server.serverip > 0 then
		client:bind(server.serverip, 0)
	end
	
	client:async_connect(host:get(), port:get(), function(error_message)

		if error_message then
				error("could not register server, connecting failed: "..error_message)
			return
		end
		
		client:async_send(string.format("regserv %i\n", server.serverport), function(error_message)
			
			if error_message then
				error("could not register server, regserv failed: "..error_message)
				return
			end
			start_reading()
		end)
	end)
end


function start_reading()
	print("[AS Master client] Starting reading operations")
	
	read()
	
	if not connection then
		print("[AS Master client] Stoping read operations, fatal error closed the socket.")
		--print("[AS Master client] Error: ", a, errormsg)
	else
		--print("[AS Master client] Error: "..errormsg)
	
		start_reading()
	end
end

function send_message(msg)
	client:async_send(msg.."\n", function() end)
end

function read()
	client:async_read_until("\n", function(line, error_message)
		if not line then
			error("could not register server, "..error_message or "unable to read reply")
			return
		end
		
		print("read", line)
			
		local command, ee = line:match("^([^ ]+)(.*)\n")
			
		--registration on list	
		if command == "succreg" then
			print (alpha.log.message("successfully registered to masterserver: %s:%i", host:get(), port:get()))
		elseif command == "failreg" then
			error("could not register server, ".. reason or "master rejected registration")
			
		--authenitcation
		elseif command == "login_fail" then--login_fail %(session_id)i
			local sess_id = ee:match("([0-9]+)")
			call_handler("auth", false, sess_id)
		
		elseif command == "login_success" then --login_success %(session_id)i %(session_key)q %(Json(info))q
			local sess_id, session_key, extinfo = ee:match("^([0-9]-) (.-)")
			call_handler("auth", true, sess_id, session_key, {})
		
		
		--stats
		--return stats requested bt player
		elseif command == "stats" then  -- stats %(session_key)i %(Json(stats))q
		
		--cross server chat
		elseif command == "pm" then -- pm %(session_key)q %(message)q
		
		elseif command == "notice" then
			server.msg("GLOBAL NOTICE: "..ee)
			print("GLOBAL NOTICE: "..ee)
		
		--nameprotection / clanprotection
		elseif command == "add_name" then --add_name %(name)q
			local name = ee:match("\"([^\"]-)\"")
			call_handler("add_name", name)
			
		elseif command == "namelist" then --namelist %(Json(name_array))s
			local list = Json.Decode(ee)
			for i, name in pairs(list) do
				call_handler("add_name", name)
			end
			
		elseif command == "add_clan" then --add_clan %(clantag)q
			local tag = ee:match("\"([^\"]-)\"")
			call_handler("add_clantag", tag)
		
		elseif command == "clanlist" then--clanlist %(Json(clantag_array))s
			local list = Json.Decode(ee)
			for i, tag in pairs(list) do
				call_handler("add_clantag", tag)
			end		
		
		--server verification
		elseif command == "req_serverauth" then
			client:async_send("serverauth %(1)q" % { key:get() }, function() end)

		elseif command == "serverauth_success" then
			print("Successfully connected and authenticated to alphaserv master server")
			
		elseif command == "serverauth_fail" then
			client:close()
			client = nil
			error("Could not authenticate to the master server: "..ee)
			
		--banning
		elseif command == "add_ban" then --add_ban %(ip)q\n
			local ip = ee:match("([0-9.]+)")
			call_handler("add_ban", ip)
				
		elseif command == "banlist" then
			local list = Json.Decode(ee)
			for i, ip in pairs(list) do
				call_handler("add_ban", ip)
			end
			
		--map
		elseif command == "mapinfo" then --mapinfo %(mapname)q %(crc)q %(has_bases)i %(has_flags)i %(motd)q
			--TODO
		else
			error("master sent unkown reply: "..line)
		end
		
		read()
	end)
end

server.event_handler("config_loaded", init)


