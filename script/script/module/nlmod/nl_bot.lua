--[[
	script/module/nl_mod/nl_bot.lua
	Hankus (Derk Haendel)
	Created: 31-Jan-2011
	Last Modified: 31-Jan-2011
	License: GPL3

	Funktionen:
		Kommunikation zwischen den Sauerbraten-Servern und dem IRC-Server
		Setzen und Ueberwachen der Berechtigungen von IRC-Usern

]]

local bot = {}
bot.irc = require("irc")
bot.geoip = require("geoip")
bot.debug = 1
bot.server = server.irc_network
bot.channel = server.irc_channel
bot.nick = server.irc_bot_name
bot.cmd = server.irc_bot_command_name .. " "

--[[
		API
]]

bot.irclog = io.open("log/bot.log","w+")
function bot.log(msg)
	assert(msg ~= nil)
	bot.irclog:write(os.date("[%a %d %b %X] ",os.time()))
	bot.irclog:write(msg)
	bot.irclog:write("\n")
	bot.irclog:flush()
end

function bot.init()
	bot.con = bot.irc.new{ nick = bot.nick }

	bot.con:hook("OnDisconnect", function(message, errorOccured)
		if bot.debug == 1 then bot.log(string.format( "OnDisconnect(message=%s, errorOccurred=%s)", tostring(message), tostring(errorOccurred) )) end
		-- bot.init()
	end)

	bot.con:hook("OnChat", function(user, channel, message)
		local rcmd
		if bot.debug == 1 then bot.log(string.format( "OnChat(user=%s, channel=%s, message=%s)", user.nick, channel, message )) end
		-- Prüfen, ob wir gemeint sind (z.b. nl4)
		if message:sub(1,bot.cmd:len()):upper() == bot.cmd:upper() then
			message = message:sub( bot.cmd:len()+1 )
			-- SET ACCESS-LEVEL
	--[[
			local whois = bot.con:whois(user.nick)
			for i, v in pairs(whois.userinfo) do
				irc_say(string.format( "WHOIS.userinfo: %s=%s", tostring(i), tostring(v) ))
			end
			for i, v in pairs(whois.node) do
				irc_say(string.format( "WHOIS.node: %s=%s", tostring(i), tostring(v) ))
			end
			for i, v in pairs(whois.channels) do
				irc_say(string.format( "WHOIS.channels: %s=%s", tostring(i), tostring(v) ))
			end
	]]
			rcmd = "say "
			if message:sub( 1, rcmd:len() ) == rcmd then
				message = message:sub( rcmd:len() )
				--bot.con:sendChat( server.irc_channel, "say command found" )
				local fname = user.nick
				local fcn = 0
				while server.valid_cn(fcn) and fcn < 127 do fcn = fcn + 1 end
				if fcn < 128 then
					for ci in server.aplayers() do
						server.send_fake_connect(ci.cn, fcn, fname, "irc")
						server.send_fake_text_(ci.cn, fcn, message)
						server.send_fake_disconnect(ci.cn, fcn)
					end
					--irc_say(string.format("Valid cn = %s", tostring(fcn)))
				else
					irc_say("Could not get a valid cn ...")
				end
			end
		end
	end)

	bot.con:hook("OnRaw", function(line)
		if bot.debug == 1 then bot.log(string.format( "OnRaw( %s )", tostring(line) )) end
	end)

	bot.con:hook("OnNotice", function(user, channel, message)
		if bot.debug == 1 then bot.log(string.format( "OnNotice(user.nick=%s, channel=%s, message=%s)", tostring(user.nick), tostring(channel), tostring(message) )) end
	end)

	bot.con:hook("OnJoin", function(user, channel)
		if bot.debug == 1 then bot.log(string.format( "OnJoin(user.nick=%s, channel=%s)", tostring(user.nick), tostring(channel) )) end
	end)

	bot.con:hook("OnPart", function(user, channel)
		if bot.debug == 1 then bot.log(string.format( "OnPart(user.nick=%s, channel=%s)", tostring(user.nick), tostring(channel) )) end
	end)

	bot.con:hook("OnQuit", function(user, message)
		if bot.debug == 1 then bot.log(string.format( "OnQuit(user.nick=%s, message=%s)", tostring(user.nick), tostring(message) )) end
	end)

	bot.con:hook("NickChange", function(user, newnick, channel)
		if bot.debug == 1 then bot.log(string.format( "NickChange(user.nick=%s, newnick=%s, channel=%s)", tostring(user.nick), tostring(newnick), tostring(channel) )) end
	end)

	bot.con:hook("NameList", function(channel, names)
		if bot.debug == 1 then bot.log(string.format( "NameList(channel=%s, names=%s)", tostring(channel), tostring(names) )) end
	end)

	bot.con:hook("OnTopic", function(channel, topic)
		if bot.debug == 1 then bot.log(string.format( "OnTopic(channel=%s, topic=%s)", tostring(channel), tostring(topic) )) end
	end)

	bot.con:hook("OnTopicInfo", function(channel, creator, timeCreated)
		if bot.debug == 1 then bot.log(string.format( "OnTopicInfo(channel=%s, creator=%s, timeCreated=%s)", tostring(channel), tostring(creator), tostring(timeCreated) )) end
	end)

	bot.con:hook("OnKick", function(channel, nick, kicker, reason)
		if bot.debug == 1 then bot.log(string.format( "OnKick(channel=%s, nick=%s, kicker=%s, reason=%s)", tostring(channel), tostring(nick), tostring(kicker), tostring(reason) )) end
	end)

	bot.con:hook("OnUserMode", function(modes)
		if bot.debug == 1 then bot.log(string.format( "OnUserMode(modes=%s)", tostring(modes) )) end
	end)

	bot.con:hook("OnChannelMode", function(user, channel, modes)
		if bot.debug == 1 then bot.log(string.format( "OnChannelMode(user.nick=%s, channel=%s, modes=%s)", tostring(user.nick), tostring(channel), tostring(modes) )) end
	end)

	bot.con:hook("OnModeChange", function(user, target, modes)
		if bot.debug == 1 then bot.log(string.format( "OnModeChange(user.nick=%s, target=%s, modes=%s)", tostring(user.nick), tostring(target), tostring(modes) )) end
	end)

	bot.con:connect( bot.server )
	bot.con:join( bot.channel )
