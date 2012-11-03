desc = {}
desc.msg = ""

desc.runmsg = ""
desc.runmsg_service = true
desc.runmsg_pos = 0
desc.runmsg_color = ""

desc.blinkmsg = {}
desc.blinkmsg_service = true
desc.blinkmsg_pos = 0
desc.blinkmsg_time = 1000

desc.maxmsglen = 20

function desc.set(cn, msg)
	if not msg then
		local msg = cn
		if string.len(msg) > 25 then
			desc.runmsg = msg
		else
			for ci in server.aplayers() do
				local cn = ci.cn
				server.send_servinfo(cn, msg)
			end
		end
		desc.msg = msg
	else
		if string.len(msg) > 25 then
			desc.addrunmsg(cn, msg)
		else
			server.send_servinfo(cn, msg)
		end
	end
end

function desc.reset()
	desc.runmsg = ""
	desc.runmsg_service = true
	desc.runmsg_pos = 0
	desc.runmsg_color = ""

	desc.blinkmsg = ""
	desc.blinkmsg_service = true
	desc.blinkmsg_pos = 0
	desc.runmsg_color = ""
	
	desc.sendall(server.servername)
end

function desc.sendall(msg)
	for ci in server.aplayers() do
		server.send_servinfo(ci.cn, (msg or server.servername))
	end
end

local function start_runmsg_service()
	if not desc.runmsg_service then server.sleep(1000, start_runmsg_service); return end
	if desc.runmsg == "" then server.sleep(1000, start_runmsg_service); return end
	if server.playercount <= 0 then server.sleep(1000, start_runmsg_service); return end
	server.sleep(100, start_runmsg_service) -- keep it running, also if it crashes!
	
	local spaces = string.rep(" ", desc.maxmsglen)
	
	if desc.runmsg_pos >= string.len(spaces .. desc.runmsg .. spaces) then
		desc.runmsg_pos = 0
	end
	
	desc.runmsg_pos = desc.runmsg_pos + 1
	desc.sendall(
		desc.runmsg_color .. string.sub(
			spaces .. desc.runmsg .. spaces,
			desc.runmsg_pos,
			(desc.runmsg_pos + (desc.maxmsglen - 1 - string.len(desc.runmsg_color)))
		)
	)
end
start_runmsg_service()

local function start_blinkmsg_service()
	if not desc.blinkmsg_service then server.sleep(1000, start_blinkmsg_service); return end
	if desc.blinkmsg == "" or #(desc.blinkmsg) <= 0 then server.sleep(1000, start_blinkmsg_service); return end
	if server.playercount <= 0 then server.sleep(1000, start_blinkmsg_service); return end
	server.sleep(desc.blinkmsg_time or 100, start_blinkmsg_service) -- keep it running, also if it crashes!
	
	if desc.blinkmsg_pos >= #desc.blinkmsg then
		desc.blinkmsg_pos = 0
	end
	
	desc.blinkmsg_pos = desc.blinkmsg_pos + 1
	
	desc.sendall(desc.blinkmsg[desc.blinkmsg_pos])
end
start_blinkmsg_service()
