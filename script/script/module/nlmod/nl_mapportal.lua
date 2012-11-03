--[[
	script/module/nl_mod/nl_mapportal.lua
	Hanack (Andreas Schaeffer)
	Created: 10-Mai-2012
	Last Change: 10-Mai-2012
	License: GPL3

	Funktion:
		Blah
		
	API-Methoden:
		maphack.clear_malus(cn)
			Malus Punkte des Spielers zuruecksetzen
		maphack.add_malus(cn)
			Spieler bekommt einen Malus Punkt
		
	Commands:
		#maphack recording 1
			Aufnahme starten
		#maphack recording 0
			Aufnahme stoppen
		#maphack delete
			Profil für die Map und den Mode löschen
		#maphack clear
			Profilwerte aus dem Speicher entfernen (nutzlos)
		#maphack distance <value>
			Groesse der Profil-Wuerfel

]]



--[[
		API
]]

mapportal = {}
mapportal.enabled = 0
mapportal.types = {}
mapportal.model = 0
mapportal.tag = 256
mapportal.portals = {}
mapportal.is_changing = false

function mapportal.create_portal(map, mode, x, y, z)
	if mapportal.enabled == 0 then return end
	mapportal.tag = mapportal.tag - 1
	local slot1 = entities.register()
	entities.set(
		slot1,
		entities.types['teleport'],
		x + 30, y, z + 3,
		mapportal.tag, mapportal.model, 0, 0, 0
	)
	local slot2 = entities.register()
	entities.set(
		slot2,
		entities.types['teledest'],
		x, y, z + 2,
		90, mapportal.tag, 0, 0, 0
	)
	mapportal.portals[slot2] = { map, mode }
end

function mapportal.teleport_to_map(cn, tpn, tdn, x, y, z)
	if mapportal.enabled == 0 or mapportal.portals[tdn] == nil or mapportal.is_changing then return end
	mapportal.is_changing = true
	maprotation.change_map(mapportal.portals[tdn][1], mapportal.portals[tdn][2], true)
end



--[[
		COMMANDS
]]

function server.playercmd_mapportal(cn, map, mode)
	if not hasaccess(cn, admin_access) then return end
	if mapportal.enabled == 0 then
		messages.error(cn, {cn}, "MAPPORTAL", "No map portals allowed.")
	end
	local x, y, z = server.player_pos(cn)
	if mode == nil then
		mode = maprotation.get_next_mode()
	end
	if map == nil then
		map = maprotation.pull_map(mode)
	end
	mapportal.create_portal(map, mode, tonumber(x), tonumber(y), tonumber(z))
end

--[[
		EVENTS
]]

server.event_handler("mapchange", function()
	mapportal.tag = 256
	mapportal.portals = {}
	mapportal.is_changing = false
end)

server.event_handler("teleport", mapportal.teleport_to_map)

-- server.interval(mapportal.check_interval, mapportal.check)

