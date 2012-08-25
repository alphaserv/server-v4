--[[!
	File: script/alphaserv/core/user.lua

	About: Author
		Killme

	About: Copyright
		Copyright (c) 2012 Alphaserv project

	About: Purpose
		This file manages user objects which are used to store user-data as an object.

]]

module("alpha.core.user", package.seeall)

require "class"

local users = {}

local VarStorageClass = newclass("VarStorage")

VarStorageClass.types = {
	"cn",		--store while connected
	"session",  --store while using the same name and ip
	"ip",		--store while using the same ip
	"user"		--store on the user object
}

VarStorageClass.cache = {}

function VarStorageClass:addVar(name, type, default)

end

local userList = newclass("userList")

userList.users = {}

function userList:filter(filter, attr, reverse)
	local attr = attr or {}
	local reverse = reverse and true
	
	local f = userFilter.find(filter)
	f:init(attr)

	local newList = {}

	for i, user in pairs(self.users) do
		local res = f:match(user)
		if (res or reverse) and not (res and reverse) then
			table.insert(newList, user)
		end
	end
	
	self.users = newList
	
	return self
end

function userList:each(func)
	for i, user in ipairs(self.users) do
		func(i, user)
	end
	
	return self
end

local baseUser = newclass("userList")

baseUser.userEntity = false
baseUser.accessCache = {
--[[
	baseEntityId = {
		node = true, --allow
		node2 = false --deny
	}
]]
}

baseUser.user_id = -1
baseUser.loggedIn = false

function baseUser:can(accessNode, baseEntity)
	if not accessNode then
		error("accessNode is nil", 1)
	end

	local baseEntity = baseEntity or as:getServerEntity()
	
	if self.accessCache[baseEntity:getId()] and type(self.accessCache[baseEntity:getId()][accessNode]) == "boolean" then
		return self.accessCache[baseEntity:getId()][accessNode]
	else
		local res
		if self:authorized() then
			res = baseEntity:can(self:getEntity(), accessNode)
		end
		
		if type(res) == "nil" then
			res = baseEntity:canPublic(accessNode)
		end
		
		self.accessCache[baseEntity:getId()][accessNode] = res
		
		return res
	end
end

function baseUser:authorize(userEntity)
	self.userEntity = userEntity
	
	self:initAccess()
end

function baseUser:reloadAccess()
	self.accessCache = {}
end

function baseUser:var(name)

end

function baseUser:getVar(name)

end

function baseUser:login(userId)
	self.loggedIn = true
	self.userId = userId
end

function baseUser:logout()
	self.loggedIn = false
end

function baseUser:authorised()
	return self.loggedIn
end

local userClasses = {}
function extendUserClass(extention)
	for i, class in pairs(userClasses) do
		class[i] = class:extend(extention)
	end
end

function loadUserClass(class)

end

function unLoadUserClass(class)

end

local User = baseUser:subclass("User")

User.msg		= function(self, text)	return server.player_msg(self.cn, text) end
User.kick		= function(self, ...) 	return server.kick(self.cn, unpack(arg)) end
User.disconnect	= function(self, ...) 	return server.disconnect(self.cn, unpack(arg)) end
User.name		= function(self) 		return server.player_name(self.cn) end
User.displayname= function(self) 		return server.player_displayname(self.cn) end
User.team		= function(self) 		return server.player_team(self.cn) end
User.priv		= function(self) 		return server.player_priv(self.cn) end
User.priv_code	= function(self) 		return server.player_priv_code(self.cn) end
User.id			= function(self) 		return server.player_id(self.cn) end
User.ping		= function(self) 		return server.player_ping(self.cn) end
User.lag		= function(self) 		return server.player_lag(self.cn) end
User.ip			= function(self) 		return server.player_ip(self.cn) end
User.iplong		= function(self) 		return server.player_iplong(self.cn) end
User.status		= function(self) 		return server.player_status(self.cn) end
User.status_code= function(self) 		return server.player_status_code(self.cn) end
User.frags		= function(self) 		return server.player_frags(self.cn) end
User.score		= function(self) 		return server.player_score(self.cn) end
User.deaths		= function(self) 		return server.player_deaths(self.cn) end
User.suicides	= function(self) 		return server.player_suicides(self.cn) end
User.teamkills	= function(self) 		return server.player_teamkills(self.cn) end
User.damage		= function(self) 		return server.player_damage(self.cn) end
User.damagewasted	= function(self)	return server.player_damagewasted(self.cn) end
User.maxhealth	= function(self) 		return server.player_maxhealth(self.cn) end
User.health		= function(self) 		return server.player_health(self.cn) end
User.gun		= function(self) 		return server.player_gun(self.cn) end
User.hits		= function(self)		return server.player_hits(self.cn) end
User.misses		= function(self)		return server.player_misses(self.cn) end
User.shots		= function(self)		return server.player_shots(self.cn) end
User.accuracy	= function(self)		return server.player_accuracy(self.cn) end
User.accuracy2	= function(self) 		return server.player_accuracy2(self.cn) end
User.timetrial	= function(self) 		return server.player_timetrial(self.cn) end
User.timeplayed	= function(self) 		return server.player_timeplayed(self.cn) end
User.win		= function(self) 		return server.player_win(self.cn) end
User.slay		= function(self) 		return server.player_slay(self.cn) end
User.changeteam	= function(self,newteam)return server.changeteam(self.cn,newteam) end
User.bots		= function(self) 		return server.player_bots(self.cn) end
User.rank		= function(self) 		return server.player_rank(self.cn) end
User.isbot		= function(self) 		return server.player_isbot(self.cn) end
User.mapcrc		= function(self) 		return server.player_mapcrc(self.cn) end
User.connection_time	= function(self)return server.player_connection_time(self.cn) end
User.force_spec	= function(self)		return server.force_spec(self.cn) end
User.spec		= function(self)		return server.spec(self.cn) end
User.unspec		= function(self)		return server.unspec(self.cn) end
User.setadmin	= function(self)		return server.setadmin(self.cn) end
User.setmaster	= function(self)		return server.setmaster(self.cn) end
User.set_invadmin	= function(self)	return server.set_invisible_admin(self.cn) end
User.set_invisible_admin=function(self) return server.set_inivisible_admin(self.cn) end
User.pos		= function(self)		return server.player_pos(self.cn) end

loadUserClass(User)

function getCnFromSid(session_id)
	for i, cn in pairs(players.all) do
		if session_id == server.player_sessionid(cn) then
			return cn
		end
	end
	
	return -1
end

--[[!
	Function: OnConnect
	Connect event handler, creates an user instance and inserts it into the users table
		
	Parameters:
		cn - The cn of the player connecting
]]

function OnConnect(cn)
	users[cn] = user_obj(cn)
	users[cn]:set_cn(cn)
	
	--print("connect, table is now: "..table_to_string(users, true, true).." (added: "..table_to_string(users[cn], true, true)..")")
end

--[[!
	Function: OnDisconnect
	Executes the OnDisconnect event handler and removes the user from the table
		
	Parameters:
		cn - The cn of the player disconnecting
]]

function OnDisconnect(cn)
	--print("%(1)i disconnected" % {cn})
	users[cn]:OnDisconnect()
	users[cn] = nil
end

--print("init user events")
--server.event_handler("connect", OnConnect)
--server.event_handler("disconnect", OnDisconnect)

return {
	getCnFromSid = getCnFromSid,
	getUserList = function()
		return userlist(users)
	end
}
