module("auth.alphaserv_dbauth", package.seeall)

local override_privs = alpha.settings.new_setting("user_rules", {""}, "Overriding rules for as database authed users.")

alphaserv_db_auth_obj = class.new(auth.auth_obj, {
	
	clantags = {}
	
	__init = function(self)
	
	end,
	
	
	_getname = function(self, name)
		local namerow = alpha.db:query("SELECT id, name, user_id FROM names WHERE name = ?;", name):fetch()
		
		if not namerow or not namerow[1] or not namerow[1]['user_id'] then
			return false--no name found in db
		else
			self.namecache[name] = namerow[1]
		end
		
		return true, namerow
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
		if pass ~= server.hashpassword(cn, userrow["pass"]) then
			return false
		end
		
		alpha.auth.success(cn, userrow.priv)

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

add_module("alphaserv db", alphaserv_db_auth_obj)

