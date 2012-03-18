if false then
function alpha.messages.escape(data)
--[[
	& => &00;
	^ => &01;
	| => &02;
	[ => &03;
	] => &04;
	; => &05;
	\f => &06;
	} => &07;
	{ => &08;
	\ => &09;
	> => &10;
	< => &11;

]]
	data = string.gsub(data, "&", "&00;")
	data = string.gsub(data, "^", "&01;")
	data = string.gsub(data, "|", "&02;")
	data = string.gsub(data, "[", "&03;")
	data = string.gsub(data, "]", "&04;")
	data = string.gsub(data, ";", "&05;")
	data = string.gsub(data, "\f", "&06;")
	data = string.gsub(data, "}", "&07;")
	data = string.gsub(data, "{", "&08;")
	data = string.gsub(data, "\\", "&09;")
	data = string.gsub(data, ">", "&10;")
	data = string.gsub(data, "<", "&11;")
	
	return data
end

function alpha.messages.unescape(data)
	--reverse escape
	data = string.gsub(data, "&00;", "&")
	data = string.gsub(data, "&01;", "^")
	data = string.gsub(data, "&02;", "|")
	data = string.gsub(data, "&03;", "[")
	data = string.gsub(data, "&04;", "]")
	data = string.gsub(data, "&05;", ";")
	data = string.gsub(data, "&06;", "\\f")
	data = string.gsub(data, "&07;", "}")
	data = string.gsub(data, "&08;", "{")
	data = string.gsub(data, "&09;", "\\")
	data = string.gsub(data, "&10;", ">")
	data = string.gsub(data, "&11;", "<")
	
	return data
end

function alpha.messages.send(msg, to)
	--function to color strings and get the name of players from cn
	
	to = tonumber(to)
	
	msg = string.gsub(msg, "{{(.-)}}", function(string) return server[string] end)
	msg = string.gsub(msg, "[[(.-)]]", function(string) return alpha.settings:get(string) end)
	
	msg = string.gsub(msg, "name<(.-)>(.-)|(.-)|(.-)|", function(cn, seperator, you_text, name_text)
		if tonumber(cn) == to and alpha.settings:get("you_replacing") then
			return "name<"..cn..">"..seperator..you_text
		else
			return "name<"..cn..">"..seperator..name_text
		end
	end)

	msg = string.gsub(msg, "name<(.-)>", function(cn)
		if tonumber(cn) == to and alpha.settings:get("you_replacing") then --fast code first
			return "you"
		elseif server.valid_cn(cn) then
			return server.displayname
		else
			return "unkown"
		end
	end)
	
	msg = string.gsub(msg, "language<(.-),\"(.-)\">", function(string, default)
		return alpha.settings.get(alpha.playervars(cn).language.."_"..string) or default
	end)
	--[[
	      msg = string.gsub(msg, "db<(.-)>", function (string)
			local lang = playervars.get(to, "lang")
			if not messages.db_temp[lang] then
				messages.db_temp[lang] = {}
			end
        	if messages.db_temp[lang][string] then
        		return messages.db_temp[lang][string]
        	else
        		local res = db.query("SELECT message AS string FROM messages WHERE name="..db.escape(string).." AND lang="..db.escape(lang)..";");
        		if not res or not res[1] or not res[1]["string"] then
        			debug.write(1, "could not find an message in that language trying again")
					res = db.query("SELECT message FROM messages WHERE name="..db.escape(string).." AND lang=\"en\";");
	        		if not res or not res[1] or not res[1]["string"] then
	        			debug.write(2, string.format("failed to get data: string=\"%s\" lang=\"%s\"(tried en too)", string, lang))
	        			log.write("failed to get message from the database", "error")
	        			return "could not find that message"
	        		end
        		end
        		messages.db_temp[lang][string] = res[1]["string"] --store in cache
       			return res[1]["string"]
        	end
        end)
	]]
	
	msg = string.gsub(msg, "red<(.-)>", function (string) return red(string) end)
	msg = string.gsub(msg, "white<(.-)>", function (string) return white(string) end)
	msg = string.gsub(msg, "blue<(.-)>", function (string) return blue(string) end)
	msg = string.gsub(msg, "yellow<(.-)>", function (string) return yellow(string) end)
	msg = string.gsub(msg, "magenta<(.-)>", function (string) return magenta(string) end)
	msg = string.gsub(msg, "green<(.-)>", function (string) return green(string) end)
	msg = string.gsub(msg, "orange<(.-)>", function (string) return orange(string) end)
	msg = string.gsub(msg, "grey<(.-)>", function (string) return grey(string) end)

	alpha.log.write_to("messages", "%s: %s", alpha.log.logname(to), msg)
		
	return server.player_message(to, alpha.messages.descape(msg))
end

function alpha.messages.prepocess(from_module, msg_color, msg_type, private, msg)

	local type_ = alpha.config.get("messages_type")
	if type_ == "xsbs" then
		--custom xsbs
		--prefix the message
    	msg = msg_color.."<["..msg_type.."] >"..msg
        
		--if the message is private
		if private == true then
			--add an private prefix
			msg = alpha.settings.get("private_prefix")..msg
		end
		return msg
	elseif type_ == "simpleserv" then
		--simpleserv
		msg = "orange<--[>white<> "..msg.." orange<]-- >"
	else
		--nooblounge
		--prefix the message
    	msg = msg_color.."<[ "..string.upper(from_module).." ] >"..msg
		return msg	
	end
end

function messages.new (name)
	alpha.messages[name] = function(from_module, to, msg, private)
	    local msg_type = name

	    --check if all required fields are set
	    if from_module == nil or to == nil or msg == nil then
	    	return
	    end
		    
	    msg = alpha.messages.send(from_module, alpha.settings:get("message_color_"..msg_type), msg_type, private, msg)

	    if (not private ) and ircbot and ircbot.say then
	    		ircbot.say(msg)
	    end
	end
end
--messages.*
--@description a function to send an mesage
--@arg  cn from who it comes. if not needed add -1
--@arg  to array({}) filled with cns where the message should be delivered
--@arg  true if the message should look private
messages.new("notice")
messages.new("info")
messages.new("warning")
messages.new("teamkiller")
messages.new("fail")
messages.new("debug")
messages.new("own")
end
