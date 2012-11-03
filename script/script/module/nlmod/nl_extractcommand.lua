--[[
	script/module/nl_mod/nl_extractcommand.lua
	Hanack (Andreas Schaeffer)
	Created: 23-Okt-2010
	Last Change: 23-Okt-2010
	License: GPL3

	Funktion:
		Versucht die Textnachrichten der Spieler zu interpretieren. Ein erkannter
		Text oder ein erkanntes Textfragment kann damit eine Aktion auslösen. So
		können registrierte Texte bzw. Fragmente zur Ausführung einer registrierten
		Funktion führen.

	API-Methoden:
		extractcommand.register(text, is_fragment, command_function, check_function, append_msg)
			Registriert einen Text oder ein Textfragment. Wird dieses erkannt,
			wird die angegebenen Funktion ausgeführt. Allerdings nur, wenn eine
			angegebene Funktion check_function true zurückgibt. Die check_function
			kann optional angegeben werden. Ist append_msg true, dann wird der
			Funktion nicht nur die cn, sondern auch die ursprüngliche Nachricht
			übergeben.

	Commands:
		#extractcommand
			Listet alle Texte bzw. Fragmente und die dazugehörigen Funktionen auf
]]


--[[
		API
]]

extractcommand = {}
extractcommand.rules = {}

function extractcommand.register(text, is_fragment, command_function, check_function, append_msg)
	local ds = {}
	ds['text'] = string.lower(text)
	ds['fragment'] = is_fragment
	ds['func'] = command_function
	ds['chkfunc'] = check_function
	ds['appendmsg'] =  append_msg
	table.insert(extractcommand.rules, ds)
end



--[[
		EVENTS
]]

server.event_handler("text", function(cn, msg)
	if string.sub(msg,1,1) ~= "#" and string.sub(msg,1,1) ~= "!" then
		lmsg = string.lower(msg)
		for _,rule in pairs(extractcommand.rules) do
			if rule['text'] == lmsg or ( rule['fragment'] and string.find(lmsg, rule['text']) ) then
				if rule['chkfunc'] ~= nil then
					if rule['chkfunc']() then
						if rule['appendmsg'] then
							rule['func'](cn, msg)
						else
							rule['func'](cn)
						end
					end
				else
					if rule['appendmsg'] then
						rule['func'](cn, msg)
					else
						rule['func'](cn)
					end
				end
			end  
		end
	end
end)



--[[
		COMMANDS
]]

function server.playercmd_extractcommand(cn)
end
