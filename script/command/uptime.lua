-- [[ Player command written by Thomas

return function(cn)
    server.player_msg(cn, "Server-Uptime: " .. server.format_duration_str(server.uptime / 1000))
end
