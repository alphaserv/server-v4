module("as.auth", package.seeall)

require "as.baseModel"
require "as.models.User"
require "as.models.Name"

local clanTags = {}

function checkAuth(user)
	user = type(user) == "table" and user or as.user.getUser(user)

	if user:isAuthorised() then
		return
	end
	
	local model = as.models.User():findByName(
		user:getName()
	)

	local protected = false
		
	if model ~= nil then
		protected = 1
	else		
		for i, tag in pairs(clanTags) do
			if user:getName():find(tag) then
				protected = 2
				break
			end
		end
	end	
	
	if protected == nil then
		return
	end
	
	User:sendRawMessage("You have failed to authenticate!")
	local lock = as.spectator.Lock()
	lock.name = "Authentication failed"
	lock.type = protected --!TODO custom lock class
	user.authLock = user:addSpectatorLock(Lock)
	user:checkSpectatorLocks()
end

function checkLogin(user, password)
	user = type(user) == "table" and user or as.user.getUser(user)
	local model = as.models.User():findByName(
		user:getName()
	)
	
	if model and user:checkPassword(model.password, password) then
		user:sendRawMessage("Authorized!")
		user:authorize(model)
	end
end

function logout(user)
	user = type(user) == "table" and user or as.user.getUser(user)
	user.userId = -1
	checkAuth(user)
end


function init()
	as.server.onConnect:addListner(checkAuth)
	as.server.onConnecting:addListner(function(cn, hostname, name, password)
		checkLogin(as.user.getUser(cn), password)
	end)

	as.server.onSetmaster:addListner(checkLogin)

	as.server.onRename:addListner(function(cn)
		logout(cn)
		checkAuth(cn)
	end)

	as.server.onRename:addListner(function(cn)
		logout(cn)
		checkAuth(cn)
	end)
end
