command.command_from_table("warning", {
	name = "warning",
	usage = "#warning <cn> <text>",
	
	list = function(self, player)
		return true, "#warning"
	end,
	
	help = function(self, player)
		return true, "Send a warning message to a player."
	end,
	
	execute = function(self, player, cn, ...)
		local msg = table.concat(arg, " ")
		
		if not cn or msg == "" or msg == " " then
			return false, self.usage
		end

		messages.load("punish", "warning", {default_type = "info", default_message = "name<%(1)i> %(2)s"})
			:format(cn, msg)
			:send()
		
		return true, {"Warning sent."}
	end,
})
