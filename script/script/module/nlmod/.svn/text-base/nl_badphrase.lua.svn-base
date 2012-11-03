--[[
	script/module/nl_mod/nl_badphrase.lua
	Hanack (Andreas Schaeffer)
	Created: 24-Okt-2010
	Last Modified: 24-Okt-2010
	License: GPL3

	Funktionen:
		Führt verschiedene Aktionen aus, wenn bestimmte Dinge gesagt werden.
		Vor allem um Nazis oder Trolls draußen zu halten.

	API-Methoden:
		badphrase.check_message(cn, msg)
			Überprüft eingehende Chat-Messages

	Konfigurations-Variablen:
		badphrase.messages.kick
			Liste mit Phrases, die zu einem Kick führen
		badphrase.messages.mute
			Liste mit Phrases, die geblockt werden
]]



--[[
		API
]]

badphrase = {}
badphrase.messages = {}
badphrase.messages.kick = {
	"hitler is cool",
	"long live 18",
	"long live 88",
	"the only way: 18",
	"the only way: 88",
	"tod den juden",
	"yeahh hitler",
	"hunt down all the niggers",
	"100% deutsch",
	"unsere ehre heißt treue",
	"mein kampf",
	"heil hitler",
	"heil.hitler",
	"hiel.hitler",
	"sieg heil",
	"seig heil",
	"seig hiel",
	"sieg hiel"
}
badphrase.messages.pbox = {
	"i wanna cheat",
	"i need cheat",
	"i need some cheats"
}
badphrase.messages.mute = {
	"faggot",
	"arisch",
	"auschwitz",
	"dachau",
	"nigger",
	"nigga",
	"negro",
	"kike",
	"motherfucker",
	"jude",
	"wichser",
	"kanake",
	"polake",
	"kinderficker",
	"scheiss auslaender"
}

function badphrase.check_message(cn, msg)
	for _,t in pairs(badphrase.messages.kick) do
		if string.find(string.lower(msg), t) then
			server.kick(cn, cheater.ban.time, "Server", "Automatically banned for spreading bad phrases")
			return -1
		end
	end
	for _,t in pairs(badphrase.messages.pbox) do
		if string.find(string.lower(msg), t) then
			penaltybox.penalty(cn, cheater.pbox.time, "Automatically put into the penalty box for spreading bad phrases")
			return -1
		end
	end
	for _,t in pairs(badphrase.messages.mute) do
		if string.find(string.lower(msg), t) then
			return -1
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("text", badphrase.check_message)
server.event_handler("sayteam", badphrase.check_message)
