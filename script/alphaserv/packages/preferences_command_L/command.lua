command.command_from_table("preference", {
	name = "preference",
	usage = "usage: #preference [name] <value>",
	
	list = function(self, player)
		return true, "yellow<preference>"
	end,
	
	help = function(self, player)
		return true, "This command shows and sets your preferences. "..self.usage
	end,
	
	execute = function(self, player, name, value)
		if not name then
			return false, self.usage
		end
		
		if value then
			if value == "false" then
				value = false
			elseif value == "true" then
				value = true
			else
				value = tostring(value)
			end
			
			local success, msg = player:preference(name, value)
			
			if msg then
				return success, msg
			end
						
			return true, "successfully set"
		else
			return true, "value = "..alpha.settings.serialize_data(player:preference(name), 0)
		end
	end,
})
