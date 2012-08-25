command.command_from_table("admin", {
	name = "admin",
	usage = "#admin",
	
	list = function(self, player)
		return true, "#admin"
	end,
	
	help = function(self, player)
		return true, "gives you admin if you are allowed to have admin."
	end,
	
	execute = function(self, user)
		if user:has_permission("auth::be::admin") then
			server.setadmin(user.cn)				

			messages.load("privilege", "grant_admin", {default_type = "info", default_message = "green<name<%(1)i>> |have|has| claimed admin.", use_irc = true })
				:format(user.cn)
				:send()

			return true, {}
		else
			return false, true, {user.cn}, {default_type = "info", default_message = "You cannot claim admin, red<Access denied>"}
		end
	end,
})
