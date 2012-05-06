
cmd = {}
cmd.say_list = {}
cmd.list = {}
function cmd.error(cn, cmd, message, errormsg)
	local message_template = ''
	if not cmd then
		message_template = config.get('commands:main:failed')
		if message then message_template = message end
         	messages.warning(-1, {cn}, message_template, true)
	else
		message_template = config.get('commands:main:failed2')
--		if (not errormsg) or priv.has(cn, config.get("priv:show_error")) then
			--this is only displayed if not an fatal error message (with linenumber) or
			--if has enough premisions to see fatal errors
			--not working
			if message then message_template = message end
--		end
         	messages.warning("command", {cn}, string.format(message_template, cmd, cn), true)
	end
	log.write(string.format("Command (#%s) failed: %s , actor: %s", (cmd or "none"), (message or "none"), server.player_displayname(cn)),"error")
end

function exec_command (cn, text)
	local chars = ""
	string.gsub((config.get("command:main:prefixes") or "<#><@><!>"), "<(.-)>", function (char) chars = chars.. char end)
	local regex = string.format((config.get("command:main:regex") or "^^[%s]"), chars)
	local arguments = server.parse_player_command(text)
	if string.match(text, regex) then
		arguments[1] = string.sub(arguments[1], 2)
	else
		return
	end
	local command_name = arguments[1]
	local command = cmd.list[command_name]
	if not command then
		cmd.error(cn, command_name, config.get("command:main:not_found"))
		return -1
	end
	arguments[1] = cn
	if not (command.enabled == true) or not command._function then
		cmd.error(cn, command_name, config.get("command:main:disabled"))
		return -1
	end

	if not priv.has(cn, command.min_priv ) then
		cmd.error(cn, command_name, config.get("command:main:priv_error"))
		return -1
	end
	local pcallret, success, errmsg = pcall(command._function, unpack(arguments))

	if pcallret == false then
		--an error has occurd
		local message = success  -- success value is the error message returned by pcall
		cmd.error(cn, command_name, message, true)
	end
	if success == false then
		cmd.error(cn, command_name, errmsg)
	end
	return -1
end


function cmd.create(name)

    local command = {
        name = name,
        enabled = true,
        min_priv = priv.DEFAULT, 
        _function = nil,
        control = {}
    }
    
    cmd.list[name] = command
    
    return command
end

function cmd.parse_list(commandlist)
	if not commandlist then commandlist = "" end
	return string.split(commandlist, "[^ \r\n\t]+")
end

function cmd.set(cmdname, fields)
	local command = cmd.list[cmdname] or cmd.create(cmdname)
	for field_name, field_value in pairs(fields) do
		cmd.list[cmdname][field_name] = field_value
		debug.write(-2, "setting "..tostring(field_name).." with value: "..tostring(field_value).." on command "..tostring(cmdname).." was "..tostring(command[field_name]))
	end
end

function cmd.foreach(commandlist, fun)
    for _, cmdname in ipairs(cmd.parse_list(commandlist)) do
        local command = cmd.list[cmdname] or cmd.create(cmdname)
        fun(command)
    end
end

function cmd.enable(commandlist)
    
    cmd.set(commandlist, {enabled = true})
    
    cmd.foreach(commandlist, function(command)
        if command.control.init then command.control.init(command) end
    end)
end

function cmd.disable(commandlist)
    
    cmd.set(commandlist, {enabled = false})
    
    cmd.foreach(commandlist, function(command)
        if command.control.unload then
		command.control.unload(command)
		collectgarbage()
	end
    end)
end



function cmd.set_priv(command, privi)

	local already_set = (cmd.list[command].min_priv == tonumber(privi))
	if already_set then
		debug.write(-1, "already set priv "..privi.." on command "..tostring(command.name))
		return
	end    
	debug.write(-2, "setting priv "..privi.." on command "..tostring(command.name))
	cmd.set(command, {min_priv = tonumber(privi)})
end

function cmd.new_table(name)
    
    local command = cmd.list[name] or cmd.create(name)
    
    if command._function then
        server.log_error(string.format("Overwriting player command '%s'", name))
    end
    
    return command
end

function cmd.filename(name)
    return "./script/command/" .. name .. ".lua"
