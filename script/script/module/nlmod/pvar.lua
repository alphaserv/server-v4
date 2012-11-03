local function readtable(cn)
	local table = {}
	for _, part in pairs(string.split_(server.private_string(cn), "\n")) do -- string.split_ function in ../promod/tools.lua (split_ because hopmod has one already, which is used in script/base/auth/client.lua)
		name, val = string.match(part, "(%S+)=(.+)")
		if name and val then
			table[name] = val
		end
	end
	return table
end

local function writetable(cn, table)
	local str = ""
	for name, val in pairs(table) do
		if val then
			if str ~= "" then str = str .. "\n" .. name .. "=" .. val
			else str = name .. "=" .. val end
		end
	end
	server.set_private_string(cn, str)
end

local function write_var(cn, var, val)
	local table = readtable(cn)
	if val ~= nil then table[var] = string.gsub(tostring(val), "\n", "///n") else table[var] = val end
	writetable(cn, table)
end

local function read_var(cn, var)
	local table = readtable(cn)
	if table[var] then return string.gsub(table[var], "///n", "\n") else return nil end
end

function server.player_pvar(cn, var, val, type_)
	type_ = type_ or "str"
	if not cn then error("missing cn") end
	if not var then error("missing varname") end
	cn = tonumber(cn)
	if not server.valid_cn(cn) then server.log_error("error in use of server.player_pvar() function: invalid cn!"); return end
	if val ~= nil then
		write_var(cn, var, val)
	else
		local pvar = read_var(cn, var)
		if type_ == "int" then
			return tonumber(pvar)
			
		elseif type_ == "bool" then
			if pvar == "true" then return true
			elseif pvar == "false" then return false
			else return nil end
			
		else
			return pvar
		end
	end
end

function server.player_unsetpvar(cn, var)
	if not server.valid_cn(cn) then return end
	if not cn then error("missing cn") end
	if not var then error("missing varname") end
	cn = tonumber(cn)
	if not server.valid_cn(cn) then error("invalid cn"); return end
	write_var(cn, var, nil)
end

function server.resetpvars(cn)
	server.set_private_string(cn, "")
end

server.event_handler("disconnect", server.resetpvars)
