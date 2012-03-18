alpha.auth.plugins.masterauth = {
	current = false,
	auth_name = -1,
	sid = -1,
	
	init = function(obj)
		auth.directory.server{
			id = "MASTER",
			hostname = "sauerbraten.org",
			port = 28787
		}
		
		auth.directory.domain{
			server = "MASTER",
			id = ""
		}
	end,
	
	unload = function(obj)

	end,

	OnAuthkey = function (obj, cn, user_id, domain, status)
		
		if status ~= auth.request_status.SUCCESS then
			messages.warning("auth", {cn}, config.get("auth:failed"), true)
			return
		end
		
		if alpha.auth.priv_present() then
			messages.warning("auth", {cn}, config.get("messages:priv_present"), true)
		end
		
		if server.player_priv_code(cn) == 0 then
			
			local name = server.player_name(cn)
			
			if banned[user_id] then --where does this come from?
				messages.warning("auth", {cn}, config.get("auth:banned"), true)
				return
			end
			
			if server.setmaster(cn) then
			
				obj.current = true
				obj.auth_name = user_id
            	obj.sid = server.player_sessionid(cn)
            	
            	messages.info("auth", {cn}, string.format(config.get("auth:authed"),cn,cn,alpha.masterauth.auth_name), true)
            	
            	alpha.log.message("%s(%i) claimed master as '%s'", name, cn, user_id)
	        else
    	        messages.warning("auth", {cn}, config.get("auth:no_master"), true)
    	    end
		else
			alpha.auth.fail("higher_priv_now")
		end
    end,
    
    OnConnect = function (obj, cn)
		if obj.current then
			obj.current = false
			
			for i, cn_ in pairs(players.all()) do
				if server.player_sessionid(cn_) == obj.sid then
					alpha.masterauth.current = true
					messages.info("auth", {cn}, string.format(config.get("auth:authed"),cn,cn,alpha.masterauth.auth_name), true)
				end
			end
		end
    end,
}
