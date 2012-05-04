
module("messages", package.seeall)

local you_replacing = alpha.settings.new_setting("You_replacing", true, "Replace the name of a player with you")

message_object = class.new(nil, {
	message_string = "",
	message_type = "info",
	use_irc = false,
	
	message_name = "",
	module_name = "",
	
	from_data = function(self, data)
		self.name = data.name
		self.module_name = data.module
		self.message_string = data.message
		self.use_irc = data.use_irc and true
		
		return self
	end,
	
	escape = function(self, data)
		if type(data) == "table" then
			local ret = {}
			for key, str in pairs(data) do
				ret[key] = self:escape(str)
			end
			data = nil
			
			return ret
		end

		data = string.gsub(data, "&", "&00;")
		data = string.gsub(data, "%^", "&01;")
		data = string.gsub(data, "|", "&02;")
		data = string.gsub(data, "%[", "&03;")
		data = string.gsub(data, "%]", "&04;")
		data = string.gsub(data, ";", "&05;")
		data = string.gsub(data, "\f", "&06;")
		data = string.gsub(data, "}", "&07;")
		data = string.gsub(data, "{", "&08;")
		data = string.gsub(data, "\\", "&09;")
		data = string.gsub(data, ">", "&10;")
		data = string.gsub(data, "<", "&11;")
	
		return data
	end,
	
	unescape = function(self, data)
		if type(data) == "table" then
			local ret = {}
			for key, str in pairs(data) do
				ret[key] = self:escape(str)
			end
			data = nil
			
			return ret
		end

		data = string.gsub(data, "%&00;", "&")
		data = string.gsub(data, "%&01;", "^ ")
		data = string.gsub(data, "%&02;", "|")
		data = string.gsub(data, "%&03;", "[")
		data = string.gsub(data, "%&04;", "]")
		data = string.gsub(data, "%&05;", ";")
		data = string.gsub(data, "%&06;", "\\f")
		data = string.gsub(data, "%&07;", "}")
		data = string.gsub(data, "%&08;", "{")
		data = string.gsub(data, "%&09;", "\\")
		data = string.gsub(data, "%&10;", ">")
		data = string.gsub(data, "%&11;", "<")
	
		return data
	end,
		 
	
	format = function(self, ...)
		self.message_string = self.message_string % self:escape(arg)
		
		return self
	end,
	
	prefix = function(self, msg)
		if self.message_type == "info" then
			if true then
				return "blue<[info] >"..msg
			end
		end
		
		return self
	end,
	
	color = function(self, to, is_private)
		local msg = self.message_string
		
		msg = self:prefix(msg)
		
		msg = string.gsub(msg, "red<(.-)>", function (string) return color.red(string) end)
		msg = string.gsub(msg, "white<(.-)>", function (string) return color.white(string) end)
		msg = string.gsub(msg, "blue<(.-)>", function (string) return color.blue(string) end)
		msg = string.gsub(msg, "yellow<(.-)>", function (string) return color.yellow(string) end)
		msg = string.gsub(msg, "magenta<(.-)>", function (string) return color.magenta(string) end)
		msg = string.gsub(msg, "green<(.-)>", function (string) return color.green(string) end)
		msg = string.gsub(msg, "orange<(.-)>", function (string) return color.orange(string) end)
		msg = string.gsub(msg, "grey<(.-)>", function (string) return color.grey(string) end)
		
		msg = string.gsub(msg, "name<(.-)>(.-)|(.-)|(.-)|", function(cn, seperator, you_text, name_text)
			if tonumber(cn) == to and you_replacing:get() then
				return "name<"..cn..">"..seperator..you_text
			else
				return "name<"..cn..">"..seperator..name_text
			end
		end)

		msg = string.gsub(msg, "name<(.-)>", function(cn)
			if tonumber(cn) == to and you_Replacing:get() then
				return "you"
			elseif server.valid_cn(cn) then
				return server.player_displayname(cn)
			else
				return "unkown"
			end
		end)
		
		return self:unescape(msg)
	end,
	
	send = function(self, to, is_private)
	
		if type(to) == "number" then
			to = {to}
		end
		
		if type(to) == "string" then
			error("cannot send a message to a string player")
		end
		
		if to == nil then
			to = players.groups.all()
		end
		
		for _, cn in pairs(to) do
			server.player_msg(cn, self:color(cn, is_private))
		end
		
		if self.use_irc and irc and irc.send then
			irc.send(self.message_string)
		end
		
		return self
	end,
})

local cache = {}
function load(module, name, default)
	if not cache[module.."::"..name] then
		local result = alpha.db:query("SELECT id, name, module, message FROM messages WHERE name = ? AND module = ?;", name, module)
		
		if result:num_rows() < 1 then
			alpha.db:query("INSERT INTO messages (name, module, message) VALUES (?, ?, ?)", name, module, default.default_message)
			
			row = {name = name, module = module, message = default.default_message}
		else
			row = result:fetch()[1]
		end
		
		cache[module.."::"..name] = row
	end
	
	return message_object():from_data(cache[module.."::"..name])
end

server.event_handler("connect", function(cn)
	messages.load("messages", "connect", {default_type = "info", default_message = "green<Welcome> blue<on yet another alphaserver.> green<V4 version>"})
		:send({cn}, true)
end)
