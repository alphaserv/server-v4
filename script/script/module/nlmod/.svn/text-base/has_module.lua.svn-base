--[[
		Hide & Seek script by X35
]]

math.randomseed(os.time())

has_mode = false
doing_has = false
waiting_has = false
has_chief = false
has_seeker = false
has_nospawn = false
has_waitmap = false
has_no_seeker_spawn = false
has_lockteams = false
has_player_count = 0
has_finished_count = 0
has_gameover = false

function server.playercmd_has(cn, val)
	if server.player_priv(cn) ~= "admin" then
		server.player_msg(cn, "Error -> \f3Permission Denied.")
		return
	end
	if val == "0" then
		stop_has(cn)
	else
		start_has(cn)
	end
end

function ischief(cn)
	if (tonumber(cn) == has_chief) then
		return true
	else
		server.player_msg(cn, "Error -> \f3you are not the chief.")
	end
end

function server.playercmd_setchief(cn, ocn)
	if doing_has or waiting_has then
		if not ocn then ocn = cn else ocn = tonumber(ocn) end
		if server.player_priv(cn) ~= "none" then
			server.msg("Hide & Seek -> new chief \f0" .. server.player_displayname(ocn) .. "\f7.")
			has_chief = ocn
		else
			server.player_msg(cn, "Error -> \f3Permission Denied.")
		end
	else
		server.player_msg(cn, "Error -> \f3not playing Hide & Seek at the moment. \f7type \f3#has \f7to start a Hide & Seek game.")
	end
end

local function unsetpvars()
	for a in server.gclients() do
		server.player_unsetpvar(a.cn, "has_player")
	end
end

function server.playercmd_spec(cn, ocn)
	if ischief(cn) then
		if not ocn then ocn = cn else ocn = tonumber(ocn) end
		server.spec(ocn)
		server.player_unsetpvar(ocn, "has_player")
		server.msg("Hide & Seek -> " .. server.player_displayname(ocn) .. "\f3 doesn't play\f7.")
	end
end

function server.playercmd_unspec(cn, ocn)
	if ischief(cn) then
		if not ocn then ocn = cn else ocn = tonumber(ocn) end
		server.unspec(ocn)
		server.player_pvar(ocn, "has_player", true)
		server.msg("Hide & Seek -> " .. server.player_displayname(ocn) .. "\f0 plays\f7.")
	end
end

function server.playercmd_chief(cn)
	if has_chief then
		server.player_msg(cn, "Hide & Seek -> current chief is \f0" .. server.player_displayname(has_chief))
	else
		server.player_msg(cn, "Error -> \f3currently there is no chief.")
	end
end

function get_has_playercount()
	has_p_count = 0
	for a in server.gclients() do
		cn = a.cn
		if server.player_pvar(cn, "has_player") or server.player_status(cn) ~= "spectator" then
			server.player_pvar(cn, "has_player", true)
			has_p_count = has_p_count + 1
		end
	end
	return has_p_count
end

function getseekercn()
	if server.playercount < 1 then return -1 end
	if get_has_playercount == 0 then return -1 end
	count = 0
	while count < 100 do
		count = count + 1
		for a in server.gclients() do
			cn = a.cn
			if server.player_pvar(cn, "has_player") then
				rand = math.random(0, 4)
				if rand == 3 then
					return cn
				end
			end
		end
	end
	return -1
end

