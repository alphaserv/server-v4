--[[!
    File: script/components/db/connection.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This provides the database connection object

	About: Package db.connection
]]

module("db.connection", package.seeall)

--TODO: move!
table.merge = function(t1, t2)
	for k,v in pairs(t2) do t1[k] = v end
	return t1
end

--[[!
	Class: connection
	connection wrapper class that implements reconnecting on errors, logging queries, autoconnecting and more
]]

connection = class.new(nil, {
	--[[!
		Property: _connection
		the luasql connection resource
	]]
	_connection = nil,

	--[[!
		Property: _env
		the luasql driver resource
	]]
	_env = nil,

	--[[!
		Property: credentials
		An table containing the connection credentials
	]]	
	credentials = {
		type = "mysql",
		
		database = "alphaserv",
		host = "localhost",
		port = 3306,
		
		username = "root",
		password = "",
		
		timeout = 4000 * 60 * 60, --4 hours
	},

	--[[!
		Property: lastAction
		time in miliseconds of the last action, is used together with credentials.timeout to reconnect when there is too much time between two actions
	]]
	lastAction = as.as.app.uptime,
	
	--[[!
		Function: __init
		initializes the class with database credentials
		
		Parameters:
			self -
			credentials - a table containing the database credentials
	]]
	__init = function(self, credentials)
		if credentials then
			--!use merge here so that we can have default values
			self.credentials = table.merge(self.credentials, credentials)
		end
	end,
	
	--[[!
		Function: getConnection
		internally used function to retreive the connection object and set lastaction
		
		Parameters:
			self -
		
		Return:
			the luasql connection resource
	]]
	
	getConnection = function(self)
		--auto connect
		if not self._connection then
			self:openConnection()
		
		--reconnect
		elseif self.lastAction + self.credentials.timeout < as.as.app.uptime then
			self:reconnect()
		end
		self.lastAction = as.as.app.uptime
	
		return self._connection
	end,

	--[[!
		Function: openEnv
		internally used to include the luasql_* and open the env
		
		Parameters:
			self -
	]]	
	openEnv = function(self)
		require ("luasql_"..self.credentials.type)
		local errorString
		self._env, errorString = luasql[self.credentials.type]()
		
		if not self._env then
			error(
				as.as:log("fatal", "db", "Could not load database driver: %(1)s", errorString)
			)
		end
	end,

	--[[!
		Function: openConnection
		internally used to connect to the database with the credentials provided in _init
		
		Parameters:
			self -
	]]		
	openConnection = function(self)
		if not self._env then
			self:openEnv()
		end
	
		--env:connect(sourcename[,username[,password[,hostname[,port]]]])
		local errorString
		self._connection, errorString = self._env:connect(
			self.credentials.database,
			self.credentials.username,
			self.credentials.password,
			self.credentials.host,
			self.credentials.port
		)
		
		if not self._connection then
			error(
				as.as:log("fatal", "db", "Could not connect to the database: %(1)s", errorString)
			)
		end
	end,
	
	--[[!
		Function: open
		see openConnection
		
		Parameters:
			self -
	]]	
	open = function(self, ...)
		return self:openConnection(...)
	end,
	
	--[[!
		Function: closeEnv
		internally used to close the env when the connection is closed
		
		Parameters:
			self -
	]]
	closeEnv = function(self)
		local res, errorString = self._env:close()
		
		if not res then
			error(
				as.as:log("fatal", "db", "Could not close env: %(1)s", errorString)
			)
		end
	end,
	
	--[[!
		Function: closeConnection
		closes the database connection and the env
		
		Parameters:
			self -
	]]	
	closeConnection = function(self)
		local res, errorString = self._connection:close()
		
		if not res then
			error(
				as.as:log("fatal", "db", "Could not close connection: %(1)s", errorString)
			)
		end
		
		self:closeEnv()	
	end,

	--[[!
		Function: close
		see closeConnection
		
		Parameters:
			self -
	]]		
	close = function(self, ...)
		return self:closeConnection(...)
	end,
	
	--[[!
		Function: reConnect
		reconnect to the database
		
		Parameters:
			self -
	]]	
	reConnect = function(self)
		self:closeConnection()
		self:openConnection()
	end,
	
	--[[!
		Function: escape
		escapes a string
		
		Parameters:
			self -
			string - the string to escape
	]]
	escape = function(self, ...)
		local connection = self:getConnection()
		
		if connection.escape then
			return connection:escape(...)
		else
			--escape like: aa's":) => "aa\'s:)" => aa\'s:)
			return ("%q"):escape(...):gsub("^(.).*?(.)$", "")
		end
	end,
	
	--[[!
		Function: execute
		executes an sql query
		
		Parameters:
			self -
			string - the string to execute
		
		Return: cursor object
	]]
	execute = function(self, ...)
		as.as:log("info", "db", "Executing query: %(1)s", ...)
		
		return self:getConnection():execute(...)
	end,
	
	--[[!
		Function: commit
		Commits the current transaction. This feature might not work on database systems that do not implement transactions.
		Returns: true in case of success and false when the operation could not be performed or when it is not implemented.
	]]
	
	commit = function(self, ...)
		as.as:log("info", "db", "Executing commit")
		
		if not self:getConnection():commit(...) then
			as.as:log("warning", "db", "Database system does not support commits!")
			return false
		else
			return true
		end
	end,

	--[[!
		Function: rollback
		Rolls back the current transaction. This feature might not work on database systems that do not implement transactions.
		Returns: true in case of success and false when the operation could not be performed or when it is not implemented.
	]]
	rollback = function(self, ...)
		as.as:log("info", "db", "Executing rollback")
		
		if not self:getConnection():rollback(...) then
			as.as:log("warning", "db", "Database system does not support rollbacks!")
			return false
		else
			return true
		end		
	end,

	--[[!
		Function: setautocommit
		Function: setAutoCommit
		Turns on or off the "auto commit" mode. This feature might not work on database systems that do not implement transactions.
		On database systems that do not have the concept of "auto commit mode", but do implement transactions, this mechanism is implemented by the driver. 
		Returns: true in case of success and false when the operation could not be performed or when it is not implemented.
	]]
	setautocommit = function(self, value, ...)
		as.as:log("info", "db", "Executing setautocommit %(1)i", value and 1 or 0)
		
		if not self:getConnection():setautocommit(...) then
			as.as:log("warning", "db", "Database system does not support autocommits!")
			return false
		else
			return true
		end		
	end,

	setAutoCommit = function(self, ...)
		return self:setautocommit(...)
	end,
})
