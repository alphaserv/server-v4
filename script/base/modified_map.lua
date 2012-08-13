local modified_clients = {}
function server.modified_map_clients()
    return modified_clients
end

local function failed_action(cn)
    server.force_spec(cn)
    modified_clients[server.player_sessionid(cn)] = cn
end

server.event_handler("modmap", function(cn, map, crc)

    if map ~= server.map or server.gamemode == "coop edit" then
        return
    end

    server.log(string.format("%s(%i) is using a modified map (crc %s)", server.player_name(cn), cn, crc))  
    failed_action(cn)

end)

server.event_handler("disconnect", function(cn)
    modified_clients[server.player_sessionid(cn)] = nil
end)

server.event_handler("mapchange", function()
    modified_clients = {}
end)

server.event_handler("checkmaps", function(cn)
    for sessionid, cn in pairs(modified_clients) do
        server.player_msg(cn, string.format("%s is using a modified map", server.player_displayname(cn)))
    end
end)


