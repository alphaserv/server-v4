--[[!
	File: script/alphaserv/core/user.lua

	About: Author
		Killme

	About: Copyright
		Copyright (c) 2012 Alphaserv project

	About: Purpose
		This file manages user objects which are used to store user-data as an object.

]]

module("as.user", package.seeall)

require "class"
require "as.filters"
require "as.userlist"
require "as.team"

local users = {}

function getList()
	return users
end

function getUser(cn)
	if not users[cn] then
		error("Invalid cn")
	end
	
	return users[cn]
end

User = newclass("User")

User.accessCache = {}

User.userId = -1

User.authLock = nil

User.cn = -1

function User:can(accessNode)
	error("not implemented")
--[[
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
	end]]
end

function User:checkPassword(password, check)
	return crypto.tigersum(
		string.format("%i %i %s", self:getCn(), self:getSessionId(), password)
	) == check
end

function User:authorize(userEntity)
	self.userId = userEntity.id
	--!TODO copy more vars
	
	if self.removeSpectatorLock and self.authLock then
		self:removeSpectatorLock(self.authLock)
		self:checkSpectatorLocks()
	end
	
	self:initAccess()
end

function User:getCn()
	return self.cn
end

function User:getSessionId()
	return as.server.player_sessionid(self.cn)
end

function User:reloadAccess()
	self.accessCache = {}
end

function User:setCn(cn)
	self.cn = cn
end

function User:isAuthorised()
	return self.userId ~= -1
end

function User:sendRawMessage(msg)
	as.server.player_msg(self.cn, msg)
end

function User:kick(...)
	return as.server.kick(self.cn, ...)
end

function User:disconnect(...)
	return as.server.disconnect(self.cn, ...)
end

function User:getName()
	return as.server.player_name(self.cn)
end

function User:getDisplayName()
	return as.server.player_displayname(self.cn)
end

function User:getTeamName()
	return as.server.player_team(self.cn)
end

function User:getPrivName()
	return as.server.player_priv(self.cn)
end

function User:getPriv()
	return as.server.player_priv_code(self.cn)
end

function User:getId()
	as.server.player_id(self.cn)
end

function User:getPing()
	return as.server.player_ping(self.cn)
end

function User:getLag()
	return as.server.player_lag(self.cn)
end

function User:getIp()
	return as.server.player_ip(self.cn)
end

function User:getIpLong()
	as.server.player_iplong(self.cn)
end

function User:getStatusName()
	return as.server.player_status(self.cn)
end

function User:getStatus()
	return as.server.player_status_code(self.cn)
end

function User:getFrags()
	return as.server.player_frags(self.cn)
end

function User:getFlagScores()
	return as.server.player_score(self.cn)
end

function User:getDeaths()
	return as.server.player_deaths(self.cn)
end

function User:getSuicides()
	return as.server.player_suicides(self.cn)
end

function User:getTeamkills()
	return as.server.player_teamkills(self.cn)
end

function User:getDamage()
	return as.server.player_damage(self.cn)
end

function User:getDamageWasted()
	return as.server.player_damagewasted(self.cn)
end

function User:getMaxHealth()
	return as.server.player_maxhealth(self.cn)
end

function User:getHealth()
	return as.server.player_health(self.cn)
end

function User:getGun()
	return as.server.player_gun(self.cn)
end

function User:getHits()
	return as.server.player_hits(self.cn)
end

function User:getMisses()
	return as.server.player_misses(self.cn)
end

function User:getShots()
	return as.server.player_shots(self.cn)
end

function User:getServerAccuracy()
	return as.server.player_accuracy(self.cn)
end

function User:getClientAccuracy()
	return as.server.player_accuracy2(self.cn)
end

function User:getAccuracy()
	return self:getServerAccuracy()
end

function User:getTimeTrial()
	return as.server.player_timetrial(self.cn)
end

function User:getTimePlayed()
	return as.server.player_timeplayed(self.cn)
end

function User:isWinner()
	return as.server.player_win(self.cn) and true or false
end

function User:slay()
	return as.server.player_slay(self.cn)
end

function User:changeTeam(team)
	team = type(team) == "table" and team  or {name = team}
	as.server.changeteam(self.cn,	team.name)
end

function User:getHostedBots()
	return as.server.player_bots(self.cn)
end

function User:getRank()
	return as.server.player_rank(self.cn)
end

function User:isBot()
	return as.server.player_isbot(self.cn) and true or false
end

function User:getMapCrc()
	return as.server.player_mapcrc(self.cn)
end

function User:getConnectionTime()
	return as.server.player_connection_time(self.cn)
end

function User:forceSpec()
	return as.server.force_spec(self.cn)
end

function User:spec()
	return as.server.spec(self.cn)
end

function User:unSpec()
	return as.server.unspec(self.cn)
end

function User:getPos()
	return as.server.player_pos(self.cn)
end

function User:setAdmin()
	return as.server.setadmin(self.cn)
end

function User:setMaster()
	return as.server.setmaster(self.cn)
end

function User:setInvisibleAdmin()
	
end



--Old
User.set_invadmin	= function(self)	return as.server.set_invisible_admin(self.cn) end
User.set_invisible_admin=function(self) return as.server.set_inivisible_admin(self.cn) end

function getCnFromSid(session_id)
	for i, cn in pairs(players.all) do
		if session_id == as.server.player_sessionid(cn) then
			return cn
		end
	end
	
	return -1
end

function init()
	as.server.onConnecting:addListner(function(cn)
		print("creating user")
		local user = User(cn)
		user:setCn(cn)
		users[cn] = user
	end)

	--!TODO store variables in cache
	as.server.onDisconnect:addListner(function(cn)
		print("destroying user")
		users[cn] = nil
	end)
end
