local invadmin_domains = table_unique(server.parse_list(server["admin_domains"])) or ""

local cns = {}

authconnecting = {}
function authconnecting.nosendinitmap(cn) local cn = tonumber(cn); cns[cn] = cns[cn] or {}; return cns[cn].nosendinitmap end
function authconnecting.nosendclients(cn) local cn = tonumber(cn); cns[cn] = cns[cn] or {}; return cns[cn].nosendclients end
function authconnecting.nosendinitclient(cn) local cn = tonumber(cn); cns[cn] = cns[cn] or {}; return cns[cn].nosendinitclient end
function authconnecting.nobanner(cn) local cn = tonumber(cn); cns[cn] = cns[cn] or {}; return cns[cn].nobanner end

function server.finishconnect(cn)
	server.visible(cn)
	server.sendinitmap(cn)
	local pcnt = 0
	for ci in server.gclients() do
		if ci.cn ~= tonumber(cn) then pcnt = pcnt + 1 end
	end
	if pcnt > 0 then server.sendclients(cn) end
	for ci in server.gclients() do
		if ci.cn ~= cn and server.isvisible(ci.cn) then server.sendinitclient(ci.cn, cn) end
	end
	server.reset_maploaded(cn)
	server.signal_connect(cn)
	cns[cn] = cns[cn] or {}
	cns[cn].nosendinitmap = nil
	cns[cn].nosendclients = nil
	cns[cn].nosendinitclient = nil
	cns[cn].nobanner = nil
end

function server.authconnecting(cn)
	server.invisible(cn)
	server.resetpvars(cn)
	cns[cn] = cns[cn] or {}
	cns[cn].nosendinitmap = true
	cns[cn].nosendclients = true
	cns[cn].nosendinitclient = true
	cns[cn].nobanner = true
	auth.initclienttable(cn)
end

function server.send_connect_auth(cn)
	local session_id = server.player_sessionid(cn)
	log("client " .. server.player_name(cn) .. " (" .. cn .. ")(" .. server.player_ip(cn) .. ") is trying authconnect!")
	server.player_msg(cn, getmsg("sending auth request ..."))
	local domains = table_unique(server.parse_list(server["admin_domains"])) or ""
	for i, invadmin_domain in ipairs(domains) do
		auth.send_quick_request(cn, invadmin_domain, function(cn, user_id, domain, status)
			if session_id ~= server.player_sessionid(cn) then
				return
			elseif status ~= auth.request_status.SUCCESS then
				server.resetpvars(cn)
				server.player_msg(cn, badmsg("failed!"))
				server.sleep(10, function() server.disconnect(cn, server.DISC_NONE, "") end)-- works only because we've got only one admin domain!
				return
			end
			server.resetpvars(cn)
			server.player_msg(cn, getmsg("succeeded!"))
			server.sleep(500, function()
				if session_id ~= server.player_sessionid(cn) then return end
				server.finishconnect(cn)
				server.give_user_access(cn, user_id)
				if server.player_status(cn) ~= "spectator" then server.spawn_player(cn) end
			end)
		end)
	end
end
