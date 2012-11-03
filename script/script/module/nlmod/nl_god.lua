--[[
	script/module/nl_mod/nl_god.lua
	Hanack (Andreas Schaeffer)
	Created: 24-Okt-2010
	Last Modified: 24-Okt-2010
	License: GPL3

	Funktionen:
		Nur wenn ausschliesslich Admins auf dem Server sind, koennen diese ausnahmslos boesartigen
		Befehle, die einen nie dagewesenen Machtmissbrauch darstellen, ausgefuehrt werden. 

	Commands:
		#atomicbomb
			Tötet alle Spieler
		#atomicbomb <TEAM>
			Tötet alle Spieler eines Teams

	Konfigurations-Variablen:
		badphrase.messages.kick
			Liste mit Phrases, die zu einem Kick führen
		badphrase.messages.mute
			Liste mit Phrases, die geblockt werden
]]

require "math"

--[[
		API
]]

god = {}

function god.are_there_only_admins()
	for i,cn in ipairs(players.all()) do
		if not hasaccess(cn, admin_access) then return false end
    end
    return true
end



--[[
		COMMANDS
]]

function server.playercmd_atomicbomb(cn, team)
	if god.are_there_only_admins() then
		if team then
			local active_players = server.team_players(team)
			for _,pcn in pairs(active_players) do
				if cn ~= pcn then server.spec(pcn) end
	    	end
			server.sleep(300, function()
				for _,pcn in pairs(active_players) do
					if cn ~= pcn then server.unspec(pcn) end
			    end		
			end)
		else
			local active_players = players.active()
			for _,pcn in pairs(active_players) do
				if cn ~= pcn then server.spec(pcn) end
	    	end
			server.sleep(300, function()
				for _,pcn in pairs(active_players) do
					if cn ~= pcn then server.unspec(pcn) end
			    end		
			end)
		end
	end
end

function server.playercmd_chickenrun(cn)
	if god.are_there_only_admins() then
		nl.updatePlayer(cn, "protect", 1, "set")
		server.changemap("box_demo", "ffa")
		for _,cn in pairs(players.all()) do
			server.unspec(cn)
		end
	end
end

