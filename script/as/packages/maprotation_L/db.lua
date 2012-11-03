require "crypto" --for mapcrc

module("maprotation.db", package.seeall)
alpha.settings.init_setting("maprotation:allow_unkown_maps", true, "bool", "choose to accept map wich arn't in the database.")

--TODO: move to utils
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function install_maps(table)
	local maps = table or maps.maps

	local flags
	local allow_coop
	local bases
	local items
	
	local errors = {}

	for mapname, map in pairs(maps) do
		flags = 0
		allow_coop = 1
		bases = 0
		items = 0
		
		if table.contains(modes["insta ctf"], mapname) then
			flags = 1
		end

		if table.contains(modes["capture"], mapname) then
			bases = 1
		end

		if table.contains(modes["ffa"], mapname) then
			items = 1
		end
				
		local success, error = pcall(function()
			alpha.db:query([[
				INSERT INTO
					maps
					(
						name,
						plays, 
						flags, 
						bases, 
						allow_coop, 
						map_motd, 
						crc
					)
				VALUES
					(
						?,
						0,
						?,
						?,
						?,
						?,
						?
					)
				]], mapname, flags, bases, allow_coop, map.motds[mapname] or "", map.crc)
		end)
		
		if not success then
			table.insert(errors, error)
		end
	end
	
	if #errors == 0 then
		return true
	else
		return false, errors
	end
end

function add_play(map, mapname, gamemode)
	server.sleep(10000, function()
		--check if it's the same map and gamemode as 10 seconds ago
		if (server.playercount > 0) and (server.map == mapname) and (server.gamemode == gamemode) then
			alpha.db:query('UPDATE maps SET plays = plays + 1 WHERE id = ?', map.id)
		end
	end)
end

function get_map(name)
	local res = alpha.db:query("SELECT id, name, plays, flags, bases, allow_coop, map_motd, crc FROM maps WHERE name = ?;", name)
	
	if not res or res:num_rows() < 1 then
		return false
	else
		return true, res:fetch()[1]
	end
end

function allowed(map, gamemode)
	if
		(tonumber(map.allow_coop) == 0 and string.find(gamemode, 'coop'))
	or
		(tonumber(map.flags) == 0 and string.find(gamemode, 'ctf'))
	or
		(tonumber(map.bases) == 0 and (string.find(gamemode, 'capture') or string.find(gamemode, 'hold')))
	then
		return false
	else
		return true
	end
end

function on_load(mapname, gamemode)
	local result, row = get_map(mapname)
	
	if not result then
		log_msg(LOG_WARNING, "Could not find map %(1)s" % { mapname })
		
		if tonumber(alpha.settings:get("maprotation:allow_unkown_maps")) ~= 1 then
			disallow_map(mapname, gamemode, false)
		end
		
		return
	end
	
	local map = result:fetch()[1]
	
	if not allowed(map) then
		disallow_map(mapname, gamemode, true)
	end
	
	send_motd(map, mapname, gamemode)

	add_play(map, mapname, gamemode)
end

function vote (mapname, gamemode)
	local result, row = get_map()
	if not result then
		--unkown map
		
		if tonumber(alpha.settings:get("maprotation:allow_unkown_maps")) ~= 1 then
			disallow_map(mapname, gamemode, false, true)
			return false
		end
		
	else
		local map = row:fetch()[1]
	
		if not allowed(map, gamemode) then
			disallow_map(mapname, gamemode, true, true)
			return false
		else
			alpha.db:query('UPDATE maps SET suggests = suggests + 1 WHERE id = ?', map.id)
		end
	end
	
	return true
end

function add_map(mapname, crc, info)
	--encode crc
	crc = crypto.tigersum(tostring(crc))
	
	if not info then 
		info = {
			flags = 0,
			bases = 0,
			allow_coop = 1,
			map_motd = ""
		}
	end
	
	return alpha.db:query([[
		INSERT INTO
			maps
		(
			name,
			suggests,
			mapbattle_votes,
			vetos,
			novetos,
			plays,
			flags,
			bases,
			allow_coop,
			has_plays,
			map_motd,
			crc			
		)
		VALUES
		(
			?,
			0,
			0,
			0,
			0,
			0,
			?,
			?,
			?,
			0,
			?,
			?		
		);]], mapname, info.flags, info.bases, info.allow_coop, info.map_motd, crc)
end

local events = {}

events.mapvote = server.event_handler("mapvote", mapvote)
events.mapchange = server.event_handler("mapchange", loadmap)
events.mapcrc = server.event_handler("mapcrc", function(cn, mapname, crc)
	if string.find(server.gamemode, 'coop') then
		return
	end
    
	local map = get_map(mapname)
	
	if map:num_rows() < 1 then
		return
	else
		map = map:fetch()[1]
		
		if crypto.tigersum(tostring(crc)) ~= map.crc then
			server.force_spec(cn)
		
			--messages.info("mapdb", players.all(), "orange<name<"..cn..">> blue<is using a modified map>", false)
        end
	end
end)

--[[

]]
