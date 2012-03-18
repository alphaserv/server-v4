--[[alpha.acl = {
	players = {},
	groups = {},
	methods={}, --{name = "displayname", method=metheodname (also alpha.fn["methodname"])}
	
	addplayer = function(obj, id, flags)
		
	end,
	
	trycall = function(obj, player, fname)
	
	end,
}

alpha.acl_group = {
	roles = {},
}

alpha.acl_player = {
	roles = {},
	groups = {},
	
	allow = function (obj, resource_name, set)
		if set ~= nil then
			onj.roles[resource_name] = set
			return
		end
		
		if not onj.roles[resource_name] then
			local allow_l = 0
			for i, groupname in pairs(obj.groups) do
				if alpha.acl.groups[groupname].roles[resource_name] and alpha.acl.groups[groupname].roles[resource_name] > allow_l then
					allow_l = alpha.acl.groups[groupname].roles[resource_name]
				end
			end
			
			--cache
			obj.rolses[resource_name] = allow_l
		end
		
		return obj.rolses[resource_name]
	end,
	
	new = function (onj)
		local returning = {}
		for k, v in pairs(obj) do
			returning[k] = v
		end
		return returing
	end,
	
	addgroup = function (obj, name)
		obj.groups[name] = name
	end,
	
	delgroup = function (obj, name)
		obj.groups[name] = nil
	end,
	
	setrolepriv = function (obj, name, priv)
		obj.roles[name] = priv
	end
}

]]

module("alpha.acl", package.seeall)

function has_access
