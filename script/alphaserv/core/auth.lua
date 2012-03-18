--[[
	===  ===    ====	 ===	|=|
	 |	|	|	|   \ 	|	|
	 |	|	|	|	/ 	|	|
	 |	 ===	 ===	 ===	|=|
	 
	 __
	 \ \	* stop using pixelart
	 /_/	* move to module

]]

alpha.auth = {}
alpha.auth.plugins = {}
alpha.auth.loggedin = {}
alpha.auth.usecaching = true

alpha.settings.init_setting("auto_master", true, "bool", "let the first one to connect become master automatically.\nThis may attract noobs kicking everyone.")

--util
function alpha.auth.priv_present()
	--function to check if an master or admin is present
	if #players.admins() + #players.masters() < 1 then
		return false
	else
		return true
	end
end

--###################
--	playersession
--###################
alpha.privilege = {}

--privileges low to high
alpha.privilege.DEFAULT = 1
alpha.privilege.USER = 50
alpha.privilege.MASTER = 300
alpha.privilege.ADMIN = 600
alpha.privilege.OWNER = 1000
alpha.privilege.DEV = 5000

local lastclean = {}
--alpha.auth.loggedin = {}

function alpha.auth.clean_access()
	--only change if players diconnected (/ connected sadly 2)
	if players.all == lastclean then return end
	local sessionids = {}
	for i, cn in pairs(players.all()) do
		sessionids[server.player_sessionid(cn)] = true
	end
	for sid, priv in pairs(alpha.auth.loggedin) do
		if not sessionids[sid] then
			alpha.auth.loggedin[sid] = nil
		end
	end
	lastclean = players.all()
end

function alpha.auth.set_access(cn, number)
	if not number then return false end
	local sid = server.player_sessionid(cn)
	if sid == -1 then return false end
	alpha.auth.loggedin[sid] = number
	alpha.auth.clean_access()
	
	return true
end

function alpha.auth.get_access(cn)
	alpha.auth.clean_access()
	return alpha.auth.loggedin[server.player_sessionid(cn)]
end

function alpha.auth.has_access(cn, number)
	alpha.auth.clean_access()
	if privi <= priv.get(cn)then
		return true
	else
		return false
	end
end

function alpha.auth.logout(cn)
	alpha.auth.set_access(cn, alpha.privilege.DEFAULT)
end

function alpha.auth.success(cn, privilege)
	alpha.auth.set_access(cn, privilege)
	server.player_msg(cn, "u recieved privilege")
	alpha.auth.unlock_spec(cn)
end

--###################
--	util functions
--###################

local function load_plugin(name)
	alpha.auth.plugins[name]:init()
	if alpha.auth.plugins[name].cfg_commands then
		for i, command in pairs(alpha.auth.plugins[name].cfg_commands) do
			if server[command] then error("command name already in use") end
			if not alpha.auth.plugins[name][command] then error("could not register cfg_command to cubescript, lua function not found") end
			server[command] = function(...)
				if alpha.auth.plugins[name].enabled then
					alpha.auth.plugins[name][command](alpha.auth.plugins[name], unpack(arg))
				else
					error("unable to call disabled function.")
				end
			end
		end
	end
end

local function unload_plugin(name)
	if alpha.auth.plugins[name].unload then
		alpha.auth.plugins[name]:unload()
	end
end


--###################
--	event functions
--###################

local function event(name, ...)
--	server.msg("call "..name.." "..table_to_string(arg))
	local returning = nil
	for i, plugin in pairs(alpha.auth.plugins) do
		if plugin.enabled == true and plugin[name] then
			--server.msg(tostring(plugin).." "..i)
			local a, b = alpha.auth.plugins[i][name](alpha.auth.plugins[i], unpack(arg))
			if b and b == "FORCE" then
				returning = a
			elseif type(a) == "number" and a > (returning or -1000000000) then
				returning = a
			elseif returning == nil then
				returning = a
			end
		end
	end
	
	return returning
end


--###################
--		events
--###################
server.event_handler("connect", function (cn)
	if #players.all() == 1 and (tonumber(alpha.settings:get("auto_master")) == 1) then
		server.sleep(1000, function()
			if not priv.has(cn, priv.MASTER) then
				-- don't do anything if he is already master
				messages.info("auth", {cn}, config.get("messages:auto_master"), true)
				server.setmaster(cn)
				priv.set(cn, priv.MASTER)
			end
		end)
	end
	event("OnConnect", cn)
end)

server.event_handler("connecting", function(cn, host, name, hash, reserved_slot)
	alpha.auth.logout(cn, true)

	if hash == "" then return end
	event("OnSetmaster", cn, hash)
end)

server.event_handler("setmaster", function(cn, hash, set)
	if set == 1 or set == 0 then
		event("OnSetmaster_1", cn, set)
	end
	event("OnSetmaster", cn, hash)
end)

auth.listener("", function(cn, user_id, domain, status)
	event("OnAuthkey", cn, user_id, domain, status)
end)

--TODO: cleanup (= flush cache)

--refresh every 10 minutes
--server.interval(10*60000, function() event("cleanup") end)

alpha.auth.locked = {}

local function lock_spec(cn)
	if alpha.auth.locked[server.player_ip(cn)..server.player_name(cn)] then
			server.spec(cn)
	end
end
server.event_handler("spectator", lock_spec)

function alpha.auth.lock_spec(cn)
	alpha.auth.locked[server.player_ip(cn)..server.player_name(cn)] = true
end

function alpha.auth.unlock_spec(cn)
	alpha.auth.locked[server.player_ip(cn)..server.player_name(cn)] = false
	
	--TODO: unspec
end

function alpha.auth.fail(...)
	error(unpack(arg))
end

server.event_handler("disconnect", function(cn)
	--cleanup
	local ip = server.player_ip(cn)
	local name = server.player_name(cn)
	if alpha.auth.locked[server.player_ip(cn)..server.player_name(cn)] then
		for i, cn_ in pairs(players.except({cn}, players.all())) do
			if cn ~= _cn and server.player_name(cn) == name and server.player_ip(cn) == ip then
				return --HACK attempt ?, or not :)
			end
		end
	end
	alpha.auth.locked[server.player_ip(cn)..server.player_name(cn)] = nil
end)

local function check (cn)
	local name = server.player_name(cn)
	if event("clanreserved", name) or event("namereserved", name) then
		server.spec(cn)
		alpha.auth.lock_spec(cn)
		server.player_msg(cn, "reservedname :O FAKER!!!")
	end
end
server.event_handler("maploaded", check)
server.event_handler("rename", check)

function alpha.auth.init()
	require("filesystem")
	for filetype, filename in filesystem.dir(alpha.module_prefix.."core/authplugins/") do
		if filetype ~= filesystem.DIRECTORY then
			print("loaded: "..filename)
			alpha.load.file(alpha.module_prefix.."core/authplugins/"..filename, "a", "auth plugin", true--[[raw path]])
		end
	end
	for i, j in pairs(alpha.auth.plugins) do
		load_plugin(i)
	end
end

server.event_handler("pre_started", alpha.auth.init)
