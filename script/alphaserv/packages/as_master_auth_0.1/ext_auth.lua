module("ext_auth", package.seeall)

--local override_privs = alpha.settings.new_setting("user_rules", {""}, "Overriding rules for as database authed users.")

auth_obj = class.new(auth.auth_object, {
	
	clantags = {},
	names = {},
	
	init_clantags = function(self)
		self.clantags_loaded = true
		as_master.client.send_message("clans")
		as_master.client.handlers.add_clantag = function(tag)
			table.insert(self.clantags, tag)
		end
		
		self.init_clantags = function() end
	end,
	
	init_names = function(self)
		self.names_loaded = true
		
		as_master.client.send_message("names")
		as_master.client.handlers.add_name = function(name)
			self.names[name] = true
		end
		
		self.init_names = function() end
	end,

	clanreserved = function(self, name)
		self:init_clantags()
		
		log_msg(LOG_INFO, "Checking clantags for name %(1)s" % {name})
		
		for id, tag in pairs(self.clantags) do
			if string.find(name, tag.tag) then
				log_msg(LOG_INFO, "clantag match %(1)s on %(2)s" % { tag.tag, name })
				return true
			end
		end
		
		return false
	end,
	
	namereserved = function(self, name)
		self:init_names()
		
		return self.names[name] == true
	end,
	
	_lock = function(self, user, namereserved, clanreserved)
		reserved_lock = class.new(spectator.lock.lock_obj, {
			is_locked = function(_, _)
				name = user:name()
				if self:clanreserved(name) or self:namereserved(name) then
					if user.authedwith == "as_ext_auth" and user.ext_authname == user:name() then
						return false
					else
						return true
					end
				end
			end,
	
			try_unspec = function(self, player)
				return self:is_locked()
			end,
	
			unlock = function(self, player)
				server.msg(player:name().." authed!")
			end
		})

		if namereserved then
			user:add_speclock("ext:protect:name", reserved_lock())
		end
		
		if clanreserved then
			user:add_speclock("ext:protect:clantag", reserved_lock())
		end
	end,
	
	reserved_name = function(self, user)
		local namereserved = self:namereserved(user:name())
		local clanreserved = self:clanreserved(user:name())
		
		if namereserved or clanreserved then
			self:_lock(user, namereserved, clanreserved)
			return true, true, {"You are using a reserved name / clantag, please rename or authenticate"}
		end
		
		return true, false
	end,
	
	logout = function(self, user)
		if user.authedwith and user.authedwith == "as_ext_auth" then
			self:reserved_name(user)
			
			return true
		else
			return false
		end		
	end,

	auth = function(self, user, hash)
	
		user.finish_auth = function(user, success, key, extra)
			
			log_msg(LOG_INFO, "Auth resulted into: %(1)s" % {tostring(success) or "-?-", tostring(key) or "-?-"})
			
			if success then
				user.authedwith = "as_ext_auth"
				user.ext_authname = user:name()
				
				user.ext_key = key
				user.extinfo = extra
				
				user:remove_speclock("ext:protect:clantag")
				user:remove_speclock("ext:protect:name")
				user:check_locks()
				user:msg("Authentication successed!")
			else
				user:msg("Authentication failed!")
			end
		end
		
		--auth secret cn session_id hashed_password name
		as_master.client.send_message("auth "..as_master.client.key:get().." "..user.cn.." "..user.sid.." "..hash.." "..user:name())
		
		return true, true, {"Verifying ..."}
	end,
})


auth.add_module("dbauth", auth_obj())

as_master.client.handlers.auth = function(result, session_id, ...)
	for cn, user in pairs(alpha.user.users) do
		if user.sid == session_id then
			user:finish_auth(result, ...)			
			break
		end
	end
end

