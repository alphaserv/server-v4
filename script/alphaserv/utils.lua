function pack(...) return arg end

local ii = 0
function table_to_string(table, makeup, reset)
	if makeup == nil then makeup = true end
	
	if reset then
		ii = 0
	end
	
	ii = ii + 1
	if ii > 500 then
		return '\nOVERFLOW\n'
	end
	
	local string = "{"
	if makeup then string = string.."\n" end
	for i, row in pairs(table) do
		string = string .. '"'..i..'" = '
		string = string .. '('..type(row)..')'
		if type(row) == 'table' then
			string = string .. table_to_string(row, makeup)
		else
			string = string .. '"'..tostring(row)..'"'
			if makeup then string = string.."\n" end
		end
	end
	string = string .. '}'
	if makeup then string = string.."\n" end
	
	ii = ii - 1
	return string
end

if not alpha.standalone then
	players = {}
	players.all = server.clients
	players.active = server.players
	players.spectators = server.spectators
	players.bots = server.bots

	-- returns a table containing cns of all admins
	players.admins = function()
		local newlist = {}
		for _, cn in pairs(players.all()) do
			if server.player_priv_code(cn)  > server.PRIV_MASTER then table.insert(newlist, cn) end
		end
		return newlist
	end

	-- returns a table containing cns of all masters
	players.masters = function()
		local newlist = {}
		for _, cn in pairs(server.clients()) do
			if server.player_priv_code(cn) < server.PRIV_ADMIN and server.player_priv_code(cn) >= server.PRIV_MASTER then table.insert(newlist, cn) end
		end
		return newlist
	end

	-- returns a table containing cns of all users
	players.normal = function()
		local newlist = {}
		for _, cn in pairs(server.clients()) do
			if server.player_priv_code(cn) < server.PRIV_MASTER then table.insert(newlist, cn) end
		end
		return newlist
	end

	-- removes a player from a given list
	players.except = function(players, except_cn)
		local newlist = {}
		for _, cn in pairs(players) do
			if cn ~= except_cn then table.insert(newlist, cn) end
		end
		return newlist
	end

	players.except_multi = function(players, except_cns)
		local newlist = {}
		for _, cn in pairs(players) do
			if not exept_cns[cn] then table.insert(newlist, cn) end
		end
		return newlist
	end
	
	function server.hashpassword(cn, password)
    	return crypto.tigersum(string.format("%i %i %s", cn, server.player_sessionid(cn), password))
	end
else
	function hashpassword(cn, sid, password)
    	return crypto.tigersum(string.format("%i %i %s", cn, sid, password))
	end
end--end of if not alpha.standalone

function tobool (a)
	if type(a)  == "boolean" then return a end
	
	if type(a)  == "string" then
		if a == "true" then
			return true
		elseif a == "false" then
			return false
		end
	else
		a = tonumber(a)
		
		if a == 1 then
			return true
		elseif a == 0 then
			return false
		end
	end
	
	error("Could not convert variable to boolean type.")
end

function table_typecast(type_)

	if type_ == "int" then
		return function(c) for a, b in pairs(c) do c[a] = tonumber(b) end end
	elseif type_ == "string" then
		return function(c) for a, b in pairs(c) do c[a] = tostring(b) end end
	elseif type_ == "bool" then
		return function(c) for a, b in pairs(c) do c[a] = tobool(b) end end
	end
end

function to_table(a)
	if type(a) ~= "table" and string.sub(a, 1, 1) == "{" then
		return assert(loadstring("return "..a))()
	else return a end
end

function table.simple_copy(t)
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return u
end

-- Copied from the lua-users wiki
function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- Copied from noobmod utils
function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function coloured_text_function(colour_code)
	return function(text)
		if text then
		    return "\fs\f" .. colour_code .. text .. "\fr"
		else
		    return "\fs\f" .. colour_code
		end
	end
end

color = {
	green    = coloured_text_function(0),
	blue     = coloured_text_function(1),
	yellow   = coloured_text_function(2),
	red      = coloured_text_function(3),
	grey     = coloured_text_function(4),
	magenta  = coloured_text_function(5),
	orange   = coloured_text_function(6),
	white    = coloured_text_function(7)
}

-- Copied from http://lua-users.org/wiki/SimpleRound
function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
round = math.round

function _if(expr, true_value, false_value)
    if expr then
        return true_value
    else
        return false_value
    end
end