function start_has(cn)
	if has_mode then
		if cn == has_chief then
			server.player_msg(cn, "Error -> \f3Hide & Seek already running. type \f7#has 0 \f3to stop it.")
		else
			server.player_msg(cn, "Error -> \f3Hide & Seek already running.")
		end
	else
		p_count = 0
		for a in server.gclients() do
			if server.player_status(a.cn) ~= "spectator" or server.player_pvar(a.cn, "has_player") then
				server.player_pvar(a.cn, "has_player", true)
				p_count = p_count + 1
			end
		end
		server.player_pvar(cn, "has_player", true)
		server.unspec(cn)
		waiting_has = true
		has_mode = true
		has_chief = cn
		server.changetime(0)
		server.intermission = server.gamemillis + 60000
		for a in server.gclients() do
			cur_cn = a.cn
			if cur_cn == has_chief then
				if p_count < 1 then
					server.player_msg(cur_cn, "Hide & Seek -> mode \f0enabled\f7, you are the chief. Please set the players using \f0#spec <cn> \f7and \f0#unspec <cn>\f7, then vote for a map (using \f0multiplayer \f7-> \f0vote game mode / map\f7) to start the game within next \f060\f7 seconds!")
				else
					server.player_msg(cur_cn, "Hide & Seek -> mode \f0enabled\f7, you are the chief. Please vote for a map (using \f0multiplayer \f7-> \f0vote game mode / map\f7) to start the game within next \f060\f7 seconds!")
				end
			else
				server.player_msg(cur_cn, "Hide & Seek -> mode \f0enabled\f7, chief: \f0" .. server.player_displayname(has_chief) .. "\f7. Please wait for the chief to set the players and vote for a map.")
			end
		end
	end
end

function stop_has(cn)
	if cn ~= has_chief then
		server.player_msg(cn, "Error -> \f3you're not the chief.")
		return
	end
	if (not doing_has) and (not waiting_has) then
		server.player_msg(cn, "Error -> \f3no game running. type \f7#has \f3to start one.")
		return
	end
	doing_has = false
	has_mode = false
	waiting_has = false
	has_chief = false
	has_seeker = false
	has_nospawn = false
	has_waitmap = false
	has_no_seeker_spawn = false
	has_lockteams = false
	has_player_count = 0
	has_finished_count = 0
	unsetpvars()
	server.changetime(0)
	server.msg("Hide & Seek -> \f3Game stopped!")
end

function end_has()
	has_mode = false
	doing_has = false
	waiting_has = false
	has_chief = false
	has_seeker = false
	has_nospawn = false
	has_waitmap = false
	has_no_seeker_spawn = false
	has_lockteams = false
	has_player_count = 0
	has_finished_count = 0
	unsetpvars()
end

function restart_has(msg, time_is_out)
	if msg then msg = msg .. " " else msg = "" end
	has_gameover = true
	if (not time_is_out) then server.changetime(0) end
	server.intermission = server.gamemillis + 120000
	doing_has = false
	has_seeker = false
	has_nospawn = false
	has_waitmap = false
	has_no_seeker_spawn = false
	has_lockteams = false
	has_player_count = 0
	has_finished_count = 0
	waiting_has = true
	for a in server.gclients() do
		cur_cn = a.cn
		if cur_cn == has_chief then
			server.player_msg(cur_cn, "Hide & Seek -> " .. msg .. "\f0game is over\f7, you are still the chief. Please vote for a map (using \f0multiplayer \f7-> \f0vote game mode / map\f7) to start the game within next \f02\f7 minutes!")
		else
			server.player_msg(cur_cn, "Hide & Seek -> " .. msg .. "\f0game is over\f7, please wait for the chief \f0(" .. server.player_displayname(has_chief) .. ")\f7 to vote for a map.")
		end
	end
end

function spawn_hiders()
	has_nospawn = false
	for a in server.gclients() do
		cn = a.cn
		if cn ~= has_seeker then
			if server.player_status(cn) ~= "spectator" then
				server.spawn_player(cn)
			end
			server.player_msg(cn, "Hide & Seek -> \f3Run for your life! \f7The seeking player will spawn in \f35 \f7seconds!")
		else
			server.player_msg(cn, "Hide & Seek -> Hiding players spawned, you will spawn in \f35 \f7seconds! Frag players to catch them.")
		end
	end
end

function spawn_seeker()
	has_no_seeker_spawn = false
	server.spawn_player(has_seeker)
	for a in server.gclients() do
		cn = a.cn
		if cn ~= has_seeker then
			server.player_msg(cn, "Hide & Seek -> \f3The seeking player has spawned! Hurry up!")
		end
	end
end

function inithasgame()
	server.msg("Hide & Seek -> \f0everyone ready. \f7Hiding players will spawn in \f010\f7 seconds, seeking player will spawn in \f015\f7 seconds.")
	server.sleep(10000, function() spawn_hiders() end)
	server.sleep(15000, function() spawn_seeker() end)
