if not alpha then error("trying to load 'db.lua' before alpha init."); return end

local db_load
if not alpha.standalone then
	db_load = server.create_event_signal("db_loaded")
end

local RECONNECT = 3000
local connected = false


alpha.settings.register_type("dbvar", class.new(alpha.settings.setting_obj, {

	set = function(self, value)
		if not connected then
			self.setting = value
		else
			error('NOT IMPLEMENTED: changing mysql connection settings while connected, please disconnect first', 2)	
		end
		
		return self
	end

}))

local db_host = alpha.settings.new_setting("db_host", "localhost", "the host of the database to use", "dbvar")
local db_port = alpha.settings.new_setting("db_port", 3306, "the port of the database to use", "dbvar")
local db_name = alpha.settings.new_setting("db_dbname", "alphaserv", "the name of the database to use", "dbvar")
local db_username = alpha.settings.new_setting("db_username", "alphaserv", "the username of the database user to use", "dbvar")
local db_password = alpha.settings.new_setting("db_password", "alphaserv", "the password of the database user to use", "dbvar")

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
				db_name:get(),
				db_username:get(),
				db_password:get(),
				db_host:get(),
				db_port:get()
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

if not alpha.standalone then
	server.event_handler("started", function()
		alpha.db:open("mysql")
		alpha.db:connect()
		db_load()
		server.cancel_event_signal("db_loaded")
	end)
end 
