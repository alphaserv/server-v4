module("auth", package.seeall)

local enabled_authmodules = alpha.settings.new_setting("auth_modules_enabled", {"setmaster_1", "alphaserv_db_auth"}, "Wich auth modules to enable?")

usecaching = true

--util
function priv_present()
	--function to check if an master or admin is present
	if #players.admins() + #players.masters() < 1 then
		return false
	else
		return true
	end
end

auth_obj = class.new(nil, {
	onsetmaster = function(self, cn, hash) return false end,
	onsetmaster_1 = function(self, cn) return false end,
})

modules = {dummy = auth_obj()}

local mods_available = {}
function add_module(name, module)
	mods_available[name] = module
end

function try_setmaster(cn, hash, before_connect)
	for i, module in pairs(modules) do
		if module:onsetmaster(cn, hash, before_connect) then
			--do more here?
			return true
		end
	end
	
	--TODO: limit tries
end

function try_setmaster_1(cn, value)
	for i, module in pairs(modules) do
		if module:onsetmaster_1(cn, value) then
			--do more here?
			return true
		end
	end
	
	--TODO: /setmaster or /auth message
end

server.event_handler("connecting", function(cn, host, name, hash, reserved_slot)
	if hash == "" then return end
	try_setmaster(cn, hash, true)
end)

server.event_handler("setmaster", function(cn, hash, set)
	if set == 1 or set == 0 then
		try_setmaster_1(cn, set)
	else
		try_setmaster(cn, hash, false)
	end
end)

server.event_handler("config_loaded", function()
	for i, name in pairs(enabled_authmodules:get()) do
		if mods_available[name] then
			modules[name] = mods_available[name]()
		else
			print("Warning: authmodule "..name.." not found, please check your config.")
		end
	end
	
	--clean up
	mods_available = nil
end)
--[[
auth.listener("", function(cn, user_id, domain, status)
	event("OnAuthkey", cn, user_id, domain, status)
end)
]]

