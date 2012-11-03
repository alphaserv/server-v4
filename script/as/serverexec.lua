
module("as.serverexec", package.seeall)

function open()
	local MAX_TIME = 5
	local READ_SIZE = 256

	local file, errorMessage = os.open_fifo("serverexec")

	if not file then
		--!TODO add logging
		--as.log.msg(as.log.MSG_ERROR, errorMessage)
		print ("Could not open serverexec, ", errorMessage)
		return
	end

	fileStream = net.file_stream(file)

	local function read_expression(existing_code, discard_time_limit)

		fileStream:async_read_some(READ_SIZE, function(new_code, error_message)
		    
		    if not new_code then
		        server.log_error("serverexec read error:" .. error_message)
		    end
		    
		    if discard_time_limit and os.time() > discard_time_limit then
		        server.log_error("error in serverexec: discarding old incomplete code")
		        existing_code = ""
		    end
		    
		    code = (existing_code or "") .. new_code
		    
		    if not cubescript.is_complete_expression(code) then
		    	print("reading code", new_code)
		        read_expression(code, os.time() + MAX_TIME)
		        return
		    else
				print("execute code:", code)
		    end
		    
		    local error_message = cubescript.eval_string(code)
		    
		    if error_message then
		        
		        local code = "\n<!-- START CODE -->\n" .. code .. "<!-- END CODE -->"
		        --!TODO add logging
		        print("error in serverexec: " .. error_message .. code)
		    end
		    
		    read_expression()
		end)
	end

	read_expression()

	as.server.onShutdown:addListner(function()
		fileStream:close()
		os.remove("serverexec")
	end)
end
