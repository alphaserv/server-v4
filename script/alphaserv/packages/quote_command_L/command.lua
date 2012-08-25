
command.command_from_table("quote", {
	name = "quote",
	usage = "usage: #quote <category>",
	
	list = function(self, player)
		return true, "blue<quote>"
	end,
	
	help = function(self, player)
		return true, "This commands displays quotes on different categories, default category = joke."
	end,
	
	execute = function(self, player)
		local quote = quotes.get_random_quote(category or "jokes")
		quote = quote:split("\n") --make it an array
		return true, quote
	end,
})
