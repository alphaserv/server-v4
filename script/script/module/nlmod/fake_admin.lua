local admin = {}

local function get_cn()
	local cn = 0
	while server.valid_cn(cn) and cn < 127 do cn = cn + 1 end
	if cn < 128 then return cn else return end
end

function server.fake_admin_cn()
	if admin.started then return admin.cn else return end
end

function server.send_private_fake_admin_msg(cn, text)
	server.start_admin(cn)
	server.send_fake_text(cn, server.fake_admin_cn(), text)
	server.stop_admin()
end

function server.send_fake_admin_msg(text)
	server.start_admin()
	for ci in server.aplayers() do server.send_fake_text(ci.cn, server.fake_admin_cn(), text) end
	server.stop_admin()
end

function server.start_admin(ocn)
	if not admin.started then
		local cn = server.add_fake_client("TheAdmin")
		admin.cn = cn
		admin.ocn = ocn
		admin.started = true
		if ocn then
			server.invisible(cn)
			server.sendinitclient(ocn, cn)
		else
			for ci in server.aplayers() do server.sendinitclient(ci.cn, cn) end
		end
	end
end

function server.stop_admin()
	if admin.started then
		if admin.ocn then
			server.visible(admin.cn)
			server.send_fake_disconnect(admin.ocn, admin.cn)
		else
			for ci in server.aplayers() do server.send_fake_disconnect(ci.cn, cn) end
		end
		server.remove_fake_client(admin.cn)
		admin.started = false
		admin.cn = nil
		admin.ocn = nil
	end
end
		
server.event_handler("allow_rename", function(cn, name)
	if name == "TheAdmin" then return -1 end
end)

server.event_handler("connecting", function(cn, ip, name, pwd, banned)
	if name == "TheAdmin" then
		server.player_rename(cn, "unnamed", false)
	end
end)
