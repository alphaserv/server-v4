--[[
	script/module/nl_mod/nl_invalidpickup.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		24-Apr-2012
	Last Change:	24-Apr-2012
	License:		GPL3

]]



--[[
		API
]]

invalidpickup = {}
invalidpickup.enabled = 1
invalidpickup.only_warnings = 1

function invalidpickup.no_items()
	return
		maprotation.game_mode ~= "coop edit" and
		maprotation.game_mode ~= "ffa" and
		maprotation.game_mode ~= "teamplay" and
		maprotation.game_mode ~= "capture" and
		maprotation.game_mode ~= "protect" and
		maprotation.game_mode ~= "ctf" and
		maprotation.game_mode ~= "hold"
end

-- no_ammo (capture):
-- health 14
-- health boost 15
-- armour green 16
-- armour yellow 17
-- quad 18
function invalidpickup.no_ammo(type)
	return
		maprotation.game_mode == "capture" and
		(type < 14 or type > 18)
end

function invalidpickup.check(cn, type)
	if invalidpickup.no_items() or invalidpickup.no_ammo(type) then
		if invalidpickup.only_warnings == 1 then
			messages.warning(-1, players.admins(), "INVALIDPICKUP", string.format("%s (%i) is picking up an invalid entity (type %i)", server.player_name(cn), cn, type))
		else
			messages.error(-1, players.admins(), "INVALIDPICKUP", string.format("%s (%i) is picking up an invalid entity (type %i)", server.player_name(cn), cn, type))
			cheater.autokick(-1, "Server", "Invalid respawn point")
		end
	end
end


--[[
		EVENTS
]]

server.event_handler("pickup", function(cn, i, type)
	invalidpickup.check(cn, type)
end)
