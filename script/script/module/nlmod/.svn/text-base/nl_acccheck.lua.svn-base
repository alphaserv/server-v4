--[[
	script/module/nl_mod/nl_acccheck.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		26-Jun-2012
	Last Modified:	26-Jun-2012
	License:		GPL3

	Funktionen:
		* 

]]



--[[
		API
]]

acccheck = {}
acccheck.enabled = 1
acccheck.only_warnings = 1
acccheck.min_frags = 15
acccheck.min_acc = 80
acccheck.insta_gun = 4
acccheck.check_interval = 2500
acccheck.got_warned = {}
acccheck.insta_shots = {}
acccheck.insta_misses = {}
acccheck.insta_frags = {}

-- accuracy (nur riffle schuesse)
function acccheck.insta_accuracy(cn)
	return math.floor(acccheck.insta_frags[cn] / math.max(acccheck.insta_shots[cn], 1) * 100)
end
    
function acccheck.check()
	if gamemodes.is_insta() then
		for _, cn in ipairs(players.all()) do
			local acc = acccheck.insta_accuracy(cn)
			local shots = acccheck.insta_shots[cn]
			local misses = acccheck.insta_misses[cn]
			local frags = acccheck.insta_frags[cn]
			if frags >= acccheck.min_frags and acc >= acccheck.min_acc and acccheck.got_warned[cn] == nil then
				messages.warning(cn, players.admins(), "ACCCHECK", string.format("Is player blue<%s (%i)> too good? accuracy: red< %s> frags: red< %s> shots: red< %s> misses: red< %s>", server.player_name(cn), cn, tostring(acc), tostring(frags), tostring(shots), tostring(misses)))
				acccheck.got_warned[cn] = 1
			end
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_acccheck(cn, command, arg)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#acccheck <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.enabled = " .. acccheck.enabled)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.only_warnings = " .. acccheck.only_warnings)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_frags = " .. acccheck.min_frags)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_acc = " .. acccheck.min_acc)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.insta_gun = " .. acccheck.insta_gun)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.enabled = " .. acccheck.enabled)
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.only_warnings = " .. acccheck.only_warnings)
			end
			if command == "min_frags" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_frags = " .. acccheck.min_frags)
			end
			if command == "min_acc" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_acc = " .. acccheck.min_acc)
			end
			if command == "insta_gun" then
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.insta_gun = " .. acccheck.insta_gun)
			end
		else
			if command == "enabled" then
				acccheck.enabled = tonumber(arg)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.enabled = " .. acccheck.enabled)
			end
			if command == "only_warnings" then
				acccheck.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.only_warnings = " .. acccheck.only_warnings)
			end
			if command == "min_frags" then
				acccheck.min_frags = tonumber(arg)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_frags = " .. acccheck.min_frags)
			end
			if command == "min_acc" then
				acccheck.min_acc = tonumber(arg)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.min_acc = " .. acccheck.min_acc)
			end
			if command == "insta_gun" then
				acccheck.insta_gun = tonumber(arg)
				messages.info(cn, {cn}, "ACCCHECK", "acccheck.insta_gun = " .. acccheck.insta_gun)
			end
		end
	end
end



--[[
		EVENTS
]]


server.event_handler("connect", function(cn)
	acccheck.got_warned[cn] = nil
	acccheck.insta_frags[cn] = 0
	acccheck.insta_shots[cn] = 0
	acccheck.insta_misses[cn] = 0
end)

server.event_handler("disconnect", function(cn)
	acccheck.got_warned[cn] = nil
	acccheck.insta_frags[cn] = 0
	acccheck.insta_shots[cn] = 0
	acccheck.insta_misses[cn] = 0
end)

server.event_handler("mapchange", function()
	acccheck.got_warned = {}
	for _, cn in ipairs(players.all()) do
		acccheck.insta_frags[cn] = 0
		acccheck.insta_shots[cn] = 0
		acccheck.insta_misses[cn] = 0
	end
end)

--server.event_handler("frag", function(target_cn, actor_cn, gun)
--	if not gamemodes.is_insta() or gun ~= acccheck.insta_gun then return end
--	acccheck.insta_frags[actor_cn] = acccheck.insta_frags[actor_cn] + 1
--end)

server.event_handler("shot", function(cn, gun, hits)
	if gamemodes.is_insta() and gun == acccheck.insta_gun then
		acccheck.insta_shots[cn] = acccheck.insta_shots[cn] + 1
		if hits == 0 then
			acccheck.insta_misses[cn] = acccheck.insta_misses[cn] + 1
		else
			acccheck.insta_frags[cn] = acccheck.insta_frags[cn] + 1
		end
	end
end)

server.interval(acccheck.check_interval, acccheck.check)
