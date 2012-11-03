command.command_from_table("time", {
	name = "time",
	usage = "#time <time in seconds>",
	
	list = function(self, player)
		return true, "time"
	end,
	
	help = function(self, player)
		return true, "Set the time."
	end,
	
	execute = function(self, player, time)
		if not time then
			return false, self.usage
		end
		
		server.changetime(time * 1000)
		
		messages.load("time", "new", {default_type = "info", default_message = "green<name<%(1)i>> Changed the time to green<%(1)2>", use_irc = true })
			:format(cn, time * 10000)
			:send()
			
		return true, "Time successfully changed"
	end,
})
