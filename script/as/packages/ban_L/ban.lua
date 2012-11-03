
module("bans", package.seeall)

function is_banned(cn)
	server.msg("checking bans ... ("..os.time()..")")
	local result = alpha.db:query([[
		SELECT
			id,
			expire_time,
			name,
			ip,
			reason
		FROM
			bans
		WHERE
		(
				ip
			OR
				name = ?
		)
		AND
		(
				expire_time > ?
			OR
				expire_time = -1
		)
		]], server.player_name(cn), os.time())
	
	result = result:fetch()

	server.msg(#result)
	for j, row in pairs(result) do
		if row.ip then
			local ip = string.split(row.ip, '.')
			local check_ip = string.split(server.player_ip(cn), '.')
			server.msg(row.ip .. "vs" .. server.player_ip(cn))
			for i, part in ipairs(ip) do
				if part ~= "*" then --allow wildchars
					if check_ip[i] ~= part then
						result[j] = nil
					end
				end
			end
		end
	end
	server.msg(#result)
	if #result > 0 then
		return true, result[1]
	else
		return false
	end
end

function block_user(cn, reason)
	
	--Fake disconnect all other players
	for i, cn_ in pairs(server.players()) do
		server.fake_disconnect(cn, cn_)
	end
	
	server.disconnect(cn, server.DISC_IPBAN, "")

	server.setspy(cn, true)	
	--mute and mute.mute({cn = cn}, -1)
end

function server.kick(cn, bantime, admin, reason)

	local real_admin
	
	if admin and server.valid_cn(admin) and user_from_cn(admin).user_id ~= -1 then
		real_admin = user_from_cn(admin).user_id
	end
end
server.permban(ip)	 nil	 Set IP address range as permanently banned from the server.
server.unsetban(ip)


server.event_handler("connecting", function(cn)

	local is_banned, row = is_banned(cn)
	
	if is_banned then
		messages.load("ban", "banned", {default_type = "warning", default_message = "orange<YOU> red<are currently> orange<BANNED>, red<reason:> orange<%(1)s>"})
			:format(row.reason)
			:send(cn, true)
		
		block_user(cn)
	end
end)
