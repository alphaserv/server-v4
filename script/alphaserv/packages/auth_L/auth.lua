module("auth", package.seeall)

preferences.new("auth::auto_give_privs", true)
preferences.new("auth::auto_setmaster", false)

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


local authmodules = {}


function add_module(name, instance)
	authmodules[name] = instance
end

function checkall(name, ...)
	for i, module in pairs(authmodules) do
		local ret = pack(module[name](module, ...)) --should return: found_something, ...
		
		if ret[1] == true then
			table.remove(ret, 1)
			return unpack(ret)
		end
	end
	
	log_msg(LOG_ERROR, "could not find any module for "..name)
end


if not alpha.standalone then

	server.event_handler("setmaster", function(cn, password, set)
		local user = user_from_cn(cn)

		log_msg(LOG_INFO, "Setmaster event: " % { cn, password, set })			

		if set == 0 then
			log_msg(LOG_INFO, "%(1)s (%(2)i) tried to logout" % { user:name(), user.cn })			
			
			--checkall("auth", user, password) TODO
			return
		elseif set == 1 then
			--TODO
			log_msg(LOG_INFO, "%(1)s (%(2)i) tried to claim master" % { user:name(), user.cn })
			return
		end
	
		local result, messages_table, meta = checkall("auth", user, password)
		
		meta = meta or {}
		
		log_msg(LOG_INFO, "%(1)s (%(2)i) tried to auth (result=%(3)i)" % { user:name(), user.cn, tonumber(result or 0)or 0 })
		
		if type (messages_table) ~= "table" then
			messages_table = {messages_table}
		end
		
		if result then
			if not meta.nomsg then
				messages.load("auth", "success", { default_message = "green<name<%(1)i>> authenticated" })
					:format(user.cn)
					:send()
			end
			
			if user:preference("auth::auto_give_privs") then
				if user:has_permission("auth::be::admin") then
					server.set_invisible_admin(user.cn)				
				elseif user:has_permission("auth::be::master") then
					server.set_invisible_master(user.cn)
				elseif not priv_present() and user:preference("auth::auto_setmaster") then
					server.setmaster(user.cn)
				end
			end

			user:check_locks()
		else
			if not meta.nomsg then
				messages.load("auth", "fail", { default_message = "Could not authenticate green<name<%(1)i>>" })
					:format(user.cn)
					:send(user.cn, true)
			end
		end
			
		for i, msg in pairs(messages_table) do
			messages.load("auth", "result", { default_message = "auth: %(1)s" })
				:unescaped_format(msg)
				:send(user.cn, true)
		end
	end)
	
	server.event_handler("connect", function(cn)
		local user = user_from_cn(cn)
		
		server.sleep(1000, function()
			checkall("reserved_name", user)
		end)
	end)
	
	server.event_handler("rename", function(cn)
		local user = user_from_cn(cn)
		user:check_locks()
		checkall("reserved_name", user)
	end)
end