end
bot.init()

bot.con:sendChat("NL-ChanBot", "rucki607zucki")

server.interval(10, function()
	bot.con:think()
end)

--[[
		FUNKTONS
]]

function irc_say( message )
	bot.con:sendChat( bot.channel, message )
end

--[[
		COMMANDS
]]

function server.playercmd_spy(cn)
	if access(cn) == admin_access then
		server.spec(cn)
		server.invisible(cn)
		--for _,tcn in pairs(players.all()) do
		--	server.send_fake_disconnect(tcn, cn)
		--end
	end
end

function server.playercmd_irctest(cn)
	server.spec(0)
end

--[[
		EVENT HANDLERS
]]

server.event_handler("kick", function(cn, bantime, admin, reason)
	local reason_tag = ""
	if reason ~= "" then reason_tag = "for " .. reason end
	local action_tag = "kicked"
	if tonumber(bantime) < 0 then action_tag = "kicked and permanently banned" end
	irc_say(string.format("\0034KICK\003    \00312%s(%i)\003 was \0037%s\003 by \0037%s\003 \0037%s\003\n",server.player_name(cn),cn,action_tag,admin,reason_tag), noop)
end)

server.event_handler("rename",function(cn, oldname, newname)
    irc_say(string.format("\0032RENAME\003  \00312%s(%i)\003 renamed to \0037%s\003\n",oldname,cn,newname))
end)

