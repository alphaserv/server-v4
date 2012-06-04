
module("maprotation.veto", package.seeall)

local allowed_gamemodes = alpha.settings.new_setting("veto_ignore_novote", true , "just pick a random map when no suggestions were made.")

votes = {}
maps = {}

vote_obj = class.new(nil, {
	user = nil,
	vote = "",
	
	__init = function(self, user, vote)
		self.user = user
		self.vote = vote
	end,
})


veto_intermission_mode_obj = class.new(maprotation.default_intermission_mode_obj, {
	intermission = function(self, map, next, i)
		votes = {}
		self.cancelled = false
		
		i = i or 1
		
		map = map or maps[1] or maprotation.get_map_provider():get_map(server.gamemode)


		if i == 1 then
			messages.load("veto", "vote", {default_type = "info", default_message = "blue<veto> green<%(1)s> use green<#veto> or green<#noveto> to vote!" })
				:format(map)
				:send()
		end
		
		maps = {map}
		
		server.sleep(5000, function()
			if not self.cancelled then
				if votes[1] == votes[2] then
					if i == 1 then
						messages.load("veto", "sudden_death", {default_type = "info", default_message = "green<SUDDEN DEATH> blue<you can now> green<vote again> blue<vote> green<fast!>" })
								:format(map)
								:send()
						
						for cn, player in pairs(alpha.user.users) do
							player.has_voted = false
							user.map_suggested = false
						end
							
						self:intermission(map, _, i + 1)
					else
						messages.load("veto", "random", {default_type = "info", default_message = "green<SUDDEN DEATH> orange<failed> blue<picking random map>" })
							:format(map, map2, votes[1], votes[2])
							:send()

						maps = {}	
						
						maprotation.get_map_provider():change_map(map, server.gamemode)
					end
				else
					local count = 0
					
					for i, vote in pairs(votes) do
						if vote.vote == map then
							count = count + 1
						end
					end
					
					if count > (#votes / 2) then

						messages.load("veto", "veto_not_accepted", {default_type = "info", default_message = "Map accepted" })
							:format(map2, map, server.gamemode)
							:send()

						maps = {}
						
						maprotation.get_map_provider():change_map(map2, server.gamemode)
					elseif count < (#votes / 2) then

						messages.load("veto", "veto_accepted", {default_type = "info", default_message = "Map voted out!" })
							:format(map, map2, server.gamemode)
							:send()

						maps = {}
						self:intermission(maprotation.get_map_provider():get_map(server.gamemode))
					end
				end
			else
				log_msg(LOG_WARNING, "intermission cancelled")
			end
		end)
	end,
	
	mapvote = function(self, user, map, mode, count)
		if user.has_voted then
			return false, {"you have already voted!"}
		end
		
		votes[#votes + 1 ] = vote_obj(user, map)
		
		messages.load("maprotation", "suggest", {default_type = "info", default_message = "green<accepted>" })
			:format(cn, map, mode)
			:send(cn, true)
		
		return true
	end,
	
	cancel = function(self)
		self.cancelled = true
		maps = {}
	end,
})

maprotation.add_intermissionmode("veto", veto_intermission_mode_obj)
maprotation.set_intermissionmode("veto")
--[[
command.command_from_table("veto", {
	name = "veto",
	
	list = function(self, player)
		return false
	end,
	
	help = function(self, player)
		return true, "Votes for map 1 in a veto."
	end,
	
	execute = function(self, player)
		if player.has_voted then
			return false, {"you have already voted!"}
		end
		
		player.has_voted = true
		
		votes[1] = votes[1] + 1
		
		messages.load("veto", "vote_1", {default_type = "info", default_message = "%(2)s (%(4)i) VS %(3)s (%(5)i) --name<%(1)i> voted for 1, use #1 and #2 to vote!" })
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
		return true, "Votes for map 2 in a veto."
	end,
	
	execute = function(self, player)
		if player.has_voted then
			return false, {"you have already voted!"}
		end
		
		player.has_voted = true
		
		votes[2] = votes[2] + 1
		
		messages.load("veto", "vote_2", {default_type = "info", default_message = "%(2)s (%(4)i) VS %(3)s (%(5)i) --name<%(1)i> voted for 2, use #1 and #2 to vote!" })
			:format(player.cn, maps[1], maps[2], votes[1], votes[2])
			:send()
		
		return true, {"Successfully voted"}
	end,
})]]
