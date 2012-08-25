
module("maproation.suggestions", package.seeall)

local allowed_gamemodes = alpha.settings.new_setting("allowed_modes", { "insta ctf", "instagib" } , "Gamemodes that are allowed.")
local unkown_maps = alpha.settings.new_setting("allowed_unkown_mapvotes", false, "accept votes for unkown maps.")

suggestions = {}
use_buildin = true -- use buildin c++ mapvote system

local function allowed_gamemode(mode_)
	for i, mode in pairs(allowed_gamemodes:get()) do
		if mode == mode_ then
			return true
		end
	end
	
	return false
end

server.event_handler("mapvote", function(cn, map, mode)

	if not allowed_gamemode(mode) then
		messages.load("maprotation", "cannot_vote", {default_type = "warning", default_message = "red<Cannot vote for that map: > orange<%(1)s>" })
			:format("invalid gamemode", cn, map, mode)
			:send(cn, true)
		return -1
	end
	
	if not unkown_maps:get() and not maprotation.get_map_provider():has_map(mode, map) then
		messages.load("maprotation", "cannot_vote", {default_type = "warning", default_message = "red<Cannot vote for that map: > orange<%(1)s>" })
			:format("unkown map", cn, map, mode)
			:send(cn, true)	
		return -1
	end
	
	local user = user_from_cn(cn)
	
	if user.map_suggested then
		messages.load("maprotation", "cannot_vote", {default_type = "warning", default_message = "red<Cannot vote for that map: > orange<%(1)s>" })
			:format("You can only vote for a map once", cn, map, mode)
			:send(cn, true)		
		return -1
	end
	
	user.map_suggested = true
	
	if not suggestions[mode..":"..map] then
		suggestions[mode..":"..map] = 0
	end
	
	suggestions[mode..":"..map] = suggestions[mode..":"..map] + 1
	
	if maprotation.get_intermissionmode_obj():mapvote(user, map, mode, 	suggestions[mode..":"..map]) then
		return -1
	end
		
	messages.load("maprotation", "suggest", {default_type = "info", default_message = "green<suggestion accepted>" })
		:format(cn, map, mode)
		:send(cn, true)
	
	if not use_buildin then
		return -1
	end
end)
