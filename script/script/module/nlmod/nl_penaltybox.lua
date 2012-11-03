--[[
	script/module/nl_mod/nl_penaltybox.lua
	PeterPenacka
	Created: 2-Mar-2010
	Last modified: 9-Mar-2010
	Based on: nl_camping.lua, nl_teamkiller.lua by Hanack
	License: GPL3

	The infamous Nooblounge penlaty box.
	Forcing a player into spectator as punishment for misbehaving.
	
	Featues:
	 * 
	
	Provides:
	 * A function for putting a player into the box to be used by other modules
	 * An admin command for manually putting a player into the penalty box
]]



penaltybox = {}

penaltybox.module_name = "PENALTY BOX"

penaltybox.penalty_countdown_interval = 5		-- Interval for notice to player
penaltybox.reconnect_sleep = 5					-- Time to wait after reconnect
penaltybox.reason_shortcuts = {					-- Shortcuts for common reasons
	tk="intentional teamkilling",
	sc="spawncamping",
	gp="disrupting gameplay",
	lag="excessive lagging"}

penaltybox.max_penalty_duration = 3600			-- Maximum duration of a penalty in seconds

-- Reconnect detection
penaltybox.penalties = {}						-- Active penalties by penalty ID
penaltybox.namedetection = {}					-- Penalties by player name
penaltybox.ipdetection = {}						-- Penalties by player IP
penaltybox.penalty_id = 0						-- Counter for penalties

--[[
	TODO: keep track of different penalties 
]]

--[[
	API-
]]

---	Modified version of teamkiller.penalty / camping.penalty by Hanack
-- Put a player into the penalty box for a specified duration and reason
--
-- @param cn CN of the player to punish
-- @param duration Duration of the penalty in seconds
-- @param reason Reason for the penalty
function penaltybox.penalty(cn, duration, reason)
	local duration = tonumber(duration)
	local cn = tonumber(cn)
	
	if duration > penaltybox.max_penalty_duration then
		duration = penaltybox.max_penalty_duration
	end
	
	penaltybox.penalty_id = penaltybox.penalty_id + 1
	local penalty_id = penaltybox.penalty_id
	local playerName = server.player_name(cn)
	local playerIp = server.player_ip(cn)
	local penalty = { duration=duration, reason=reason }
	
	if penaltybox.namedetection[playerName] == nil then
		penaltybox.namedetection[playerName] = {}
	end
	penaltybox.namedetection[playerName][penalty_id] = penalty
	if penaltybox.ipdetection[playerIp] == nil then
		penaltybox.ipdetection[playerIp] = {}
	end
	penaltybox.ipdetection[playerIp][penalty_id] = penalty
	penaltybox.penalties[penalty_id] = penalty
	
	spectator.fspec(cn, reason, penaltybox.module_name)
	for s = 1, (duration / penaltybox.penalty_countdown_interval) - 1 do
		server.sleep(s * penaltybox.penalty_countdown_interval * 1000,
			function()
				if penaltybox.penalties[penalty_id] == nil then
					return
				end
				penaltybox.do_with_player_penalty(penaltybox.namedetection,
					playerName, penalty_id,
					function(penalty)
						messages.warning(cn, {cn},
							string.format("PENALTY (%s)", penalty["reason"]),
							string.format("%i orange<seconds left>",
								(duration - (s * penaltybox.penalty_countdown_interval))))
					end)
			end)
	end
	if penaltybox.penalties[penalty_id] == nil then
		return
	end
	server.sleep(duration * 1000, function()
			penaltybox.do_with_player_penalty(penaltybox.namedetection,
				playerName, penalty_id,
				function(penalty)
					penaltybox.unpenalty(cn, playerName, playerIp, penalty_id)
				end)
		end)
end



--- End the penalty of a player
-- @param cn CN of the player
-- @param playerName Name of the player
-- @param playerIp IP of the player
function penaltybox.unpenalty(cn, playerName, playerIp, penalty_id)
	local cn = tonumber(cn)
	if not server.valid_cn(cn) then
		messages.debug(cn, players.admins(), penaltybox.module_name, string.format("Could not unspec player %s (%d). Maybe he left the server.", playerName, cn))
		return
	end
	if playerName == server.player_name(cn) and playerIp == server.player_ip(cn) then
		local reason = penaltybox.namedetection[playerName][penalty_id]["reason"]
		-- Only unspec player if there are no other penalties
		if count_penalties(playerName) == 1 then
			spectator.funspec(cn, reason, penaltybox.module_name)
			messages.debug(cn, players.admins(), string.format("PENALTY (%s)", reason), string.format("Player %s (%s) left penalty box.", playerName, cn))
			messages.info(-1, {cn}, string.format("PENALTY (%s)", reason), string.format("green<Your penalty for %s is over!>", reason))
		else
			messages.warning(-1, {cn}, string.format("PENALTY (%s)", reason), string.format("orange<Your penalty for %s is over!> red<But you cannot leave the penalty box because of other penalties.>", reason))
		end
		
		
		
		penaltybox.remove_penalty(penaltybox.namedetection[playerName], penalty_id)
		penaltybox.remove_penalty(penaltybox.ipdetection[playerIp], penalty_id)
		penaltybox.remove_penalty(penaltybox.penalties, penalty_id)
	end
