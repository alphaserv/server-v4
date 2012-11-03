--[[
	script/module/nl_mod/nl_gamemodes.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		08-Aug-2012
	Last Modified:	08-Aug-2012
	License:		GPL3

	Description:
		Library for game modes
]]



--[[
		API
]]

gamemodes = {}
gamemodes.is_insta_mode = {}
gamemodes.is_insta_mode['ffa'] = false
gamemodes.is_insta_mode['coop edit'] = false
gamemodes.is_insta_mode['teamplay'] = false
gamemodes.is_insta_mode['instagib'] = true
gamemodes.is_insta_mode['instagib team'] = true
gamemodes.is_insta_mode['efficiency'] = false
gamemodes.is_insta_mode['efficiency team'] = false
gamemodes.is_insta_mode['tactics'] = false
gamemodes.is_insta_mode['tactics team'] = false
gamemodes.is_insta_mode['capture'] = false
gamemodes.is_insta_mode['regen capture'] = false
gamemodes.is_insta_mode['ctf'] = false
gamemodes.is_insta_mode['insta ctf'] = true
gamemodes.is_insta_mode['protect'] = false
gamemodes.is_insta_mode['insta protect'] = true
gamemodes.is_insta_mode['hold'] = false
gamemodes.is_insta_mode['insta hold'] = true
gamemodes.is_insta_mode['efficiency ctf'] = false
gamemodes.is_insta_mode['efficiency protect'] = false
gamemodes.is_insta_mode['efficiency hold'] = false

function gamemodes.is_insta(mode)
	if mode ~= nil then
		retval = gamemodes.is_insta_mode[mode]
		if retval == nil then
			return false
		else
			return retval
		end
	else
		return gamemodes.is_insta_mode[maprotation.game_mode]
	end 
end

