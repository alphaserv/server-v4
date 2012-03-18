
module("alpha.api", package.seeall)

module_obj = class.new(nil, {
	functions = {},
	__init = function(self, name)
	
	end,
	
	add_function = function(name, func, access)
		--TODO: do something with access? -> default values acl in db?
		functions[name] = func
	end,

})

local modules = {}

function module(name)
	modules[name] = module_obj(name)
	
	return modules[name]
end
