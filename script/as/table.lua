--[[!
    File: script/as/table.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This provides table utils used by the core

	About: Package as.table
	
	TODO: move this to the global table.*
]]

module("as.table", package.seeall, as.component)

--[[!
    Class: table
    An Object for table manipulation
    
    Note: most of the members are static
]]

table = {

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
	end,
	
	add_tabs = function(string, i)
		i = tonumber(i) or 0
		if i <= 0 then
			return string
		else
			i = i - 1
		end
		
		string = "\t"..string
		
		return table.add_tabs(string, i)
	end,

	print_r = function(t, i)
		i = i or 0
		
		if i > 100 then
			print "RECURSION?"
			return
		end

		if i == 0 then		
			print (table.add_tabs("{", i))
		end
		for k, v in pairs(t) do
			if type(v) == "table" then
				print (table.add_tabs(("[%q]"):format(tostring(k)) .. " = {", i+1))
				table.print_r(v, i+2)
				print (table.add_tabs("},", i+1))
			elseif type(v) == "number" then
				print (table.add_tabs(("[%q] = %i"):format(tostring(k), tonumber(v)), i+1))
			else
				print (table.add_tabs(("[%q] = %q"):format(tostring(k), tostring(v)), i+1))
			end
		end
		
		if i == 0 then
			print (table.add_tabs("},", i))
		end
	end,

	--[[!
		Function: mergeArray
		Recursively merges an array
	
		Parameters
			table1 - the base table to override
			table2 - the table to merge with table1
	
		Return:
			(table) the newly merged table
	]]	
	mergeArray = function(array1, array2, recursive)
	
		--table.print_r({array1, array2})
		--[[
		for key, value in pairs(array1) do
			if type(value) == "table" and type(array2[key]) == "table" then
				if table.isList(value) and table.isList(array2[key]) then
					array1[key] = table.mergeList(value, array2[key])
				else
					array1[key] = table.mergeArray(array1[key], array2[key], true)
				end
			else
				array1[key] = array2[value]
			end
		end
		
		--Append items that were not in array1
		for key, value in pairs(array2) do
			if not array1[key] then
				array1[key] = value
			end
		end
		]]
		
		for name, value in pairs(array2) do
			if type(array1[name]) == "table" and type(value) == "table" then
				array1[name] = table.mergeArray(array1[name], value, true)
			else
				array1[name]  = value
			end
		end		
		
		--table.print_r({array1})
			
		return array1
	end,

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
			_G.table.insert(list, item)
		end
		
		return list
	end,
}