end


--[[
	COMMANDS
]]

--- Admin command for putting a player into the penalty box
-- @param issuer_cn CN of the player who issued the command
-- @param target_cn The player who shall be put into teh penalty box
-- @param duration The desired duration of the penalty in seconds
-- @param reason The reason for the penalty
function server.playercmd_penaltybox(issuer_cn, target_cn, duration, reason, ...)
	local issuer_cn = tonumber(issuer_cn)
	local target_cn = tonumber(target_cn)
	local duration = tonumber(duration)
	local reason = tostring(reason)
	local usage = "Usage: #penaltybox <CN> <DURATION> <REASON>"
	
	if not hasaccess(issuer_cn, admin_access) then
		return
	end
	if not target_cn then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Missing CN! %s", usage))
		return
	end
	if not server.valid_cn(target_cn) then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Invalid CN! %s", usage))
		return
	end
	if not duration then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Missing duration! %s", usage))
		return
	elseif duration > penaltybox.max_penalty_duration then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Penalty duration can be no more than %d seconds!",
				penaltybox.max_penalty_duration))
		return
	elseif duration < 0 then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			"Penalty duration cannot be negative!")
		return
	end
	if not reason then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Missing reason! %s", usage))
		return
	end
	messages.debug(cn, players.admins(), "PENALTY BOX",
		string.format(
			"New penalty, reason = \"%s\"",
			reason))
	if penaltybox.reason_shortcuts[reason] ~= nil then
		reason = penaltybox.reason_shortcuts[reason]
	end
	
	for _, item in ipairs(arg) do
		item = tostring(item)
		if #item > 0 then
			if #reason > 0 then
				reason = reason .. " "
			end

			reason = reason .. item
		end
	end
	
	-- Initiate penalty
	penaltybox.penalty(target_cn, duration, reason)
	
	-- Notify all players
	messages.info(-1, players.all(), "PENALTY BOX",
		string.format(
			"%s has been placed in the penalty box by %s for %d seconds because of %s",
			server.player_displayname(target_cn),
			server.player_displayname(issuer_cn),
			duration,
			reason))
end



--[[
	Shortcut for #penaltybox : #pbox
]]
server.playercmd_pbox = server.playercmd_penaltybox



---	Admin command for releasing a player from the penalty box
-- @param issuer_cn The CN of the player who issued the command
-- @param target_cn The CN of the player who shall be released from the penalty box
-- @param reason The reason for releasing the player
function server.playercmd_penaltybox_release(issuer_cn, target_cn, reason, ...)
	local issuer_cn = tonumber(issuer_cn)
	local target_cn = tonumber(target_cn)

	local usage = "Usage: #penaltybox_release <CN> [<REASON>]"
	
	if not hasaccess(issuer_cn, admin_access) then
		return
	end
	
	if issuer_cn == target_cn then
		messages.error(issuer_cn, {issuer_cn}, "ERROR",
			string.format("You cannot release yourself from the penalty box."))
		return
	end
	
	if not target_cn then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Missing CN! %s", usage))
		return
	end
	if not server.valid_cn(target_cn) then
		messages.error(issuer_cn, {issuer_cn}, "WARNING",
			string.format("Invalid CN! %s", usage))
		return
	end
	
	
	local playerName = server.player_name(tonumber(cn))
	local playerIp = server.player_ip(tonumber(cn))
	
	penaltybox.do_with_penalties(cn,
		penaltybox.namedetection[playerName], 0,
		"You have been released from the penalty box",
		function(cn, id, penalty)
			penaltybox.unpenalty(cn, playerName, playerIp, id)
		end)
	
	if not reason then
		messages.info(-1, players.all(), "PENALTY BOX",
			string.format("%s has been released from the penalty box by %s",
				server.player_displayname(target_cn),
				server.player_displayname(issuer_cn)))
	else
		for _, item in ipairs(arg) do
			item = tostring(item)
			if #item > 0 then
				if #reason > 0 then
					reason = reason .. " "
				end
				reason = reason .. item
			end
		end
		messages.info(-1, players.all(), "PENALTY BOX",
			string.format(
				"%s has been released from the penalty box by %s because of %s",
				server.player_displayname(target_cn),
				server.player_displayname(issuer_cn),
				reason))
	end
