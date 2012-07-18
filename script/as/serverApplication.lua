depend "as.component"

module("as.serverApplication", package.seeall, as.component)

serverApplication = class.new(nil, {
	__init = function(self)
		--[[
			Settings to assign to the c++ code
		]]
		local coreSettings = {
			name = "servername",
			ip = "serverip",
			port = "serverport",
			maxClients = "maxclients",
			specSlots = "specslots",
			reservedSlots = "reserved_slots",
			reservedSlotsPassword = "reserved_slots_password",
			serverPassword = "server_password",
			ctfTeamkillPenalty = "ctf_teamkill_penalty",
			uptime = "uptime",
			enetTime = {"enet_time_set", "enet_time_get"},
		}

		for internalName, name in pairs(coreSettings) do
			local setterName = name
			if type(name) == "table" then
				name = name[1]
				setterName = name[2]
			end
			
			self:define_getter(
				internalName,
				function(self, name)
					if _G.core.vars[name] then
						return _G.core.vars[name]()
					else
						return _G.core[name]()
					end
				end,
				name
			)
			self:define_setter(
				internalName,
				function(self, value, name)
					if _G.core.vars[name] then
						return _G.core.vars[name](value)
					else
						return _G.core[name](value)
					end
				end,
				setterName
			)
		end
	end,

	init = function(self)
	
	end,
	
	load = function(self)
	
	end,
	
	initConfigVar = function(self, var, value)
		self[var] = value
	end,
	
	run = function(self)
		print "app run"
	end,
	
	--!TODO: add more core.* functions in here
})
