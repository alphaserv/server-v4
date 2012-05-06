local game_is_paused = false

server.event_handler("gamepaused", function() game_is_paused = true end)
server.event_handler("gameresumed", function() game_is_paused = false end)

function alpha.resume(by)
    server.pausegame(false)
    if ( by == -1 ) or ( by == nil ) or not server.valid_cn(by) then
        byn = "the server"
        messages.info(-1, players.all(), string.format(config.get("messages:pause"),byn,"resumed"), false)
    else
        byn = "name<"..by..">"
        messages.info(by, players.all(), string.format(config.get("messages:pause"),byn,"resumed"), false)
    end
end
function alpha.pause(by)
    server.pausegame(true)
    if (by == -1 ) or ( by == nil ) or not server.valid_cn(by) then
        byn = "the server"
        messages.info(-1, players.all(), string.format(config.get("messages:pause"),byn,"paused"), false)
    else
        byn = "name<"..by..">"
        messages.info(by, players.all(), string.format(config.get("messages:pause"),byn,"paused"), false)
    end
end
