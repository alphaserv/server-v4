if server.no_standard_banner then return end

require("geoip")

local sentwelcome = {}

local function getcountry(cn)
	return geoip.ip_to_country(server.player_ip(cn))
end

local function countrymsg(cn)
	local country = getcountry(cn)
	local login = (server.xstats_user(cn) ~= "")
	if country ~= "" then
		if login then
			return getmsg("{1} is fragging in {2} and is {3}", server.player_displayname(cn), country, "logged in")
		else
			return getmsg("{1} is fragging in {2}", server.player_displayname(cn), country)
		end
	elseif login then
		return getmsg("{1} is {2}", server.player_displayname(cn), "logged in")
	else
		return ""
	end
end

local function message(msg, cn)
	for ci in server.gclients() do
		if ci.cn ~= cn then server.player_msg(ci.cn, msg) end
	end
end

local function sendwelcome(cn, time)
	time = time or 2000
	if sentwelcome[cn] then return end
	if authconnecting.nobanner(cn) then return end
	local sid = server.player_sessionid(cn)
	server.sleep(time, function()
		if sid ~= server.player_sessionid(cn) then return end
		local login = server.xstats_user(cn)
		server.player_msg(cn, getmsg(""))
		server.player_msg(cn, getmsg("Welcome to "..server.servername..", {1}! commands:", server.player_name(cn)))
		server.player_msg(cn, getmsg(" {2}, {3}, {4}, {5}, {6}, {7}", nil, "#info", "#help", "#rules", "#stats", "#mapsucks", "#veto"))
		if login ~= "" then server.player_msg(cn, getmsg("you are logged in as {1}", login)) end
		server.player_msg(cn, getmsg(""))
		sentwelcome[cn] = true
	end)
end

server.event_handler("maploaded", sendwelcome)

server.event_handler("disconnect", function(cn)
	sentwelcome[cn] = nil
end)

server.event_handler("connect", function(cn)
	local msg = countrymsg(cn)
	if msg ~= "" then message(msg, cn) end
end)
