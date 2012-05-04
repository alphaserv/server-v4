
return {
	name = "Logging in with your password stored in the database",
	dependics = {
		"messages",
		"auth",
		"database"
	},
	load = {
		"dbauth.lua"
	}
}
	
