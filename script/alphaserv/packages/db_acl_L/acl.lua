
local current_init = user_obj.__init
user_obj.__init = function(self, ...)
	self._inited_groups = false
	self.groups = {}
	self.user_overrides = {}
	current_init(self, ...)
end

user_obj.load_groups = function(self)
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
end

user_obj.auth = function(self, user_id)
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
			
			self.user_overrides[row.name][row.on_id] = tonumber(row.allow) == 1
		end
	end
end,
	
user_obj.has_permission = function(self, name, id)
	
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
				rules_groups.order_by,
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
				rules_groups.order_by]], self.user_id, name, id)
		
		if res:num_rows() > 0 then
			return tonumber(res:fetch()[1].allow) == 1
		else
			--TODO: log error
			print("Could not find permission rule!!! (user_id = %(1)i, name = %(2)s, on_id = %(3)i" % {self.user_id, name, id})
			return false
		end
	end		
end
