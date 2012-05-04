module("dbauth", package.seeall)

--local override_privs = alpha.settings.new_setting("user_rules", {""}, "Overriding rules for as database authed users.")

auth_obj = class.new(auth.auth_object, {
	
	clantags = {},
	clantags_loaded = false,
	
	init_clantags = function(self)
		if self.clantags_loaded == true then return end
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

	auth = function(self, user, hash)
	
		local res = alpha.db:query([[
			SELECT
				users.name,
				users.email,
				users.pass,
				users.priv
			FROM
				users,
				names
			WHERE
				users.id = names.user_id
			AND
				names.name = ?;]], user:name())
				
		if res:num_rows() < 1 then
			return false
		end
		
		local row = res:fetch()
		row = row[1]
		
		if user:comparepassword(hash, row.pass) then
			user:auth(row.id)
		
			--spectator lock enabled
			if user.check_locks then
				user:remove_speclock("protect:clantag")
				user:remove_speclock("protect:name")
				user:check_locks()
			end
			return true, true, {"successfully authed"}
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

