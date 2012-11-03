command.command_from_table("master", {
	name = "master",
	usage = "#master",
	
	list = function(self, player)
		return true, "#master"
	end,
	
	help = function(self, player)
		return true, "gives you master if you are allowed to have master."
	end,
	
	execute = function(self, user)
		if user:has_permission("auth::be::master") then
			server.setmaster(user.cn)

			messages.load("privilege", "grant_master", {default_type = "info", default_message = "green<name<%(1)i>> |have|has| claimed master.", use_irc = true })
				:format(user.cn)
				:send()

			return true, {}
		else
			return false, true, {user.cn}, {default_type = "info", default_message = "You cannot claim master, red<Access denied>"}
		end
	end,
})
