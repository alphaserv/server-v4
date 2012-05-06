require "crypto"
--||--///FUNCTIONS\\\--||--
local function loadmap (mapname, mode)
        local result = db.query('SELECT `name`, `plays`, `flags`, `bases`, `allow_coop`, `map_motd`, `crc` FROM `maps` WHERE name = '..db.escape(mapname)..';')
        if ( not result ) or ( result == nil ) then
                debug.write(1, "no result on map "..mapname)
                return
        end
        result = result[1]
        if ( not result ) or ( result == nil ) then
                debug.write(1, "no result on map "..mapname)
                return
        end
        local map = {}
        map.name = result['name'] or mapname
        map.plays = result['plays'] or 0
        map.flags = result['flags'] or true
        map.bases = result['bases'] or true
        map.allow_coop = result['allow_coop'] or false
        map.map_motd = result['map_motd'] or mapname
--[[]-]
        --debug prints
        print("\nmap.name:"..map.name)
        print("\nmap.flags:"..map.flags)
        print("\nmap.bases:"..map.bases)
        print("\nmap.allow_coop:"..map.allow_coop)
        print("\nmap.map_motd:"..map.map_motd)
--[-[]]
        if string.find(mode, 'coop') then
                if not (tonumber(map.allow_coop) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "Coop edit"), false)
                        alpha.pause(-1)
                        return false
                end
        end
        if string.find(mode, 'ctf') then
                if not (tonumber(map.flags) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "CTF"), false)
                        alpha.pause(-1)
                        return false
                end
        end
        if string.find(mode, 'capture') then
                if not (tonumber(map.bases) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "Capture"), false)
                        alpha.pause(-1)
                        return false
                end
        end
        messages.info("mapdb", players.all(), map.map_motd, false)
        server.sleep(10000, function()
                if (server.playercount > 0) and (server.map == mapname) and (server.gamemode == mode) then
                        db.query('UPDATE `maps` SET `plays` = `plays` + 1 WHERE name = '..db.escape(mapname)..';')
                end
        end)
end
local function mapvote(cn, mapname, mode)
        local result = db.query('SELECT `name`, `plays`, `flags`, `bases`, `allow_coop`, `map_motd`, `crc` FROM `maps` WHERE name = '..db.escape(mapname)..';')
        if ( not result ) or ( result == nil ) then
                debug.write(1, "no result on map "..mapname)
                return
        end
        result = result[1]
        if ( not result ) or ( result == nil ) then
                debug.write(1, "no result on map "..mapname)
                return
        end
        local map = {}
        map.name = result['name'] or mapname
        map.plays = result['plays'] or 0
        map.flags = result['flags'] or true
        map.bases = result['bases'] or true
        map.allow_coop = result['allow_coop'] or false
        map.map_motd = result['map_motd'] or mapname
        if string.find(mode, 'coop') then
                if not (tonumber(map.allow_coop) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "Coop edit"), false)
                        return -1
				end
        end
        if string.find(mode, 'ctf') then
                if not (tonumber(map.flags) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "CTF"), false)
                        return -1
                end
        end
        if string.find(mode, 'capture') then
                if not (tonumber(map.bases) == 1) then
                        messages.warning("mapdb", players.all(), string.format(config.get("mapdb:not_allowed"), "Capture"), false)
                        return -1
                end
        end        db.query('UPDATE `maps` SET `suggests` = `suggests` + 1 WHERE name = '..db.escape(mapname)..';')
end

local function add_map(map, crc)
        crc = crypto.tigersum(tostring(crc))
        local res = db.query([[INSERT INTO `alphaserv`.`maps` (
                `id`, `name`, `suggests`, `mapbattle_votes`, `vetos`, `novetos`, `plays`, `flags`, `bases`, `allow_coop`, `has_plays`, `map_motd`, `crc`
        ) VALUES (
                NULL, ]]..db.escape(map)..[[, '0', '0', '0', '0', '0', 1, 1, 1, 0, ]]..db.escape(map)..[[, ]]..db.escape(crc)..[[);]]);
        if not res then debug.write(2, "Could not execute addmap query("..tostring(res)..")") end
end


--||--///EVENTS\\\--||--
server.event_handler("mapvote", mapvote)
server.event_handler("mapchange", loadmap)
server.event_handler("mapcrc", function(cn, mapname, crc)
        if string.find(server.gamemode, 'coop') then
                return
        end
        local result = db.query('SELECT `name`, `plays`, `flags`, `bases`, `allow_coop`, `map_motd`, `crc` FROM `maps` WHERE `maps`.`name` = '..db.escape(mapname)..';')
        if (not result) or (not result[1]) or (result == nil) or (result[1] == nil)   then
                --no map in database yet
                debug.write(1, "no result on map "..mapname)
                return
        else
                debug.write(-1, "Checking crc of "..mapname)
                if not crypto.tigersum(tostring(crc)) == result[1]['crc'] then
                        server.force_spec(cn)
                        debug.write(1, server.player_displayname(cn).." is using an MODEFIED map: "..mapname)
                        messages.info("mapdb", players.all(), "orange<name<"..cn..">> blue<is using an modified map>", false)
                end
        end             
end)

cmd.command_function("addmap", function(cn, flags, bases, coop, motd)
        if (flags == nil) or (bases == nil) or (coop == nil) or (motd == nil) then
                return false, "#addmap <flags> <bases> <coop> <motd>"
        end
        local crc = crypto.tigersum(tostring(server.player_mapcrc(cn)))
        local sql = [[INSERT INTO `alphaserv`.`maps` (`id`, `name`, `suggests`, `mapbattle_votes`, `vetos`, `novetos`, `plays`, `flags`, `bases`, `allow_coop`, `has_plays`, `map_motd`, `crc`
                                                                                ) VALUES (NULL, %q,             '0',            '0',                            '0',    '0',            '0',            %i,             %i,             %i,                             0,                      %q,                     %q);]]
        sql = string.format(sql, server.map, flags, bases, coop, motd, crc)
        local res = db.query(sql)
        if not res then return false, "Could not execute addmap query("..tostring(res)..")" end

end, priv.ADMIN)
