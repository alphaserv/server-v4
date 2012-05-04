module("command", package.seeall)

command_obj = class.new(nil, {
	name = "demo",
	
	list = function(self, player)
		--if player:can_do(self.name..":list") then
			return true, "red<"..name..">"
		--else
		--	return false
		--end
	end,
	
	help = function(self, player)
		--if player:can_do(self.name..":help") then
			return true, name..": A command wich is not implemented."
		--else
		--	return false
		--end		
	end,
	
	execute = function(self, player, ...)
		return false, {"command not implemented :/"}		
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
		return false, {"command already loaded"}
	elseif not loaded_commands[name] then
		return false, {"could not find command"}
	else
		commands[name] = loaded_commands[name]()
		local ret = pack(commands[name]:enable())
		
		return unpack(ret)
	end
end

function disable_command(name)
	if not commands[name] then
		return false, {"command not loaded"}
	elseif not loaded_commands[name] then
		return false, {"could not find command"}
	else
		local ret = pack(commands[name]:disable())
		commands[name] = nil
		
		return unpack(ret)
	end
end

function get_command(name)
	return commands[name]
end

function execute_command(player, name, ...)

	local command = get_command(name)
	
	if not command then
		if loaded_commands[name] then
			return false, {"command not loaded"}
		end
		return false, { "could not find command!" }
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
	local ret, newtext = is_command(text)
	
	if not ret then
		--ignore
		return -1
	end
	
	local words = newtext:split(" ")
	
	local command_name = words[1]
	
	table.remove(words, 1) --remove command name
	
	server.player_msg(player.cn, "command: "..table_to_string(words))
	
	return execute_command(player, command_name, unpack(words))
end

events.on_text = server.event_handler("text", function(cn, text)
	local result = pack(exec_from_string(user_from_cn(cn), text))
	
	if result[1] == -1 then
		return
	elseif result[1] == false then
		server.player_msg(cn, "result: "..table.concat(result[2], " "))
	elseif result[1] == true then
		server.player_msg(cn, "result: "..table.concat(result[2], " "))
	end
	
	return -1
end)

command_from_table("help", {
	name = "help",
	
	list = function(self, player)
		return false
	end,
	
	help = function(self, player)
		return false
	end,
	
	execute = function(self, player, command)
		if not command then
			local list = ""
		
			local first = true
			for i, command in pairs(commands) do
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
		
			return true, list:split("\n")
		else
			local cmd = get_command(command)
			
			if not cmd then
				return false, { "command not found" }
			end
			
			return cmd:help()
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
			return false, {self.usage}
		end
		
		local res = enable_command(command) or {}
		
		for i, row in pairs(res) do
			res[i] = tostring(row)
		end
		
		return true, {"Command green<enabled>", "result: ", unpack(res)}
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
			return false, {self.usage}
		end
		
		local res = disable_command(command) or {}
		
		for i, row in pairs(res) do
			res[i] = tostring(row)
		end
		
		return true, {"Command green<disabled>", "result: ", unpack(res)}
	end,
})

enable_command("help")
enable_command("enable_command")
