local fields = alpha.settings.new_setting("stats_command_display_fields", { name = "green", username = "green", team = "green", country = "green", frags = "blue", deaths = "orange", suicides = "red", misses = "yellow", shots = "blue", hits_made = "blue", hits_get = "orange", tk_made = "red", tk_get = "red", flags_returned = "green", flags_stolen = "green", flags_gone = "orange", flags_scored = "green", total_scored = "green", damage = "orange", damagewasted = "orange", accuracy = "green", timeplayed = "blue"}, "The fields that the #stats command should use.")
local chars = alpha.settings.new_setting("stats_command_max_column", 50, "How many columns before starting a new line.")

command.command_from_table("stats", {
	name = "stats",
	usage = "usage: #stats, #stats <cn> or #stats <name>",
	
	list = function(self, player)
		return true, "blue<stats>"
	end,
	
	help = function(self, player)
		return true, "This command enables you to see all the stats of yourself or another player. Usage: "..self.usage
	end,
	
	execute = function(self, player, cn)
		if not cn then
			return true, self.send_stats(player, player.cn)
		end
		
		if cn == -1 then
		
		elseif not server.valid_cn(cn) then
			cn = server.name_to_cn(cn)
			
			if not server.valid_cn(cn) then
				return false, {self.usage}
			end
		end
		
		send.stats(player, cn)
	end,
	
	send_stats = function(player, cn)
		local ret = {}
		local user = user_from_cn(cn)
		local count = chars:get()
		
		for row, color in pairs(fields:get()) do
			if #ret[#ret] > count then
				ret[#ret + 1] = ""
			else
				ret[#ret] = ret[#ret] .. ", "
			end
			
			ret[#ret] = ret[#ret] .. color .. "<" .. user:get_stat(row) .. ">"
		end
		
		return ret
	end,
})