end
function cmd.script(name, filename, privi)
    
    if not filename then
        filename = cmd.filename(name)
    end
	if not privi then privi = priv.DEFAULT end
    
    local command = cmd.new_table(name)
    
    cmd.set_priv(name, privi)
    
    local script,err = loadfile(filename)
    if not script then error(err) end
    
    command_info = command
    
    command._function = script()
    
    if type(command._function) == "table" then
        
        command.control = command._function
        command._function = command.control.run
        
        if not command.control.unload or not command.control.init then
            error(string.format("Player command script '%s' is missing a init or unload function.", filename))
        end

		if command.enabled == true then
			command.control.init()
		end
    end
    
    command_info = nil
end
function cmd.alias(new, old)
	cmd.list[new] = cmd.list[old]
end

function cmd.command_function(name, func, privi)

	local command = cmd.new_table(name)
	if not privi then privi = priv.DEFAULT end
	cmd.set_priv(name, privi)
	command._function = func
end

cmd.command_function("enable_command", function (cn, name) cmd.enable(name); messages.info("playercommand", {cn}, string.format("you enabled %s", name), true) end,  priv.OWNER)
cmd.command_function("disable_command", function (cn, name) cmd.disable(name); messages.info("playercommand", {cn}, string.format("you disabled %s", name), true) end,  priv.OWNER)



--events
server.event_handler("text", exec_command)

--[[
function cmd.exec_playercmd(cn, name)
    if not alpha.playercmd.enabled[name] then 
        --not enabled
        messages.warning (cn, {cn}, string.format(config.get("messages:not_enabled"),"command"), true)
        return -1
    end
    if not ( cmd.say_list[name].priv <= server.player_priv_code(cn) ) then
        --premission error
        messages.warning (cn, {cn}, string.format(config.get("messages:priv_error"), "to execute the command"), true)
        return -2
    end
    --log usage of the function
    debug.write(0, cn.."("..server.player_name(cn).."::"..server.player_ip(cn)..")used function"..name.."; it returned: '"..cmd.say_list[name].func(cn).."'")
end

function cmd.say(name, func, priv)
    cmd.say_list[name] = {}
    cmd.say_list[name].priv = priv or server.priv_NORMAL or 0
    cmd.say_list[name].func = func
end

cmd.say("help", function(cn)
    local priv_code = server.player_priv_code(cn)
    local output = ""
    local moutput = ""
    local aoutput = ""
    
    local normal = {}
    local master = {}
    local admin = {}
    
    for name, command in pairs(player_commands) do
        if command.enabled then
            if command.require_admin then
                if priv_code == server.PRIV_ADMIN then
                    admin[#admin + 1] = name
                end
            elseif command.require_master then
                if priv_code >= server.PRIV_MASTER then
                    master[#master + 1] = name
                end
            else
                normal[#normal + 1] = name
            end
        end
    end
    
    for _, name in ipairs(normal) do
        if name ~= "help" then
		local prefix = ""
            if #output > 0 then prefix = ", " end
		
            output = string.format(config.get("messages:help_normal"), output, prefix, name)
        end
    end
    output = config.get("messages:help_prefix") .. output
    messages.info(cn, {cn}, output, true)
    
    if priv_code >= server.PRIV_MASTER then
        for _, name in ipairs(master) do
		local prefix = ""
            if #moutput > 0 then prefix = ", " end
		moutput = string.format(config.get("messages:help_master"), moutput, prefix, name)

        end
	messages.info(cn, {cn}, moutput, true)
    end
    
    if priv_code == server.PRIV_ADMIN then
        for _, name in ipairs(admin) do
		local prefix = ""
            if #aoutput > 0 then prefix = ", " end
		aoutput = string.format(config.get("messages:help_admin"), aoutput, prefix, name)
        end
	messages.info(cn, {cn}, aoutput, true)
    end
    messages.info(cn, {cn}, config.get("messages:help_command_description"), true )

end)
]]
cmd.command_function("help", function(cn)

	local commands = {}
	local output = config.get("messages:help_prefix")
	for name, command in pairs(cmd.list) do
		if command.enabled then
			if priv.has(cn,command.min_priv) then
				commands[#commands + 1] = name
			end
		end
	end
	local i = 0
	for _, name in ipairs(commands) do
--		if name ~= "help" then
			local prefix = ""
			i = i +1
			if output ~= config.get("messages:help_prefix") then prefix = ", " end
			output = string.format(config.get("messages:help_normal"), output, prefix, name)
			if i == 10 then
				i = 0
				messages.info("help", {cn}, output, true)
				output = ""
			end
--		end
	end
	messages.info("help", {cn}, output, true)				
end, 0)
--[[
server.event_handler("text", function(cn, text)
    if cmd.say_list[text] ~= nil then
        cmd.exec_playercmd(cn, text)
        return -1
    end
end)

]]
