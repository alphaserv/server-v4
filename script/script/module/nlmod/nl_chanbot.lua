--[[
	script/module/nl_mod/nl_irc.lua
	Hankus (Derk Haendel)
	Created: 01-Jan-2011
	Last Modified: 08-Jan-2011
	License: GPL3

	Funktionen:
		Kommunikation zwischen den Sauerbraten-Servern und dem IRC-Server
		Setzen und Ueberwachen der Berechtigungen von IRC-Usern

]]

local chanbot = {}
chanbot.irc = require("irc")
chanbot.geoip = require("geoip")
chanbot.debug = 1
chanbot.con = chanbot.irc.new{nick = "NL-ChanBot"}
chanbot.srvlist = { "NL",	"ML",	"EL", "GS" }
chanbot.srvpass = "rucki607zucki"

chanbot.irclog = io.open("log/chanbot.log","w+")
function chanbot.log(msg)
	assert(msg ~= nil)
	chanbot.irclog:write(os.date("[%a %d %b %X] ",os.time()))
	chanbot.irclog:write(msg)
	chanbot.irclog:write("\n")
	chanbot.irclog:flush()
end

-- <li><code>OnDisconnect(message, errorOccurred)</code></li>
chanbot.con:hook("OnDisconnect", function(message, errorOccured)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnDisconnect(message=%s, errorOccurred=%s)", tostring(message), tostring(errorOccurred) )) end
	--irc_say(string.format( "OnDisconnect(message=%s, errorOccurred=%s)", tostring(message), tostring(errorOccurred) ))
end)

-- <li><code>OnChat(user, channel, message)</code></li>
chanbot.con:hook("OnChat", function(user, channel, message)
	-- if chanbot.debug == 1 then chanbot.log(string.format( "OnChat(user=%s, channel=%s, message=%s)", user.nick, channel, message )) end
	if channel == "NL-ChanBot" then
		chanbot.base = db.select('user', { 'nickname', 'clantag', 'pwd_clear', 'activated', 'adminlevel' }, 'CHAR_LENGTH(pwd_clear) > 0')
		for i, base in pairs(chanbot.base) do
			if (user.nick == base.nickname) or (user.nick == base.clantag .. base.nickname) or (user.nick == base.nickname .. base.clantag) then
				--chanbot.con:sendChat(user.nick, base.nickname .. " found.")
				if base.activated == "1" and message == base.pwd_clear then
					-- chanbot.con:sendChat(user.nick, base.nickname .. " is verified.")
					chanbot.con:send(string.format( "MODE %s %s %s", "#nooblounge", "+o", user.nick ))
					chanbot.con:send(string.format( "MODE %s %s %s", "#gstf", "+o", user.nick ))
					-- chanbot.con:send("MODE %s %s", user.nick, "+o")
					-- chanbot.con:send("MODE %s %s %s", "#gstf", user.nick, "+O")
				end
			end
		end
		for i, base in pairs(chanbot.srvlist) do
			--chanbot.con:sendChat("Hankus", string.sub(user.nick, 1, 2).."=="..base)
			--chanbot.con:sendChat("Hankus", string.sub(user.nick, -4).."==".."-Bot")
			--chanbot.con:sendChat("Hankus", message.."=="..chanbot.srvpass)
			if (string.sub(user.nick, 1, 2)  == base) and (string.sub(user.nick, -4)  == "-Bot") and (message == chanbot.srvpass) then
				--chanbot.con:sendChat("Hankus", user.nick.."="..chanbot.srvpass)
				chanbot.con:send(string.format( "MODE %s %s %s", "#nooblounge", "+v", user.nick ))
				chanbot.con:send(string.format( "MODE %s %s %s", "#gstf", "+v", user.nick ))
				--return
			end
		end
		-- chanbot.con:sendChat(user.nick, message)
	end
end)

-- <li><code>OnNotice(user, channel, message)</code></li>
chanbot.con:hook("OnNotice", function(user, channel, message)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnNotice(user.nick=%s, channel=%s, message=%s)", tostring(user.nick), tostring(channel), tostring(message) )) end
end)