end

function hiderscount()
	if server.playercount < 1 then return 0 end
	count = 0
	for a in server.gclients() do
		if server.player_pvar(a.cn, "has_player") and server.player_status(a.cn) ~= "spectator" and server.player_team(a.cn) == "Hide" then count = count + 1 end
	end
	return count
end

function seekercount()
	if server.playercount < 1 then return 0 end
	count = 0
	for a in server.gclients() do
		if server.player_pvar(a.cn, "has_player") and server.player_status(a.cn) ~= "spectator" and server.player_team(a.cn) == "Seek" then count = count + 1 end
	end
	return count
end

server.event_handler("mapvote", function(cn, map, mode)
	if (not has_mode) then return end
	if waiting_has and (not has_nospawn) and (not has_no_seeker_spawn) then
		if cn == has_chief then
			if get_has_playercount() ~= 0 then
				waiting_has = false
				server.changemap(map, "efficiency team", 7)
				doing_has = true
				has_nospawn = true
				has_waitmap = true
				has_no_seeker_spawn = true
				has_seeker = getseekercn()
				has_player_count = 0
				has_finished_count = 0
				has_loadmap = true
				for a in server.gclients() do
					ccn = a.cn
					if ccn == has_seeker then
						server.changeteam(ccn, "Seek")
					else
						server.changeteam(ccn, "Hide")
					end
					if server.player_status(a.cn) ~= "spectator" or server.player_pvar(a.cn, "has_player") then
						server.player_pvar(a.cn, "has_player", true)
						server.spec(a.cn)
						has_player_count = has_player_count + 1
					end
				end
				has_loadmap = false
				has_lockteams = true
				server.msg("Hide & Seek -> waiting for all players to load the map. Seeking player is: \f3" .. server.player_displayname(has_seeker))
			else
				server.player_msg(cn, "Error -> \f3you did not set any players, please do that using \f7#unspec <cn> \f3and \f7#spec <cn>\f7.")
			end
		else
			server.player_msg(cn, "Error -> \f3only the chief \f7(" .. server.player_displayname(has_chief) .. ") \f3can set a map.")
		end
		return -1
	elseif doing_has then
		if cn == has_chief then
			server.player_msg(cn, "Error -> \f3please type \f7#has 0 \f3and start a new game first.")
		else
			server.player_msg(cn, "Error -> \f3only the chief \f7(" .. server.player_displayname(has_chief) .. ") \f3can set a map.")
		end
		return -1
	end
end)

server.event_handler("maploaded", function(cn)
	if (not has_mode) then return end
	if has_waitmap then
		if server.player_pvar(cn, "has_player") then
			server.unspec(cn)
			has_finished_count = has_finished_count + 1
			if has_finished_count == has_player_count or has_finished_count > has_player_count then
				has_waitmap = false
				inithasgame()
			end
		end
	end
end)

server.event_handler("spawn", function(cn)
	if (not has_mode) then return end
	if has_nospawn then
		return -1
	elseif cn == has_seeker and has_no_seeker_spawn then
		return -1
	end
end)

server.event_handler("chteamrequest", function(cn)
	if (not has_mode) then return end
	if has_lockteams and server.player_status(cn) ~= "spectator" and (not server.player_pvar(cn, "allow_switch")) then
		server.player_msg(cn, "Error -> \f3you can't switch during a Hide & Seek game.")
		return -1
	else
		server.player_unsetpvar(cn, "allow_switch")
	end
end)

server.event_handler("damage", function(tcn, acn)
	if (not has_mode) then return end
	if (not doing_has) and (not waiting_has) then return end
	if tcn == acn then return -1
	elseif server.player_team(acn) == server.player_team(tcn) then server.player_msg(acn, "Error -> \f3teamkill not possible."); return -1
	elseif server.player_team(tcn) == "Seek" and server.player_team(acn) == "Hide" then server.player_msg(acn, "Error -> \f3you can't damage a seeker."); return -1 end
	
end)

