--[[
	script/module/nl_mod/nl_maphack.lua
	Hanack (Andreas Schaeffer)
	Created: 24-Apr-2012
	Last Change: 24-Apr-2012
	License: GPL3

	Funktion:
		Erkennt MapHacker anhand von ungueltigen Positionen. Es werden (wie bei
		der Speedhack-Detection und der Minmax-Detection) pro Map Profile gebildet.
		
		* Ein Profil enthaelt gueltige Punkte, die ueber die Map zerstreut liegen.
		* Entfernung von einem Punkt zu einem anderen Punkt (Rastergroesse): 2 Einheiten in x, y und z
		* Ein Spieler bekommt Maluspunkte, wenn er eine Zeitlang keinen der Punkte ueberlaufen hat

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

maphack = {}
maphack.enabled = 1
maphack.protected = 1 -- change this, if you want to do bad things like deleting the profiles
maphack.only_warnings = 1
maphack.distance = 10
maphack.recording = 0
maphack.testing = 0
maphack.visualisation = 1
maphack.check_interval = 100
maphack.record_interval = 50
maphack.visualisation_interval = 50
maphack.pointleader_interval = 3000
maphack.pointleader_interval2 = 30000
maphack.reverse = 1
maphack.vxdist = 2
maphack.vydist = 2
maphack.vzdist = 2
maphack.default_warnmalus = 10
maphack.default_banmalus = 20
maphack.warnmalus = 10
maphack.banmalus = 20
maphack.profile = {} -- tree: z -> y -> x
maphack.profile_size = 0
maphack.load_carrots = 0
maphack.warn_level = {}
maphack.carrots = {}
maphack.carrots_id = {}
maphack.carrots_min = 8501
maphack.carrots_max = 9999
maphack.carrots_cur = maphack.carrots_min
maphack.carrots_x = 5
maphack.carrots_y = 5
maphack.carrots_z = 10
maphack.carrots_enttype = 22 -- 22: carrot; 2: mapmodel
maphack.carrots_entattr2 = 0 -- 23: carrot
maphack.malus = {}
maphack.falling = {}
maphack.undercover = {}
maphack.undercover_enabled = 1
maphack.undercover_active = 0
maphack.undercover_agents = { "Hanack", "-NC-Istha", "westernheld", "antiprecision", "-NC-Andreas", "-NC-Panda", "-NC-Nuster", "{GSTF}micha", "{GSTF}Laslo69", "{GSTF}Hanni", "superTUX", "-NC-mozn", "KeksDrache", "ShadowDragon", "Shaun", "Braten", "Hankus", "-NC-Punky", "SomeLady", "-NC-angst", "elPresidente", "nothing", "PeterPenacka", "-NC-Cerez", "Morphix", "BanShee", "Charlotte", "Nick", "-NC-Amaiur", "ToP|Rexus", "Flo", "DaveX", "NuckChorris", "|SK|boulax" }
maphack.points = {}
maphack.pointleader = -1
maphack.startpoints = 0
maphack.profile_key = {}
maphack.profile_key['ffa'] = 'efficiency'
maphack.profile_key['coop edit'] = nil
maphack.profile_key['teamplay'] = 'efficiency'
maphack.profile_key['instagib'] = 'insta ctf'
maphack.profile_key['instagib team'] = 'insta ctf'
maphack.profile_key['efficiency'] = 'efficiency'
maphack.profile_key['efficiency team'] = 'efficiency'
maphack.profile_key['tactics'] = 'efficiency'
maphack.profile_key['tactics team'] = 'efficiency'
maphack.profile_key['capture'] = 'efficiency'
maphack.profile_key['regen capture'] = 'efficiency'
maphack.profile_key['ctf'] = 'efficiency'
maphack.profile_key['insta ctf'] = 'insta ctf'
maphack.profile_key['protect'] = 'efficiency'
maphack.profile_key['insta protect'] = 'insta ctf'
maphack.profile_key['hold'] = 'efficiency'
maphack.profile_key['insta hold'] = 'insta ctf'
maphack.profile_key['efficiency ctf'] = 'efficiency'
maphack.profile_key['efficiency protect'] = 'efficiency'
maphack.profile_key['efficiency hold'] = 'efficiency'



function maphack.set_malus(warnmalus, banmalus)
	db.insert_or_update("nl_maphack_malus", { map=maprotation.map, mode=maphack.profile_key[maprotation.game_mode], warn=warnmalus, kick=banmalus }, string.format("map='%s' and mode='%s'", maprotation.map, maphack.profile_key[maprotation.game_mode]))
end

function maphack.reset_malus()
	maphack.warnmalus = 3
	maphack.banmalus = 6
	maphack.set_malus(maphack.warnmalus, maphack.banmalus)
end

-- maluspunkte zuruecksetzen
function maphack.clear_malus(cn)
	cn = tonumber(cn)
	maphack.malus[cn] = 0
end

-- maluspunkt hinzufuegen
function maphack.add_malus(cn)
	cn = tonumber(cn)
	if maphack.malus[cn] == nil then
		maphack.malus[cn] = 0
	end
	local add_points = 1
	if maphack.falling[cn] ~= nil then
		add_points = 1 / (maphack.falling[cn][2] + 1)
	end
	maphack.malus[cn] = maphack.malus[cn] + add_points
	malus_points = math.floor(maphack.malus[cn])
	if malus_points > 1 then
		messages.debug(cn, players.admins(), "MAPHACK", string.format("%s (%i) has %i malus points", server.player_name(cn), cn, malus_points))
	end
	
	if maphack.testing == 1 and malus_points >= maphack.warnmalus then
		maphack.warnmalus = malus_points + 1
		maphack.banmalus = malus_points * 2
		maphack.set_malus(maphack.warnmalus, maphack.banmalus)
		messages.debug(cn, players.admins(), "MAPHACK", string.format("%s (%i) set new maphack malus limits! white<warn malus:> %i white<ban malus:> %i", server.player_name(cn), cn, maphack.warnmalus, maphack.banmalus))
		return
	end
	
	if malus_points == maphack.warnmalus then
		-- TODO: re-enable
		-- messages.warning(cn, players.admins(), "MAPHACK", string.format("%s (%i) is *possibly* map hacking", server.player_name(cn), cn))
	else
		if malus_points >= maphack.banmalus then
			if maphack.only_warnings == 1 then
				if maphack.warn_level[cn] == nil then
					maphack.warn_level[cn] = 1
				else
					maphack.warn_level[cn] = maphack.warn_level[cn] + 1
					if maphack.warn_level[cn] % 20 == 0 then
						-- TODO: re-enable
						-- messages.warning(cn, players.admins(), "MAPHACK", string.format("%s (%i) is *possibly* map hacking", server.player_name(cn), cn))
					end
				end
			else
				messages.error(cn, players.admins(), "CHEATER", string.format("Automatically kicked %s (%i) because of map hacking", server.player_name(cn), cn))
				cheater.autokick(cn, "Server", "Maphacking/Flyhacking")
			end
		end
	end
	
end

function maphack.set_falling_state(cn, z)
	if maphack.falling[cn] == nil then
		maphack.falling[cn] = {}
		maphack.falling[cn][1] = z
		maphack.falling[cn][2] = 0
		return
	end
	if maphack.falling[cn][1] > z then
		maphack.falling[cn][2] = maphack.falling[cn][2] + 1
	else
		maphack.falling[cn][2] = 0
	end
	maphack.falling[cn][1] = z
end

-- setzt profil zurueck
function maphack.clear_profile()
	maphack.profile_size = 0
	maphack.profile = {}
	maphack.malus = {}
end

-- loescht ein profil
function maphack.delete_profile()
	if maphack.protected ~= 0 then return end
	maphack.clear_profile()
	db.delete("nl_maphack", string.format("map='%s' and mode='%s'", maprotation.map, maphack.profile_key[maprotation.game_mode]))
end

-- laedt profil aus der datenbank
function maphack.load_profile(force)
	if maphack.enabled == 0 and force ~= nil then return end -- do not load maphack profile if maphack is disabled
	if maphack.profile_key[maprotation.game_mode] == nil then
		messages.debug(-1, players.admins(), "MAPHACK", string.format("Not loading maphack profile for game mode %s", maprotation.game_mode))
		return
	end
	
	-- messages.verbose(-1, players.admins(), "MAPHACK", string.format("Loading maphack profile for map %s and mode %s", maprotation.map, maprotation.game_mode))
	maphack.clear_profile()
	local t = os.clock()
	local mappositions = db.select("nl_maphack", { "x", "y", "z" }, string.format("map='%s' and mode='%s'", maprotation.map, maphack.profile_key[maprotation.game_mode]) )
	if #mappositions == 0 then
		messages.debug(-1, players.admins(), "MAPHACK", string.format("Could not load maphack profile for map %s and mode %s", maprotation.map, maprotation.game_mode))
	else
		for i, mapposition in pairs(mappositions) do
			x = tonumber(mapposition.x)
			y = tonumber(mapposition.y)
			z = tonumber(mapposition.z)
			if maphack.profile[z] == nil then
				maphack.profile[z] = {}
			end
			if maphack.profile[z][y] == nil then
				maphack.profile[z][y] = {}
			end
			if maphack.profile[z][y][x] == nil then
				maphack.profile[z][y][x] = 1
				maphack.profile_size = maphack.profile_size + 1
			end
		end

		-- also loading insta points for efficiency
		if maphack.profile_key[maprotation.game_mode] == 'efficiency' then
			local mappositions_insta = db.select("nl_maphack", { "x", "y", "z" }, string.format("map='%s' and mode='%s'", maprotation.map, 'insta ctf') )
			if #mappositions_insta > 0 then
				for i, mapposition in pairs(mappositions_insta) do
					x = tonumber(mapposition.x)
					y = tonumber(mapposition.y)
					z = tonumber(mapposition.z)
					if maphack.profile[z] == nil then
						maphack.profile[z] = {}
					end
					if maphack.profile[z][y] == nil then
						maphack.profile[z][y] = {}
					end
					if maphack.profile[z][y][x] == nil then
						maphack.profile[z][y][x] = 1
						maphack.profile_size = maphack.profile_size + 1
					end
				end
			end
		end

		maphack.startpoints = maphack.profile_size
		messages.debug(-1, players.admins(), "MAPHACK", string.format("Successfully loaded maphack profile for map %s and mode %s with %i valid positions (in %i s)", maprotation.map, maprotation.game_mode, maphack.profile_size, os.clock() - t))

		-- load max malus
		local result = db.select("nl_maphack_malus", { "warn", "kick" }, string.format("map='%s' and mode='%s'", maprotation.map, maphack.profile_key[maprotation.game_mode]) )
		if #result > 0 then
			maphack.warnmalus = tonumber(result[1].warn)
			maphack.banmalus = tonumber(result[1].kick)
		else
			maphack.warnmalus = maphack.default_warnmalus
			maphack.banmalus = maphack.default_banmalus
		end

		if maphack.load_carrots == 1 then
			maphack.send_carrots()
		end
	end
end

-- speichert profil in die datenbank
--function maphack.save_profile()
--	messages.debug(-1, players.admins(), "MAPHACK", string.format("Saving maphack profile for map %s and mode %s", maprotation.map, maprotation.game_mode))
--	db.delete("nl_maphack", string.format("map='%s' and mode='%s'", maprotation.map, maphack.profile_key[maprotation.game_mode]))
--	for z,zv in pairs(maphack.profile) do
--		for y,yv in pairs(zv) do
--			for x,xv in pairs(yv) do
--				-- messages.debug(-1, players.admins(), "MAPHACK", string.format("x=%i, y=%i, z=%i, map=%s, mode=%s", x, y, z, maprotation.map, maprotation.game_mode))
--				db.insert("nl_maphack", { map=maprotation.map, mode=maphack.profile_key[maprotation.game_mode], x=x, y=y, z=z })
--			end
--		end
--	end
--	messages.debug(-1, players.admins(), "MAPHACK", string.format("Successfully saved maphack profile for map %s and mode %s with %i valid positions", maprotation.map, maprotation.game_mode, maphack.profile_size))
--end

-- eine carrot senden (innerhalb von grenzen
function maphack.clear_carrots()
	maphack.carrots_cur = maphack.carrots_min - 1
	while maphack.carrots_cur <= maphack.carrots_max do
		maphack.carrots_cur = maphack.carrots_cur + 1
		server.send_entity(maphack.carrots_cur, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	end
	maphack.carrots = {}
	maphack.carrots_id = {}
end

function maphack.get_carrot_id(x, y, z)
	if maphack.carrots[z] ~= nil and maphack.carrots[z][y] ~= nil and maphack.carrots[z][y][x] ~= nil then
		return maphack.carrots[z][y][x]
	end
	return -1
end

function maphack.remove_carrot(x, y, z)
	local id = maphack.get_carrot_id(x2, y2, z2)
	maphack.carrots_id[id] = nil
	if maphack.carrots ~= nil and maphack.carrots[z] ~= nil and maphack.carrots[z][y] ~= nil and maphack.carrots[z][y][x] ~= nil then
		maphack.carrots[z][y][x] = nil
	end
	server.send_entity(id, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

-- eine carrot senden (innerhalb von grenzen)
function maphack.send_carrot(x, y, z)
	if maphack.get_carrot_id(x, y, z) > 0 then return end
	maphack.carrots_cur = maphack.carrots_cur + 1
	if maphack.carrots_cur > maphack.carrots_max then
		maphack.carrots_cur = maphack.carrots_min
			end
	-- clear old
	if maphack.carrots_id[maphack.carrots_cur] ~= nil then
		if maphack.carrots_id[maphack.carrots_cur][1] ~= nil and maphack.carrots_id[maphack.carrots_cur][1] ~= nil and maphack.carrots_id[maphack.carrots_cur][1] ~= nil then
			maphack.carrots[maphack.carrots_id[maphack.carrots_cur][1]][maphack.carrots_id[maphack.carrots_cur][2]][maphack.carrots_id[maphack.carrots_cur][3]] = nil
		end
	end
	-- set new
	if maphack.carrots[z] == nil then maphack.carrots[z] = {} end
	if maphack.carrots[z][y] == nil then maphack.carrots[z][y] = {} end
	maphack.carrots[z][y][x] = maphack.carrots_cur
	maphack.carrots_id[maphack.carrots_cur] = { z, y, x }
	-- send entity
	server.send_entity(maphack.carrots_cur, x + maphack.carrots_x, y + maphack.carrots_y, z + maphack.carrots_z, maphack.carrots_enttype, 0, maphack.carrots_entattr2, 0, 0, 0)
end

-- laedt carrots
function maphack.send_carrots()
	if maphack.visualisation ~= 1 then
		messages.error(-1, players.admins(), "MAPHACK", "Carrots are currently disabled!")
		return
	end 
	for z,zv in pairs(maphack.profile) do
		for y,yv in pairs(zv) do
			for x,xv in pairs(yv) do
				maphack.send_carrot(x, y, z)
			end
		end
	end
end


-- eine einzelne position aufnehmen
function maphack.record_pos(cn, x, y, z)
	x1 = math.floor(x)
	y1 = math.floor(y)
	z1 = math.floor(z)
	x2 = x1 - (x1 % maphack.distance)
	y2 = y1 - (y1 % maphack.distance)
	z2 = z1 - (z1 % maphack.distance)
	if maphack.profile[z2] == nil then maphack.profile[z2] = {} end
	if maphack.profile[z2][y2] == nil then maphack.profile[z2][y2] = {} end
	if maphack.profile[z2][y2][x2] == nil then
		maphack.profile[z2][y2][x2] = 1
		if maphack.visualisation == 1 then
			if maphack.reverse == 1 then
				maphack.remove_carrot(x2, y2, z2)
			else
				maphack.send_carrot(x2, y2, z2)
			end
		end
		db.insert("nl_maphack", { map=maprotation.map, mode=maphack.profile_key[maprotation.game_mode], x=x2, y=y2, z=z2 })
		if maphack.recording == 1 then
			messages.debug(-1, players.all(), "MAPHACK", string.format("%s added a new position x: %i y: %i z: %i", server.player_name(cn), x2, y2, z2))
		elseif maphack.undercover_active == 1 then
			local undercovers = {}
			for i,cn in ipairs(players.all()) do
				if maphack.undercover[cn] == 1 then
					table.insert(undercovers, cn)
				end
			end
			messages.debug(-1, undercovers, "MAPHACK", string.format("%s added a new position x: %i y: %i z: %i", server.player_name(cn), x2, y2, z2))
		end
		maphack.profile_size = maphack.profile_size + 1
		if maphack.points[cn] == nil then
			maphack.points[cn] = 1
		else
			maphack.points[cn] = maphack.points[cn] + 1
		end
	else
		messages.debug(-1, players.admins(), "MAPHACK", "Position x:" .. x2 .. " y:" .. y2 .. " z:" .. z2 .. " was already recorded!")
	end
end

-- eine einzelne position pruefen
function maphack.check_pos(x, y, z)
	x1 = math.floor(x)
	y1 = math.floor(y)
	z1 = math.floor(z)
	x2 = x1 - (x1 % maphack.distance)
	y2 = y1 - (y1 % maphack.distance)
	z2 = z1 - (z1 % maphack.distance)
	if maphack.profile[z2] == nil then
		-- messages.debug(-1, players.admins(), "MAPHACK", "Position x:" .. x2 .. " y:" .. y2 .. " z:" .. z2 .. " is NOT valid")
		return false
	else
		if maphack.profile[z2][y2] == nil then
			-- messages.debug(-1, players.admins(), "MAPHACK", "Position x:" .. x2 .. " y:" .. y2 .. " z:" .. z2 .. " is NOT valid")
			return false
		else
			if maphack.profile[z2][y2][x2] == nil then
				-- messages.debug(-1, players.admins(), "MAPHACK", "Position x:" .. x2 .. " y:" .. y2 .. " z:" .. z2 .. " is NOT valid")
				return false
			end
		end
	end
	-- messages.debug(-1, players.admins(), "MAPHACK", "Position x:" .. x2 .. " y:" .. y2 .. " z:" .. z2 .. " is valid")
	return true
end

-- aufnahme von positionen
function maphack.record()
	if server.paused == 1 or server.timeleft <= 0 or maphack.enabled == 0 or (maphack.recording == 0 and maphack.undercover_active == 0) then return end
	for i,cn in ipairs(players.all()) do
		if maphack.recording == 1 or (maphack.undercover[cn] ~= nil and maphack.undercover[cn] == 1) then
			if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE then
				local x, y, z = server.player_pos(cn)
				if not maphack.check_pos(x, y, z) then
					maphack.record_pos(cn, x, y, z)
				end
			end
		end
	end
end

-- pruefen der positionen der spieler
function maphack.check()
	if server.paused == 1 or server.timeleft <= 0 or maphack.enabled == 0 or maphack.recording == 1 or maphack.profile_size == 0 then return end
	for i,cn in ipairs(players.all()) do
		if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE and (maphack.undercover[cn] == nil or maphack.undercover[cn] == 0) then
			local x, y, z = server.player_pos(cn)
			maphack.set_falling_state(cn, z)
			if maphack.check_pos(x, y, z) then
				maphack.clear_malus(cn)
			else
				maphack.add_malus(cn)
			end
		end		
	end
end

-- visualisiert den spieler umgebende carrots
function maphack.visualize()
	if server.paused == 1 or server.timeleft <= 0 or maphack.enabled == 0 or maphack.recording ~= 1 or maphack.visualisation ~= 1 or maphack.profile_size == 0 then return end
	local n = table.getn(players.active())
	if n == 0 then return end
	local cn = players.active()[ math.random(n) ] 
	local mxdist = maphack.vxdist * maphack.distance
	local mydist = maphack.vydist * maphack.distance
	local mzdist = maphack.vzdist * maphack.distance
	-- for i,cn in ipairs(players.active()) do
	local x, y, z = server.player_pos(cn)
		x1 = math.floor(x)
		y1 = math.floor(y)
		z1 = math.floor(z)
		x2 = x1 - (x1 % maphack.distance)
		y2 = y1 - (y1 % maphack.distance)
		z2 = z1 - (z1 % maphack.distance)
		xmin = x2 - mxdist
		xmax = x2 + mxdist
		ymin = y2 - mydist
		ymax = y2 + mydist
		zmin = z2 - mzdist
		zmax = z2 + mzdist
	for z3 = zmin, zmax, maphack.distance do
		for y3 = ymin, ymax, maphack.distance do
			for x3 = xmin, xmax, maphack.distance do
				if maphack.reverse == 0 and maphack.profile[z3] ~= nil and maphack.profile[z3][y3] ~= nil and maphack.profile[z3][y3][x3] ~= nil then
					maphack.send_carrot(x3, y3, z3)
				end
				if maphack.reverse == 1 and (maphack.profile[z3] == nil or maphack.profile[z3][y3] == nil or maphack.profile[z3][y3][x3] == nil) then
					maphack.send_carrot(x3, y3, z3)
				end
			end
		end
	end
	-- end
end

function maphack.check_pointleader()
	if maphack.enabled == 0 then return end
	if maphack.recording == 1 then
		local most = -1
		local pointleader = -1
		for i,cn in ipairs(players.all()) do
			if server.player_status(cn) ~= "spectator" and maphack.points[cn] ~= nil then -- and server.player_status_code(cn) == server.ALIVE
				if maphack.points[cn] > most then
					most = maphack.points[cn]
					pointleader = cn
				end
			end
		end
		if most > -1 and pointleader > -1 and pointleader ~= maphack.pointleader then
			maphack.pointleader = pointleader
			messages.info(cn, players.all(), "MAPHACK", string.format("blue<%s> orange<is the new point leader> (%i positions)", server.player_name(maphack.pointleader), most))
			for i,cn in ipairs(players.all()) do
				if maphack.points[cn] ~= nil and maphack.pointleader ~= cn then
					local behind = most - maphack.points[cn]
					messages.info(cn, {cn}, "MAPHACK", string.format(">> You have recorded %i positions (%i points behind blue<%s>)", maphack.points[cn], behind, server.player_name(maphack.pointleader)))
				end
			end
		end
	end
end

function maphack.check_pointleader2()
	if maphack.enabled == 0 then return end
	if maphack.recording == 1 then
		if maphack.pointleader ~= nil and maphack.points[maphack.pointleader] ~= nil and server.valid_cn(maphack.pointleader) then
			messages.info(-1, players.all(), "MAPHACK", string.format("Current point leader: blue<%s> (%i positions)", server.player_name(maphack.pointleader), maphack.points[maphack.pointleader]))
		end
		for i,cn in ipairs(players.all()) do
			if maphack.pointleader ~= nil and maphack.points[cn] ~= nil and maphack.points[maphack.pointleader] ~= nil and maphack.pointleader ~= cn then
				local behind = maphack.points[maphack.pointleader] - maphack.points[cn]
				messages.info(-1, {cn}, "MAPHACK", string.format(">> You have recorded %i positions (%i points behind blue<%s>)", maphack.points[cn], behind, server.player_name(maphack.pointleader)))
			end
		end
	end
end



--[[
		COMMANDS
]]

function server.playercmd_maphack(cn, command, arg, arg2)
	if not hasaccess(cn, admin_access) then return end
	if maprotation.game_mode == "coop edit" or maprotation.game_mode == "coop" then
		messages.warning(cn, {cn}, "MAPHACK", "Disabled maphack module in red<coop edit> game mode")
		return
	end
	if command == nil then
		return false, "#maphack <CMD> [<ARG>]"
	else
		if arg == nil then
			if command == "info" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.recording = " .. maphack.recording)
				messages.info(cn, {cn}, "MAPHACK", "maphack.testing = " .. maphack.testing)
				messages.info(cn, {cn}, "MAPHACK", "maphack.visualisation = " .. maphack.visualisation)
				messages.info(cn, {cn}, "MAPHACK", "maphack.enabled = " .. maphack.enabled)
				messages.info(cn, {cn}, "MAPHACK", "maphack.only_warnings = " .. maphack.only_warnings)
				messages.info(cn, {cn}, "MAPHACK", "maphack.distance = " .. maphack.distance)
				messages.info(cn, {cn}, "MAPHACK", "maphack.check_interval = " .. maphack.check_interval)
				messages.info(cn, {cn}, "MAPHACK", "maphack.record_interval = " .. maphack.record_interval)
				messages.info(cn, {cn}, "MAPHACK", "maphack.load_carrots = " .. maphack.load_carrots)
				messages.info(cn, {cn}, "MAPHACK", string.format("maphack.v(x, y, z)dist = (%i, %i, %i)", maphack.vxdist, maphack.vydist, maphack.vzdist))
				messages.info(cn, {cn}, "MAPHACK", "maphack.reverse = " .. maphack.reverse)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_max = " .. maphack.carrots_max)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_enttype = " .. maphack.carrots_enttype)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_entattr2 = " .. maphack.carrots_entattr2)
				messages.info(cn, {cn}, "MAPHACK", "maphack.undercover_enabled = " .. maphack.undercover_enabled)
				messages.info(cn, {cn}, "MAPHACK", "profile size = " .. maphack.profile_size)
				messages.info(cn, {cn}, "MAPHACK", string.format("maphack.warnmalus = %i --- maphack.banmalus = %i", maphack.warnmalus, maphack.banmalus))
			end
			if command == "reset" then
			    maphack.clear_profile()
				maphack.recording = 1
				messages.warning(cn, players.admins(), "MAPHACK", "Cleared maphack profile")
				cheater.start_recording("maphack")
				messages.info(cn, {cn}, "MAPHACK", "maphack.recording = " .. maphack.recording)
			end
			if command == "delete" then
				-- maphack.delete_profile()
			end
			-- if command == "clear" then
			-- 	maphack.clear_profile()
			-- end
			-- if command == "save" then
			--	  maphack.save_profile()
			-- end
			if command == "reset_malus" then
			 	maphack.reset_malus()
			end
			if command == "reload" then
				maphack.load_profile(true)
			end
			if command == "send_carrots" then
				maphack.send_carrots()
			end
			if command == "clear_carrots" then
				maphack.clear_carrots()
			end
			if command == "recording" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.recording = " .. maphack.recording)
			end
			if command == "testing" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.testing = " .. maphack.testing)
			end
			if command == "visualisation" or command == "visualization" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.visualisation = " .. maphack.visualisation)
			end
			if command == "enabled" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.enabled = " .. maphack.enabled)
			end
			if command == "only_warnings" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.only_warnings = " .. maphack.only_warnings)
			end
			if command == "distance" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.distance = " .. maphack.distance)
			end
			if command == "interval" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.check_interval = " .. maphack.check_interval)
				messages.info(cn, {cn}, "MAPHACK", "maphack.record_interval = " .. maphack.record_interval)
			end
			if command == "load_carrots" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.load_carrots = " .. maphack.load_carrots)
			end
			if command == "carrots_x" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_x = " .. maphack.carrots_x)
			end
			if command == "carrots_y" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_y = " .. maphack.carrots_y)
			end
			if command == "carrots_z" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_z = " .. maphack.carrots_z)
			end
			if command == "carrots_max" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_max = " .. maphack.carrots_max)
			end
			if command == "carrots_enttype" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_enttype = " .. maphack.carrots_enttype)
			end
			if command == "carrots_entattr2" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_entattr2 = " .. maphack.carrots_entattr2)
			end
			if command == "undercover_enabled" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.undercover_enabled = " .. maphack.undercover_enabled)
			end
			if command == "vxdist" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.vxdist = " .. maphack.vxdist)
			end
			if command == "vydist" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.vydist = " .. maphack.vydist)
			end
			if command == "vzdist" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.vzdist = " .. maphack.vzdist)
			end
			if command == "vdist" then
				messages.info(cn, {cn}, "MAPHACK", string.format("maphack.v(x, y, z)dist = (%i, %i, %i)", maphack.vxdist, maphack.vydist, maphack.vzdist))
			end
			if command == "reverse" then
				messages.info(cn, {cn}, "MAPHACK", "maphack.reverse = " .. maphack.reverse)
			end
			if command == "points" then
				if maphack.pointleader ~= nil then
					messages.info(cn, {cn}, "MAPHACK", string.format("The current point leader is blue<%s> yellow<(%i positions)>", server.player_name(maphack.pointleader), maphack.points[maphack.pointleader]))
				else
					messages.info(cn, {cn}, "MAPHACK", string.format("Currently no is the point leader"))
				end
				if maphack.points[cn] ~= nil then
					messages.info(cn, {cn}, "MAPHACK", string.format("You have recorded yellow<%i positions>", maphack.points[cn]))
				else
					messages.info(cn, {cn}, "MAPHACK", "You have recorded yellow<no positions>")
				end
			end
		else
			if command == "recording" then
				local recording_val = tonumber(arg)
				if maphack.recording ~= recording_val then
					if maphack.recording == 0 then
						maphack.undercover = {}
						maphack.undercover_active = 0
						cheater.start_recording("maphack")
						messages.info(cn, players.all(), "MAPHACK", string.format("orange<Starting profiling %s on %s for maphack detection...>", maprotation.game_mode, maprotation.map))
					end
					if maphack.recording == 1 then
						messages.info(cn, players.all(), "MAPHACK", string.format("orange<Stopped profiling %s on %s for maphack detection...>", maprotation.game_mode, maprotation.map))
						cheater.stop_recording("maphack")
						maphack.clear_carrots()
					end
				else
					messages.info(cn, {cn}, "MAPHACK", "maphack.recording = " .. recording_val)
				end
				maphack.recording = recording_val
			end
			if command == "testing" then
				maphack.testing = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.testing = " .. maphack.testing)
			end
			if command == "visualisation" or command == "visualization" then
				maphack.visualisation = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.visualisation = " .. maphack.visualisation)
			end
			if command == "enabled" then
				maphack.enabled = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.enabled = " .. maphack.enabled)
			end
			if command == "only_warnings" then
				maphack.only_warnings = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.only_warnings = " .. maphack.only_warnings)
			end
			if command == "distance" then
				maphack.distance = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.distance = " .. maphack.distance)
			end
			if command == "load_carrots" then
				maphack.load_carrots = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.load_carrots = " .. maphack.load_carrots)
			end
			if command == "carrots_x" then
				maphack.carrots_x = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_x = " .. maphack.carrots_x)
			end
			if command == "carrots_y" then
				maphack.carrots_y = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_y = " .. maphack.carrots_y)
			end
			if command == "carrots_z" then
				maphack.carrots_z = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_z = " .. maphack.carrots_z)
			end
			if command == "carrots_max" then
				maphack.carrots_max = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_max = " .. maphack.carrots_max)
			end
			if command == "carrots_enttype" then
				maphack.carrots_enttype = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_enttype = " .. maphack.carrots_enttype)
			end
			if command == "carrots_entattr2" then
				maphack.carrots_entattr2 = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.carrots_entattr2 = " .. maphack.carrots_entattr2)
			end
			if command == "vxdist" then
				maphack.vxdist = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.vxdist = " .. maphack.vxdist)
			end
			if command == "vydist" then
				maphack.vydist = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.vydist = " .. maphack.vydist)
			end
			if command == "vzdist" then
				maphack.vzdist = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.vzdist = " .. maphack.vzdist)
			end
			if command == "reverse" then
				maphack.reverse = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.reverse = " .. maphack.reverse)
			end
			if command == "undercover_enabled" then
				maphack.undercover_enabled = tonumber(arg)
				messages.info(cn, {cn}, "MAPHACK", "maphack.undercover_enabled = " .. maphack.undercover_enabled)
				if maphack.undercover_enabled == 0 then
					maphack.undercover = {}
					maphack.undercover_active = 0
					messages.info(cn, {cn}, "MAPHACK", "maphack.undercover[*] = 0")
				end
			end
			if command == "undercover" then
				maphack.undercover_active = 1
				if arg2 == nil then
					if arg == "stop" then
						maphack.undercover = {}
						maphack.undercover_active = 0
					else
						maphack.undercover[cn] = tonumber(arg)
						messages.info(cn, {cn}, "MAPHACK", string.format("maphack.undercover[%i] = %i", cn, maphack.undercover[cn]))
					end
				else
					undercover_cn = tonumber(arg)
					maphack.undercover[undercover_cn] = tonumber(arg2)
					messages.info(cn, {cn}, "MAPHACK", string.format("maphack.undercover[%i] = %i", undercover_cn, maphack.undercover[undercover_cn]))
				end
			end
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	maphack.undercover[cn] = 0
	if maphack.undercover_enabled == 1 then
		for i,undercover_agent in ipairs(maphack.undercover_agents) do
			if server.player_name(cn) == undercover_agent then
				messages.info(cn, players.admins(), "MAPHACK", string.format("  blue<%s> orange<is starting recording maphack profiles! Thank you for your support!>", server.player_name(cn)))
				maphack.undercover[cn] = 1
			end
		end
	end
end)

server.event_handler("disconnect", function(cn)
	maphack.undercover[cn] = 0
end)

server.event_handler("intermission", function()
	if maphack.enabled == 0 or maphack.recording == 0 then
		if maphack.undercover_active == 1 and maphack.startpoints < maphack.profile_size then
			local undercovers = {}
			for i,cn in ipairs(players.all()) do
				if maphack.undercover[cn] == 1 then
					table.insert(undercovers, cn)
				end
			end
			local new_positions = maphack.profile_size - maphack.startpoints
			messages.info(-1, undercovers, "MAPHACK", string.format("Recording stats: white<%i> new positions recorded by %i undercover agents. Thank you for your support!", new_positions, #undercovers))
		end
	else
		local most = -1
		local most_cn = -1
		for i,cn in ipairs(players.all()) do
			if server.player_status(cn) ~= "spectator" and maphack.points[cn] ~= nil then -- and server.player_status_code(cn) == server.ALIVE
				if maphack.points[cn] > most then
					most = maphack.points[cn]
					most_cn = cn
				end
				messages.info(cn, players.all(), "MAPHACK", string.format("  blue<%s:> yellow<%i positions>", server.player_name(cn), maphack.points[cn]))
			end
		end
		if most_cn >= 0 then
			messages.info(-1, players.all(), "MAPHACK", string.format("orange<WINNER:> %s", server.player_name(most_cn)))
		end
	end
end)

server.event_handler("mapchange", function()
	maphack.warn_level = {}
	maphack.startpoints = 0
	maphack.load_profile()
	maphack.recording = 0
	maphack.carrots_cur = maphack.carrots_min
	maphack.carrots = {}
	maphack.carrots_id = {}
	maphack.points = {}
	maphack.pointleader = -1
	cheater.stop_recording("maphack")
end)

server.interval(maphack.check_interval, maphack.check)

server.interval(maphack.record_interval, maphack.record)

server.interval(maphack.visualisation_interval, maphack.visualize)

server.interval(maphack.pointleader_interval, maphack.check_pointleader)

server.interval(maphack.pointleader_interval2, maphack.check_pointleader2)
