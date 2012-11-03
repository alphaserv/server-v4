
module("as.filters", package.seeall)

local userFilters = {}

UserFilter = newclass("UserFilter")

--Find filter by name
function UserFilter.find(name)
	return userFilters[name]
end

function addFilter(name, instance)
	userFilters[name] = instance
end

UserFilter.options = {}
function UserFilter:init(options)
	self.options = options or {}
end

function UserFilter:match(user)
	return false
end
