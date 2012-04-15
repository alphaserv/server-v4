
module("stats", package.seeall)

require "geoip"

local defaults = {
	name = "unnamed",
	username = "",
	
	ip = nil,
	iplong = nil,
	
	team = "",
	
	country = "",
	
    frags = 0,
    deaths = 0,
    suicides = 0,
    
    misses = 0,
    shots = 0,
    hits_made = 0,
    hits_get = 0,
    
    tk_made = 0,
    tk_get = 0,
	
	flags_returned = 0,
	flags_stolen   = 0,
	flags_gone     = 0,
	flags_scored   = 0,
	total_scored   = 0,
	
	damage = 0,
	damagewasted = 0,
	accuracy = 0,
	
	timeplayed = 0,
}

local reset_stats = {
	"team",
	"frags",
	"suicides",
	"misses",
	"shots",
	"hits_made",
	"hits_get",
	"tk_made",
	"tk_get",
	"flags_returned",
	"flags_stolen",
	"flags_gone",
	"flags_scored",
	"total_scored",
	"damage",
	"damagewasted",
	"accuracy",
	"timeplayed"
}

function get_init_stats(cn)
	local ip = server.player_ip(cn)
	return {
		name = server.player_displayname(cn),
		ip = ip,
		iplong = server.player_iplong(cn),
		country = "somewhere" --geopi.ip_to_country(ip)
	}
end

--where we save the user's info
user_obj.stats = {}

--reset on mapchange
user_obj.reset_stats = function(self)
	self:update_stat("team", "set", server.player_team(self.cn))
	
	for i, stat in pairs(reset_stats) do
		self.stats[stat] = defaults[stat]
	end
end

--on connect
user_obj.init_stats = function(self)
	self.stats = {}
	self:reset_stats()
	
	for name, value in pairs(get_init_stats(self.cn)) do
		self.stats[name] = value
	end
end

local init = user_obj.__init
user_obj.__init = function(self, ...)
	init(self, ...)
	self:init_stats()
end

--update 1 stat variable
user_obj.update_stat = function(self, name, type, value)
	if type == "set" then
		self.stats[name] = value
	elseif type == "add" then
		if not value then
			value = 1
		end
		
		self.stats[name] = self.stats[name] + value
	elseif type == "sub" then
		if not value then
			value = 1
		end
		
		self.stats[name] = self.stats[name] - value
	end
	
	return self
end

--get 1 stat variable
user_obj.get_stat = function(self, name)
	return self.stats[name]
end


server.event_handler("maploaded", function(cn)
	user_from_cn(cn):reset_stats()
end)

server.event_handler("teamkill", function(cn, target_cn)
	user_from_cn(cn):update_stat("tk_made", "add")
	user_from_cn(target_cn):update_stat("tk_get", "add")
end)

server.event_handler("frag", function(target_cn, cn)
	user_from_cn(cn):update_stat("frags", "add")
	user_from_cn(target_cn):update_stat("deaths", "add")
end)

server.event_handler("shot", function(cn, gun, hit)
	local user = user_from_cn(cn)
	user:update_stat("shots", "add")
	
	print(table_to_string(user))

	if tostring(hit)=="1" then
		user_from_cn(cn):update_stat("hits_made", "add")
	else
		user_from_cn(cn):update_stat("misses", "add")
	end
end)

server.event_handler("suicide", function(cn)
	user_from_cn(cn):update_stat("suicides", "add")
end)

server.event_handler("takeflag", function(cn, team)
	user_from_cn(cn):update_stat("flags_stolen", "add")
	user_from_cn(cn):update_stat("flagholder", "set", true)

	obj_user({not_in_team = team, spectator = false}):foreach(update_stat, "flags_gone", "add")
end)

server.event_handler("dropflag", function(cn, team)
	user_from_cn(cn):update_stat("flagholder", "set", false)
end)

server.event_handler("scoreflag", function(cn, team)
	user_from_cn(cn):update_stat("flags_scored", "add")
	user_from_cn(cn):update_stat("flagholder", "set", true)

	obj_user({not_in_team = team, spectator = false}):foreach(update_stat, "total_scored", "add")
end)

server.event_handler("returnflag", function(cn, team)
	user_from_cn(cn):update_stat("flags_returned", "add")
end)

server.event_handler("damage", function(cn, actorcn, damage, gun)
	user_from_cn(cn):update_stat("hits_get", "add")
end)

--server.event_handler("rename", function(cn, oldname, newname)
--	nl.updatePlayer(cn, "name", newname, "set")
--end)

server.event_handler("reteam", function(cn, oldteam, newteam)
	user_from_cn(cn):update_stat("team", "set", newteam)
end)

server.event_handler("spectator", function(cn, val)
	user_from_cn(cn):update_stat("playing", "set", val == 0)
end)
