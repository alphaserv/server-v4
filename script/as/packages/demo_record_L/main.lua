
module("demo_record", package.seeall)

local path = alpha.settings.new_setting("demo_path", "log/demo/", "path where to store demo recordings.")
local auto_record = alpha.settings.new_setting("demo_autorecord", true, "record demos for every game.")

recording = false

function record()
	local gamemodeinfo = server.get_gamemode_info()
	local players = players.groups.all()
	
	if recording then
		log_msg(LOG_NOTICE, "not recording demo: already recording")
		return false, "not recording demo: already recording"
	elseif gamemodeinfo.edit then
		log_msg(LOG_NOTICE, "not recording demo: gamemode is coop edit")
		return false, "not recording demo: gamemode is coop"
	else #players == 0 then
		log_msg(LOG_NOTICE, "not recording demo: server is empty")
		return false, "not recording demo: server is empty"
	end
	
	local gamemode = mode = server.gamemode:gsub(" ", "_")
	local filepath = path:get()
	
	--add ending slash
	if filepath[#filepath] ~= "/" then
		filepath = filepath .. "/"
	end
	
	local filename = "%s%s.%s.%s.dmo"

	filename = filename:format(filepath, mode, server.map, os.date("!%y_%m_%d.%H_%M"))
	
	recording = true
	messages.load("demo", "recording_start", {default_type = "info", default_message = "Recording demo"})
		:send(players, false)
		
	return true, server.recorddemo(filename)
end

function stop_recording()
	server.stopdemo()
	recording = false
end

server.event_handler("mapchange", function()
	if auto_record:get() then
		record()
	end
end)

server.event_handler("connect", function(cn)
	if not recording and auto_record:get() then
		record()
	end
end)

--[[
server.event_handler("alpha:empty", function(cn, reason)
	if recording then
		stop_recording()
	end
end)]]

server.event_handler("finishedgame", function()
	if recording then
		stop_recording()
	end
end)

command_from_table("demo", {
	name = "demo",
	
	list = function(self, player)
		if player:has_permission("command_demo:see_enabled") then
			return true, "orange<demo>"
		else
			return false, ""
		end
	end,
	
	help = function(self, player)
		if player:has_permission("command_demo:see_enabled") then
			return true, "Enable or disable demorecording for one match."
		else
			return false, ""
		end
	end,
	
	execute = function(self, player, command)
		if not command then
			if player:has_permission("command_demo:see_enabled") then
				if recording then
					return false, {"demo recording is: green<enabled>"}
				else
					return false, {"demo recording is: red<disabled>"}
				end
			else
				return false, {"You don't have the permission to execute this command!"}
			end
		end
		
		command = tostring(command)

		if command == "1" then
			if player:has_permission("command_demo:enable") then
				local result, message = record()
			
				if not result then
					return false, {message}
				else
					return true, {"Enabled demorecording for this match"}
				end
			else
				return false, {"you don't have the permission to enable demo recording!"}
			end
		elseif command == "0" then
			if player:has_permission("command_demo:disable") then
				stop_recording()
				return true, {"stopped demorecording"}
			else
				return false, {"you don't have the permission to disable demo recording!"}
			end
		end
	end,
})
