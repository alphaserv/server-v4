server.event_handler("mapcrc", function(cn, map, crc)
	irc_say("MAPCRC: " .. server.player_name(cn) .. " (" .. cn .. "), " .. map .. ": " .. crc)
	server.log("MAPCRC: " .. server.player_name(cn) .. " (" .. cn .. "), " .. map .. ": " .. crc)
end)
