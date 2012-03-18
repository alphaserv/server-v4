alpha.settings.init_setting("dbauth_enabled", true, "bool", "allow users to auth with an account.\nOnly users renamed to a linked name wich have an account on this server can login.")


alpha.auth.plugins.dbauth = {

	namecache = {},
	usercache = {},
	clancache = {},
	
	init = function(obj)
		if alpha.settings:get("dbauth_enabled") then
			obj.enabled = true
		end
		obj:cleanup()
	end,
	
	_getname = function(obj, name)
		local namerow
		if not alpha.auth.usecaching or not obj.namecache[name] then
			namerow = alpha.db:query("SELECT id, name, user_id FROM  `names` WHERE  `name` = ?;", name):fetch()
			
			if not namerow or not namerow[1] or not res[1]['user_id'] then
				return false--no name found in db
			else
				obj.namecache[name] = namerow[1]
			end
		else
			namerow = obj.namecache[name]
		end
		return true, namerow
	end,
	
	OnSetmaster = function(obj, cn, pass)
		alpha.auth.logout(cn)
		
		local name = server.player_name(cn)
		
		local namerow = obj:_getname(name)
		
		local userrow
		if not alpha.auth.usecaching or not obj.usercache[name] then
			userrow = alpha.db:query("SELECT `name`, `email`, `pass`, `priv` FROM `users` WHERE  `id` = ?;", user_id):fetch()[1]
			
			if not userrow or not userrow[1] or not userrow[1]['pass'] then
				server.sleep(1, function() error('matching user not found') end)
				return false
			else
				obj.usercache[name] = userrow[1]
			end
		else
			userrow = obj.usercache[name]
		end
		
		if pass ~= server.hashpassword(cn, userrow[1]["pass"]) then
			alpha.log.message("SETMASTER: %s failed to authenticate", alpha.log.name(cn))
			return false
		end
		
		alpha.auth.success(cn, userrow[1].priv)
		
	end,
	
	clanreserved = function(obj, name)
		for i, row in pairs(obj.clancache) do
			if string.find(name, row) then
				return true
			end
		end
	end,
	
	namereserved = function(obj, name)
		return obj:_getname(name)
	end,
	
	cleanup = function (obj)
		--clean up cache
		obj.namecache = nil
		obj.usercache = nil
		obj.clancache = nil
		--just for testing these are already filled in :)
		obj.namecache = { "|TEST|" }
		obj.usercache = { ["~UT~killme_nl"] = { name = "KILL ME", "A_PASS", 10000000} }
		obj.clancache = {}
		
		--TODO: update clanlist here
	end,
}
