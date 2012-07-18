--[[!
    File: script/components/db/init.lua

    About: Author
        Killme

    About: Copyright
        Copyright (c) 2012 Alphaserv project

    About: Purpose
		This file provides the database connection and brings the connection and an orbit model together

	About: Package components.db
]]

module("components.db", package.seeall, as.component)

require "components.db.connection"

db = class.new(class.new(component, db.connection.connection), {
	--[[!
		Property: _orbitConnection
		the orbit model dao connection
	]]	
	_orbitConnection = {},
	
	--[[!
		Function: initSettings
		This function initializes the class by loading the settings
		and imports the components
			
		Parameters:
			self - 
			settings - an array of config settings for this component
	]]	
	initSettings = function(self, array)
		--[[
			Provide shorthand linking to other components
		]]
		for as, dependic in pairs(self.import) do
			self[as] = _G.as.as[dependic]
		end
		
		self.credentials = table.merge(self.credentials, array)
		
		self._orbitConnection = static ("orbit.model", "").new(self.credentials.prefix or "", self, self.credentials.type)
	end,

	--[[!
		Function: model
		Creates a new orbit model
					
		Parameters:
			self - 
			... - additional parameters to orbitConnection:new()
		
		Return:
			the newly created orbit model
	]]	
	model = function(self, ...)
		return self._orbitConnection:new(...)
	end,

	--[[!
		Function: initDone
		event that occurs after having load this component
					
		Parameters:
			self - 
	]]
	initDone = function(self)
		print "Successfully loaded database component"
		
		local model = self:model("users"):find_all()
		_G.as.table.table.print_r(model)
	end,
	
})

