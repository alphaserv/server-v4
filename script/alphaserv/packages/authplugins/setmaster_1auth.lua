alpha.settings.init_setting("allow_setmaster_1", true, "bool", "allow users to claim master on this server by typing '/setmaster 1'.")
alpha.settings.init_setting("setmaster_1_min_priv", 0, "int", "limit the people who can claim master.")

alpha.auth.plugins.setmaster1 = {
	init = function(obj)
		if alpha.settings:get("allow_setmaster_1") then
			obj.enabled = true
		end
	end,
	OnSetmaster_1 = function(obj, cn)
		if priv.has(cn, alpha.settings:get("setmaster_1_min_priv")) and alpha.settings:get("allow_setmaster_1") then
			server.setmaster(cn)
			server.msg(server.player_displayname(cn).." claimed master")
		end
	end,

}
