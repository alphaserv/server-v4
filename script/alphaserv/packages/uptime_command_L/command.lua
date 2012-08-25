command.command_from_table("uptime", {
	name = "uptime",
	usage = "#uptime",
	
	list = function(self, player)
		return true, "#uptime"
	end,
	
	help = function(self, player)
		return true, "Get the server uptime."
	end,
	
	execute = function(self, player, set)
		return true, true, {server.uptime / 1000, server.uptime }, {default_msg = "The uptime is: %(1)i"}
	end,
})
