--[[
	script/module/nl_mod/nl_utils.lua
	Andreas Schaeffer
	Created: 23-Okt-2010
	Last Change: 12-Nov-2010
	License: GPL3

	Funktion:
		Stellt verschiedene allgemein gebräuchliche Funktionen zur Verfügung

	API-Methoden:
		utils.is_numeric(x)
			Gibt true oder false zurück, wenn es sich um eine Zahl handelt oder nicht

]]


--[[
		API
]]

utils = {}

function utils.is_numeric(a)
    return type(tonumber(a)) == "number"
end


function utils.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function utils.table_val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and utils.table_tostring( v ) or
      tostring( v )
  end
end

function utils.table_key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. utils.table_val_to_str( k ) .. "]"
  end
end

function utils.table_tostring(tbl)
  if tbl == nil then return "{}" end
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, utils.table_val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        utils.table_key_to_str( k ) .. "=" .. utils.table_val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function utils.table_copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function utils.table_size(t)
	local count = 0
	for k, v in pairs(t) do count=count+1 end
	return count
end


function utils.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

function utils.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end

