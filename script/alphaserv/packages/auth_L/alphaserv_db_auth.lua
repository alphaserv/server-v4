module("auth.alphaserv_dbauth", package.seeall)

local override_privs = alpha.settings.new_setting("user_rules", {""}, "Overriding rules for as database authed users.")

alphaserv_db_auth_obj = class.new(auth.auth_obj, {
	
	clantags = {},
	clantags_loaded = false,
	
	init_clantags = function(self)
		if self.clantags_loaded then return end
		local res = alpha.db:query("SELECT id, tag FROM clans"):fetch()
		
		for i, row in pairs(res) do
			log_msg(LOG_INFO, "Adding tag %(1)s to the clantag list" % { row.tag })
			self.clantags[row.id] = row.tag
		end
		
		res = nil
		
		self.clantags_loaded = true
	end,
	
	
	_getname = function(self, name)
		local namerow = alpha.db:query("SELECT id, name, user_id FROM names WHERE name = ?;", name):fetch()
		
		if not namerow or not namerow[1] or not namerow[1]['user_id'] then
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

	onsetmaster = function(self, cn, hash, while_connecting)
	
		local name = server.player_name(cn)
		
		local exists, namerow = self:_getname(name)
		
		--name not found
		if not exists then
			return false
		end
		
		userrow = alpha.db:query("SELECT name, email, pass, priv FROM users WHERE id = ?;", namerow.user_id):fetch()
			
		if not userrow or not userrow[1] then
			server.sleep(1, function() error('matching user not found, please check the database.') end)
			return false
		else
			userrow = userrow[1] 
		end

		--password incorrect
		if hash ~= server.hashpassword(cn, userrow["pass"]) then
			--server.msg(hash.." ~= "..userrow.pass)
			return false
		end
		
		local user = user_from_cn(cn)
		user:auth(userrow.id)
		
		--spectator lock enabled
		if user.check_locks then
			user:remove_speclock("protect:clantag")
			user:remove_speclock("protect:name")
			user:check_locks()
		end

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
				user.user_overrides[rule][-1] = true
			end
		end
		
	end,
})

auth.add_module("alphaserv_db_auth", alphaserv_db_auth_obj)