server.event_handler("reteam",function(cn, oldteam, newteam)
    irc_say(string.format("\0034CHANGETEAM\003    \00312%s(%i)\003 changed team to \0037%s\003\n",server.player_name(cn),cn,newteam))
end)

--[[
server.event_handler("text", function(cn, msg)
    -- Hide player commands
    if string.match(msg, "^#.*") or string.match(msg, "^!.*") then
        return
    end
    local mute_tag = ""
    if server.is_muted(cn) then mute_tag = "(muted)" end
    irc_say(string.format("\0033CHAT\003    \00312%s(%i)\003%s  ~>  \0033%s\003\n",server.player_name(cn),cn,mute_tag,msg))
end)

server.event_handler("sayteam", function(cn, msg)
    irc_say(string.format("\0033TEAMCHAT\003    \00312%s(%i)\003(team): %s\n",server.player_name(cn),cn,msg))
end)
]]

server.event_handler("mapvote", function(cn, map, mode)
    irc_say(string.format("\0033VOTE\003    \00312%s(%i)\003 suggests \0037%s\003 on map \0037%s\003",server.player_name(cn),cn,mode,map))
end)

server.event_handler("mapchange", function(map, mode)
    
    local playerstats = ""
    local sc = tonumber(server.speccount)
    local pc = tonumber(server.playercount) - sc
    playerstats = tostring(pc) .. " players"
    if sc > 0 then playerstats = playerstats .. " " .. tostring(sc) .. " spectators" end
    
    irc_say(string.format("\0032NEWMAP\003    New game: \0037%s\003 on \0037%s\003, \0037%s\003", mode, map, playerstats))
end)

server.event_handler("setmastermode", function(cn, oldmode, newmode)
    irc_say(string.format("\0034MM\003    Mastermode changed to %s",newmode))
end)

server.event_handler("masterchange", function(cn, value)

    local action_tag = "claimed"
    if tonumber(value) == 0 then action_tag = "relinquished" end

    irc_say(string.format("\0034MASTER\003    \00312%s(%i)\003 %s \0037%s\003", server.player_name(cn), cn, action_tag, server.player_priv(cn)))
end)


server.event_handler("spectator", function(cn, value)
    
    local action_tag = "joined"
    if tonumber(value) == 0 then action_tag = "left" end
    
    irc_say(string.format("\0034SPEC\003    \00312%s(%i)\003 %s spectators",server.player_name(cn),cn,action_tag))
end)

server.event_handler("gamepaused", function() irc_say("\0034PAUSE\003    game is paused")end)
server.event_handler("gameresumed", function() irc_say("\0034RESM\003    game is resumed") end)

server.event_handler("addbot", function(cn,skill,owner)
    local addedby = "server"
    if cn ~= -1 then addedby = "\00312" .. server.player_name(cn) .. string.format("(%i)\003", cn) end
    irc_say(string.format("\00315ADDBOT\003    %s added a bot (skill %i)", addedby, skill))
end)

server.event_handler("delbot", function(cn)
    irc_say(string.format("\00315DBOT\003    \00312%s(%i)\003 deleted a bot\n",server.player_name(cn),cn))
end)

server.event_handler("beginrecord", function(id,filename)
    irc_say(string.format("\00312DEMOSTART\003    Recording game to %s",filename))
end)

server.event_handler("endrecord", function(id, size)
    irc_say(string.format("\00312DEMOEND\003    finished recording game (%s file size)\n",format_filesize(tonumber(size))))
end)

server.event_handler("mapcrcfail", function(cn) 
    irc_say(string.format("\0034MCRC\003    \00312%s(%i)\003 has a modified map (%s %i). [ip: %s]\n",server.player_name(cn),cn, server.map, server.player_mapcrc(cn), server.player_ip(cn)))
    log_usednames(cn)
end)

server.event_handler("shutdown", function() irc_say("\0034HALT\003    Server shutting down"); end)

server.event_handler("reloadhopmod", function() irc_say("\0034RELOAD\003    Reloading hopmod...\n") end)

