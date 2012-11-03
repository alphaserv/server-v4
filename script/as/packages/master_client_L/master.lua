require "net"

module("master.client", package.seeall)
 
local enabled = alpha.settings.new_setting("register_server", true, "enable master registration")
local interval = alpha.settings.new_setting("register_interval", 36000, "time between register attempts.")
local servers = alpha.settings.new_setting("master_servers", {"sauerbraten.org:28787"}, "the masterservers to register to.\nusage: { \"address:port\" }")

function register_server(hostname, port)

	if not enabled:get() then return false, "registering server is not enabled in the config file" end
	
    local client = net.tcp_client()
    
    if #server.serverip > 0 then
        client:bind(server.serverip, 0)
    end
    
    client:async_connect(hostname, port, function(error_message)

        if error_message then
                error("could not register server, connecting failed")
            return
        end
        
        client:async_send(string.format("regserv %i\n", server.serverport), function(error_message)
            
            if error_message then
                error("could not register server, regserv failed")
                return
            end
            
            client:async_read_until("\n", function(line, error_message)
                
                if not line then
					error("could not register server ("..server.serverport.."=>"..hostname..":"..port.."), "..error_message or "unable to read reply")
                    return
                end
                
                local command, reason = line:match("([^ ]+)([ \n]*.*)\n")
                
                if command == "succreg" then
					print (alpha.log.message("successfully registered to masterserver: %s:%i", hostname, port))
					client:close()
                elseif command == "failreg" then
                	client:close()
	                error("could not register server ("..server.serverport.."=>"..hostname..":"..port.."), ".. reason or "master rejected registration")
                else
                	client:close()
					error("could not register server, master sent unkown reply: "..line)
                end
            end)
        end)
    end)
	
end

function init()
	if not enabled:get() then return false, "registering server is not enabled in the config file" end
	
	local function loop()
		
		for i, adress in pairs(servers:get()) do
			local ip, port = unpack(adress:split(":"))
			
			register_server(tostring(ip), tonumber(port))
		end
	end
	loop()

	server.interval(interval:get(), loop)
end

server.event_handler("config_loaded", init)


