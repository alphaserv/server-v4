
module("bans", package.seeall)

function is_ip_banned(ip)

	result = alpha.db:query("SELECT id, reason, expire, ip, by_ip, by_name FROM	bans WHERE ip = ?;", ip)
	
	if not result then
		error("could not check bans! for ip: %(1)s, query returned false" % {ip })
	end
	
	if result:num_rows() > 0 then
		for i, row in ipairs(result:fetch()) do
			if tonumber(row.expire) < os.time() then
				clean_ban(row.id)
			else
				return true, row
			end
		end
	end
	
	return false
end

function block_user(cn)
	server.setspy(cn)
	server.force_spec(cn)
end

local connect_event = server.event_handler("connecting", function(cn)

	local is_banned, row = is_ip_banned(cn)
	
	if is_banned then
		messages.load("ban", "banned", {default_type = "warning", default_message = "orange<YOU> red<are currently> orange<BANNED>"})
				--:format()
				:send({cn}, true)
	end
end)
