
return {
	name = "Irc Bot",
	
	dependics = {
		"command"
	},
	load = {
		--"user_obj.lua"
		"chan_obj.lua",
		"network_obj.lua",
		"irc.lua"
	}
}
	
