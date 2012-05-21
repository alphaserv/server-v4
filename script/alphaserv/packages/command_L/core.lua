module("command", package.seeall)

local enabled_commands = alpha.settings.new_setting("commands_enabled", {"help", "enable_command", "disable_command"}, "The commands to enable.")

command_obj = class.new(nil, {
	name = "demo",
	
	list = function(self, player)
		return true, "red<"..name..">"
	end,
	
	help = function(self, player)
		return true, name..": A command wich is not implemented."
	end,
	
	execute = function(self, player, ...)
		return false, true, {name, "Command not implemented"} , { name = "cmd_fail", default_message = "red<Could not execute command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	end,
	
	enable = function(self) end,
	disable = function(self) end,
})

events = { on_text = nil }

local loaded_commands = {}
local commands = {}

function add_command(name, class)
	loaded_commands[name] = class
end

function command_from_table(name, table)
	return add_command(name, class.new(command_obj, table))
end

function command_from_file(name, filename)
	command_from_table(name, dofile(filename))
end

function enable_command(name)
	if commands[name] then
		return false, true, {name, "command already loaded"} , { name = "enable_fail", default_message = "red<Could not enable command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	elseif not loaded_commands[name] then
		return false, true, {name, "could not find command"} , { name = "enable_fail", default_message = "red<Could not enable command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	else
		commands[name] = loaded_commands[name]()
		local ret = pack(commands[name]:enable())
		
		return true, unpack(ret)
	end
end

function disable_command(name)
	if not commands[name] then
		return false, true, {name, "command not loaded"} , { name = "disable_fail", default_message = "red<Could not disable command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	elseif not loaded_commands[name] then
		return false, true, {name, "could not find command"} , { name = "disable_fail", default_message = "red<Could not enable command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	else
		local ret = pack(commands[name]:disable())
		commands[name] = nil
		
		return true, unpack(ret)
	end
end

function get_command(name)
	return commands[name]
end

function execute_command(player, name, ...)

	local command = get_command(name)
	
	if not command then
		if loaded_commands[name] then
		return false, true, {name, "command not loaded"} , { name = "cmd_fail", default_message = "red<Could not execute command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
		end
		return false, true, {name, "command not found"}, { name = "cmd_fail", default_message = "red<Could not execute command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	end
	
	if acl and not player:has_permission("command:execute:"..name) then
		return false, true, {name, "access denied"} , { name = "cmd_fail", default_message = "red<Could not execute command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
	end
	
	return command:execute(player, ...)
end

function is_command(string)

	if string[1] == "#" then
		return true, string:sub(2), "#"
	else
		return false
	end
end

function exec_from_string(player, text)
	local ret, newtext, char = is_command(text)
	
	if not ret then
		--ignore
		return -1
	end
	
	local words = newtext:split(" ")
	
	local command_name = words[1]
	
	table.remove(words, 1) --remove command name
	
	local res
	
	local success, error_ = native_pcall(function()
		res = pack(execute_command(player, command_name, unpack(words)))
	end)
	
	if not success then
		return false, {"error while executing command: ", error_}
	end

	return unpack(res)
end

events.on_text = server.event_handler("text", function(cn, text)
	local user = user_from_cn(cn)

	local command_name = text:gsub("^[^ ](.*)", "")

	local result = pack(exec_from_string(user, text))

	if result[1] == -1 then
		return
	elseif result[1] == false then
		if result[2] == true then --nextgen messages
			messages.load("command", result[4].name, result[4])
				:format(unpack(result[3]))
				:send(cn, true)
		else
			local message = messages.load("command", command_name..":failed", { default_message = "red<%(1)s:> %(2)s" })
			
			if type(result[2]) ~= "table" then
				result[2] = { result[2] }
			end
			
			for i, msg in pairs(result[2]) do
				message:unescaped_format(command_name, msg)
				message:send(cn, true)
			end
		end
	elseif result[1] == true then
		if result[2] == true then --nextgen messages
			messages.load("command", result[4].name, result[4])
				:format(unpack(result[3]))
				:send(cn, true)
		else
			local message = messages.load("command", command_name, { default_message = "green<%(1)s:> %(2)s" })

			if type(result[2]) ~= "table" then
				result[2] = { result[2] }
			end

			for i, msg in pairs(result[2]) do
				if msg ~= "" then
					message:unescaped_format(command_name, msg)
					message:send({cn}, true)
				end
			end
		end
	end
	
	return -1
end)

command_from_table("help", {
	name = "help",
	
	list = function(self, player)
		return false
	end,
	
	help = function(self, player)
		return true, true, {self.name, "Display infomational messages about commands"}, { name = "help_info", default_message = "About green<#%(1)s:> %(2)s" }
	end,
	
	execute = function(self, player, command)
		if not command then
			local list = "Available commands:\n"
		
			local first = true
			for i, command in pairs(commands) do
				if player:has_permission("command:list:"..command.name) then
					local use, string = command:list()
			
					if use then
						if not first then
							list = list ..", "
						else
							first = false
						end
				
						list = list .. string
					end
				end
			end
		
			return true, list:split("\n")
		else
			if player:has_permission("command:help:"..command) then
				local cmd = get_command(command)
			
				if not cmd then
					return false, true, {name, "command not found"} , { name = "help_fail", default_message = "red<Could not print help text for command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
				end
			
				return cmd:help(player)
			else
				return false, true, {name, "access denied"} , { name = "help_fail", default_message = "red<Could not print help text for command> orange<#%(1)s>red<:> orange<%(2)s>!!!" }
			end
		end
	end,
})

command_from_table("enable_command", {
	name = "enable_command",
	usage = "usage: #enable_command <command>",
	
	list = function(self, player)
		return true, "orange<enable_command>"
	end,
	
	help = function(self, player)
		return true, "This commands enables another command so it can be used"
	end,
	
	execute = function(self, player, command)
		if not command then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end
		
		local res = pack(enable_command(command))
		
		if not res[1] then
			table.remove(res, 1)
			return unpack(res)
		end
		
		res = res[2] or {}
		
		for i, row in pairs(res) do
			res[i] = tostring(row)
		end
		
		return true, {"Command green<enabled>, result: ", unpack(res)}
	end,
})

command_from_table("disable_command", {
	name = "disable_command",
	usage = "usage: #disable_command <command>",
	
	list = function(self, player)
		return true, "orange<disable_command>"
	end,
	
	help = function(self, player)
		return true, "This commands disables another command so it can't be used anymore."
	end,
	
	execute = function(self, player, command)
		if not command then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end
		
		local res = pack(disable_command(command))
		
		if not res[1] then
			table.remove(res, 1)
			return unpack(res)
		end
		
		res = res[2] or {}
		
		for i, row in pairs(res) do
			res[i] = tostring(row)
		end
		
		return true, {"Command orange<disabled>, result: ", unpack(res)}
	end,
})


server.event_handler("pre_started", function()
	for i, cmd in pairs(enabled_commands:get()) do
		enable_command(cmd)
	end
end)
