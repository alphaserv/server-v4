
module("maprotation.mapbattle", package.seeall)

local allowed_gamemodes = alpha.settings.new_setting("mapbattle_ignore_novote", true , "just pick a random map when no suggestions were made.")

votes = {}
maps = {}


mapbattle_intermission_mode_obj = class.new(maprotation.default_intermission_mode_obj, {
	intermission = function(self, map, map2, i)
		votes = {0, 0}
		self.cancelled = false
		
		i = i or 1
		
		map = map or maps[1] or maprotation.get_map_provider():get_map(server.gamemode)
		map2 = map2 or maps[2] or maprotation.get_map_provider():get_map(server.gamemode)

		if i == 1 then
			messages.load("mapbattle", "vote", {default_type = "info", default_message = "blue<mapbattle> green<%(1)s> yellow<VS> green<%(2)s> blue<use> green<#1> and green<#2> to vote!" })
				:format(map, map2)
				:send()
		end
		
		maps = {map, map2}
		
		server.sleep(5000, function()
			if not self.cancelled then
				if votes[1] == votes[2] then
					if i == 1 then
						messages.load("mapbattle", "sudden_death", {default_type = "info", default_message = "green<SUDDEN DEATH> blue<you can now> green<vote again> blue<vote> green<fast!>" })
								:format(map, map2, votes[1], votes[2])
								:send()
						
						for cn, player in pairs(alpha.user.users) do
							player.has_voted = false
						end
							
						self:intermission(map, map2, i + 1)
					else
						messages.load("mapbattle", "random", {default_type = "info", default_message = "green<SUDDEN DEATH> orange<failed> blue<picking random map>" })
							:format(map, map2, votes[1], votes[2])
							:send()

						maps = {}					
						
						maprotation.get_map_provider():change_map(map, server.gamemode)
					end
				else
					if votes[1] < votes[2] then

						messages.load("mapbattle", "winner", {default_type = "info", default_message = "Winner: green<%(1)s>; loser: yellow<%(2)s> (mode: %(3)s)" })
							:format(map2, map, server.gamemode)
							:send()

						maps = {}
						
						maprotation.get_map_provider():change_map(map2, server.gamemode)
					elseif votes[1] > votes[2] then

						messages.load("mapbattle", "winner", {default_type = "info", default_message = "Winner: green<%(1)s>; loser: yellow<%(2)s> (mode: %(3)s)" })
							:format(map, map2, server.gamemode)
							:send()

						maps = {}
						maprotation.get_map_provider():change_map(map, server.gamemode)
					end
				end
			end
		end)
	end,
	
	mapvote = function(self, user, map, mode, count)
		if maps[1] and maps[2] then
			messages.load("maprotation", "cannot_vote", {default_type = "warning", default_message = "red<Cannot vote for that map: > orange<%(1)s>" })
				:format("already 2 maps suggested for a mapbattle", user.cn, map, mode)
				:send(cn, true)
			
			return true
		end
		
		if maps[1] == map then
			messages.load("maprotation", "cannot_vote", {default_type = "warning", default_message = "red<Cannot vote for that map: > orange<%(1)s>" })
				:format("that map is already suggested", user.cn, map, mode)
				:send(cn, true)
			
			return true
		end
		
		
		if mode ~= server.gamemode then
			--TODO
		end
		
		if maps[1] then
			maps[2] = map
		else
			maps[1] = map
		end
		
		messages.load("maprotation", "suggest", {default_type = "info", default_message = "green<suggestion accepted>" })
			:format(cn, map, mode)
			:send(cn, true)
		
		return true
	end,
	
	cancel = function(self)
		self.cancelled = true
		maps = {}
	end,
})

maprotation.add_intermissionmode("mapbattle", mapbattle_intermission_mode_obj)
maprotation.set_intermissionmode("mapbattle")

command.command_from_table("1", {
	name = "1",
	
	list = function(self, player)
		return false
	end,
	
	help = function(self, player)
		return true, "Votes for map 1 in a mapbattle."
	end,
	
	execute = function(self, player)
		if player.has_voted then
			return false, {"you have already voted!"}
		end
		
		player.has_voted = true
		
		votes[1] = votes[1] + 1
		
		messages.load("mapbattle", "vote_1", {default_type = "info", default_message = "%(2)s (%(4)i) VS %(3)s (%(5)i) --name<%(1)i> voted for 1, use #1 and #2 to vote!" })
			:format(player.cn, maps[1], maps[2], votes[1], votes[2])
			:send()
		
		return true, {"Successfully voted"}
	end,
})

command.command_from_table("2", {
	name = "2",
	
	list = function(self, player)
		return false
	end,
	
	help = function(self, player)
		return true, "Votes for map 2 in a mapbattle."
	end,
	
	execute = function(self, player)
		if player.has_voted then
			return false, {"you have already voted!"}
		end
		
		player.has_voted = true
		
		votes[2] = votes[2] + 1
		
		messages.load("mapbattle", "vote_2", {default_type = "info", default_message = "%(2)s (%(4)i) VS %(3)s (%(5)i) --name<%(1)i> voted for 2, use #1 and #2 to vote!" })
			:format(player.cn, maps[1], maps[2], votes[1], votes[2])
			:send()
		
		return true, {"Successfully voted"}
	end,
})
