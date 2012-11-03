module("as.userlist", package.seeall)

local UserList = newclass("UserList")

UserList.users = {}

function UserList:filter(filter, attr, reverse)
	local attr = attr or {}
	local reverse = reverse and true
	
	local f = as.filters.userFilter.find(filter)
	f:init(attr)

	local newList = {}

	for i, user in pairs(self.users) do
		local res = f:match(user)
		if (res or reverse) and not (res and reverse) then
			table.insert(newList, user)
		end
	end
	
	self.users = newList
	
	return self
end

function UserList:each(func)
	for i, user in ipairs(self.users) do
		func(i, user)
	end
	
	return self
end

function new(users)
	local list = UserList()
	list.users = users or as.user.getList()
	return list
end
