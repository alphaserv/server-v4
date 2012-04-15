module("alpha.user", package.seeall)

users = {}

user_obj = class.new(nil, {
	sid = "",
	cn = -1,
	user_id = -1,
	
	_inited_groups = false,
	groups = {},
	user_overrides = {},
	
	__init = function(self, cn)
		self.sid = server.player_sessionid(cn)
		self.cn = cn
	end,
	
	check = function(self)
		if self.sid ~= server.player_sessionid(self.cn) then
			return false
		end
		
		return true
	end,

	load_groups = function(self)
		if self._inited_groups then
			return
		end
		
		if self.user_id ~= -1 then
			local res = alpha.db:query([[
				SELECT
					groups.group_id,
					groups.name
				FROM
					groups,
					groups_users
				WHERE
					groups.group_id = groups_users.group_id
				AND
					groups_users.user_id = ?
				
				]], self.user_id)
				
			self.groups = res:fetch()
		end		
	end,
	
	auth = function(self, user_id)
		self._inited_groups = false
		self.user_id = user_id
		
		self:load_groups()
		
		local res = alpha.db:query([[
			SELECT
				rules_users.rule_id AS id,
				rules.name AS name,
				rules.on AS on_id,
				rules_users.type AS allow
			
			FROM
				rules_users,
				rules
			
			WHERE
				rules_users.user_id = ?
			
			AND
				rules_users.rule_id = rules.id
			]], self.user_id)
		
		if res:num_rows() > 0 then
			for i, row in pairs(res:fetch()) do
				if not self.user_overrides[row.name] then
					self.user_overrides[row.name] = {}
				end
				
				self.user_overrides[row.name][row.on_id] = tonumber(row.allow) == 1
			end
		end
	end,
	
	has_permission = function(self, name, id)
	
		if id == nil then
			id = -1
		end

		if self.user_overrides[name] and self.user_overrides[name][id] then
			return self.user_overrides[name][id]
		else
			local res = alpha.db:query([[
				SELECT
					rules_groups.rule_id AS id,
					rules.name AS name,
					rules.on AS on_id,
					rules_groups.order,
					rules_groups.type AS allow
			
				FROM
					rules_groups,
					rules,
					groups_users
				WHERE
					groups_users.user_id = ?
			
				AND
					rules_groups.group_id = groups_users.group_id
			
				AND
					rules_groups.rule_id = rules.id
			
				AND
					rules.name = ?
			
				AND
					rules.on = ?
				ORDER BY
					rules_groups.order]], self.user_id, name, id)
			
			if res:num_rows() > 0 then
				return tonumber(res:fetch()[1].allow) == 1
			else
				--TODO: log error
				print("Could not find permission rule!!! (user_id = %(1)i, name = %(2)s, on_id = %(3)i" % {self.user_id, name, id})
				return false
			end
		end		
	end,
	
	disconnect = function(self)
		server.player_msg(self.cn, "bb")
	end,	
	
	--default stuff
	msg = function(self, text) return server.player_msg(self.cn, text) end,
    kick            = function(self, ...) return server.kick(self.cn, unpack(arg)) end,
    execute_disconnect      = function(self, ...) return server.disconnect(self.cn, unpack(arg)) end,
    name            = function(self) return server.player_name(self.cn) end,
    displayname     = function(self) return server.player_displayname(self.cn) end,
    team            = function(self) return server.player_team(self.cn) end,
    priv            = function(self) return server.player_priv(self.cn) end,
    priv_code       = function(self) return server.player_priv_code(self.cn) end,
    id              = function(self) return server.player_id(self.cn) end,
    ping            = function(self) return server.player_ping(self.cn) end,
    lag             = function(self) return server.player_lag(self.cn) end,
    ip              = function(self) return server.player_ip(self.cn) end,
    iplong          = function(self) return server.player_iplong(self.cn) end,
    status          = function(self) return server.player_status(self.cn) end,
    status_code     = function(self) return server.player_status_code(self.cn) end,
    frags           = function(self) return server.player_frags(self.cn) end,
    score           = function(self) return server.player_score(self.cn) end,
    deaths          = function(self) return server.player_deaths(self.cn) end,
    suicides        = function(self) return server.player_suicides(self.cn) end,
    teamkills       = function(self) return server.player_teamkills(self.cn) end,
    damage          = function(self) return server.player_damage(self.cn) end,
    damagewasted    = function(self) return server.player_damagewasted(self.cn) end,
    maxhealth       = function(self) return server.player_maxhealth(self.cn) end,
    health          = function(self) return server.player_health(self.cn) end,
    gun             = function(self) return server.player_gun(self.cn) end,
    hits            = function(self) return server.player_hits(self.cn) end,
    misses          = function(self) return server.player_misses(self.cn) end,
    shots           = function(self) return server.player_shots(self.cn) end,
    accuracy        = function(self) return server.player_accuracy(self.cn) end,
    accuracy2       = function(self) return server.player_accuracy2(self.cn) end,
    timetrial       = function(self) return server.player_timetrial(self.cn) end,
    timeplayed      = function(self) return server.player_timeplayed(self.cn) end,
    win             = function(self) return server.player_win(self.cn) end,
    slay            = function(self) return server.player_slay(self.cn) end,
    changeteam      = function(self,newteam) return server.changeteam(self.cn,newteam) end,
    bots            = function(self) return server.player_bots(self.cn) end,
    rank            = function(self) return server.player_rank(self.cn) end,
    isbot           = function(self) return server.player_isbot(self.cn) end,
    mapcrc          = function(self) return server.player_mapcrc(self.cn) end,
    connection_time = function(self) return server.player_connection_time(self.cn) end,
    force_spec      = function(self) return server.force_spec(self.cn) end,
    spec            = function(self) return server.spec(self.cn) end,
    unspec          = function(self) return server.unspec(self.cn) end,
    setadmin        = function(self) return server.setadmin(self.cn) end,
    setmaster       = function(self) return server.setmaster(self.cn) end,
    set_invadmin    = function(self) return server.set_invisible_admin(self.cn) end,
    set_invisible_admin = function(self) return server.set_inivisible_admin(self.cn) end,
    pos             = function(self) return server.player_pos(self.cn) end,
})

