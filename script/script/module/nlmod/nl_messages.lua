--[[
	script/module/nl_mod/nl_messages.lua
	Hanack (Andreas Schaeffer)
	Created: 17-Okt-2010
	Last Change: 23-Okt-2010
	License: GPL3

	Funktion:
		Stellt Funktionen zur Verfügung, um Spielern Nachrichten zu schicken. Es
		können dabei mehrere Spieler adressiert werden. Der Spieler kann selbst
		bestimmen, welche Nachrichten er auf einem bestimmten Niveau erhalten
		möchte. So kann er zum Beispiel einstellen, dass er nur Fehlermeldungen
		erhalten möchte. Oder er kann sich sogar die Debug-Ausgaben schicken
		lassen.
		Warnungen werden automatisch zusätzlich im IRC ausgegeben. Fehlermeldungen
		werden im IRC und im Server-Log ausgegeben.

	API-Methoden:
		messages.error(from, to, module, message)
			Schickt eine Fehlermeldung an ein oder mehrere Spieler
			from: source cn
			to: list of target cns
			module: Das Modul (meist das Modul) wird vorangestellt
			message: Die Nachricht an sich
		messages.warning(from, to, module, message)
			Schickt eine Warnung an ein oder mehrere Spieler, wie messages.error
		messages.info(from, to, module, message)
			Schickt eine Ist-Gut-Zu-Wissen-Nachricht an ein oder mehrere Spieler, wie messages.error
		messages.debug(from, to, module, message)
			Schickt eine Debug-Nachricht an ein oder mehrere Spieler, wie messages.error

	Commands:
		#loglevel
			Der Spieler kann sein LogLevel abrufen
		#loglevel <LEVEL>
			Der Spieler kann sein LogLevel einstellen


]]



--[[
		API
]]

messages = {}
messages.loglevels = { "debug", "info", "warning", "error" }
messages.logmod = {}
messages.LOGLEVEL_DEBUG = 1
messages.LOGLEVEL_INFO = 2
messages.LOGLEVEL_WARNING = 3
messages.LOGLEVEL_ERROR = 4
messages.LOGLEVEL_DEFAULT = messages.LOGLEVEL_INFO
messages.repeated_millis = 1000
messages.repeated = {}
messages.combined_millis = 1000
messages.combined = {}
messages.muted_ips = {}

function messages.get_loglevel_num(level)
	if not level then return messages.LOGLEVEL_DEFAULT end
	if utils.is_numeric(level) then
		if level > 0 and level < 5 then
			return level
		else
			return messages.LOGLEVEL_DEFAULT
		end
	else
		if string.lower(level) == messages.loglevels[messages.LOGLEVEL_DEBUG] then
			return messages.LOGLEVEL_DEBUG
		elseif string.lower(level) == messages.loglevels[messages.LOGLEVEL_INFO] then
			return messages.LOGLEVEL_INFO
		elseif string.lower(level) == messages.loglevels[messages.LOGLEVEL_WARNING] then
			return messages.LOGLEVEL_WARNING
		elseif string.lower(level) == messages.loglevels[messages.LOGLEVEL_ERROR] then
			return messages.LOGLEVEL_ERROR
		else
			return messages.LOGLEVEL_DEFAULT
		end
	end
end

function messages.get_loglevel_string(level)
	if utils.is_numeric(level) then
		return messages.loglevels[level]
	else
		return messages.loglevels[messages.LOGLEVEL_DEFAULT]
	end
end

function messages.get_logmod(module)
	if messages.logmod[module] ~= nil then
		return tonumber(messages.logmod[module])
	else
		return tonumber(messages.LOGLEVEL_DEFAULT)
	end
end

function messages.set_logmod(module, level)
	messages.logmod[module] = level
	db.insert_or_update('nl_logmod', {module=module,level=level}, string.format("module='%s'",module))
end

