
function server.kick(cn, admin, reason, bantime)
	local ip = server.player_ip(cn)
	local admin_ip = "0.0.0.0"
	if server.valid_cn(admin) then
		admin_ip = server.player_ip(admin)
		messages.warning(admin, {cn}, "name<"..admin.."> kicked you becouse: "..reason, true)
	end
	server.sleep(1000, function()
		server.disconnect(cn, server.DISC_KICK, reason)
	end)
	if not bantime or bantime < -1 then
		bantime = 10000 -- 10 sec :)
	end
	bantime = tonumber(bantime)
	if bantime == -1 then
		return db.query("INSERT INTO `alphaserv`.`bans` (`id`, `reason`, `expire`, `ip`, `by_ip`) VALUES (NULL, "..db.escape(reason)..", "..db.escape(bantime)..", "..db.escape(ip)..", "..db.escape(admin_ip)..");")
	else
		return db.query("INSERT INTO `alphaserv`.`bans` (`id`, `reason`, `expire`, `ip`, `by_ip`) VALUES (NULL, "..db.escape(reason)..", "..db.escape(os.time()+bantime)..", "..db.escape(ip)..", "..db.escape(admin_ip)..");")
	end
end


server.event_handler("connecting", function(cn, hostname, name, password, reserved_slot)
	local ip = server.player_ip(cn)
	local result = db.query('SELECT id, reason, expire,  ip, by_ip FROM `bans` WHERE `ip` = '..db.escape(ip)..';')
	if ( result == {} ) or ( not result[1] ) then
		debug.write(-1, ip.." is not banned")
		--not banned
		return
	elseif tonumber(result[1]['expire']) < os.time() and not tonumber(result[1]['expire']) == -1 then
		db.query("DELETE FROM `alphaserv`.`bans` WHERE `bans`.`id` = "..result[1]['id']) -- clean up
		--not banned 2
		return
	end
	debug.write(-1, ip.." is banned: "..tostring(result[1][2]))
	server.sleep(3000, function()
		if not priv.has(cn, priv.ADMIN) then
			messages.warning(-1, {cn}, "red<==================================>", true)
			messages.warning(-1, {cn}, "red<=> orange<YOU> red<are currently> orange<BANNED>red<.>", true)
			messages.warning(-1, {cn}, "red<= becouse of >orange<"..messages.escape(tostring(result[1]["reason"]))..">", true)
			messages.warning(-1, {cn}, "red<= if you think we made a mistake>", true)
			messages.warning(-1, {cn}, "red<= please contact us.>", true)
			messages.warning(-1, {cn}, "red<==================================>", true)
			server.sleep(1000, function()
				server.disconnect(cn, server.DISC_KICK, false)
			end)
		else
			messages.warning("ban", {cn}, "red<you> are banned but you are not kickd becouse of your orange<admin>", true)
		end
	end)
end)

local function cleanup()
	local result = db.query('SELECT id, reason, expire,  ip, by_ip FROM `bans`;')
	if ( result == {} ) or ( not result[1] ) then
		debug.write(-1, "nobody is banned so nothing to clean")
		return
	end
	for i, row in pairs(result) do
		if tonumber(row['expire']) < os.time() and not tonumber(result[1]['expire']) == -1 then
			--time to clean
			db.query("DELETE FROM `alphaserv`.`bans` WHERE `bans`.`id` = "..row['id']) -- clean up
			print("unbanning ip: "..row["ip"])
		end
	end
	print("cleaned up ban list")
end

server.event_handler("kick_request", function(admin_cn, admin_name, bantime, target, reason)
	if priv.get(admin_cn) > priv.get(target) then
		cleanup()
		if (not bantime) or (not reason) then
			server.disconnect(target, server.DISC_KICK, false)
		end
		if not priv.has(admin_cn, priv.ADMIN) then
			server.disconnect(target, server.DISC_KICK, false) --only disconnect if kicked by an non admin
			return
		else
			server.kick(target, admin_cn, reason, bantime)		
		end
	else
		messages.warning("kick", {admin_cn}, config.get("too_high_priv"), true)
		messages.warning("kick", {target}, string.format(config.get("tried_to_kick"), admin_cn), true)
	end
end)

server.event_handler("started", function()
    
    cleanup()
    -- Don't run on server reload
    if server.uptime > 1 then return end 
	
	local bancount = #db.query('SELECT id, reason, ip, by_ip FROM `bans`;')
    
    if bancount > 0 then
        print(string.format("Ban count: %i", bancount))
    end
end)


