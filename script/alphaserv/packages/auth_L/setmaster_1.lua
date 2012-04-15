module("auth.setmaster_1", package.seeall)

local master_privs = alpha.settings.new_setting("master_rules", {"spec_player", "unspec_player", "mastermode_veto", "mastermode_locked", "kick"}, "Overriding rules for setmaster 1 authed masters.")


setmaster1_auth_obj = class.new(auth.auth_obj, {
	onsetmaster_1 = function(self, cn)
		if auth.priv_present() then
			return false			
		end
		
		local user = user_from_cn(cn)
		
		for i, rule in pairs(master_privs:get()) do
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
		
		server.setmaster(cn)
		
		return true
	end,
})

auth.add_module("setmaster_1", setmaster1_auth_obj)
