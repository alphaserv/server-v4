--[[!
	Global config for all servers,
	 please change to your needs
]]

return {
	components = {
		db = {
			class = "components.db",
			username = "{db.username}",
			password = "{db.password}",
			database = "{db.database}",
			
			hostname = "{db.hostname}",
			port = "{db.port}"
		}	
	}
}
