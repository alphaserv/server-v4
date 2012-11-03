module("edit", package.seeall)

local editmute_type = "spec"

user_obj.editmute = function(self, value)
	value = tonumber(value)
	
	messages.load("edit", "mute", {default_type = "info", default_message = "name<%(1)i>|r|'s| editmute is set to %(2)i."})
		:format(self.cn, value)
		:send()
		
	if value == 1 then
		self.editmute_type = editmute_type
	else
		self.editmute_type = nil
	end
end

user_obj.edit = function(self, package)
	if not self.editmute_type then
		return true
	elseif self.editmute_type == "spec" then
		messages.load("edit", "muted", {default_type = "info", default_message = "name<%(1)i> |have|has| been denyed to edit."})
			:format (self.cn, "spectator")
			:send(self.cn)
		
		self:spec()
		
		server.sleep(500, function()
			self:unspec()
		end)
		
		return false
	elseif self.editmute_type == "ignore" then
		return false
	end	
end

server.event_handler("edit", function(cn, package)
	if not user_from_cn(cn):edit(package) then
		return -1
	end
end)
server.event_handler("sendmap", function(cn)
	messages.load("edit", "sendmap", {default_type = "info", default_message = "name<%(1)s> |have|has| uploaded a map to the server, use green</getmap> to receive it."})
		:format (cn)
		:send()
end)

server.event_handler("getmap", function(cn)
	messages.load("edit", "getmap", {default_type = "info", default_message = "name<%(1)s> |are|is| getting the map."})
		:format(cn)
		:send()
end)

command.command_from_table("editmute", {
	name = "editmute",
	usage = "#editmute <cn> <value>",
	
	list = function(self, player)
		return true, "green<editmute>"
	end,
	
	help = function(self, player)
		return true, "This commands mutes players from editing."
	end,
	
	execute = function(self, player, cn, value)
		if type(cn) == "nil" or type(value) == "nil" then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end

		cn = tonumber(cn)
		value = tonumber(value)
		
		user_from_cn(cn):editmute(value)
		
		return true, true, {cn, value}, { name = "mute_success", default_message = "Successfully set editmute." }
	end,
})

command.command_from_table("savemap", {
	name = "savemap",
	usage = "#savemap <name>",
	
	list = function(self, player)
		return true, "blue<savemap>"
	end,
	
	help = function(self, player)
		return true, "Saves the sent map map onto the server. See also: #loadmap, #sendmapto"
	end,
	
	execute = function(self, player, name)
		if not name then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end

		name = tostring(name)
		name = name:gsub("/", "")
		name = "content/"..name..".ogz"
		server.save_map(name)		
		
		return true, true, {cn, name}, { name = "save_success", default_message = "Successfully save the map." }
	end,
})

command.command_from_table("sendto", {
	name = "sendto",
	usage = "#sendto <cn>",
	
	list = function(self, player)
		return true, "blue<sentdo>"
	end,
	
	help = function(self, player)
		return true, "forces getmap onto a player."
	end,
	
	execute = function(self, player, cn)
		if not cn then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end

		server.send_to(cn)
		
		return true, true, {cn}, { name = "sent_success", default_message = "Successfully save the map." }
	end,
})

command.command_from_table("loadmap", {
	name = "loadmap",
	usage = "#loadmap <name>",
	
	list = function(self, player)
		return true, "blue<loadmap>"
	end,
	
	help = function(self, player)
		return true, "load a map on the server, forces sendmap to all players. See also: #savemap, #sendmapto"
	end,
	
	execute = function(self, player, name)
		if not name then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end

		name = tostring(name)
		name = name:gsub("/", "")
		name = "content/"..name..".ogz"

		server.load_map(name)
		
		for i, cn in pairs(server.players()) do
			server.send_to(cn)
		end
		
		return true, true, {name}, { name = "load_success", default_message = "Successfully loaded the map." }
	end,
})

command.command_from_table("sendmapto", {
	name = "sendmapto",
	usage = "#sendmapto <cn> <name>",
	
	list = function(self, player)
		return true, "blue<sendmapto>"
	end,
	
	help = function(self, player)
		return true, "loads a map from a file and sents it to a player. See also: #savemap, #loadmap"
	end,
	
	execute = function(self, player, cn, name)
		if not cn or not name then
			return false, true, {self.name, self.usage} , { name = "command_usage", default_message = "Usage of orange<#%(1)s>: %(2)s" }
		end

		name = tostring(name)
		name = name:gsub("/", "")
		name = "content/"..name..".ogz"

		server.send_map_to(cn, name)

		return true, true, {cn, name}, { name = "load_success", default_message = "Successfully loaded and sent the map." }
	end,
})
