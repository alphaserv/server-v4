--[[
	script/module/nl_mod/nl_silence.lua
	Hanack (Andreas Schaeffer)
	Created: 12-Sep-2010
	Last Modified: 24-Okt-2010
	License: GPL3

	Funktionen:
		Erlaubt alle Spieler zu muten und unmuten

	Commands:
		#silence
			Alle Spieler werden gemuted
		#unsilence
			Alle Spieler können wieder schreiben
]]



--[[
		COMMANDS
]]

function server.playercmd_silence(cn)
	if not hasaccess(cn, mute_access) then return end
	for _,pcn in pairs(players.all()) do
		server.mute(pcn)
    end
	messages.warning(cn, players.admins(), "SILENCE", server.player_displayname(cn) .. " wants silence and muted all players!")
end

function server.playercmd_unsilence(cn)
	if not hasaccess(cn, mute_access) then return end
	for _,pcn in pairs(players.all()) do
		server.unmute(pcn)
    end
	messages.warning(cn, players.admins(), "SILENCE", server.player_displayname(cn) .. " unmuted all players!")
end
