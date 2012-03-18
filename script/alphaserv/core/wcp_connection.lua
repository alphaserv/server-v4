
alpha.settings.init_setting("use_phpwcp", "true", "bool", "setup a connection with a connection with a control panel")
alpha.settings.init_setting("phpwcp_id", "-1", "int", "serverid to use")

alpha.settings.init_setting("phpwcp_fifo_path", "", "string", "path to the fifo file to use.")

alpha.settings.init_setting("server_id", "-1", "int", "id of the server")--TODO: make this a dynamic_setting

alpha.wcp = {}


local MAX_TIME = 5
local READ_SIZE = 256
local file_stream

server.event_handler("db_loaded", function()
	if not alpha.settings:get("use_phpwcp") then return end

	--get path
	local path = alpha.settings:get("phpwcp_fifo_path")
	
	--get serverid
	local id = tonumber(alpha.settings:get("phpwcp_id"))
	
	print("[debug] initial serverid is: "..id)
	local result
	if id < 0 then
		print("[debug] seacrching id ...")
		result = alpha.db:query("SELECT `id`, `port`, `name`, `path`, `running` FROM  `local_servers` WHERE  port = ? and name = ?;", server.serverport, alpha.settings:get("servername"))
		
		if not result then
			error("no db result received")
		end
	else
		result = alpha.db:query("SELECT `id`, `port`, `name`, `path`, `running` FROM  `local_servers` WHERE  id = ?;", id)
		if result:num_rows() < 1 then
			error("invalid serverid, did you add it in the database?")
		end
	end	
	
	if result:num_rows() ~= 1 then
		local update_path
		if path == "" then

			update_path = true
		else
			update_path = false
		end
		
		if not alpha.db:query("INSERT INTO local_servers (`id`, `port`, `name`, `path`, `running`) VALUES (NULL, ?, ?, ?, b'1');", server.serverport, alpha.settings:get("servername"), path) then
			error('could not insert server into serverlist')
		else
			local r = alpha.db:query("SELECT last_insert_id() as id"):fetch()
			print("found id: "..r[1].id)
			if r ~= nil then
				if id < 0 and update_path then
					id = r[1]["id"]
					r = nil

					--reupdate path					
					path = "/tmp/as/"..alpha.settings:get("servername").."."..id
					if not alpha.db:query("UPDATE local_servers SET path = ? WHERE id = ?", path, id) then
						error("could not update path in database, db corruption occured")
					end
				else
					id = r[1]["id"]
					r = nil
				end

			else
				error("could not find serverid of inserted row")
			end
		end
	else
		local fetchedresult	= result:fetch()[1]
		if path == "" then
			path = fetchedresult.path
		end
		if id < 0 then
			fetchedresult.id = tonumber(fetchedresult.id)
			if fetchedresult.id < 0 then
				--wtf
				error("unvalid database id value: "..table_to_string(fetchedresult))
			end
			id = fetchedresult.id
		end
			
	end
	alpha.settings:set("phpwcp_fifo_path", path)
	alpha.settings:set("server_id", id)
	print("serverid is: "..id)
	
	--update status
	if not alpha.db:query("UPDATE  local_servers SET running = b'1' WHERE `id` = ?;", id) then
		error("could not change database server status to: online")
	end
	
	--[ [ TODO: make shure that the dir exists?
	pcall(function()
	os.execute("mkdir "..path.."-a")
	os.execute("rm -r "..path.."-a")
	end)--]]
	
	local file, error_message = os.open_fifo(path)
	
	if not file then
		error(string.format("could not create server connection fifo file %s: %s", path.."as_"..id, error_message))
	end
	
	print(path.." opened for wcp")

	file_stream = net.file_stream(file)
	
	local function read_expression(existing_code, discard_time_limit)

		file_stream:async_read_some(READ_SIZE, function(new_code, error_message)
		    
		    if not new_code then
		        error("wcp file read error:" .. error_message)
		    end
		    
		    local discard = false
		    if discard_time_limit and os.time() > discard_time_limit then
		        discard = true
		        existing_code = ""
		    end
		    
		    code = (existing_code or "") .. new_code
		    
		    if not cubescript.is_complete_expression(code) then
		        read_expression(code, os.time() + MAX_TIME)
		        return
		    end
		    
		    local error_message = cubescript.eval_string(code)
		    
		    if error_message then
		        
		        local code = "\n{{\n" .. code .. "}}"
		        error("error in wcp file: " .. error_message .. code)
		    end
		    
		    if discard then
		    	error("error in wcp file: discarding old incomplete code")
		    end
		    read_expression()
		end)
	end
	
	read_expression()
end)



server.event_handler("shutdown", function()
	if file_stream then
		file_stream:close()
		os.remove(alpha.settings:get("phpwcp_fifo_path"))
	end
    if not alpha.db:query("UPDATE local_servers SET running = b'0' WHERE `id` = ?;", id) then
		error("could not change database server status to: offline")
	end
end)

--TODO: use a second namespace
cubescript.library["wcp"] = function(call, ...)
	--create acces to alphaserv extern-marked functions
	if not alpha.fn[call] then
		local file = assert(io.open(alpha.settings:get("phpwcp_fifo_path")..".result","w"))
		file:write("<?php throw new exceptiion ('trying to call undefinded function'); ?>")
		file:close()
		error("ẗrying to call undefined function")
	else
		local file = assert(io.open(alpha.settings:get("phpwcp_fifo_path")..".result","w"))
		file:write("<?php return '"..alphaserv.fn[call](unpack(arg)).."';?>")
		file:close()
	end
end