-- <li><code>OnJoin(user, channel)</code>*</li>
chanbot.con:hook("OnJoin", function(user, channel)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnJoin(user.nick=%s, channel=%s)", tostring(user.nick), tostring(channel) )) end
end)

-- <li><code>OnPart(user, channel)</code>*</li>
chanbot.con:hook("OnPart", function(user, channel)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnPart(user.nick=%s, channel=%s)", tostring(user.nick), tostring(channel) )) end
end)

-- <li><code>OnQuit(user, message)</code></li>
chanbot.con:hook("OnQuit", function(user, message)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnQuit(user.nick=%s, message=%s)", tostring(user.nick), tostring(message) )) end
end)

-- <li><code>NickChange(user, newnick, channel)</code>*</li>
chanbot.con:hook("NickChange", function(user, newnick, channel)
--[[
	if chanbot.debug == 1 then
		chanbot.log(string.format( "user.nick=%s", tostring(user.nick) ))
		chanbot.log(string.format( "newnick=%s", tostring(newnick) ))
		chanbot.log(string.format( "channel=%s", tostring(channel) ))
	end
]]
	if chanbot.debug == 1 then chanbot.log(string.format( "NickChange(user.nick=%s, newnick=%s, channel=%s)", tostring(user.nick), tostring(newnick), tostring(channel) )) end
end)

-- <li><code>NameList(channel, names)</code></li>
chanbot.con:hook("NameList", function(channel, names)
	if chanbot.debug == 1 then chanbot.log(string.format( "NameList(channel=%s, names=%s)", tostring(channel), tostring(names) )) end
end)

-- <li><code>OnTopic(channel, topic)</code></li>
chanbot.con:hook("OnTopic", function(channel, topic)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnTopic(channel=%s, topic=%s)", tostring(channel), tostring(topic) )) end
end)

-- <li><code>OnTopicInfo(channel, creator, timeCreated)</code></li>
chanbot.con:hook("OnTopicInfo", function(channel, creator, timeCreated)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnTopicInfo(channel=%s, creator=%s, timeCreated=%s)", tostring(channel), tostring(creator), tostring(timeCreated) )) end
end)

-- <li><code>OnKick(channel, nick, kicker, reason)</code>* (kicker is a <code>user</code> table)</li>
chanbot.con:hook("OnKick", function(channel, nick, kicker, reason)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnKick(channel=%s, nick=%s, kicker=%s, reason=%s)", tostring(channel), tostring(nick), tostring(kicker), tostring(reason) )) end
end)

-- <li><code>OnUserMode(modes)</code></li>
chanbot.con:hook("OnUserMode", function(modes)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnUserMode(modes=%s)", tostring(modes) )) end
end)

-- <li><code>OnChannelMode(user, channel, modes)</code></li>
chanbot.con:hook("OnChannelMode", function(user, channel, modes)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnChannelMode(user.nick=%s, channel=%s, modes=%s)", tostring(user.nick), tostring(channel), tostring(modes) )) end
end)

-- <li><code>OnModeChange(user, target, modes)</code>*</li>
chanbot.con:hook("OnModeChange", function(user, target, modes)
	if chanbot.debug == 1 then chanbot.log(string.format( "OnModeChange(user.nick=%s, target=%s, modes=%s)", tostring(user.nick), tostring(target), tostring(modes) )) end
end)

chanbot.con:connect("localhost")

--[[
chanbot.con:send("OPER NL-Chanbot superdillgurke")
chanbot.con:join("#chanbot")
chanbot.con:send("MODE #chanbot +o NL-Chanbot")
]]

chanbot.con:send("OPER NL-ChanBot superdillgurke")

chanbot.con:join("#gstf")
chanbot.con:send("MODE #gstf +o NL-ChanBot")

chanbot.con:join("#nooblounge")
chanbot.con:send("MODE #nooblounge +o NL-ChanBot")

server.interval(1000, function()
	chanbot.con:think()
end)

--while true do
    --s:think()
    --sleep(0.5)
--end

