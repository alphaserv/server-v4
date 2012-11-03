local cnnames = {}
local idnames = {}
local ipnames = {}
local xstatsnames = {}

local function setup(cn)
	local name = server.player_name(cn)
	cnnames[cn] = {name}
	idnames[server.player_sessionid(cn)] = {name}
	local ip = server.player_ip(cn)
	if not ipnames[ip] then ipnames[ip] = {name} end
	if server.xstats_name(cn) then
		xstatsnames[server.xstats_name(cn)] = {name}
	end
end

local function add(cn, name)
	cn = tonumber(cn)
	if not cn then error("could not get int of cn var") end
	local id = server.player_sessionid(cn)
	local ip = server.player_ip(cn)
	local xstats = server.xstats_name(cn)
	if not cnnames[cn] then cnnames[cn] = {} end
	if not idnames[id] then idnames[id] = {} end
	if not ipnames[ip] then ipnames[ip] = {} end
	
	local added = false
	for _, name_ in cnnames[cn] do if name_ == name then added = true; break end
	if not added then cnnames[cn][#cnnames[cn] + 1] = name end
	
	local added = false
	for _, name_ in idnames[id] do if name_ == name then added = true; break end
	if not added then idnames[id][#idnames[id] + 1] = name end
	
	local added = false
	for _, name_ in ipnames[ip] do if name_ == name then added = true; break end
	if not added then ipnames[ip][#ipnames[ip] + 1] = name end
	
	if xstats then
		if not xstatsnames[xstats] then xstatsnames[xstats] = {} end
		local added = false
		for _, name_ in xstatsnames[xstats] do if name_ == name then added = true; break end
		if not added then xstatsnames[xstats][#xstatsnames[xstats] + 1] = name end
	end
end
