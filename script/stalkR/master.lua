
require("net")

module("master", package.seeall)
--[[ Confiruation Part ]]--

alpha.settings.init_setting("master_port", 28787, "int", "the port to run the masterserver on")
alpha.settings.init_setting("master_ip", "0.0.0.0", "string", "the ip to run the masterserver on")

alpha.settings.init_setting("master_extern_port", 28787, "int", "the port of an external masterserver to sync with")
alpha.settings.init_setting("master_extern_host", "sauerbraten.org", "string", "the host of an external masterserver to sync with")

alpha.settings.init_setting("master_extern_sync", true, "bool", "enable sync with external masterserver")

alpha.settings.init_setting("master_debug", true, "bool", "debug masterserver")
alpha.settings.init_setting("master_colors", true, "bool", "color masterserver messages")

--[[ Rewritten part]]--

--servers online
servers = {}

function debug(message, ...)
	if not alpha.settings:get('master_debug') then
		return
	end
	
	message = string.format(message, ...)
	
	if alpha.settings:get("master_colors") then
		message = string.char(27).."[32m"..--[[os.data("%x %X")..]]"[debug] |"..message..string.char(27) .. "[0m"
	else
		message = --[[os.data("%x %X")..]]"[debug] |"..message
	end
	
	print(message)
end

server_obj = class.new(nil, {
	ip = nil,
	port = nil,
	
	__init = function(self, ip, port)
		self.ip = ip
		self.port = port
	end,
})

function addserver (ip, port)
	table.insert(servers, server_obj(ip, port))
end

function clear_list()
	servers = {}
end

dofile(PREFIX.."master/client.lua")
dofile(PREFIX.."master/server.lua")

