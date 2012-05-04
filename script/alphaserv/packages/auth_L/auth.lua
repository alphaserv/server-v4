module("auth", package.seeall)

--util
function priv_present()
	for i, player in pairs(server.players()) do
		if server.player_priv_code(cn) ~= server.PRIV_NONE then
			return true
		end
	end
	
	return false
end

--abstract
auth_object = class.new(nil, {
	auth = function(self, player, password) return false end,
	try_claim_master = function(self, player) return false end,
	logout = function(self, player) return false end,
	reserved_name = function(self, player) return false end,
})

acl_object = class.new(nil, {
	has_permission = function(self, user, name, id) return true end
})

local authmodules = {}
local aclmodules = {}

function add_module(name, instance)
	authmodules[name] = instance
end

function add_acl_module(name, instance)
	aclmodules[name] = instance
end

function checkall(name, ...)
	for i, module in pairs(authmodules) do
		local ret = pack(module[name](module, ...)) --should return: found_something, ...
		
		if ret[1] == true then
			table.remove(ret, 1)
			return unpack(ret)
		end
	end
	
	error("could not find any module")
end

function checkaclall(name, ...)
	for i, module in pairs(aclmodules) do
		local ret = pack(module[name](module, ...))
		
		if ret[1] == true then
			table.remove(ret, 1)
			return unpack(ret)
		end
	end
	
	error("could not find any module")
end


if not alpha.standalone then
	user_obj.has_permission = function(self, name, id)
		return checkaclall("has_permission", user, name, id or -1)
	end

	server.event_handler("setmaster", function(cn, password, set)
		local user = user_from_cn(cn)

		log_msg(LOG_INFO, "Setmaster event: " % { cn, password, set })			

		if set == 0 then
			log_msg(LOG_INFO, "%(1)s (%(2)i) tried to logout" % { server.player_name(user.cn), user.cn })			
			
			checkall("auth", user, password)
			return
		elseif set == 1 then
			log_msg(LOG_INFO, "%(1)s (%(2)i) tried to claim master" % { server.player_name(user.cn), user.cn })
			return
		end
	
		local result, messages = checkall("auth", user, password)
			
		log_msg(LOG_INFO, "%(1)s (%(2)i) tried to auth (result=%(3)i)" % { server.player_name(user.cn), user.cn, tonumber(result or 0) })
			
		if result then
			--TODO: use message framework
			server.player_msg(user.cn, "authed")
			user:check_locks()
		else
			server.player_msg(user.cn, "could not log you in")
		end
			
		for i, msg in pairs(messages) do
			server.player_msg(user.cn, msg)
		end
	end)
	
	server.event_handler("connecting", function(cn, host, name, hash, reserved_slot)
		if hash == "" then return end
		local user = user_from_cn(cn)
		
		local result, messages = checkall("auth", user, password)
			
		log_msg(LOG_INFO, "%(1)s (%(2)i) tried to auth (result=%(3)i)" % { server.player_name(user.cn), user.cn, tonumber(result) })
			
		if result then
			--TODO: use message framework
			server.player_msg(player.cn, "authed")
			user:check_locks()
		else
			server.player_msg(player.cn, "could not log you in")
		end
			
		for i, msg in pairs(messages) do
			server.player_msg(player.cn, messages)
		end
	end)
	
	server.event_handler("mapload", function(cn)
		local user = user_from_cn(cn)
		
		if not user.NP_mapload then --only  check 1 time per user
			checkall("reserved_name", user)
		end
		
		user.NP_mapload = true
	end)
	
	server.event_handler("rename", function(cn)
		checkall("reserved_name", user_from_cn(cn))
	end)
	
	
	admin_pass_auth = class.new(auth_object, {
	
	})
end
