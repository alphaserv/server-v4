--[[!

	Add your server specific configuration here.

]]

return {
	
	name = "name of the server",
	port = {config.port},
	
	--[[
		the id of the server as in the database, this should correspond to the database AND the name of the directory
		
		Note: you probably won't need to change this
	]]
	id = {config.id},

	components = {
		--[[
			You can add modules in here like:
			
			banners = {
				class = "modules.banners",
				
				banners = {
					"banner",
				},
				
				interval = 30000,
			},
		]]
	
	}
}
