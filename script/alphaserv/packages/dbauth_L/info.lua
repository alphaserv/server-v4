
return {
	name = "Logging in with your password stored in the database",
	dependics = {
		"messages",
		"auth",
		"database",
		"spec_control"
	},
	load = {
		"dbauth.lua"
	}
}
	