server.event_handler("frag", function(tcn, acn)
	if (not has_mode) then return end
	if server.player_team(acn) == "Seek" and server.player_team(tcn) == "Hide" then
		server.player_pvar(tcn, "allow_switch", true)
		server.changeteam(tcn, "Seek")
		players = hiderscount()
		if players == 0 then
			restart_has("\f3" .. server.player_displayname(acn) .. " \f7caught \f0" .. server.player_displayname(tcn) .. "\f7,")
		else
			server.msg("Hide & Seek -> \f3" .. server.player_displayname(acn) .. " \f7caught \f0" .. server.player_displayname(tcn) .. "\f7, \f0" .. players .. "\f7 players left.")
		end
	end
end)

server.event_handler("suicide", function(cn)
	if (not has_mode) then return end
	server.sleep(10, function()
		if server.player_team(cn) == "Seek" then
			server.spawn_player(cn)
		elseif (not server.player_pvar(cn, "allow_switch")) then
			server.player_pvar(cn, "allow_switch", true)
			server.changeteam(cn, "Seek")
			players = hiderscount()
			if players == 0 then
				restart_has("\f0" .. server.player_displayname(cn) .. " killed himself\f7,")
			else
				server.msg("Hide & Seek -> \f0" .. server.player_displayname(cn) .. " killed himself\f7, \f0" .. players .. "\f7 players left.")
			end
		end
	end)
end)

server.event_handler("disconnect", function(cn)
	if (not has_mode) then return end
	if server.playercount > 1 then
		if cn == has_chief then
			has_chief = getseekercn()
			server.msg("Hide & Seek -> new chief: \f0" .. server.player_displayname(has_chief))
		end
		if server.playercount > 1 then
		if hiderscount() < 1 then
			new_hider = getseekercn()
			server.player_pvar(new_hider, "allow_switch", true)
			server.changeteam(new_hider, "Hide")
			server.msg("Hide & Seek -> new hiding player: \f0" .. server.player_displayname(has_seeker))
		elseif seekercount() < 1 then
			has_seeker = getseekercn()
			server.player_pvar(has_seeker, "allow_switch", true)
			server.changeteam(has_seeker, "Seek")
			server.msg("Hide & Seek -> new seeking player: \f3" .. server.player_displayname(has_seeker))
		end
		end
	else
		end_has()
	end
	if server.player_pvar(cn, "has_player") then
		has_player_count = has_player_count - 1
	end
end)

server.event_handler("spectator", function(cn, val)
	if (not has_mode) then return end
	if val == 1 and server.player_pvar(cn, "has_player") and (not has_loadmap) then
		if seekercount() == 0 then
			new_cn = getseekercn()
			if new_cn ~= -1 then
				has_seeker = new_cn
				server.player_pvar(has_seeker, "allow_switch", true)
				server.changeteam(has_seeker, "Seek")
				server.spawn_player(has_seeker)
				server.msg("Hide & Seek -> new seeker: " .. server.player_displayname(has_seeker))
			else
				end_has()
			end
		end
	end

	if has_waitmap then return end

	if val == 1 and server.player_pvar(cn, "has_player") then
		server.player_unsetpvar(cn, "has_player")
		server.msg("Hide & Seek -> " .. server.player_displayname(cn) .. " \f3doesn't play\f7.")
	elseif val == 0 and (not server.player_pvar(cn, "has_player")) then
		server.player_pvar(cn, "has_player", true)
		server.msg("Hide & Seek -> " .. server.player_displayname(cn) .. " \f0plays\f7.")
	end
end)

server.event_handler("connect", function(cn)
	if (not has_mode) then return end
	if server.mastermode > 1 then
		server.spec(cn)
		server.changeteam(cn, "Hide")
	end
end)

server.event_handler("mapchange", function()
	if (not has_mode) then return end
	if waiting_has then
		end_has()
		server.msg("Hide & Seek -> \f3the game was canceled \f7(chief vote timeout) type \f3#has \f7to start a game.")
	end
end)

server.event_handler("intermission", function()
	if (not has_mode) then return end
	if (not has_gameover) and doing_has then
		restart_has("\f3timeout\f7,", true)
	end
end)
		
