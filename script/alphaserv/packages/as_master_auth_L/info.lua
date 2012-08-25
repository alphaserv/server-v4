
return {
	name = "Logging in with your by using an external autentication server",
	dependics = {
		"messages",
		"auth",
		"database",
		"spec_control",
		"as_master_client"
	},
	load = {
		"ext_auth.lua"
	}
}
	
