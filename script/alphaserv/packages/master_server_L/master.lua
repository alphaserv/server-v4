--[[
-- old
require "net"
require "cubescript"

master = {}
master.servers = {}

function server.addserver(ip, port)
--	master.servers[ip..':'..port] = { ['ip'] = ip, ['port'] = port }
--	debug.write(-1, string.format('adding server (ip=%q, port=%q)', ip, port))
end

--//client//--
function master.close_client_connection(client, callback, error_message)
    client:close()
    if error_message then
    	debug.write(1, "master client error: "..tostring(error_message))
    end
    callback(error_message)
end

function master.register_server(hostname, port, gameport, callback)

    local client = net.tcp_client()
    
    if #server.serverip > 0 then
        client:bind(server.serverip, 0)
    end
    
    client:async_connect(hostname, port, function(error_message)
        
        if error_message then
            master.close_client_connection(client, callback, error_message)
            return
        end

        client:async_send(string.format("list\n", gameport), function(error_message)
        	local function readrow()
        		client:async_read_until("\n", function(data)
        			
        			if data then
        				print(string.format("data: %q", data))
        				data:gsub("\r", "")
        				data:gsub("\\r", "")
        				data:gsub("\n", "")
        				data:gsub("\\n", "")
        				data:gsub("\\", "")
        				print(string.format("data2: %q", data))
--        				assert(cubescript.eval_string(data)) --unsafe? yes, a bit
		    			if string.match(data ,"addserver (.*?) (.*?)") then
		    				local ip, port = string.match(data ,"addserver (.*?) (.*?)")
		    				master.servers[ip..':'..port] = { ['ip'] = ip, ['port'] = port }
		    				debug.write(-1, string.format('adding server (ip=%q, port=%q)', ip, port))
		    			else
		    				debug.write(1, string.format("error in addserver line(line=%q, i=none)", data))
		    			end
        				print('reading row')
        				readrow()
        			else
        				
					end
				end)
			end
			readrow()
        end)

    	client:async_send(string.format("regserv %i\n", gameport), function(error_message)
            
            if error_message then
                master.close_client_connection(client, callback, error_message)
                return
            end
            
            client:async_read_until("\n", function(line, error_message)
                
                if not line then
                    master.close_client_connection(client, callback, error_message or "failed to read reply from server")
                    return
                end
                
                local command, reason = line:match("([^ ]+)([ \n]*.*)\n")
                
                if command == "succreg" then
                    master.close_client_connection(client, callback)
                elseif command == "failreg" then
                    master.close_client_connection(client, callback, reason or "master server rejected registration")
                else
                    master.close_client_connection(client, callback, "master server sent unknown reply: "..line)
                end
            end)
        end)
    end)
end
function master.clientloop()
	if tonumber(config.get("master:client:updatemaster")) == 1 then
		debug.write(-1, "registering server")
		master.register_server(config.get("masterserver_host"), config.get("masterserver_port"), server.serverport, function(error_message)
        		if error_message then
                		log.write(("Master server error: " .. error_message), "error")
            		else
            			print("Server registration succeeded.")
            		end
		end)
	end
	server.sleep(tonumber(config.get("master:client:timeout")), master.clientloop)
end
server.sleep(1000, function()
	master.clientloop()
end)
--TODO: making masterserver
--//server//--

sauermaster = {}

function master:handleError(errmsg, retry)
    if not errmsg then return end
	print('Error :'..errmsg)
end

function print_debug(...) print(unpack(arg)) end

master.server_client, errors = net.tcp_acceptor("0.0.0.0", 10000)-- socket
if not master.server_client then error(errors) end

-- Send a response to the client
function sendmsg(msg)
    print_debug("[Output] : " .. msg)
    if not allow_stream then return end
    masterserver:async_send(msg .. "\n", function(success) end)
end

-- Accept client connection and read data sent
local function accept_next(master_server)
	master_server:async_accept(function(server)
		masterserver = server
		
		function read_data(server)
			server:async_read_until("\n", function(data)
				if data then
					print_debug("[Input] : " .. data)
					
					-- List handler
					if data.find(data,"list") then
						masterserver:async_send("addserver (init = [echo \"Welcome to Killme's masterserver\"; echo \"have fun gaming :)\"]; init;)\n", function(success) end)
						for i, row in ipairs(master.servers) do
							sendmsg("addserver "..row.ip.." "..row.port..";")
						end
						
						--close here?
						server:close()
						return
					elseif string.match(data, 'regserv %i') then
						local port = string.match(data, 'regserv %i')
						local endpoint = server:remote_endpoint(server)
						local ip = endpoint.ip;
						master.servers[ip..':'..port] = { ['ip'] = ip, ['port'] = port }
					elseif string.match(data, 'Login "(.-)" "(.-)" "(.-)"') then
						local function_name, player_name, session_id, password = string.gmatch(data, "[^ \n]+")
					end
					read_data(server)
				else
					master:handleError("Read error")
				end
			end)
		end
		read_data(server)

		print_debug("[Input] : " .. "connection accepted")
		allow_stream = true
					
		accept_next(master.server_client)
    end)
end


print("*-*+*-* Sauerbraten MasterServer listening on " .. '0.0.0.0' .. ":" .. 10000 .." *-*+*-*")

master.server_client:listen()

masterserver = master.server_client
accept_next(master.server_client)]]
