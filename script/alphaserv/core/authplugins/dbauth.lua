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
		print("name: ", tostring(obj.usercache[name]))
	
		local namerow
		if not alpha.auth.usecaching or not obj.namecache[name] then
			namerow = alpha.db:query("SELECT id, name, user_id FROM names WHERE name = ?;", name):fetch()
			
			if not namerow or not namerow[1] or not namerow[1]['user_id'] then
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
		
		local exists, namerow = obj:_getname(name)
		
		local userrow
		if not alpha.auth.usecaching or not obj.usercache[name] then
			userrow = alpha.db:query("SELECT `name`, `email`, `pass`, `priv` FROM `users` WHERE  `id` = ?;", namerow.user_id):fetch()
			
			if not userrow or not userrow[1] then
				server.sleep(1, function() error('matching user not found') end)
				return false
			else
				obj.usercache[name] = userrow[1]
			end
		end

		userrow = obj.usercache[name]
		
		if pass ~= server.hashpassword(cn, userrow["pass"]) then
			alpha.log.message("SETMASTER: %s failed to authenticate", alpha.log.name(cn))
			return false
		end
		
		print("AUTH SUCCESS!!!!!!!!!!!! OMG")
		alpha.auth.success(cn, userrow.priv)
		
	end,
	
	clanreserved = function(obj, name)
		print("checking name for clan..."..name)
		for i, row in pairs(obj.clancache) do
			if string.find(name, row) then
				return true, "FORCE"
			end
		end
		print("not reserved!")
	end,
	
	namereserved = function(obj, name)
		print("checking name..."..name)
		local a, b = obj:_getname(name)
		if a then return true, "FORCE" end
		print("not reserved!")
	end,
	
	cleanup = function (obj)
		--clean up cache
		obj.namecache = nil
		obj.usercache = nil
		obj.clancache = nil
		--just for testing these are already filled in :)
		obj.namecache = { "|TEST|" }
		obj.usercache = { ["~UT~killme_nl"] = { name = "KILL ME", "A_PASS", 10000000} }
		obj.clancache = { "_nl"}
		
		--TODO: update clanlist here
	end,
}
