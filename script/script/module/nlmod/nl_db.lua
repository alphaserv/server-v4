--[[
	script/module/nl_mod/nl_db.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		23-Okt-2010
	Last Modified:	23-Okt-2010
	License: GPL3

	Funktionen:
		Stellt einen Datenbank-Abstraktionslayer zur Verfügung, um den Zugriff auf die Datenbank
		zu vereinfachen und zu standardisieren.

	API-Methoden:
		db.insert(db_table, data)
			Fügt einen Datensatz in die Tabelle db_table ein. Die Daten liegen in der Variablen
			data vor, wobei Key und Value berücksichtigt werden.
			z.B. wird in die Spalte id der Wert 20 gespeichert: data['id'] = 20
		db.select(db_table, keys, where)
		db.select_and(db_table, keys, where)
		db.select_or(db_table, keys, where)

	Konfigurations-Variablen:
		db.templates
			Verschiedene Templates für SQL Anfragen.

	Laufzeit-Variablen:
		db.env
			Zugriff auf die Lua MySQL Umgebung
		db.con
			Eine Datenbank-Verbindung zu MySQL


]]



require "luasql_mysql"

--[[
		API
]]

db = {}
db.env = assert(luasql.mysql())
db.con = assert(db.env:connect(server.stats_mysql_database, server.stats_mysql_username, server.stats_mysql_password, server.stats_mysql_hostname, server.stats_mysql_port))
db.templates = {}
db.templates.select = [[SELECT %s FROM %s]]
db.templates.selectWhere = [[SELECT %s FROM %s WHERE %s]]
db.templates.selectOrderBy = [[SELECT %s FROM %s WHERE %s ORDER BY %s]]
db.templates.insert = [[INSERT IGNORE INTO %s (%s) VALUES (%s)]]
db.templates.update = [[UPDATE %s SET %s WHERE %s]]
db.templates.delete = [[DELETE FROM %s WHERE %s]]

server.interval(6000, function()
	local sql = string.format(db.templates.select, "label", "nl_announce")
	local cur = assert (db.con:execute(sql))
end)

function db.parseDateTime(str)
	--"2011-10-25T00:29:55.503-04:00"
	local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
	local xyear, xmonth, xday, xhour, xminute, xseconds = str:match(pattern)
	return os.time({year = xyear, month = xmonth, day = xday, hour = xhour, min = xminute, sec = xseconds})
--  return os.time({year=Y, month=M, day=D, hour=(h+oh), min=(m+om), sec=s})
end

function db.escape(s)
	if s ~= nil then
		return string.gsub(s, "'", "\\'")
	end
	return nil
end

function db.insert(db_table, data)
	local keys = {}
	local values = {}
	for key, value in pairs(data) do
		table.insert(keys, key)
		if utils.is_numeric(value) then 
			table.insert(values, value)
		else
			table.insert(values, string.format("'%s'", db.escape(value)))
		end
	end
	local keys_string = table.concat(keys, ", ")
	local values_string = table.concat(values, ", ")
	local sql = string.format(db.templates.insert, db_table, keys_string, values_string)
	local cur = assert (db.con:execute(sql))
end

function db.update(db_table, data, where)
	local sql = string.format(db.templates.update, db_table, db.get_fields_string(data), where)
	local cur = assert (db.con:execute(sql))
end

function db.insert_or_update(db_table, data, where)
	local data2 = db.select(db_table, {"*"}, where)
	if #data2 > 0 then
		db.update(db_table, data, where)
	else
		db.insert(db_table, data)
	end
end

function db.delete(db_table, where)
	local sql = string.format(db.templates.delete, db_table, where)
	local cur = assert (db.con:execute(sql))
end

function db.select_and(db_table, keys, where)
	return db.select(db_table, keys, db.get_where(where, " AND "))
end

function db.select_or(db_table, keys, where)
	return db.select(db_table, keys, db.get_where(where, " OR "))
end

function db.select(db_table, keys, where, orderBy)
	local data = {}
	local keys_string = table.concat(keys, ", ")
	local sql = ""
	if where ~= nil then
		if orderBy ~= nil then
			sql = string.format(db.templates.selectOrderBy, keys_string, db_table, where, orderBy)
		else
			sql = string.format(db.templates.selectWhere, keys_string, db_table, where)
		end
	else
		sql = string.format(db.templates.select, keys_string, db_table)
	end
	-- server.msg(sql)
	local cur = assert (db.con:execute(sql))
	if cur:numrows() > 0 then
		local row = cur:fetch ({}, "a")
		while row do
			table.insert(data, utils.table_copy(row))
			row = cur:fetch (row, "a")
		end
	end
	return data
end

function db.get_where(where, op)
	local where_values = {}
	for key, value in pairs(where) do
		if utils.is_numeric(value) then 
			table.insert(where_values, string.format("%s = %i", key, value))
		else
			table.insert(where_values, string.format("%s = '%s'", key, db.escape(value)))
		end
	end
	return table.concat(where_values, op)
end

function db.get_fields_string(data)
	local fields_values = {}
	for key, value in pairs(data) do
		if utils.is_numeric(value) then 
			table.insert(fields_values, string.format("%s = %i", key, value))
		else
			table.insert(fields_values, string.format("%s = '%s'", key, db.escape(value)))
		end
	end
	return table.concat(fields_values, ", ")
end

function db.create_table(db_table, schema)
	local sql = ""
	for key, value in pairs(schema) do
		-- TODO
	end
end
