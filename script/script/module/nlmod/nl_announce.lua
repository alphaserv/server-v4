--[[
	script/module/nl_mod/nl_announce.lua
	Authors:		Hanack (Andreas Schaeffer)
	Created:		20-Sep-2010
	Last Modified:	13-Aug-2012
	License:		GPL3

	Funktionen:
		Es werden wichtige bzw. weniger wichtige Informationen an alle Spieler gesendet.

	Commands:
		#announce <TEXT>
			xyz

	API-Methoden:
		announce.xyz()
			xyz

	Konfigurations-Variablen:
		announce.xyz
			xyz
]]



--[[
		API
]]

announce = {}
announce.interval = 45000
announce.start_delay = 3000
announce.loaded = false
announce.current = 0
announce.max_mname = 7
announce.banners = {}

function announce.next()
	if maprotation.intermission_running == 0 and announce.loaded == true and #announce.banners > 0 then
		announce.current = announce.current + 1
		local banners = announce.banners
		if announce.current > #banners then
			announce.current = 1
		end
		messages.info(-1, players.all(), banners[announce.current].label, banners[announce.current].text)
		-- server.msg(green("  [ " .. banners[announce.current].label .. " ]  ") .. banners[announce.current].text)
	end
end

function announce.load()
	if server.nmgrpid ~= nil then
		announce.banners = db.select("nl_announce", { "id", "active", "name", "label", "text" }, string.format("active = 1 AND server = '%s'", server.nmgrpid) )
	else
		announce.banners = db.select("nl_announce", { "id", "active", "name", "label", "text" }, "active = 1")
	end
	announce.loaded = true
	messages.debug(-1, players.admins(), string.format("Successfully loaded %s announces", #announce.banners))
end

function announce.get_all_banners()
	local banners = {}
	if server.nmgrpid ~= nil then
		banners = db.select("nl_announce", { "id", "active", "name", "label", "text" }, string.format("server = '%s'", server.nmgrpid) )
	else
		banners = db.select("nl_announce", { "id", "active", "name", "label", "text" })
	end
	return banners
end

function announce.get_named_announce(name)
	local banners = {}
	if server.nmgrpid ~= nil then
		banners = db.select("nl_announce", { "id", "active", "name", "label", "text" }, string.format("server = '%s' and name = '%s'", server.nmgrpid, name))
	else
		banners = db.select("nl_announce", { "id", "active", "name", "label", "text" }, string.format("name = '%s'", name))
	end
	if #banners == 0 then
		return nil
	else
		return banners[1]
	end
end



--[[
		COMMANDS
]]

function server.playercmd_announce(cn, command, arg, arg2, arg3, arg4)
	if not hasaccess(cn, admin_access) then return end
	if command == nil then
		return false, "#announce <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "ANNOUNCE", string.format("red<%i> green<announces loaded for server> red<%s>", #announce.banners, server.nmgrpid))
				messages.info(cn, {cn}, "ANNOUNCE", "announce.interval = " .. announce.interval)
				messages.info(cn, {cn}, "ANNOUNCE", "announce.current = " .. announce.current)
			end
			if command == "reload" then
				announce.load()
			end
			if command == "next" then
				announce.next()
			end
			if command == "list" then
				messages.info(cn, {cn}, "ANNOUNCE", "List of all active messages:")
				for i,banner in pairs(announce.get_all_banners()) do
					messages.info(cn, {cn}, "ANNOUNCE", string.format("  [ %s ]  %s blue<NAME: %s> blue<ID: %i> blue<ACTIVE: %i>", banner.label, banner.text, banner.name, banner.id, banner.active))
				end
			end
			if command == "interval" then
				messages.info(cn, {cn}, "ANNOUNCE", "announce.interval=" .. announce.interval)
			end
		else
			if command == "new" then
				if arg2 == nil or arg3 == nil then
					return false, "#announce new <NAME> <LABEL> <TEXT> [<ACTIVE>]"
				end
				local announce_active = 1
				if arg4 ~= nil then
					local is_active = tonumber(arg4)
					if is_active ~= nil then
						announce_active = is_active
					end
				end
				local announce_name = string.lower(tostring(arg))
				local announce_label = string.upper(tostring(arg2))
				local announce_text = tostring(arg3)
				db.insert("nl_announce", { name=announce_name, label=announce_label, text=announce_text, active=announce_active, frequency=1, server=server.nmgrpid })
				messages.info(cn, {cn}, "ANNOUNCE", string.format("Announce %s successfully created", announce_name))
				announce.load()
			end
			if command == "enable" then
				local announce_id = tonumber(arg)
				db.update("nl_announce", { active = 1 }, string.format("id=%i", announce_id))
				messages.info(cn, {cn}, "ANNOUNCE", string.format("Announce %i enabled", announce_id))
				announce.load()
			end
			if command == "disable" then
				local announce_id = tonumber(arg)
				db.update("nl_announce", { active = 0 }, string.format("id=%i", announce_id))
				messages.info(cn, {cn}, "ANNOUNCE", string.format("Announce %i disabled", announce_id))
				announce.load()
			end
			if command == "send" then
				if arg2 == nil then
					messages.info(-1, players.all(), "INFO", arg)
				else
					local module_name = string.sub(string.upper(arg), 1, announce.max_mname) -- convert to uppercase, strip to max_mname chars
					messages.info(-1, players.all(), module_name, arg2)
					messages.info(-1, players.admins(), "ANNOUNCE", string.format("blue<This message was brought to you by %s>", server.player_displayname(cn)))
				end
			end
			if command == "predefined" then
				local announce_name = tostring(arg)
				local named_announce = announce.get_named_announce(announce_name)
				if named_announce == nil then
					messages.error(cn, {cn}, "ANNOUNCE", string.format("No announce name orange<%s> found", announce_name))
				else
					messages.info(-1, players.all(), named_announce.label, named_announce.text)
				end
			end
			if command == "interval" then
				announce.interval = arg
				messages.info(cn, {cn}, "ANNOUNCE", "announce.interval=" .. announce.interval)
			end
		end
	end
end



--[[
		EVENTS
]]

server.interval(announce.interval, announce.next)

server.event_handler("started", function()
	server.sleep(announce.start_delay, function()
		announce.load()
	end)
end)

