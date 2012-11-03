--[[
	script/module/nl_mod/nl_controlteams.lua
	Hanack (Andreas Schaeffer)
	Created: 19-Nov-2010
	Last Modified: 19-Nov-2010
	License: GPL3

	Funktionen:
		Team Control

	Commands:
		#xyz
			xyz

	API-Methoden:
		teamcontrol.change(mode)
			Aendert den Modus

	Konfigurations-Variablen:
		teamcontrol.xyz
			xyz
]]



--[[
		API
]]

teamcontrol = {}

teamcontrol.balance_modes = {}
teamcontrol.balance_modes.NOBALANCE = 1

teamcontrol.shuffle_modes = {}
teamcontrol.shuffle_modes.NOSHUFFLE = 1

teamcontrol.shuffle_mode = 1
teamcontrol.balance_mode = 1
teamcontrol.shuffle = {}



function teamcontrol.change_shuffle_mode(mode)
	teamcontrol.shuffle_mode = mode
end

function teamcontrol.change_balance_mode(mode)
	teamcontrol.balance_mode = mode
end

teamcontrol.shuffle_mode[teamcontrol.shuffle_modes.NOSHUFFLE] = function()
	-- do nothing
end

teamcontrol.balance_mode[teamcontrol.balance_modes.NOBALANCE] = function()
	-- do nothing
end


--[[
		COMMANDS
]]

function server.playercmd_teamcontrol(cn, cmd, arg1)
end

-- function server.playercmd_tcshuffle(cn, t)
-- end

-- function server.playercmd_dobalance(cn,t )
-- end


--[[
		EVENTS
]]

server.event_handler("mapchange", function(map, mode)
	server.sleep(250, function()
		teamcontrol.shuffle_mode[teamcontrol.shuffle_mode](map, mode)
	end)
end)

server.event_handler("frag", function(cn)
	server.sleep(250, function()
		teamcontrol.balance_mode[teamcontrol.balance_mode](cn)
	end)
end)


