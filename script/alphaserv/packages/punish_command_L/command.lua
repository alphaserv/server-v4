
command.command_from_table("punish", {
	name = "punish",
	usage = "usage: #punish <cn> <reason> [<punishment> [<time>]]",
	
	list = function(self, player)
		return true, "orange<punish>"
	end,
	
	help = function(self, player)
		return true, "This commands let you punish players. "..self.punish
	end,
	
	execute = function(self, player, cn, reason, punishement, time)
		if not cn or not reason or (punishment and not time) then
			return false, self.usage
		end
		
		if not server.valid_cn(cn) then
			return false, "invalid cn"
		end
		
		local user = user_from_cn(cn)
		user:punish(reason, punishment, time)
		return true, "punished"
	end,
})
