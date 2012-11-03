command.command_from_table("spy", {
	name = "spy",
	usage = "#spy [1|0]",
	
	list = function(self, player)
		return true, "#spy"
	end,
	
	help = function(self, player)
		return true, "Toggle or set Spy mode."
	end,
	
	execute = function(self, player, set)
		if player:has_permission("auth::be::spy") then
			
			local set
			
			if type(set) == "nil" then
				set = not player.spymode
			elseif tonumber(set) == 1 then
				set = true
			elseif tonumber(set) == 0 then
				set = false
			else
				return false, self.usage			
			end
			
			player.spymode = set
			
			server.setspy(player.cn, player.spymode)

			return true, {}
		else
			return false, true, {player.cn}, {default_type = "info", default_message = "You cannot spy, red<Access denied>"}
		end
	end,
})
