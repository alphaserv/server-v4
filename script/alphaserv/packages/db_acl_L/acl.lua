--[[
	PHP version

	static function GetUserAccess($object, $user = false)
	{
		if(!is_object($object))
			throw new exception('Could not find object');
		
		if(!Yii::app()->user->isGuest)
		{
			
			if($user === false)
			{
				$user = Yii::app()->user->id;
			}
			
			if(!is_object($user))
			{
				$user = User::Model()->with('aclGroupUsers')->findByAttributes(array('id' => $user));
			
				if($user === null)
					throw new exception('Access not found, Could not find user from id');
			}

				
			$groups = $user->aclGroups;
			$user = self::getGroup('user');
			
			if(!$user)
				throw new exception('DB corruption, group user not found!');
			
			$groups[] = $user;
		}
		
		$world = self::getGroup('world');
		
		if(!$world)
			throw new exception('DB corruption, group world not found!');
		
		$groups[] = $world;
		
		#try all groups for every object
		do
		{

			$privileges = $object->aclPrivileges;

			if(!$privileges)
				continue;
			
			
			#TODO: let the database sort
			usort($privileges, function($a, $b)
			{
				if($a->order_by == $b->order_by)
					return 0;
				elseif($a->order_by < $b->order_by)
					return -1;
				else
					return 1;
			});



			
			foreach($privileges as $privilege)
			{
				foreach($groups as $group)
				{
					if($privilege->group_id == $group->id)
						return Access::FromResult($privilege);
				}
			}
		}
		while($object = $object->parent);

		throw new exception('Could not find rule');
	}
]]


user_obj.reinit_acl = function(self)
	self.groups = {}
	
	local res
	
	if self.user_id ~= -1 then
		res = alpha.db:query([[
			SELECT
				acl_group.id,
				acl_group.name,
				acl_group.parent_id
			FROM
				acl_group,
				acl_group_user
			WHERE
			(
					acl_group.id = acl_group_user.group_id
				AND
					acl_group_user.user_id = ?
			)
			OR
				acl_group.name = "world"
			OR
				acl_group.name = "user"
		]], self.user_id)
	else
		res = alpha.db:query([[
			SELECT
				acl_group.id,
				acl_group.name,
				acl_group.parent_id
			FROM
				acl_group,
				acl_group_user
			WHERE
				acl_group.name = "world"
		]])
	end
	
	res = res:fetch()
	
	local parents = {}
	local fetched = {}	
	
	function fetch_parents(res)
		for i, group in pairs(res) do
			if group.parent_id ~= nil then
				parents[group.parent_id] = tonumber(group.parent_id)
			end
		
			if type(parents[group.id]) ~= "nil" then
				parents[group.id] = nil
			end
			
			fetched[group.id] = group.id
		end
		
		if #parents > 0 then
		
		end
	end

	if not acl.users[self.user_id] then
		acl.users[self.user_id] = {
			groups = { "world"}
		}
		
		write()
	end
	
	self.access = {}
	
	for i, group in pairs(acl.users[self.user_id].groups) do
		repeat
			for name, access in pairs(acl.groups[group].access) do
				self.access[name] = access
			end
			group = acl.groups[group.parent]
		until not group
	end
end

user_obj.has_permission = function(self, name, id)
	if id and id ~= -1 then
		name = name..':'..id
	end
	
	--log_msg(LOG_DEBUG, "Checking %(1)q "% {name})
	
	--log_msg(LOG_DEBUG, "Checking "..table_to_string(acl.objects))
	
	--[[
	for item, b in pairs(self.access) do
		log_msg(LOG_DEBUG, "Checking %(1)q" % {item})
	end
	
	-- [ [
	log_msg(LOG_DEBUG, "Checking "..tostring(type(self.access[name]) ~= "boolean") or "false")
	log_msg(LOG_DEBUG, "Checking "..tostring(type(acl.objects[name]) == "table"))
	log_msg(LOG_DEBUG, "Checking "..tostring(type(acl.objects[name].default) == "boolean"))]]
	
	--not found at all -> add
	if not acl.objects[name] then
		log_msg(LOG_DEBUG, "not set")
		acl.objects[name] = { parent = "world" }
		server.sleep(1, write)
	end
	
	--log_msg(LOG_DEBUG, ":"..type(self.access[name]))
	--log_msg(LOG_DEBUG, ":"..tostring(self.access[name]))
	
	if type(self.access[name]) == "boolean" then
		log_msg(LOG_DEBUG, "has access")
		return self.access[name]
	
	--is not set -> check for default value
	elseif type(self.access[name]) ~= "boolean" and type(acl.objects[name]) == "table" and type(acl.objects[name].default) == "boolean" then
		--log_msg(LOG_DEBUG, "Checking default value")
		self.access[name] = acl.objects[name].default
	
		return self.access[name]
	
	--is not set -> find parent
	elseif type(self.access[name]) == "nil" and acl.objects[name].parent then
		--log_msg(LOG_DEBUG, "finding parent "..acl.objects[name].parent)
		local res = self:has_permission(acl.objects[name].parent)
		self.access[name] = res
		return res
	end
	
	return false
end




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
end,

