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



function messages.irc(module, message)
	if module == nil or message == nil then return end
	irc_say(string.format("\0034[ %s ]\003  %s", module, message))
end

function messages.log(module, message)
	if module == nil or message == nil then return end
	server.log(string.format("[ %s ]  %s", module, message))
end

function messages.error(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if utils.is_numeric(to) then
		server.player_msg(to, string.format(red("  [ %s ] %s"), module, message))
	else
		for _, cn in pairs(to) do
			server.player_msg(cn, string.format(red("  [ %s ] %s"), module, message))
		end
	end
	messages.irc(module, message)
	messages.log(module, message)
end

function messages.warning(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if messages.get_logmod(module) <= messages.LOGLEVEL_WARNING then
		if utils.is_numeric(to) then
			if tonumber(nl.getPlayer(to, "loglevel")) <= messages.LOGLEVEL_WARNING then
				server.player_msg(to, string.format(orange("  [ %s ] %s"), module, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_WARNING then
					server.player_msg(cn, string.format(orange("  [ %s ] %s"), module, message))
				end
			end
		end
		messages.irc(module, message)
	end
end
messages.warn = messages.warning

function messages.info(from, to, module, message)
	if from == nil or to == nil or module == nil or message == nil then return end
	if messages.get_logmod(module) <= messages.LOGLEVEL_INFO then
		if utils.is_numeric(to) then
			if tonumber(nl.getPlayer(to, "loglevel")) <= messages.LOGLEVEL_INFO then
				server.player_msg(to, string.format(green("  [ %s ] %s"), module, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_INFO then
					server.player_msg(cn, string.format(green("  [ %s ] %s"), module, message))
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
				server.player_msg(to, string.format(blue("  [ %s ] %s"), module, message))
			end
		else
			for _, cn in pairs(to) do
				if tonumber(nl.getPlayer(cn, "loglevel")) <= messages.LOGLEVEL_DEBUG then
					server.player_msg(cn, string.format(blue("  [ %s ] %s"), module, message))
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
--[[
		if utils.is_numeric(level) then
			nl.updatePlayer(cn, "loglevel", level, "set")
			if messages.loglevels[level] ~= nil then
				server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Loglevel was set to: ", messages.loglevels[level]))
			end
		else
			if string.lower(level) == "debug" then
				nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_DEBUG, "set")
				server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was set to: debug "))
			elseif string.lower(level) == "info" then
				nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_INFO, "set")
				server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was set to: info"))
			elseif string.lower(level) == "warning" then
				nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_WARNING, "set")
				server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was set to: warning"))
			elseif string.lower(level) == "error" then
				nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_ERROR, "set")
				server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was set to: error"))
			elseif string.lower(level) == "reset" then
				nl.updatePlayer(cn, "loglevel", messages.LOGLEVEL_INFO, "set")
				server.player_msg(cn, string.format(blue("  [ %s ] %s"), "MESSAGES", "Loglevel was reset (info)"))
			else
				messages.error("MESSAGES", "Es sind folgende Werte erlaubt: 1, 2, 3, 4 oder debug, info, warning, error")
			end
		end
	else
		server.player_msg(cn, string.format(blue("  [ %s ] %s %s"), "MESSAGES", "Your current log level is ", nl.getPlayer(cn, "loglevel")))
	end
	]]
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
				messages.info(cn, {cn}, "MESSAGES", string.format("Loglevel for module %s is %s", module, messages.get_loglevel_string(messages.get_logmod(module))))
			else
				-- set
				messages.set_logmod(module, messages.get_loglevel_num(level))
				messages.info(cn, {cn}, "MESSAGES", string.format("Loglevel for module %s was set to %s", module, messages.get_loglevel_string(messages.get_logmod(module))))
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

