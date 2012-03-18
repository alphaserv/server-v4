module("alpha.user", package.seeall)
--[[
users = {}

user = class.new(nil, {

	__init = function(self, ...)
		--print("hello world, i am a USER")
		--print(unpack(arg))
	end,

})

user_classes = {}
user_class = ""

events = {}

function init()
	local std_user = "StdUser"
	user_classes[std_user] = user
	user_class = std_user
	
	events.OnConnect = server.event_handler("connect", OnConnect)
end

function new_user(...)
	user_classes[user_class](unpack(arg))
end

function get_cn_from_sid(session_id)
	for i, cn in pairs(players.all) do
		if session_id == server.player_session_id(session_id) then
			return cn
		end
	end
	
	return -1
end

function OnConnect(cn)
	table.insert(users, new_user_instance(cn))
end

function OnDisconnect(cn)
	for i, user in pairs(users) do
		if not user:check() then
			user:disconnect()
			users[i] = nil
		end
	end
end
user("my name is LOL", "I hate u")]]
