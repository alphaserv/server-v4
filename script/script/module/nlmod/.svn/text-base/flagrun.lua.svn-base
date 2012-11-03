local current_flagcarrier = {}
local current_flagtaketime = {}

local flagtime = {}

server.event_handler("takeflag", function(cn)
	if cn == nil then return end
	current_flagcarrier[cn] = true
	current_flagtaketime[cn] = server.uptime
end)

server.event_handler("dropflag", function(cn)
	if cn == nil then return end
	current_flagcarrier[cn] = nil
	current_flagtaketime[cn] = nil
end)

server.event_handler("scoreflag", function(cn)
	if cn == nil then return end
	current_flagcarrier[cn] = nil
	current_flagtaketime[cn] = current_flagtaketime[cn] or 0
	local time = server.uptime - current_flagtaketime[cn]
	current_flagtaketime[cn] = nil
	flagtime[cn] = flagtime[cn] or (60 * 60 * 1000)
	if time < flagtime[cn] then flagtime[cn] = time end
end)

server.event_handler("mapchange", function()
	flagtime = {}
	current_flagcarrier = {}
	current_flagtaketime = {}
end)

function server.fastestflagrun(cn)
	if cn == nil then return end
	return (flagtime[cn] or (60 * 60 * 1000))
end