function messages.load()
	messages.logmod = {}
	local result = db.select('nl_logmod', { 'module', 'level' }, 'level > 0')
	for i,row in pairs(result) do
		messages.logmod[row['module']] = tonumber(row['level'])
	end
end



-- "Der Spieler white(%s) hat die Flagge returned. Commands are: orange(#mapsucks)
function messages.parse_console(from, input)
	local output = input
	output = string.gsub(output,"name<(.-)>",function(cn)
		if cn == from then
			return red("You")
		else
			return string.format(blue("%s (%i)"), server.player_displayname(cn), cn)
		end
	end)
	output = string.gsub(output,"white<(.-)>",function(word) return white(word) end)
	output = string.gsub(output,"red<(.-)>",function(word) return red(word) end)
	output = string.gsub(output,"orange<(.-)>",function(word) return orange(word) end)
	output = string.gsub(output,"green<(.-)>",function(word) return green(word) end)
	output = string.gsub(output,"yellow<(.-)>",function(word) return yellow(word) end)
	output = string.gsub(output,"magenta<(.-)>",function(word) return magenta(word) end)
	output = string.gsub(output,"blue<(.-)>",function(word) return blue(word) end)
	return output
end

function messages.parse_irc(input)
	local output = input
	output = string.gsub(output,"white<(.-)>",function(word) return string.format("\0030%s\003", word) end)
	output = string.gsub(output,"black<(.-)>",function(word) return string.format("\0031%s\003", word) end)
	output = string.gsub(output,"green<(.-)>",function(word) return string.format("\0033%s\003", word) end)
	output = string.gsub(output,"red<(.-)>",function(word) return string.format("\0034%s\003", word) end)
	output = string.gsub(output,"magenta<(.-)>",function(word) return string.format("\0036%s\003", word) end)
	output = string.gsub(output,"orange<(.-)>",function(word) return string.format("\0037%s\003", word) end)
	output = string.gsub(output,"yellow<(.-)>",function(word) return string.format("\0038%s\003", word) end)
	output = string.gsub(output,"blue<(.-)>",function(word) return string.format("\00312%s\003", word) end)
	--output = string.gsub(output,"navy<(.-)>",function(word) return string.format("\0032%s\003", word) end)
	--output = string.gsub(output,"brown<(.-)>",function(word) return string.format("\0035%s\003", word) end)
	--output = string.gsub(output,"bright_green<(.-)>",function(word) return string.format("\0039%s\003", word) end)
	--output = string.gsub(output,"light_blue<(.-)>",function(word) return string.format("\00310%s\003", word) end)
	--output = string.gsub(output,"neon<(.-)>",function(word) return string.format("\00311%s\003", word) end)
	--output = string.gsub(output,"pink<(.-)>",function(word) return string.format("\00313%s\003", word) end)
	--output = string.gsub(output,"grey<(.-)>",function(word) return string.format("\00314%s\003", word) end)
	--output = string.gsub(output,"light_grey<(.-)>",function(word) return string.format("\00315%s\003", word) end)
	return output
end

function messages.parse_log(input)
	local output = input;
	output = string.gsub(output,"white<(.-)>",function(word) return word end)
	output = string.gsub(output,"green<(.-)>",function(word) return word end)
	output = string.gsub(output,"red<(.-)>",function(word) return word end)
	output = string.gsub(output,"magenta<(.-)>",function(word) return word end)
	output = string.gsub(output,"orange<(.-)>",function(word) return word end)
	output = string.gsub(output,"yellow<(.-)>",function(word) return word end)
	output = string.gsub(output,"blue<(.-)>",function(word) return word end)
	return output
end



--function messages.console(to, module, message, color)
--	server.player_msg(tonumber(to), messages.parse_console(color.."(  [ "..module.." ] ) ")..messages.parse_console(message))
--end

function messages.send_combined()
	local combined_string = ""
	for _, message in ipairs(messages.combined) do
		combined_string = string.format("%s\n%s", combined_string, message)
	end
	messages.combined = {}
	if irc_say ~= nil then
		server.sleep(100, function()
			irc_say(combined_string)
		end)
	end
