
module("connect", package.seeall)

local unkown_text = alpha.settings.new_setting("unkown_text", "unkown", "The text to display when there is no country/city match.")
local local_country = alpha.settings.new_setting("local_country", "netherlands", "The country where the server is located or false.\n is used when there is no country match and the ip starts with 192.")

server.event_handler("connect", function(cn)
	local ip = server.player_ip(cn)
	local country = geoip.ip_to_country(ip)
	local city = geoip.ip_to_city(ip)
	
	server.sleep(1000, function()
	
		if not country or country == "" then
			country = unkown_text:get()
		
			--[[if ip[1] == "1" and ip[2] == "9" and ip[1] == "2" and local_country:get() then
				country = local_country:get()
			end]]
		end

		if not city or city == "" then
			country = unkown_text:get()
		end
	
		messages.load("connect", "motd", {default_type = "info", default_message = "green<Welcome> blue<on yet another alphaserver.> green<V4 version>"})
			:format(cn)
			:send({cn}, true)

		messages.load("connect", "message", {default_type = "info", default_message = "green<name<%(1)i>> blue<connected from> green<%(2)s, %(3)s>", use_irc = true})
			:format(cn, country, city)
			:send()

		messages.load("connect", "ip", {default_type = "info", default_message = "blue<IP:> green<%(1)s>"})
			:format(ip, cn, geoip.ip_to_country(ip), geoip.ip_to_city(ip))
			:send()
	end)
end)
