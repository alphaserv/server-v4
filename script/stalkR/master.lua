
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
	info = nil,
	players = nil,
	id = nil,
	
	connection = nil,
	
	__init = function(self, ip, port, id)
		self.ip = ip
		self.port = port
		
		self.id = id
		
		--self:serverinfo()
		--self:read_info()
	end,
	
	serverinfo = function(self)
		self.connection = network.extinfo:connect(self.ip, self.port+1)

		self.connection:get_players()
	end,
	
	read_info = function(self)
		self.connection:read_extinfo()
		self.connection:close()
	end,
	
	set_gen_info = function(self, info)
		self.info = nil
	end,
	
	set_players = function(self, players)
		self.players = players
	end,
	
	add_player = function(self, player)
		self.players[player.cn] = player
	end,
})

function addserver (ip, port)
	local id = #servers +1
	servers[id] = server_obj(ip, port, id)
end

function get_server(id)
	return servers[id]
end

function clear_list()
	servers = {}
end


--addserver ("psl.sauerleague.org", 10000)
dofile(PREFIX.."master/client.lua")
dofile(PREFIX.."master/server.lua")

