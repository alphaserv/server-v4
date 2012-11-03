local pro_color1 = server.color1
local pro_color2 = server.color2

local function getcns()
	frags = {}
	acc = {}
	tk = {}
	deaths = {}
	flagrun = {}
	frags[0] = 0
	acc[0] = 0
	tk[0] = 0
	deaths[0] = 0
	flagrun[0] = 0
	for a in server.gclients() do
		frags[0] = a.cn
		acc[0] = a.cn
		tk[0] = a.cn
		deaths[0] = a.cn
		flagrun[0] = a.cn
		frags[1] = server.player_frags(a.cn)
		deaths[1] = server.player_deaths(a.cn)
		acc[1] = server.player_accuracy(a.cn)
		tk[1] = server.player_teamkills(a.cn)
		flagrun[1] = server.fastestflagrun(a.cn)
		break
	end
	for a in server.gclients() do
		cn = a.cn
		if server.player_frags(cn) > frags[1] then
			frags[1] = server.player_frags(cn)
			frags[0] = cn
		end
		if server.player_accuracy(cn) > acc[1] then
			acc[1] = server.player_accuracy(cn)
			acc[0] = cn
		end
		if server.player_teamkills(cn) > tk[1] then
			tk[1] = server.player_teamkills(cn)
			tk[0] = cn
		end
		if server.player_deaths(cn) > deaths[1] then
			deaths[1] = server.player_deaths(cn)
			deaths[0] = cn
		end
		if server.fastestflagrun(cn) < flagrun[1] then
			flagrun[1] = server.fastestflagrun(cn)
			flagrun[0] = cn
		end
	end
	return frags[0], acc[0], tk[0], deaths[0], flagrun[0]
end

server.event_handler("intermission", function()
	frags, accuracy, teammates, deaths, flagrun = getcns()
	if server.valid_cn(frags) and server.valid_cn(deaths) and server.valid_cn(teammates) and server.valid_cn(deaths) and server.valid_cn(flagrun) then
		if server.player_frags(frags) ~= 0 then
			frags_part = pro_color2.."frags: "..pro_color1..server.player_displayname(frags)..pro_color2.." ("..pro_color1..server.player_frags(frags)..pro_color2.."), "
		else
			frags_part = ""
		end
		if server.player_teamkills(teammates) ~= 0 then
			tk_part = pro_color2.."teamkills: "..pro_color1..server.player_displayname(teammates)..pro_color2.." ("..pro_color1..server.player_teamkills(teammates)..pro_color2.."), "
		else
			tk_part = ""
		end
		if server.fastestflagrun(flagrun) ~= (60*60*1000) then
			flag_part = pro_color2..", fastest flagrun: "..pro_color1..server.player_displayname(flagrun)..pro_color2.." ("..pro_color1..server.fastestflagrun(flagrun)..pro_color2.."ms)"
		else
			flag_part = ""
		end
		acc_part = pro_color2.."accuracy: "..pro_color1..server.player_displayname(accuracy)..pro_color2.." ("..pro_color1..server.player_accuracy(accuracy).."%"..pro_color2.."), "
		deaths_part = pro_color2.."deaths: "..pro_color1..server.player_displayname(deaths)..pro_color2.." ("..pro_color1..server.player_deaths(deaths)..pro_color2..")"
		server.msg(getmsg("best stats: {1}{2}{3}{4}{5}", frags_part, acc_part, tk_part, deaths_part, flag_part))
	end
end)
