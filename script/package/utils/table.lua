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
	Recursively merges an array
	
	Parameters
		table1 - the base table to override
		table2 - the table to merge with table1
	
	Return:
		(table) the newly merged table
]]	
merge = function(array1, array2, recursive)
	for name, value in pairs(array2) do
		if type(array1[name]) == "table" and type(value) == "table" then
			if isList(array1) and isList(array2) then
				array1[name] = mergeList(array1[name], value)
			else
				array1[name] = merge(array1[name], value, true)
			end
		else
			array1[name]  = value
		end
	end		

	return array1
end

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
