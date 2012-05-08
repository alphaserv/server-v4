
module("maprotation.mapbattle", package.seeall)

mapbattle_intermission_mode_obj = class.new(maprotation.default_intermission_mode_obj, {
	intermission = function(self)
		self.cancelled = false
		local map = current_map_provider:get_map(server.gamemode)
		local map2 = current_map_provider:get_map(server.gamemode)

		server.msg("Mapbattle use #1 and #2 to vote"
		
		server.sleep(3000, function()
			if not self.cancelled then
				current_map_provider:change_map(map, server.gamemode)
			end
		end)
	end,
	
	--on mapchange not done by map provider
	cancel = function(self)
		self.cancelled = true
	end,
})

add_intermissionmode("default", default_intermission_mode_obj)

set_intermissionmode("default")

