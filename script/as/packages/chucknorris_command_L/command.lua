
command.command_from_table("chucknorris", {
	name = "chucknorris",
	usage = "usage: #chucknorris",
	
	list = function(self, player)
		return true, "blue<chucknorris>"
	end,
	
	help = function(self, player)
		return true, "This command enables fun by returning chucknorris facts."
	end,
	
	execute = function(self, player)
		return true, {chucknorris.get_joke()}
	end,
})
