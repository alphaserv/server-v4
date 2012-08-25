module("clanwar", package.seeall)

command.command_from_table("clanwar", {
	usage = "#clanwar [map [mode]]",
	
	list = function(self, player)
		return true, "orange<#clanwar>"
	end,
	
	help = function(self, player)
		return true, "Command to start clanwars, usage: "..self.usage
	end,
	
	execute = function(self, player, map, mode)
		map = map or server.map
		mode = mode or server.gamemode
		
		server.pausegame(true)
		
		messages.load("clanwar", "announce", {default_type = "info", default_message = "A clanwar event will start in 10 seconds" })
							:format(map, map2, votes[1], votes[2])
							:send()
		server.msg("\f6CLANWAR\f1 EVENT WILL START IN\f5 20\f1 SECONDS! (\f5" .. mode .. "\f1) ON MAP (\f5" .. map .. "\f1)")

server.sleep(20000, function()

	server.changemap(map, mode)
	server.pausegame(true)
	
	local countdown = 11

server.interval(1000, function()

	countdown = countdown -1

	server.msg("\f6CLANWAR\f1 EVENT WILL START IN \f5" .. countdown .. " \f1SECONDS!")

		if countdown == 0 then

				server.pausegame(false)

				server.msg("\f6CLANWAR\f1 EVENT HAS BEEN STARTED!")

			return -1
		end

	end)

	end)

end

})


