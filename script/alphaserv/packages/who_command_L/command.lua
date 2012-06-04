
command.command_from_table("who", {
	name = "who",
	usage = "usage: #who [cn]",
	
	list = function(self, player)
		return true, "blue<who>"
	end,
	
	help = function(self, player)
		return true, "This command shows basic information about players."
	end,
	
	execute = function(self, player, cn)
		--[[ somehow crashes
		if type(cn) ~= "nil" then
			local user = user_from_cn(cn)
			messages.load("who", "single", {default_type = "info", default_message = "name<%(1)i> (%(1)i, %(2)s, %(3)s)"})
				:format(user.cn, user:ip(), geoip.ip_to_country(user:ip()))
				:send(player.cn, true)
		else]]
			for i, user in pairs(alpha.user.users) do
				messages.load("who", "multi", {default_type = "info", default_message = "name<%(1)i> (%(1)i, %(2)s, %(3)s)"})
					:format(user.cn, user:ip(), geoip.ip_to_country(user:ip()))
					:send(cn.player, true)
			end
		--end
		return true, {}
	end,
})
