
module("maprotation", package.seeall)

local default_map = alpha.settings.new_setting("default_map", nil, "Default map to change to or nil")
local default_mode = alpha.settings.new_setting("default_mode", "insta ctf", "Default mode to change to or nil")

intermission_modes = {}
providers = {}
intermission = false
map_id = 1

local current_intermissionmode = nil
local backup_intermissionmode = nil

local current_map_provider = nil

function add_intermissionmode(name, obj)
	intermission_modes[name] = obj()
end

function add_map_provider(name, obj)
	providers[name] = obj()
end

function set_intermissionmode(name)
	current_intermissionmode = intermission_modes[name]
end

function set_backup_intermissionmode(name)
	backup_intermissionmode = intermission_modes[name]
end

function set_map_provider(name)
	current_map_provider = providers[name]
end

function get_map_provider()
	return current_map_provider
end

function get_intermissionmode_obj()
	if not current_intermissionmode then
		error("No intermissionmode set")
	else
		return current_intermissionmode
	end
end

function get_backup_intermissionmode_obj()
	if not backup_intermissionmode then
		error("No backup intermissionmode set")
	else
		return backup_intermissionmode
	end
end

--don't call our intermission mode -> cancel when we change the map ourselves
local ignore = {nil, nil}
function ignoremapchange(map, mode)
	ignore = {map, mode}
end

function should_ignore(map, mode)
	if ignore[1] == map and ignore[2] == mode then
		ignore = {nil, nil}
		return true
	else
		return false
	end
end

function delay_intermission(i)
	if not intermission then
		return
	end
	
	i = i or 0
	
	log_msg(LOG_DEBUG, "delaying intermission")

	--wait longer ...
	if i < 40 then
		server.intermission = server.intermission + 1000
	
		server.sleep(500, function()
			delay_intermission(i + i)
		end)
	else
		get_intermissionmode_obj():cancel()
		get_backup_intermissionmode_obj():intermission(true)
	end
end

map_provider = class.new(nil, {
	change_map = function(self, map, mode)
		mode = mode or server.gamemode
		map = map or server.map
		
		ignoremapchange(map, mode)
		server.changemap(map, mode)
	end,
	
	get_map = function(self, mode, i) end,
})

intermission_mode_obj = class.new(nil, {
	--on intermission
	intermission = function(self) end,
	
	--on mapchange not done by map provider
	cancel = function(self) end,
})

server.event_handler("mapchange", function(map, mode)
	if not should_ignore(map, mode) then
		get_intermissionmode_obj():cancel()
	end
	
	intermission = false
	
	--clear voteds
	for cn, player in pairs(alpha.players.players) do
		player.has_voted = false
	end
end)

server.event_handler("intermission", function()
	log_msg(LOG_INFO, "intermission...")
	intermission = true
	delay_intermission()

	--[[
	server.sleep(20000, function()
		if intermission then
			get_intermissionmode_obj():cancel()
			get_backup_intermissionmode_obj():intermission()
		end
	end)]]

	get_intermissionmode_obj():intermission()
end)

default_map_provider = class.new(map_provider, {
	__init = function(self)
		log_msg(LOG_INFO, "Reloaded maps")
		--load the maps
		dofile(alpha.package.package_path.."maprotation_L/maps.lua")
	end,
	
	get_map = function(self, mode, i)
		i = i or (map_id + 1)
		
		local maps = modes.modes[mode]
		i = i % #maps
		
		map_id = i
		
		return maps[i]
	end,
})

add_map_provider("default", default_map_provider)
set_map_provider("default")

default_intermission_mode_obj = class.new(intermission_mode_obj, {
	cancelled = false,
	
	intermission = function(self)
		self.cancelled = false
		local map = current_map_provider:get_map(server.gamemode)
		
		log_msg(LOG_INFO, "starting map %(1)s (%(2)s) in 3 second" % {map, server.gamemode})
		
		server.sleep(3000, function()
			if not self.cancelled then
				current_map_provider:change_map(map, server.gamemode)
			end
		end)
	end,
	
	--on mapchange not done by map provider
	cancel = function(self)
		self.cancelled = true
	end,
})

add_intermissionmode("default", default_intermission_mode_obj)

set_intermissionmode("default")
set_backup_intermissionmode("default")

local function on_connect()
	server.sleep(1000, function()
		--Check if it's the first player connecting
		if #alpha.user.users >= 2 then
			log_msg(LOG_DEBUG, "not first player: "..table_to_string(alpha.user.users))
			return
		end
		log_msg(LOG_DEBUG, "first player")
	
		local mode = default_mode:get()
		local map = default_map:get()
	
		if not mode and not map then
			return -- nothing to change
		end
	
		mode = mode or server.gamemode
		map = map or current_map_provider:get_map(mode)

		if mode == "" then
			mode = "instagib"
		end

		if map == "" then
			map = "reissen"
		end
		log_msg(LOG_INFO, "initial changemap "..tostring(map).." ("..tostring(mode)..")")
		server.changemap(map, mode)
	end)
end

server.event_handler("started", on_connect)
server.event_handler("connect", on_connect)
