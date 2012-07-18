module("preferences.backends.db", package.seeall)


backend_obj = class.new(preferences.backend_obj, {
	cache = {
		DEFAULT = {}	
	},
	
	__init = function(self)
	
	end,
	
	set = function(self, user, preference, value)
		if user.user_id == -1 then
			return false, "please login to change your prefences."
		end

		if not self.cache[user.user_id] then
			self.cache[user.user_id] = {}
		end

		self.cache[user.user_id][preference] = value

		local type_ = type(value)
		
		if type_ == "table" then
			type_ = "json"
			value = Json.Encode(value)
		end

		local res = alpha.db:query([[
			SELECT
				id
			FROM
				preferences
			WHERE
				user_id = ?
			AND
				name = ?		
		]], user.user_id, preference)
		
		if res:num_rows() == 0 then
			--new setting
			alpha.db:query([[
				INSERT INTO
					preferences
					(
						user_id,
						name,
						type,
						value
					)
					VALUES
					(
						?,
						?,
						?,
						?
					)
				]], user.user_id, preference, type_, tostring(value))
		else
			alpha.db:query([[
				UPDATE
					preferences
				SET
					type = ?,
					value = ?
				WHERE
					user_id = ?
				AND
					name = ?
				]], type_, tostring(value), user.user_id, preference)		
		end
					
		return true
	end,
	
	get = function(self, user, preference)
		--user preferences were loaded, just not specified for this setting --> return defaults
		if self.cache[user.user_id] and type(self.cache[user.user_id][preference]) == "nil" then
			return self.cache.DEFAULT[preference] or nil
		elseif self.cache[user.user_id] and type(self.cache[user.user_id][preference]) ~= "nil" then
			return self.cache[user.user_id][preference] or nil
		elseif not self.cache[user.user_id] then
			--init cache
			
			self.cache[user.user_id] = {}
			
			local res = alpha.db:query([[
				SELECT
					name,
					type,
					value
				FROM
					preferences
				WHERE
					user_id = %(1)s
			]] % { user.user_id == -1 and "NULL" or tonumber(user.user_id) })
			
			if res:num_rows() < 1 then
				log_msg(LOG_INFO, "0 rows for user: "..user.user_id)
			end
			
			for i, row in pairs(res:fetch()) do
				if user.user_id == -1 then
					self.cache.DEFAULT[row.name] = self:convert(row)
				else
					self.cache[user.user_id][row.name] = self:convert(row)
				end
			end
			
			return self:get(user, preference)
		end

		return nil
	end,
	
	convert = function(self, row)
		row.type = string.lower(row.type)
		
		if row.type == "string" then
			return tostring(row.value)
		elseif row.type == "number" then
			return tonumber(row.value)
		elseif row.type == "json" then
			return Json.Decode(row.value)
		elseif row.type == "boolean" then
			return string.lower(row.value) == "true"
		end
		
		return nil
	end,
	
	init = function(self, preference, value)

		local type_ = type(value)
		
		if type_ == "table" then
			type_ = "json"
			value = Json.Encode(value)
		end

		alpha.db:query([[
			INSERT INTO
				preferences
				(
					user_id,
					name,
					type,
					value
				)
				VALUES
				(
					NULL,
					?,
					?,
					?
				)
			]], preference, type_, tostring(value))
		
		self.cache.DEFAULT[preference] = value
	end,
})

	
_G.preferences.register_backend("db", backend_obj)
