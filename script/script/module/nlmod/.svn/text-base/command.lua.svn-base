local commands = {}
cmd_blacklist = {}

function server.addcommand(name, func)
	if name and func then
		if commands[name] then server.log("overwriting player command '" .. name .. "'") end
		commands[name] = func
	else
		if name then command = "command '" .. name .. "'" else command = "command" end
		server.log_error("can't add " .. command .. ": not enough arguments!")
	end
end

function server.delcommand(name)
	if name then
		if commands[name] then
			commands[name] = nil
			server.log("deleted command '" .. name .. "'")
		else
			server.log("could not delete command '" .. name .. "': no such command!")
			server.log_error("could not delete command '" .. name .. "': no such command!")
		end
	else
		server.log_error("could not delete command: no command name given!")
	end
end

function send_cmd_not_found_msg(cn)
	server.player_msg(cn, cmderr("no such command"))
end

function execute_command(cn, func, cmdname, args)
	if cmd_blacklist[cmdname] then
		messages.error(cn, {cn}, "COMMAND", cmd_blacklist[cmdname])
		return
	end
	-- irc_say(string.format("execute_command(cn=%s, func=%s, args=%s", tostring(cn), tostring(func), tostring(args) ))
	--server.log_error(string.format( "execute_command(cn=%s, func=%s, cmdname=%s, args=%s)", tostring(cn), tostring(func), tostring(cmdname), tostring(args) ))
	local pcallret, success, errmsg = pcall(func, unpack(args))
	if pcallret == false then
		local message = success  -- success value is the error message returned by pcall
		server.log_error(string.format("command failed with error: %s", message))
		if server.access(cn) > errmsg_access or server.access(cn) == errmsg_access then server.player_msg(cn, cmderr("command execution error: " .. message)) else server.player_msg(cn, cmderr("command execution error")) end
	end
	if success == false then
		if server.access(cn) > errmsg_access or server.access(cn) == errmsg_access then server.player_msg(cn, cmderr(errmsg)) else server.player_msg(cn, cmderr("unknown error")) end
	end
end

function checkcommand(cn, text)
	if (not string.match(text, "^#.*")) and (not string.match(text, "^!.*")) then return end
	visible = string.match(text, "^#.*")
	if visible then command = string.match(text, "^#(%S+).*") else command = string.match(text, "^!(%S+).*") end
	if not command then server.player_msg(cn, cmderr("command processing error")); return end
	if commands[command] then
		local args = server.parse_player_command(text)
		args[1] = tonumber(cn)
		--irc_say(string.format("Try to execute command %s", commands[command]))
		execute_command(cn, commands[command], command, args)
	else
		cmd_arguments = server.parse_player_command(text)
		cmd_arguments[1] = tonumber(cn)
		cmd_name = string.gsub(string.gsub(command, "!", ""), "#", "")
		-- server.log_error(string.format("cmd_name: %s", cmd_name))
		server.eval_lua(string.format("if server.playercmd_%s then execute_command(%s, server.playercmd_%s, cmd_name, cmd_arguments) else send_cmd_not_found_msg(%s) end", cmd_name, tostring(cn), cmd_name, tostring(cn)))
	end
	if visible then return -1 else return end
end

server.event_handler("text", checkcommand)
server.event_handler("sayteam", checkcommand)
