ircbot = {}
ircbot.geoip = require("geoip")
ircbot.debug = (alpha.debug.level > 1)
ircbot.server = "irc.gamesurge.net"
ircbot.channels = "#nl, #nlcountry"
ircbot.nick = "_nl^2"
ircbot.functions = {}

function ircbot.parse_message(input)
  local output = input
  output = string.gsub(output,"name<(.-)>",function(cn) return server.player_displayname(cn) end)
  output = string.gsub(output,"white<(.-)>",function(word) return string.format("\0030%s\003", word) end)
  output = string.gsub(output,"black<(.-)>",function(word) return string.format("\0031%s\003", word) end)
  output = string.gsub(output,"green<(.-)>",function(word) return string.format("\0033%s\003", word) end)
  output = string.gsub(output,"red<(.-)>",function(word) return string.format("\0034%s\003", word) end)
  output = string.gsub(output,"magenta<(.-)>",function(word) return string.format("\0036%s\003", word) end)
  output = string.gsub(output,"orange<(.-)>",function(word) return string.format("\0037%s\003", word) end)
  output = string.gsub(output,"yellow<(.-)>",function(word) return string.format("\0038%s\003", word) end)
  output = string.gsub(output,"blue<(.-)>",function(word) return string.format("\00312%s\003", word) end)
  output = string.gsub(output,"navy<(.-)>",function(word) return string.format("\0032%s\003", word) end)
  output = string.gsub(output,"brown<(.-)>",function(word) return string.format("\0035%s\003", word) end)
  output = string.gsub(output,"bright_green<(.-)>",function(word) return string.format("\0039%s\003", word) end)
  output = string.gsub(output,"light_blue<(.-)>",function(word) return string.format("\00310%s\003", word) end)
  output = string.gsub(output,"neon<(.-)>",function(word) return string.format("\00311%s\003", word) end)
  output = string.gsub(output,"pink<(.-)>",function(word) return string.format("\00313%s\003", word) end)
  output = string.gsub(output,"grey<(.-)>",function(word) return string.format("\00314%s\003", word) end)
  output = string.gsub(output,"light_grey<(.-)>",function(word) return string.format("\00315%s\003", word) end)
  return output
end

function ircbot.writelog(msg)
	log.write(msg, "irc")
end
function ircbot.functions.disconnect(message, error_)
	ircbot.writelog(string.format("Disconnect: %q, %q", message, error_))
end
function ircbot.functions.chat(user, chanel, message)
	ircbot.writelog(string.format("Chat: %q, %q, %q", user, chanel, message))
	ircbot.command(user, chanel, message)
end
function ircbot.functions.raw(raw)
	ircbot.writelog(string.format("Raw: %q",raw))
end
function ircbot.functions.notice(user, chanel, message)
	ircbot.writelog(string.format("Notice: %q, %q, %q", user, chanel, message))
end
function ircbot.functions.join(user, chanel)
	ircbot.writelog(string.format("Join: %q, %q, %q", user, chanel))
end

function ircbot.init()
	ircbot.con = ircbot.irc.new{ nick=ircbot.nick }
	bot.con:hook("OnDisconnect", ircbot.functions.disconnect)
	bot.con:hook("OnChat", ircbot.functions.chat)
	bot.con:hook("OnRaw", ircbot.functions.raw)
	bot.con:hook("OnNotice", ircbot.functions.notice)
	bot.con:hook("OnJoin", ircbot.functions.join)
	bot.con:connect( ircbot.server )
	bot.con:join( ircbot.channel )
--	bot.con:join( "#sauerserver" )
end

ircbot.init()

server.interval(10, function()
	bot.con:think()
end)

function ircbot.say(message)
	message = ircbot.parse_message(message)
	bot.con:sendChat( "#nl", message )
	bot.con:sendChat( bot.channel, message )
end
