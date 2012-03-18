
alpha.settings.init_setting("simpleauth_enabled", true, "bool", "allow users to auth without an account, with a password.\nThis is offcourse less safe than dbauth.")

alpha.auth.plugins.simpleauth = {
	users = {},
	init = function(obj)
		if alpha.settings:get("simpleauth_enabled") then
			obj.enabled = true
		end
	end,
	adduser = function(obj, password, priv)
		if obj.users[password] then error('password already in use') end
		obj.users[password] = priv
	end,
	OnSetmaster = function(obj, cn, pass)
		for i, row in pairs(obj.users) do
			if server.hashpassword(cn, i) == pass then
				alpha.auth.success(cn, row)
				return
			end
		end
		return false
	end,
	cfg_commands = { 'adduser' },
}
