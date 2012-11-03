
module("as.server", package.seeall)

local as = as
local core = _G.core
local properties = core.vars
local type = type
local pairs = pairs



function __index(table, key)
	local value = core[key]
				
	if not value then
	    value = properties[key]
	    if type(value) == "function" then
	        value = value()
	    end
	end
				
	return value
end
		
function __newindex(table, key, value)
				
	local existing_property = properties[key]
				
	if existing_property and type(existing_property) == "function" then
		    existing_property(value)
	end
				
	core[key] = value
end

setmetatable(_M, _M)

local setting = as.config.loadSection("server", {
	servername		= _M.servername,
	server_password = _M.server_password,
	maxplayers		= _M.maxplayers,
	maxclients		= _M.maxclients,
	serverip		= _M.serverip,
	serverport		= _M.serverport,
	reassignteams	= _M.reassignteams,
	botlimit		= _M.botlimit,
	botbalance		= _M.botbalance,
	display_open	= _M.display_open,
	allow_mastermode_veto		= _M.allow_mastermode_veto,
	allow_mastermode_locked		= _M.allow_mastermode_locked,
	allow_mastermode_private	= _M.allow_mastermode_private,
	reserved_slots	= _M.reserved_slots,
    
	reserved_slots_password		= _M.reserved_slot_password, 
	
	spectator_delay	= _M.spectator_delay,
	ctftkpenalty	= _M.ctftkpenalty,
	specslots		= _M.specslots,
	cheatdetection	= _M.cheatdetection,

--[[
	flood_protect_text", server::sv_text_hit_length);
	flood_protect_sayteam", server::sv_sayteam_hit_length);
	flood_protect_mapvote", server::sv_mapvote_hit_length);
	flood_protect_switchname", server::sv_switchname_hit_length);
	flood_protect_switchteam", server::sv_switchteam_hit_length);
	flood_protect_kick", server::sv_kick_hit_length);
	flood_protect_remip", server::sv_remip_hit_length);
	flood_protect_newmap", server::sv_newmap_hit_length);
	flood_protect_spectator", server::sv_spec_hit_length);

	timer_alarm_threshold", server::timer_alarm_threshold);
	enable_extinfo", server::enable_extinfo);]]
    
	--ext_admin_pass", server::ext_admin_pass);--default value?
})

function init()
	for name, value in pairs(setting.__list) do
		_M[name] = value
	end
end
