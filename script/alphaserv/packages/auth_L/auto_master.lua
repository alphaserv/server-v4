module("auth.auto_master", package.seeall)

local auto_master = alpha.settings.new_setting("auto_master", true, "let the first one to connect become master automatically.\nThis may attract noobs kicking everyone.")
local auto_master_privs = alpha.settings.new_setting("auto_master_rules", {"spec_player", "unspec_player", "mastermode_veto", "mastermode_locked"}, "Overriding rules for automatically authed masters.")

server.event_handler("connect", function (cn)
	if #players.all() == 1 and auto_master:get() then
		local user = user_from_cn(cn)
		
		server.sleep(1000, function()
			if not user:check() or user.user_id ~= -1 then --user already disconnected
				return
			end
			
			for i, rule in pairs(auto_master_privs:get()) do
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
					user.user_overrides[rule] = { [-1] = true}
				end
			end
		end)
	end
end)
