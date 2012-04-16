module("protect", package.seeall)

local instance = auth.alphaserv_dbauth.alphaserv_db_auth_obj()

function should_auth(cn)
	local user = user_from_cn(cn)
	local name = user:name()
	
	if instance:namereserved(name) or instance:clanreserved(name) then
		--already authed
		local name, row = instance:_getname(name)
		if name == true and row.id == user.user_id then
			return false
		end
		
		return true
	end
	
	return false
end

reserved_lock = class.new(spectator.lock.lock_obj, {
	is_locked = function(self, player)
		return should_auth(player.cn)
	end,
	
	try_unspec = function(self, player)
		return should_auth(player.cn)
	end,
	
	unlock = function(self, player)
		server.msg(player:name().." authed!")
	end
})

function check(cn)
	local user = user_from_cn(cn)
	local name = user:name()
	
	if instance:namereserved(name) then
		user_from_cn(cn):add_speclock("protect:name", reserved_lock())
	elseif instance:clanreserved(name) then
		user_from_cn(cn):add_speclock("protect:clan", reserved_lock())
	end
end

server.event_handler("connect", check)
server.event_handler("rename", check)
