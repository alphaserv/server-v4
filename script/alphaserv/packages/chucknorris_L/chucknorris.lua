
module("chucknorris", package.seeall)

require "http.client"
require "Json"

--Since we're asynchronious we preload jokes
local joke = ""

function update_joke()
    http.client.get("http://api.icndb.com/jokes/random", function(body, status)
        
        if not body then
            error("Failed to download the global ban list: " .. table_to_string(status))
        end
        
        local data = Json.Decode(body)
        
        if not data then
        	error("malformed json")
        end
        
        if data.type ~= "success" then
        	error("error on fetch")
        end
        
        joke = data.value.joke
	end)
end

function get_joke()
	update_joke()
	return joke
end

--fetch the first joke
get_joke()
