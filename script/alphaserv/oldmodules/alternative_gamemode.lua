--[[if server.allow_mod_mode ~= 1 then
	server.modified_gamemode = 0
	return
end]]
local modmodule = {}
modmode = {}
modmodule.current = {}
modmodule.banner = ""
modmodule.changemap = function () end
modmodule.unload = function () end

function modmode.load (name)
	if server.allow_modmode ~= 1 then return end -- error("modmodules are currently not allowed"); 

	server.log_status(string.format(config.get("log:messages:alternative_gamemode_loaded"),name))
	server.log(string.format(config.get("log:messages:alternative_gamemode_loaded"),name))
    modmodule.unload()
    modmodule.current = alpha.module(config.get("alternative_gamemode:dir")..'/'..name)
        
    if (not modmodule.current) or (modmodule.current == nil) or (type(modmodule.current) ~= "table") then
    	return false
	end

	modmodule.current.load()
	modmodule.banner = modmodule.current.banner
	modmodule.changemap = modmodule.current.changemap
	modmodule.unload = modmodule.current.unload
	modmodule.show_banner()
end
server.event_handler("alpha:empty",function()
        modmodule.unload()
        modmodule.banner = false
        modmodule.changemap = function()end
        alpha.save_stats = true
end)

server.event_handler("mapchange", function()
	messages.debug("modmodule", players.admins(), "mapchange event", true)
	modmodule.changemap()
end)

function modmodule.show_banner()
	local banner = modmodule.banner
	server.interval(config.get("alternative_gamemode:banner_timeout"), function ()
		if server.allow_modmode ~= 1 then return -1 end
		if (not modmodule.banner) or (modmodule.banner == "") then return -1 end
		if banner ~= modmodule.banner then return -1 end
		messages.info(-1, players.all(), config.get("messages:alternative_gamemode_banner_header"), false)
		messages.info(-1, players.all(), modmodule.banner, false)
	end)
end
cmd.command_function("unloadmodmodule", function(cn, name)
        modmodule.unload()
        modmodule.banner = false
        modmodule.changemap = function()end
        alpha.save_stats = true
end, priv.OWNER)
cmd.command_function("modmodule", function(cn, name)
--reset
	server.modified_gamemode = 0
	server.mod_health = -1
	server.mod_ammo = -1
	server.mod_ammo_type = -1
	server.mod_gunselect = -1
	server.mod_shotgun = -1
	server.mod_rocket = -1
	server.mod_rifle = -1
	server.mod_gernade = -1
	server.mod_pistol = -1
	server.mod_machinegun = -1
if name then
	if server.allow_modmode ~= 1 then messages.warning("modmodule", {cn}, config.get("no_mod_modes"), true); return end
	alpha.save_stats = false
	modmode.load (name)
else
        modmodule.unload()
        modmodule.banner = false
        modmodule.changemap = function()end
        alpha.save_stats = true
end
end, priv.OWNER)

server.modmode = modmode.load