_G.user_obj = user_obj

events = {}

function new_user(...)
	return user_obj(...)
end

function _G.user_from_cn(cn)
	return users[cn] or error("cannot fin player from cn "..cn.." table: "..table_to_string(users))
end

function get_cn_from_sid(session_id)
	for i, cn in pairs(players.all) do
		if session_id == server.player_sessionid(cn) then
			return cn
		end
	end
	
	return -1
end

function OnConnect(cn)
	users[cn] = user_obj(cn)

	--print("connect, table is now: "..table_to_string(users, true, true).." (added: "..table_to_string(users[cn], true, true)..")")
end

function OnDisconnect(cn)
	--print("%(1)i disconnected" % {cn})
	users[cn]:disconnect()
	users[cn] = nil
end

--print("init user events")
server.event_handler("connect", OnConnect)
server.event_handler("disconnect", OnDisconnect)

function init()

end

search_obj = class.new(nil, {
	users = {},
	
	filter = function(self, table)
		if table.is_ai then
			if not self.users then
				self.users = server.bots
			else
				for i, cn in pairs(self.users) do
					if not server.player_isbot(cn) then
						self.users[i] = nil
					end
				end
			end
		end
		
		if not self.users then
			self.users = server.players()
		end
		
		if table.in_team then
			for i, cn in pairs(self.users) do
				if type(table.team) == "table" then
					for j, team in pairs(table.in_team) do
						if server.player_team(cn) ~= team then
							self.users[i] = nil
						end
					end
				else
					if server.player_team(cn) ~= table.in_team then
						self.users[i] = nil
					end
				end
			end
		end
		
		if table.not_in_team then
			for i, cn in pairs(self.users) do
				if type(table.team) == "table" then
					for j, team in pairs(table.in_team) do
						if server.player_team(cn) == team then
							self.users[i] = nil
						end
					end
				else
					if server.player_team(cn) == table.in_team then
						self.users[i] = nil
					end
				end
			end
		end
		
		if table.ip then
			for i, cn in pairs(self.users) do
				if type(table.ip) == "table" then
					for j, ip in pairs(table.ip) do
						if server.player_ip(ip) ~= ip then
							self.users[i] = nil
						end
					end
				else
					if server.player_ip(cn) ~= table.ip then
						self.users[i] = nil
					end
				end
			end
		end

		if table.not_ip then
			for i, cn in pairs(self.users) do
				if type(table.not_ip) == "table" then
					for j, ip in pairs(table.not_ip) do
						if server.player_ip(cn) == not_ip then
							self.users[i] = nil
						end
					end
				else
					if server.player_ip(cn) == table.not_ip then
						self.users[i] = nil
					end
				end
			end
		end

		if table.ip_long then
			for i, cn in pairs(self.users) do
				if type(table.ip_long) == "table" then
					for j, ip in pairs(table.ip_long) do
						if server.player_iplong(cn) ~= ip then
							self.users[i] = nil
						end
					end
				else
					if server.player_iplong(cn) ~= table.ip_long then
						self.users[i] = nil
					end
				end
			end
		end

		if table.not_ip_long then
			for i, cn in pairs(self.users) do
				if type(table.not_ip_long) == "table" then
					for j, ip in pairs(table.not_ip_long) do
						if server.player_iplong(cn) == ip then
							self.users[i] = nil
						end
					end
				else
					if server.player_iplong(cn) == table.not_ip_long then
						self.users[i] = nil
					end
				end
			end
		end

		if table.name then
			for i, cn in pairs(self.users) do
				if type(table.name) == "table" then
					for j, ip in pairs(table.name) do
						if server.player_name(cn) ~= name then
							self.users[i] = nil
						end
					end
				else
					if server.player_name(cn) ~= table.name then
						self.users[i] = nil
					end
				end
			end
		end

		if table.not_name then
			for i, cn in pairs(self.users) do
				if type(table.not_name) == "table" then
					for j, ip in pairs(table.name) do
						if server.player_name(cn) == name then
							self.users[i] = nil
						end
					end
				else
					if server.player_name(cn) == table.name then
						self.users[i] = nil
					end
				end
			end
		end

		if table.cn then
			for i, cn in pairs(self.users) do
				if type(table.cn) == "table" then
					for j, _cn in pairs(table.cn) do
						if cn ~= cn then
							self.users[i] = nil
						end
					end
				else
					if cn ~= table.cn then
						self.users[i] = nil
					end
				end
			end
		end

		if table.not_cn then
			for i, cn in pairs(self.users) do
				if type(table.not_cn) == "table" then
					for j, _cn in pairs(table.not_cn) do
						if cn == cn then
							self.users[i] = nil
						end
					end
				else
					if cn == table.not_cn then
						self.users[i] = nil
					end
				end
			end
		end
		--[[
		if table.has_permission then
			if type(table.has_permission) ~= "table" then
				table.has_permission = {table.has_permission}
			end

			for i, cn in pairs(self.users) do

				for i, rule in pairs(table.has_permission) do
					:has_permission()
				end
			end		
		end]]

		return self
	end,
	
	raw = function (self)
		if self.user_obj then
			local f_users = {}
			for i, cn in pairs(self.users) do
				f_users[cn] = users[cn]
			end
			
			return f_users
		else
			return self.users
		end
	end,
	
	foreach = function(self, func, ...)
		for i, cn in pairs(self.users) do
			if self.user_obj then
				func(users[cn], ...)
			else
				func(cn, ...)
			end
		end
		
		return self
	end,
})

function _G.user(search, input)
	local obj = {}
	if input and input.is_a and input:is_a(search_obj) then
		obj = input
	else
		obj = search_obj()
		
		if input then
			obj.users = input
		end
	end
	
	if #search then
		obj:filter(search)
	end
	
	return obj
end

function _G.obj_user(search, input)
	local res = _G.user(search, input)
	
	res.user_obj = true
	
	return res
end

function _G.all_obj_user()
	list_obj = class.new(nil, {
		list = {},
		__init = function(self, list)
			self.list = list
		end,
		
		foreach = function(self, func, ...)
			for i, row in pairs(self.list) do
				func(row, ...)
			end
		end,
		
		raw = function(self)
			return list
		end
	})
	
	return list_obj(users)
end

init()
