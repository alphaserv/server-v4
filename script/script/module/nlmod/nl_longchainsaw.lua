--[[
	script/module/nl_mod/nl_longchainsaw.lua
	Authors:		Hanack (Andreas Schaeffer)
					X35
	Created:		24-Apr-2012
	Last Change:	24-Apr-2012
	License:		GPL3

	Function:
		Detect players with a chainsaw hack.

]]



--[[
		API
]]

longchainsaw = {}
longchainsaw.enabled = 1
longchainsaw.only_warnings = 1
longchainsaw.gun = 0
longchainsaw.min_malus = 3
longchainsaw.dist = { 30, 30, 30 } -- x, y, z
longchainsaw.malus = {}



--[[
		COMMANDS
]]

function server.playercmd_longchainsaw(cn, command, arg, arg2, arg3)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#longchainsaw <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.enabled = " .. longchainsaw.enabled)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.only_warnings = " .. longchainsaw.only_warnings)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.min_malus = " .. longchainsaw.min_malus)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.gun = " .. longchainsaw.gun)
				messages.info(cn, {cn}, "CHAINSAW", string.format("longchainsaw.dist = { %i, %i, %i }", longchainsaw.dist[1], longchainsaw.dist[2], longchainsaw.dist[3]))
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.enabled = " .. longchainsaw.enabled)
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.only_warnings = " .. longchainsaw.only_warnings)
			end
			if command == "min_malus" then
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.min_malus = " .. longchainsaw.min_malus)
			end
			if command == "gun" then
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.gun = " .. longchainsaw.gun)
			end
			if command == "dist" then
				messages.info(cn, {cn}, "CHAINSAW", string.format("longchainsaw.dist = { %i, %i, %i }", longchainsaw.dist[1], longchainsaw.dist[2], longchainsaw.dist[3]))
			end
		else
			if command == "enabled" then
				longchainsaw.enabled = tonumber(arg)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.enabled = " .. longchainsaw.enabled)
			end
			if command == "only_warnings" then
				longchainsaw.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.only_warnings = " .. longchainsaw.only_warnings)
			end
			if command == "min_malus" then
				longchainsaw.min_malus = tonumber(arg)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.min_malus = " .. longchainsaw.min_malus)
			end
			if command == "gun" then
				longchainsaw.insta_gun = tonumber(arg)
				messages.info(cn, {cn}, "CHAINSAW", "longchainsaw.gun = " .. longchainsaw.gun)
			end
			if command == "dist" and arg2 ~= nil and arg3 ~= nil then
				longchainsaw.dist[1] = tonumber(arg)
				longchainsaw.dist[2] = tonumber(arg2)
				longchainsaw.dist[3] = tonumber(arg3)
				messages.info(cn, {cn}, "CHAINSAW", string.format("longchainsaw.dist = { %i, %i, %i }", longchainsaw.dist[1], longchainsaw.dist[2], longchainsaw.dist[3]))
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("frag", function(target_cn, actor_cn, gun)
	if longchainsaw.enabled == 0 or gun ~= longchainsaw.gun then return end
	local a_pos_x, a_pos_y, a_pos_z = server.player_pos(actor_cn)
	local t_pos_x, t_pos_y, t_pos_z = server.player_pos(target_cn)
	-- messages.verbose(-1, players.admins(), "CHAINSAW", string.format("actor: %i (%i, %i, %i) target: %i (%i, %i, %i) weapon %i", actor_cn, math.floor(a_pos_x), math.floor(a_pos_y), math.floor(a_pos_z), target_cn, math.floor(t_pos_x), math.floor(t_pos_y), math.floor(t_pos_z), server.player_gun(actor_cn)))
	local dist_x = math.abs(a_pos_x - t_pos_x)
	local dist_y = math.abs(a_pos_y - t_pos_y)
	local dist_z = math.abs(a_pos_z - t_pos_z)
	if
		(dist_x > longchainsaw.dist[1]) or
		(dist_y > longchainsaw.dist[2]) or
		(dist_z > longchainsaw.dist[3])
	then
		longchainsaw.malus[actor_cn] = longchainsaw.malus[actor_cn] + 1
		if longchainsaw.malus[actor_cn] >= longchainsaw.min_malus then
			if longchainsaw.only_warnings == 1 then
				messages.warning(-1, players.admins(), "CHAINSAW", string.format("%s (%i) is using a long chainsaw hack. Distances: x: red<%i> y: red<%i> z: red<%i>", server.player_name(actor_cn), actor_cn, dist_x, dist_y, dist_z))
			else
				messages.error(-1, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of using a long chainsaw hack", server.player_name(actor_cn), actor_cn))
				cheater.autokick(actor_cn, "Server", "Long Chainsaw Hack")
			end
		end
	end
end)

server.event_handler("connect", function(cn)
	longchainsaw.malus[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	longchainsaw.malus[cn] = 0
end)

server.event_handler("mapchange", function()
	for _, cn in ipairs(players.all()) do
		longchainsaw.malus[cn] = 0
	end
end)
