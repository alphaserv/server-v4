command.command_from_table("pause", {
	name = "pause",
	usage = "usage: #pause",
	
	list = function(self, player)
		return true, "yellow<pause>"
	end,
	
	help = function(self, player)
		return true, "This command pauses the game. "..self.usage
	end,
	
	execute = function(self, player)
		server.pause(player.cn)
		
		return true, {}
	end,
})

command.command_from_table("resume", {
	name = "resume",
	usage = "usage: #resume <countdown>",
	
	list = function(self, player)
		return true, "yellow<resume>"
	end,
	
	help = function(self, player)
		return true, "This command pauses the game. "..self.usage
	end,
	
	execute = function(self, player, cdown)
		server.resume(player.cn, cdown)		
		return true, {}
	end,
})
