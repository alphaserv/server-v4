module("db.servervars", package.seeall)
require "Json"

local db_settings

--NOTE: some core variables like db_* need 2 restarts before having effect

function reload_server_config()
	db_settings = {}
	local server_id = alpha.settings.get("server_id"):get()
	local res = alpha.db:query("SELECT name, value FROM db_vars WHERE server_id = ?", server_id)
	
	for i, row in pairs(res:fetch()) do
		if alpha.spamstartup then
			print("found setting in db: "..tostring(row.name).." = "..row.value)
		end

		db_settings[row.name] = Json.Decode(row.value)
	end

	for name, setting in pairs(alpha.settings.settings) do
		local var = Json.Encode(setting.setting)
			
		if not db_settings[name] then
			if alpha.spamstartup then
				print("Writing to db: "..tostring(name).." = "..var)
			end
			
			alpha.db:query("INSERT INTO db_vars (server_id, name, value) VALUES (?, ?, ?)", server_id, name, var)
		end
	end
	
	for name, value in pairs(db_settings) do
		alpha.settings.get(name):set(value)
	end
	
	--clean up
	db_settings = nil
end

server.event_handler("config_loading", reload_server_config)
