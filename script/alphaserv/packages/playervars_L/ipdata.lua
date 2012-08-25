if not user_obj.storage_backend then
	user_obj.storage_backend = {}
end

user_obj.storage_backend.ipdata = class.new(nil, {
	data = {},
	
	load = function(self, cn)
		self.ip = server.player_ip(cn)
		
		local res = alpha.db:query([[
			SELECT
				name,
				value
			FROM
				ipvars
			WHERE
				ip = ?		
		]], self.ip)
		
		for i, row in pairs(res:fetch()) do
			self.data[row.name] = row.value
		end
	end,
	
	get = function(self, name)
		return self.data[name]
	end,
	
	exists = function(self, name)
		return self.data[name] == nil
	end,
	
	set = function(self, name, value)
		--var doesn't exist yet
		if self.data[name] == nil then
			--TODO:warning
			print("variable %(1)s didn't exist yet!" % {name})
			return self:new(name, value)
		end
		
		self.data[name] = value
		
		return alpha.db:query([[
			UPDATA
				ipvars
			SET
				value = ?
			WHERE
				ip = ?
			AND
				name = ?
		
		]], value, self.ip, name)
	end,
	
	new = function(self, name, value)
		
		self.data[name] = value
		
		return alpha.db:query([[
			INSERT INTO
				ipvars
				(
					ip,
					value,
					name
				)
			VALUES
				(
					?,
					?,
					?
				)
		]], self.ip, value, name)	
	end,

})
