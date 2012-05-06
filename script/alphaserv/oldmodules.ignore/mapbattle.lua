mapbattle = {}
local votes1 = 0
local votes2 = 0
local has_voted = {}
local map_changed = false
local mapa = nil
local mapb = nil
local mode = nil
local voted = 0

function mapbattle.reset_votes()
votes1 = 0
votes2 = 0
has_voted = {}
map_changed = false
mode = nil
mapa = nil
mapb = nil
voted = 0

end
function mapbattle.winner(map1, map2)
if votes1 < votes2 then
    messages.info("mapbattle", players.all(), blue("winner:"..blue(map2)))
    return map2
else
    messages.info("mapbattle", players.all(), blue("winner:"..blue(map1)))
    return map1
end
end

maprotation.intermissionmodes[maprotation.intermissionmode_AUTO_MAPBATTLE] = function (map1, map2, gamemode) 
server.sleep(1000, function()
mapbattle.reset_votes()
mapa = map1
mapb = map2
mode = gamemode
messages.info("mapbattle", players.all(), green("MAPBATTLE"))
messages.info("mapbattle", players.all(), blue("vote for map ")..green(map1)..blue(" or ")..green(map2)..blue(" with 1 or 2"))

server.sleep(30000, function()
	if not maprotation.intermission then return end
    if not map_changed then
	server.changemap(mapbattle.winner(map1, map2), gamemode)
	map_changed = true
    end
end)
end)
end
server.event_handler("mapchange", function()
map_changed = true
end)
server.event_handler("text", function(cn, text)
if not maprotation.intermission then return end
if text == tostring(1) or text == tostring(map1) then
    if has_voted[cn] == true then
        messages.warning("mapbattle", {cn}, red("You have voted already"), true)
    else
	votes1 = votes1 + 1
	voted = voted + 1
	has_voted[cn] = true
	messages.info("mapbattle", players.all(), "green<name<"..cn..">> voted for blue<"..mapa..">")
	messages.info("mapbattle", players.all(), blue("vote for map ")..green(mapa)..blue(" or ")..green(mapb)..blue(" with 1 or 2"))
    end
elseif text == tostring(2) or text == tostring(map2) then
    if has_voted[cn] == true then
        messages.warning("mapbattle", {cn}, red("You have voted already"))
    else
	    votes2 = votes2 + 1
	    voted = voted + 1
	    has_voted[cn] = true
	    messages.info("mapbattle", players.all(), "green<name<"..cn..">> voted for blue<"..mapb..">")
	    messages.info("mapbattle", players.all(), blue("vote for map ")..green(mapa)..blue(" or ")..green(mapb)..blue(" with 1 or 2"))
	end
end
if voted > (#players.active()/1.5) or voted == (#players.active()/1.5) then
    if map_changed == true then return end
    map_changed = true
    server.changemap(mapbattle.winner(mapa, mapb), mode)
end
end)
