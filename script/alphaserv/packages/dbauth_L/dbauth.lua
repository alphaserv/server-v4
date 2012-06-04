module("dbauth", package.seeall)

--local override_privs = alpha.settings.new_setting("user_rules", {""}, "Overriding rules for as database authed users.")

auth_obj = class.new(auth.auth_object, {
	
	clantags = {},
	clantags_loaded = false,
	
	init_clantags = function(self)
		if self.clantags_loaded == true then return end
		local res = alpha.db:query("SELECT id, tag, clan_id, status FROM clan_tag WHERE status = 2"):fetch()
		
		self.clantags = {}
		for i, row in pairs(res) do
			log_msg(LOG_INFO, "Adding tag %(1)s to the clantag list" % { row.tag })
			self.clantags[row.id] = row.tag
		end
		
		res = nil
		
		server.sleep(30 * 60000, function()
			self:init_clantags()
		end)
		
		self.clantags_loaded = true
	end,
	
	
	_getname = function(self, name)
		local namerow = alpha.db:query("SELECT id, user_id, name, status FROM names WHERE name = ? AND status = 2;", name):fetch()
		
		if not namerow or not namerow[1] or not namerow[1].user_id then
			return false--no name found in db
		end
		
		return true, namerow[1]
	end,

	clanreserved = function(self, name)
		self:init_clantags()
		
		log_msg(LOG_INFO, "Checking clantags for name %(1)s" % {name})
		
		for id, tag in pairs(self.clantags) do
			if string.find(name, tag) then
				log_msg(LOG_INFO, "clantag match %(1)s on %(2)s" % { tag, name })
				return true
			end
		end
		
		return false
	end,
	
	namereserved = function(self, name)
		local a, b = self:_getname(name)
		
		if a then
			return true
		else
			return false
		end
	end,
	
	_lock = function(self, user, namereserved, clanreserved)
		reserved_lock = class.new(spectator.lock.lock_obj, {
			is_locked = function(_, user)
				local name, row = self:_getname(string.lower(user:name()))
				
				if name == true and row.id == user.user_id then
					return false
				elseif name == true then
					return true
				else
					return false
				end
			end,
	
			try_unspec = function(self, player)
				return self:is_locked()
			end,
	
			unlock = function(self, player)

			end
		})

		if namereserved then
			user:add_speclock("protect:name", reserved_lock())
		end
		
		if clanreserved then
			user:add_speclock("protect:clantag", reserved_lock())
		end
	end,
	
	reserved_name = function(self, user)
		local namereserved = self:namereserved(string.lower(user:name()))
		local clanreserved = self:clanreserved(string.lower(user:name()))
		if namereserved or clanreserved then
			self:_lock(user, namereserved, clanreserved)
			return true, true, {"You are using a reserved name / clantag, please rename or authenticate"}
		end
	end,
	
	logout = function(self, user)
		if user.authedwith and user.authedwith == "dbauth" then
			self:reserved_name(user)
		else
			return false
		end		
	end,

	auth = function(self, user, hash)
	
		local res = alpha.db:query([[
			SELECT
				user.id,
				user.username,
				user.ingame_password,
				user.email,
				user.hashing_method,
				user.web_password,
				user.salt,
				user.status
			FROM
				user,
				names
			WHERE
				user.id = names.user_id
			AND
				names.name = ?;]], string.lower(user:name()))
				
		if res:num_rows() < 1 then
			return false
		end
		
		local row = res:fetch()
		row = row[1]
		
		if user:comparepassword(hash, row.ingame_password) then
			user.authedwith = "dbauth"
			user:auth(row.id)
		
			--spectator lock enabled
			if user.check_locks then
				user:remove_speclock("protect:clantag")
				user:remove_speclock("protect:name")
				user:check_locks()
			end
	
			server.sleep(1, function()
				messages.load("dbauth", "success", { default_message = "green<name<%(1)i>> |have|has| authenticated as magenta<%(3)s> (%(2)s)" })
					:unescaped_format(user.cn, "green<TITLE>", row.username)
					:send()
			end)
	
			return true, true, {"successfully authed"}, {nomsg = true}
		else
			return true, false, {"Password incorrect"}
		end

		--[[
		--overrides
		for i, rule in pairs(override_privs:get()) do
			i = tostring(i)
				
			--rule with a specific value
			if i:find("$(.*)") then
					
				--rule with an id
				if i:find("$(.-)|(.*)") then
					local rule, id = i:find("$$(.-)|(.*)")
						
					user.user_overrides[rule][tonumber(id)] = rule
				else
					local rule = i:find("$$(.*)")
					user.user_overrides[rule][-1] = true
				end
					
			--simple rule without id or specific value
			else
				user.user_overrides[rule] = { [-1] = true }
			end
		end]]
		
	end,
})


auth.add_module("dbauth", auth_obj())

