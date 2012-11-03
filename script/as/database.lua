--[[!
	Mysql databse "for now"
	we will use the database that is alos used by the web interface in the futute.
	TODO
]]

require "as.config"
local luasql = require ("luasql.mysql")

module("as.database", package.seeall)

local config = as.config.loadSection("db", {
	databaseName = "alphaserv",
	username = "root",
	password = "",
	host = "localhost",
	port = 3306,
})
local env = assert(luasql.mysql())
local connection

local function connect()
	connection = assert(
		env:connect(
			config.databaseName,
			config.username,
			config.password,
			config.host,
			config.port
		)
	)
end

local function cleanup()
	connection:close()
	env:close()
	env = luasql.mysql()
end

local function checkConnection()
	return connection or connect()
end


local function runQuery(sql)
	checkConnection()
	
	return assert(connection:execute(sql))
end

function insert(model)
	local TEMPLATE = "INSERT INTO %(name)s (%(fields)s) VALUES (%(values)S);"
	local FIELDTEMPLATE = "%(name)s"
	local VALUETEMPLATE = "%(value)q"
	
	local insert = ""
	local values = ""

	local first = true
	for i, field in pairs(model.getFields()) do
		if not first then
			insert = insert .. ", "
			values = values .. ", "
		else
			first = false
		end
		
		insert = insert .. (FIELDTEMPLATE % {name = field})
		values = values .. (VALUETEMPLATE % {value = model[field]})
	end
	
	return runQuery(TEMPLATE % {
		name = model:getName(),
		fields = insert,
		values = values,
	})
end

function findAllByAttributes(model, attr)
	local TEMPLATE = "SELECT * FROM %(table)s WHERE %(where)s;"
	local ATTRSTRING = "%(key)s = %(value)q"
	
	local attrs = "1"
	for key, value in pairs(attr) do
		attrs = attrs .. " AND "
		
		attrs = attrs .. (ATTRSTRING % {
			key = key,
			value = value
		})
	end
	
	return fetch(runQuery(TEMPLATE % {table = model:getName(), where = attrs}))
end

function findByAttributes(model, attr)
	return findAllByAttributes(model, attr)[1]
end

function findByID(model, id)
	return findByAttributes(model, {id=id})
end

function update(id, model)
	local TEMPLATE = "UPDATE %(name)s SET %(vars)s WHERE id = %(id)i;"
		
	local vars = ""
	
	local first = true
	for i, field in pairs(model.getFields()) do
		if not first then
			vars = vars .. ", "
		else
			first = false
		end
		
		vars = vars .. "%(name)s = %(value)q" % {name = field, value = model[field]}		
	end
	
	return runQuery(TEMPLATE % {
		id = id,
		name = model:getName(),
		vars = vars,
	})	
end

local function fetch(result)
	local rows = {}
	
	row = cur:fetch ({}, "a")
	while row do
		table.insert(rows, row)
		row = cur:fetch (row, "a")
	end
	
	return rows, result:numrows()
end

