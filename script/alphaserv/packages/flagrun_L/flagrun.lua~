module("flagrun", package.seeall)

local flagC1 = {}
local timeFlagC1 = {}
local isValid1 = {}
local tRun1 = {}

function isValid1['taking_of_flag'](cn)

messages.load("flagrun", "take", {default_type = "info", default_message = "Player %(1)s has picked up the flag for team: %(2)s"}):format (server.player_displayname(cn), server.player_team(cn)):send()

flagC1.cn = true
timeFlagC1.cn = server.uptime()
tRun1['server.player_team(cn)'] = server.uptime()


end

function isValid1['droping_flag'](cn)

messages.load("flagrun", "drop", {default_type = "info", default_message = "Player %(1)s has lost the flag for team: %(2)s"})
:format (server.player_displayname(cn), server.player_team(cn))
:send ()

	flagC1.cn = false
	timeFlagC1.cn = false

end

function isValid1['scoring_of_flag'](cn)

	flagC1.cn = false
	local i = server.uptime() -timeFlagC1.cn
	timeFlagC1.cn = false
	i = (i / 1000)


messages.load("flagrun", "score", {default_type = "info", default_message = "Player %(1)s has scored for his team: %(2)s in just %(3)i seconds!"})
:format (server.player_displayname(cn), server.player_team(cn), i)
:send()

end

function isValid['returned'](cn)

messages.load("flagrun", "return", {default_type = "info", default_message = "Player %(1)s has returned the flag for his team: %(2)s"})
:format (server.player_displayname(cn), server.player_team(cn))
:send()

	flagC1.cn = true
	timeFlagC1.cn = server.uptime()

end

function isValid['reset_of_flag'](cn)

messages.load("flagrun", "reset", {default_type = "info", default_message = "The flag has been reseted!"})
:send()

	flagC1.cn = true
	timeFlagC1.cn = server.uptime()	

end


server.event_handler("takeflag", isValid1['taking_of_flag'])
server.event_handler("dropflag", isValid1['droping_flag'])
server.event_handler("scoreflag", isValid1['scoring_of_flag'])
server.event_handler("returnflag", isValid['returned'])
server.event_handler("restflag", isValid['reset_of_flag'])
