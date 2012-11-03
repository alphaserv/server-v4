--[[!
    File: script/as/table.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This provides additional table utils

	About: Package table
]]

module("table", package.seeall)

function pack(...)
	return {...}
end

function pull(tab)
	for i, v in pairs(tab) do
		table.remove(tab, i)
		return v
	end
end

function reverse(table)
	local size = #table
	local reversed = {}
	 
	for i,v in ipairs ( table ) do
	    reversed[size-i] = v
	end
	
	return reversed
end

--[[!
	Function: isList
	Checks if this is a list with keys
	
	Parameters
		table - The table to check
	
	Return:
		(bool) true when the table is a list
]]		

isList = function(table)
	local isindex = function(k) 
		if type(k) == "number" and k > 0 then
			if math.floor(k) == k then
				return true
			end
		end
		return false
	end

	for k,v in pairs(table) do
		if not isindex(k) then
			return false
		end
	end
	return true
end
	
addTabs = function(string, i)
	i = tonumber(i) or 0
	if i <= 0 then
		return string
	else
		i = i - 1
	end
	
	string = "\t"..string
	
	return addTabs(string, i)
end

print_r = function(t, i)
	i = i or 0
		
	if i > 100 then
		print "RECURSION?"
		return
	end

	if i == 0 then		
		print (
			addTabs("{", i)
		)
	end

	for k, v in pairs(t) do
		if type(v) == "table" then
			print (
				addTabs(
					("[%q]"):format(tostring(k)) .. " = {",
					i+1
				)
			)
			
			print_r(v, i+2)
	
			print (
				addTabs("},", i+1)
			)
		elseif type(v) == "number" then
			print (
				addTabs(
					("[%q] = (%s)%i"):format(tostring(k), type(v), tonumber(v)),
					i+1
				)
			)
		else
			print (
				addTabs(
					("[%q] = (%s)%q"):format(tostring(k), type(v), tostring(v)),
					i+1
				)
			)
		end
	end
		
	if i == 0 then
		print (
			addTabs("},", i)
		)
	end
end

--[[!
	Function: merge
	merges an array
	
	Parameters
		table1 - the base table to override
		table2 - the table to merge with table1
	
	Return:
		table - the newly merged table
]]	
merge = function(t1, t2)
	for k,v in pairs(t2) do t1[k] = v end
	return t1
end
local _merge = merge

--[[!
	Function: mergeList
	Merges two lists to one big one containing all elements
	
	Parameters
		list1 - the base list to override
		list2 - the list to merge with list1

	Return:
		(table) the newly merged list
]]		
mergeList = function(array1, array2)
	local values = {}
		
	for i, item in pairs(array1) do
		values[item] = true
	end

	for i, item in pairs(array2) do
		values[item] = true
	end
		
	local list = {}
		
	for item, _ in pairs(values) do
		table.insert(list, item)
	end
		
	return list
end
local _mergeList = mergelist

--[[!
	Function: mergeRecursive
	Recursively merges an array and merges lists found
	
	Parameters
		table1 - the base table to override
		table2 - the table to merge with table1
	
	Return:
		table - the newly merged table
]]	
mergeRecursive = function(array1, array2, recursive)
	for name, value in pairs(array2) do
		if type(array1[name]) == "table" and type(value) == "table" then
			if isList(array1) and isList(array2) then
				array1[name] = _mergeList(array1[name], value)
			else
				array1[name] = _merge(array1[name], value, true)
			end
		else
			array1[name]  = value
		end
	end		

	return array1
end

function simpleCopy(t)
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return u
end

-- Copied from the lua-users wiki
function deepCopy(object)
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
function copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end
