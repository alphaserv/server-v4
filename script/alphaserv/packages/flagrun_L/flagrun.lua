module("flagrun", package.seeall)

drops = {}

server.event_handler("takeflag", function (cn)
	messages.load("flagrun", "take", {default_type = "info", default_message = "name<%(1)i> |have|has| picked up the flag for team<%(1)i>"})
		:format(cn)
		:send()
	
	local user = user_from_cn(cn)
	
	user.has_flag = true

	if not drops[user:team()] then
		user.is_flagrun = true
		user.flagrun_start = server.uptime
	end
end)

server.event_handler("dropflag", function (cn)
	messages.load("flagrun", "drop", {default_type = "info", default_message = "name<%(1)i> |have|has| lost the flag for team<%(1)i>"})
		:format(cn)
		:send()

	local user = user_from_cn(cn)

	drops[user:team()] = true
	
	user.is_flagrun = nil
	user.flagrun_start = nil
end)

server.event_handler("scoreflag", function (cn)
	local user = user_from_cn(cn)

	if not drops[user:team()] then
		--flagrun

		local time = server.uptime - user.flagrun_start
		time = time / 1000
		
		messages.load("flagrun", "flagrun", {default_type = "info", default_message = "name<%(1)i> |have|has| made a flagrun in %(2)i seconds!"})
			:format(cn, time)
			:send()

		user.is_flagrun = nil
		user.flagrun_start = nil				
	end

	user.has_flag = false
	drops[user:team()] = nil
end)

server.event_handler("returnflag", function (cn)
	messages.load("flagrun", "return", {default_type = "info", default_message = "name<%(1)s> |have|has| returned the flag for team<%(1)i>"})
		:format (cn)
		:send()
end)

server.event_handler("resetflag", function ()

	messages.load("flagrun", "reset", {default_type = "info", default_message = "The flag has been reset!"})
		:send()
end)



