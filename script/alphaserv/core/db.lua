if not alpha then error("trying to load 'db.lua' before alpha init."); return end

local db_load = server.create_event_signal("db_loaded")

alpha.settings.init_setting("db_host", "localhost", "string", "the host of the database to use")
alpha.settings.init_setting("db_port", 3306, "int", "the port of the database to use")
alpha.settings.init_setting("db_dbname", "alphaserv", "string", "the name of the database to use")
alpha.settings.init_setting("db_username", "alphaserv", "string", "the username of the database user to use")
alpha.settings.init_setting("db_password", "alphaserv", "string", "the password of the database user to use")

local RECONNECT = 3000
local connected = false

local resultobject = {
	sql_result = nil,
	rows = {},
	result = function(obj, result)
		obj.sql_result = result
	end,
	new = function (obj, sql_result)
		local returning = {}
		for a, b in pairs(obj) do
			returning[a] = b
		end
		returning:result(sql_result)
		return returning
	end,
	
	fetch = function(obj)
		local this = {
				['rows'] = {},
				['addrow'] = function (this, row, i)
					local count = #this.rows+1
					if i then count = i end
					this.rows[count] = {}
					for a, b in pairs(row) do
						this.rows[count][a] = b
					end
				end
			}
		local i = 0
		row = obj.sql_result:fetch ({}, "a")
		while row do
			i = i + 1 --add 1
			this:addrow(row, i)
			row = obj.sql_result:fetch (row, "a")
		end
		return this.rows
	end,
	
	_ = function(obj)
		local r = obj:fetch()
		obj:close()
		return 
	end,
	
	numrows = function(obj)
		return obj.sql_result:numrows()
	end,

	num_rows = function(obj)
		return obj:numrows()
	end,
}

alpha.db = {
	env = nil,
	connection = nil,
	connected = false,
	connect = function (obj)
		if not obj.env then error('Please open an enviroment first') end
		obj.connection = assert(
			obj.env:connect(
				alpha.settings:get('db_dbname'),
				alpha.settings:get('db_username'),
				alpha.settings:get('db_password'),
				alpha.settings:get('db_host'),
				alpha.settings:get('db_port')
			)
		)
		obj.connected = true
	end,
	open = function (obj, type_, ...)
		if not type_ then type_ = 'mysql' end
		if type_ == 'mysql' then
			require "luasql_mysql"
		else
			require ("luasql."..type_)
		end			
		obj.env = assert(luasql[type_](unpack(arg or {})))
	end,
	disconnect = function (obj, reconnect)
		obj.connection:close()
		obj.env:close()
		connected = false
				
		if reconnect == true then
			server.sleep(RECONNECT, function()
				obj.connect()
			end)
		end
	end,
	query = function(obj, sql, ...)

		if not obj.connected then error('Cannot execute query: not connected to a database') end
		
		if not arg then
			arg = {}
--		elseif type(arg[1]) == 'table' then
--			arg = arg[1]
		end
		
		local i = 0
		local replacements = {}
		
		for k, v in pairs(arg) do replacements[#replacements+1] = v end
		sql = string.gsub(sql, "([?])", function ()
			i = i + 1
			if replacements[i] == nil then
				error("field count and variable count do not match in query: "..sql..". arg["..i.."] = nil in: "..table_to_string(replacements))
			end
			return string.format("%q", replacements[i])
		end)
		
		local result = assert (obj.connection:execute(sql))

		if not result then
			server.sleep(1, function() obj:disconnect(true) end)
			error('sql generated an error:  "'..sql..'", returned: "'..tostring(result)..'", reconnecting')
		end
		
		--insert or delete query
		if result == true or result == 1 then return true end
		
		return resultobject:new(result)
	end
}

--try to reconnect when a variable changes
local function varchange(_, _, name)
	if connected then
		--[[
		if not db.connect()
		if success then
			return true
		else
			--invalid
			error('Could not change mysql connection setting variable, INVALID')
			return false
		end]]
		error('NOT IMPLEMENTED: changing mysql connection settings while connected, please disconnect first')
	else
		return true
	end
end

server.event_handler("started", function()
	alpha.db:open("mysql")
	alpha.db:connect()
	db_load()
	server.cancel_event_signal("db_loaded")
end)

--TODO: make api for this
if not alpha.settings.settings['db_host'].triggers.set then alpha.settings.settings['db_host'].triggers.set = {} end
alpha.settings.settings['db_host'].triggers.set[#alpha.settings.settings['db_host'].triggers.set+1] = varchange
if not alpha.settings.settings['db_port'].triggers.set then alpha.settings.settings['db_port'].triggers.set = {} end
alpha.settings.settings['db_port'].triggers.set[#alpha.settings.settings['db_port'].triggers.set+1] = varchange
if not alpha.settings.settings['db_username'].triggers.set then alpha.settings.settings['db_username'].triggers.set = {} end
alpha.settings.settings['db_username'].triggers.set[#alpha.settings.settings['db_username'].triggers.set+1] = varchange
if not alpha.settings.settings['db_password'].triggers.set then alpha.settings.settings['db_password'].triggers.set = {} end
alpha.settings.settings['db_password'].triggers.set[#alpha.settings.settings['db_password'].triggers.set+1] = varchange