end

function messages.is_repeated(message)
	found = 0
	for _, a_message in ipairs(messages.repeated) do
		if message == a_message then
			found = 1
			break
		end
	end
	if found == 1 then
		return true
	else
		table.insert(messages.repeated, message)
		return false
	end
end
 
function messages.irc(module, message, color)
	if messages.is_repeated(message) then return end
	if module == nil or message == nil then return end
	if color == nil then color = "black" end
	table.insert(messages.combined, messages.parse_irc(color.."<["..module.."] >")..messages.parse_irc(message))
	-- irc_say(messages.parse_irc(color.."<["..module.."] >")..messages.parse_irc(message))
end

function messages.log(module, message)
	if module == nil or message == nil then return end
	-- server.log(string.format("[ %s ]  %s", module, message))
	server.log(string.format("[ %s ]  %s", module, messages.parse_log(message)))
end



function messages.error(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if utils.is_numeric(to) then
		-- messages.console(to, module, message, "red")
		-- server.player_msg(to, string.format(red("  [ %s ] %s"), module, message))
		server.player_msg(tonumber(to), red("  [ "..module.." ] ")..messages.parse_console(from, message))
	else
		for _, cn in pairs(to) do
			-- messages.console(to, module, message, "red")
			-- server.player_msg(cn, string.format(red("  [ %s ] %s"), module, message))
			server.player_msg(tonumber(cn), red("  [ "..module.." ] ")..messages.parse_console(from, message))
		end
	end
	messages.irc(module, message, "red")
	messages.log(module, message)
end

function messages.warning(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if messages.get_logmod(module) <= messages.LOGLEVEL_WARNING then
		if utils.is_numeric(to) then
			if tonumber(nl.getPlayer(to, "loglevel")) <= messages.LOGLEVEL_WARNING then
				-- messages.console(to, module, message, "orange")
				-- server.player_msg(to, string.format(orange("  [ %s ] %s"), module, message))
				server.player_msg(tonumber(to), orange("  [ "..module.." ] ")..messages.parse_console(from, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_WARNING then
					-- messages.console(to, module, message, "orange")
					-- server.player_msg(cn, string.format(orange("  [ %s ] %s"), module, message))
					server.player_msg(tonumber(cn), orange("  [ "..module.." ] ")..messages.parse_console(from, message))
				end
			end
		end
		messages.irc(module, message, "orange")
	end
end
messages.warn = messages.warning

function messages.info(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if messages.get_logmod(module) <= messages.LOGLEVEL_INFO then
		if utils.is_numeric(to) then
			if tonumber(nl.getPlayer(to, "loglevel")) <= messages.LOGLEVEL_INFO then
				-- messages.console(to, module, message, "green")
				-- server.player_msg(to, string.format(green("  [ %s ] %s"), module, message))
				server.player_msg(tonumber(to), green("  [ "..module.." ] ")..messages.parse_console(from, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_INFO then
					-- messages.console(to, module, message, "green")
					-- server.player_msg(cn, string.format(green("  [ %s ] %s"), module, message))
					server.player_msg(tonumber(cn), green("  [ "..module.." ] ")..messages.parse_console(from, message))
				end
			end
		end
	end
end

function messages.debug(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if messages.get_logmod(module) <= messages.LOGLEVEL_DEBUG then
		if utils.is_numeric(to) then
			if tonumber(nl.getPlayer(to, "loglevel")) <= messages.LOGLEVEL_DEBUG then
				-- messages.console(to, module, message, "blue")
				-- server.player_msg(to, string.format(blue("  [ %s ] %s"), module, message))
				server.player_msg(tonumber(to), blue("  [ "..module.." ] ")..messages.parse_console(from, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_DEBUG then
					-- messages.console(to, module, message, "blue")
					-- server.player_msg(cn, string.format(blue("  [ %s ] %s"), module, message))
					server.player_msg(tonumber(cn), blue("  [ "..module.." ] ")..messages.parse_console(from, message))
				end
			end
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_loglevel(cn, level)
	if level ~= nil then
		if string.lower(level) == "reset" then
			nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_DEFAULT, "set")
			server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was resetted"))
		else
			local ln = messages.get_loglevel_num(level)
			local ls = messages.get_loglevel_string(ln)
			nl.updatePlayer(cn, "loglevel", ln, "set")
			server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Loglevel was set to: ", ls))
		end
	else
		server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Your current log level is ", messages.get_loglevel_string(nl.getPlayer(cn, "loglevel"))))
	end
end

function server.playercmd_ld(cn)
	nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_DEBUG, "set")
	server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Loglevel was set to:", messages.get_loglevel_string(messages.LOGLEVEL_DEBUG)))
end

function server.playercmd_li(cn)
	nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_INFO, "set")
	server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Loglevel was set to:", messages.get_loglevel_string(messages.LOGLEVEL_INFO)))
end


function server.playercmd_logmod(cn, module, level)
	if not hasaccess(cn, admin_access) then return end
	if not module then
		-- list
		for m,l in pairs(messages.logmod) do
			messages.info(cn, {cn}, "MESSAGES", string.format("%s: %s", m, messages.get_loglevel_string(l)))
		end
	else
		if module == "reload" then
			messages.load()
			for m,l in pairs(messages.logmod) do
				messages.info(cn, {cn}, "MESSAGES", string.format("%s: %s", m, messages.get_loglevel_string(l)))
			end
		else
			if not level then
				-- get
				messages.info(cn, {cn}, "MESSAGES", string.format("Loglevel for module %s is red<%s>", module, messages.get_loglevel_string(messages.get_logmod(module))))
			else
				-- set
				messages.set_logmod(module, messages.get_loglevel_num(level))
				messages.info(cn, {cn}, "MESSAGES", string.format("Loglevel for module %s was set to red<%s>", module, messages.get_loglevel_string(messages.get_logmod(module))))
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("started", function()
	server.sleep(1000, function()
		messages.load()
	end)
end)


server.event_handler("text", function(cn, msg)
    -- Hide player commands
    if string.match(msg, "^#.*") or string.match(msg, "^!.*") then
        return
    end
    local mute_tag = ""
    if server.is_muted(cn) then mute_tag = "(muted)" end
    messages.irc("CHAT", string.format("%s (%i)%s: green<%s>", server.player_name(cn), cn, mute_tag, msg), "green")
    -- irc_say(string.format("\0033CHAT\003    \00312%s(%i)\003%s  ~>  \0033%s\003\n",server.player_name(cn),cn,mute_tag,msg))
end)

server.event_handler("sayteam", function(cn, msg)
    messages.irc("TEAMCHAT", string.format("%s (%i): blue<%s>", server.player_name(cn), cn, msg), "blue")
    -- irc_say(string.format("\0033TEAMCHAT\003    \00312%s(%i)\003(team): %s\n",server.player_name(cn),cn,msg))
end)

server.event_handler("disconnect", function(cn)
	if server.is_muted(cn) then
		table.insert(messages.muted_ips, server.player_ip(cn))
	end
end)

server.event_handler("reconnect", function(cn)
	for i,ip in ipairs(messages.muted_ips) do
		if server.player_ip(cn) == ip then
			messages.debug(cn, players.admins(), "MUTE", string.format("Detected that %s (%i) was muted before reconnect!", server.player_displayname(cn), cn))
			server.mute(cn)
			server.sleep(10000, function()
				messages.debug(cn, players.admins(), "MUTE", string.format("Muted %s (%i) after 10 seconds!", server.player_displayname(cn), cn))
				server.mute(cn)
			end)
		end
	end
end)

server.interval(messages.repeated_millis, function()
	messages.repeated = {}
end)

server.interval(messages.combined_millis, function()
	messages.send_combined()
end)
