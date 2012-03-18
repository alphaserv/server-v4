
demo = {}
demo.recording = false

function demo.record(name, force)
	if demo.recording and (not force) then
		debug.write(-1, "could not record demo: already recording")
		return false
	elseif gamemodeinfo.edit then
		debug.write(-1, "could not record demo: gamemode is coop")
		return -1
	elseif (#players.all < 2) then
		debug.write(-1, "could not record demo: too less players")
		return -2
	end
	local filename = "log/demo/%s/%s.%s.dmo"
	if name then filename = name end
    mode = string.gsub(server.gamemode, " ", "_")
	filename = string.format(filename, mode, server.map, os.date("!%y_%m_%d.%H_%M"))
	demo.recording = true
	messages.info("demo", players.all(), config.get("demo:message"))
	messages.debug("demo", players.admins(), string.format(config.get("demo:admin_message"), messages.escape(filename)))
	return server.recorddemo(filename)
end

function demo.stop_recording()
	server.stopdemo()
	demo.recording = false
end

server.event_handler("mapchange", function()
	if config.get("demo:autorecord") then
		demo.record()
	end
end)

server.event_handler("connect", function(cn)
	if #players.all() > 1 and config.get("demo:autorecord") then
		demo.record()
	end
end)

server.event_handler("alpha:empty", function(cn, reason)
	demo.stop_recording()
end)

server.event_handler("finishedgame", function()
	demo.stop_recording()
end)

cmd.command_function("demo", function(cn, force, name)
	if prov.has(cn, priv.OWNER) then
		if not force or not name then
			return false, config.get("usage:demo")
		end
		demo.record((name or false), (force or false))
		return
	end
	demo.record()
end, priv.ADMIN)