end

--- Shortcut for #penaltybox_release : #pbox_release
server.playercmd_pbox_release = server.playercmd_penaltybox_release



--[[
	EVENTS
]]

-- Handle penalty evasion by reconnect
server.event_handler("connect", function(cn)
		local playerName = server.player_name(cn)
		local playerIp = server.player_ip(cn)
		local message = "red<  [ PENALTY BOX ]  Detected player penalty on reconnect.>"
		-- Check if a player with this name has a penalty left
		if penaltybox.namedetection[playerName] ~= nil
		and table.maxn(penaltybox.namedetection[playerName]) > 0 then
			penaltybox.do_with_penalties(cn,
				penaltybox.namedetection[playerName],
				penaltybox.reconnect_sleep * 1000,
				message,
				function(cn, id, penalty)
					penaltybox.remove_penalty(
						penaltybox.namedetection[playerName], id)
					penaltybox.remove_penalty(
						penaltybox.ipdetection[playerIp], id)
					penaltybox.penalty(cn, penalty["duration"], penalty["reason"])
				end)
		-- Check if a player with this IP has a penalty left
		elseif penaltybox.ipdetection[playerIp] ~= nil
		and table.maxn(penaltybox.ipdetection[playerIp]) > 0 then
			penaltybox.do_with_penalties(cn,
				penaltybox.ipdetection[playerIp],
				penaltybox.reconnect_sleep * 1000,
				message,
				function(cn, id, penalty)
					penaltybox.remove_penalty(
						penaltybox.namedetection[playerName], id)
					penaltybox.remove_penalty(
						penaltybox.ipdetection[playerIp], id)
					penaltybox.penalty(cn, penalty["duration"], penalty["reason"])
				end)
		end
	end)



--- Deactivate a player's active penalties on isconnect
server.event_handler("disconnect",
	function(cn)
		local playerName = server.player_name(cn)
		if penaltybox.namedetection[playerName] == nil then
			return
		end
		messages.debug(cn, players.admins(), "PENALTY BOX",
			string.format(
				"Player %s (%d) left the server, suspending active penalties.",
				playerName, cn))
		for id, penalty in pairs(penaltybox.namedetection[playerName]) do
			messages.debug(cn, players.admins(), "PENALTY BOX",
				string.format("Suspending %s's penalty #%d, %d seconds for %s",
					playerName, id, penalty["duration"], penalty["reason"]))
			penaltybox.penalties[id] = nil
		end
	end)



--[[
	HELPER FUNCTIONS
]]

--- Applies a function to all penalties of a player given by cn
-- after waiting for wait_mesecs milliseconds and displaying a message
-- @param cn CN of the player
-- @param penalties table with penalties of the player
-- @param wait_msecs time to wait in milliseconds
-- @param message message to send the player upon initiating the penalty
-- @param func: function to apply
function penaltybox.do_with_penalties(cn, penalties, wait_msecs, message, func)
	server.sleep(wait_msecs, function()
		server.player_msg(cn, message)
		for id,penalty in pairs(penalties) do
			func(cn, id, penalty)
		end
	end)
end



--- Apply a function to all penalties of a certain player in a table of
-- multiple players' penalties
-- @param penalties table of multiple players' penalties
-- @param player_id ID of the player, used as key in the penalties table
-- @param penalty_id ID of the penalty
-- @param func function to call
function penaltybox.do_with_player_penalty(penalties, player_id, penalty_id, func)
	if penalties[player_id] ~= nil
	and penalties[player_id][penalty_id] ~= nil then
		func(penalties[player_id][penalty_id])
	end
end



--- Remove a penalty from a table of penalties
-- @param penalties Table of penalties
-- @param penalty_id ID of the penalty to remove, key in table
function penaltybox.remove_penalty(penalties, penalty_id)
	if penalties ~= nil and penalties[penalty_id] ~= nil then
		penalties[penalty_id] = nil
	end
end



--- Count the penalties of a player
-- @param player_name The CN of the player for whom the penalties shall be counted
function count_penalties(player_name)
	penalty_count = 0
	if penaltybox.namedetection[player_name] == nil then return 0 end
	for id, penalty in pairs(penaltybox.namedetection[player_name]) do
		penalty_count = penalty_count + 1
	end
	return penalty_count
end