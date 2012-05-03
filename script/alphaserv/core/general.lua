--[[!
    File: script/alphaserv/core/general.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file contains a wrapper for hopmod's buildin settings and the server id.
]]

alpha.settings.new_setting("server_id", 1, "unique id of the server in the database.")

--A small class for saving server vars with our config framework
alpha.settings.register_type("server_var", class.new(alpha.settings.setting_obj, {
	get = function(self)
		return server[self.name]
	end,
	
	set = function(self, value)
		server[self.name] = value
		
		return self
	end
}))

alpha.settings.new_setting("servername", server.servername, "Name as seen in the description column in the client's server browser.", "server_var")
alpha.settings.new_setting("serverip", server.serverip, "The ip of the server, if you have multipue network cards.", "server_var")
alpha.settings.new_setting("serverport", server.port, "The port of your server.", "server_var")
alpha.settings.new_setting("maxplayers", server.maxplayers, "The initial maximum number of players that can connect to the server at once.", "server_var")
alpha.settings.new_setting("server_password", server.server_password, "A pass that is required to connect to the server, note that the client doesn't show a popup box.", "server_var")

alpha.settings.new_setting("allow_mm_veto", server.allow_mm_veto, "Permit master players to switch to veto mode.", "server_var")
alpha.settings.new_setting("allow_mm_locked", server.allow_mm_locked, "Permit master players to switch to locked mode.", "server_var")
alpha.settings.new_setting("allow_mm_private", server.allow_mm_private, "Permit master players to switch to private mode.", "server_var")

