require "http_server"
require "cubescript"

local content_handler = {}

content_handler["text/x-cubescript"] = function(request, code)
    
    local error_message, result = cubescript.eval_string(code)
    
    result = tostring(result)
    
    local responseStatus = 200
    
    --if #result == 0 then responseStatus = 204 end
    
    if error_message then
        server.log_error("http resource serverexec error: " .. error_message .. "\n<!-- start code -->\n" .. code .. "\n<!-- end code -->")
        responseStatus = 400
        result = error_message
    end
    
    local response = http_server.response(request, responseStatus)
    response:header("Content-Type", "text/plain")
    
    response:set_content_length(#result)
    response:send_header()

    if #result > 0 then
        response:send_body(result)
    end
end

http_server_root["serverexec"] = http_server.resource({
    post = function(request)

        local handler = content_handler[request:content_type() .. "/" .. request:content_subtype()]
        
        if handler then
            request:async_read_content(function(code)
            
                if web_admin.require_backend_login(request) then
                    return
                end
            
                handler(request, code)
            end)
        else

            http_response.send_error(request, 400, "Unsupported content type")
        end
    end
})
