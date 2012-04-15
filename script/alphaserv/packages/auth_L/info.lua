
return {
	name = "authentication core",
	dependics = {
		"messages"
	},
	load = {
		"auth.lua",
		"auto_master.lua",
		"setmaster_1.lua", 
		"alphaserv_db_auth.lua"
	}
}
	
