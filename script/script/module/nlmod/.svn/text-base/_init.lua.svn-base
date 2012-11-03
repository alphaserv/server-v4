dofile("script/module/nlmod/tools.lua")

dofile("script/module/nlmod/loadscript.lua")

promod.read_script("script/module/nlmod/msg.lua", "message functions")
promod.read_script("script/module/nlmod/descmsg.lua", "descmessage functions")

--promod.read_script("script/module/nlmod/fake_admin.lua", "fake admin system")

promod.read_script("script/module/nlmod/_access.lua", "access functions")
promod.read_script("script/module/nlmod/_access_list.lua", "access list")
promod.read_script("script/module/nlmod/localxstatsaccess.lua", "local xstats access")

-- promod.read_script("script/module/nlmod/setmaster.lua", "setmaster handling") -- ist jetzt in nl_protect.lua
promod.read_script("script/module/nlmod/bans.lua", "ban system")
promod.read_script("script/module/nlmod/invite.lua", "invite system")
promod.read_script("script/module/nlmod/kick_protection.lua", "kick protection")
promod.read_script("script/module/nlmod/kickban.lua", "kick system")
promod.read_script("script/module/nlmod/authconnecting.lua", "authconnect system")

promod.read_script("script/module/nlmod/_command_access.lua", "command access list")
promod.read_script("script/module/nlmod/nl_players.lua", "Funktionen fuer Operationen auf Spielerlisten")
promod.read_script("script/module/nlmod/nl_messages.lua", "Nooblounge Message System")

promod.read_script("script/module/nlmod/connecting.lua", "connect system")

promod.read_script("script/module/nlmod/command.lua", "command system")
promod.read_script("script/module/nlmod/_bindings.lua", "command bindings")

promod.read_script("script/module/nlmod/_actions.lua", "actions control system")

-- promod.read_script("script/module/nlmod/recordgames.lua", "recording system")
promod.read_script("script/module/nlmod/flagrun.lua", "flagrun system")
promod.read_script("script/module/nlmod/best_stats.lua", "best stats system")
-- promod.read_script("script/module/nlmod/teamkills.lua", "teamkill control system")
-- promod.read_script("script/module/nlmod/banner.lua", "banner system")

promod.read_script("script/module/nlmod/restart_on_empty.lua", "restart system")

-- promod.read_script("script/module/nlmod/camping.lua", "camping control system")

-- promod.read_script("script/module/nlmod/teambalance.lua", "teambalance system")

promod.read_script("script/module/nlmod/pvar.lua", "pvar system")
promod.read_script("script/module/nlmod/aplayers.lua", "aplayers fix")

if server.nl_maprotation == 0 then
	promod.read_script("script/module/nlmod/gamemode.lua", "gamemode functions")
	promod.read_script("script/module/nlmod/maprotation.lua", "maprotation system")
end

promod.read_script("script/module/nlmod/sendinitclient.lua", "sendinitclient control system")

-- promod.read_script("script/module/nlmod/shuffle.lua", "shuffle system")

--promod.read_script("script/module/nlmod/inactivity.lua", "inactivity control system")

-- promod.read_script("script/module/nlmod/speed.lua", "speed control system")

-- promod.read_script("script/module/nlmod/mapcrc.lua", "mapcrc check system") ist jetzt in nl_maprotation.lua integriert

promod.read_script("script/module/nlmod/no_teamkills.lua", "teamkill protection system")
promod.read_script("script/module/nlmod/no_spawnkill.lua", "spawnkill protection system")

promod.read_script("script/module/nlmod/spawnassistant.lua", "spawn assistant")
promod.read_script("script/module/nlmod/ownage.lua", "ownage")

if server.nl_chanbot == 1 then
	promod.read_script("script/module/nlmod/nl_chanbot.lua", "nl irc")
end
promod.read_script("script/module/nlmod/nl_bot.lua", "nl bot")

server.botlimit = 0

-- generic
promod.read_script("script/module/nlmod/nl_db.lua", "Datenbankzugriffe")
promod.read_script("script/module/nlmod/nl_reconnect.lua", "Reconnect Framework")
promod.read_script("script/module/nlmod/nl_core.lua", "nl Core")
promod.read_script("script/module/nlmod/nl_utils.lua", "Allgemeine Helferfunktionen")
-- nach oben verschoben: promod.read_script("script/module/nlmod/nl_players.lua", "Funktionen fuer Operationen auf Spielerlisten")
-- nach oben verschoben: promod.read_script("script/module/nlmod/nl_messages.lua", "Nooblounge Message System")
promod.read_script("script/module/nlmod/nl_extractcommand.lua", "nooblounge extract commands from console text messages")
promod.read_script("script/module/nlmod/nl_cubes2c.lua", "cubes2c system nooblounge mod")
promod.read_script("script/module/nlmod/nl_services.lua", "nooblounge masterserver services framework")
promod.read_script("script/module/nlmod/nl_changelog.lua", "nooblounge changelog submitter")
promod.read_script("script/module/nlmod/nl_gamemodes.lua", "Gamemodes API")


--promod.read_script("script/module/nlmod/nl_stats.lua", "nl stats")

-- security, restrictions ...
promod.read_script("script/module/nlmod/nl_spectator.lua", "spectator control")
promod.read_script("script/module/nlmod/nl_protect.lua", "nl nameprotection")
promod.read_script("script/module/nlmod/nl_mastermode.lua", "mastermode system")

-- map rotation, intermission, veto, mapbattles ...
if server.nl_maprotation == 1 then
	promod.read_script("script/module/nlmod/nl_maprotation.lua", "nooblounge map rotation system")
	promod.read_script("script/module/nlmod/nl_mapbattle.lua", "intermission mode: mapbattle")
	promod.read_script("script/module/nlmod/nl_modebattle.lua", "intermission mode: modebattle")
	promod.read_script("script/module/nlmod/nl_veto.lua", "intermission mode: vetos")
	promod.read_script("script/module/nlmod/nl_mapcontest.lua", "intermission mode: mapcontest")
	promod.read_script("script/module/nlmod/nl_mapsucks.lua", "map sucks functionality")
	-- promod.read_script("script/module/nlmod/nl_modesucks.lua", "mode sucks functionality")
	promod.read_script("script/module/nlmod/nl_announce.lua", "announce system")
end

-- balance, teamfunctions ...
if server.nl_clanserver == 0 then 
	promod.read_script("script/module/nlmod/nl_balance2.lua", "balance system")
end

-- anti-cheats, badphrases, cheaters, modified maps, ping, ...
promod.read_script("script/module/nlmod/nl_cheater.lua", "cheater protection")
if server.nmsrvid ~= "ml1" then
	-- this modules should not be used on the maplounge because they needs profiles
	promod.read_script("script/module/nlmod/nl_speedhack.lua", "speedhack protection")
	promod.read_script("script/module/nlmod/nl_minmax.lua", "minmax protection")
	promod.read_script("script/module/nlmod/nl_maphack.lua", "maphack protection")
	promod.read_script("script/module/nlmod/nl_teleport.lua", "teleport protection")
end
promod.read_script("script/module/nlmod/nl_reconnectflood.lua", "reconnect flood protection")
promod.read_script("script/module/nlmod/nl_renameflood.lua", "rename flood protection")
promod.read_script("script/module/nlmod/nl_respawn.lua", "too fast respawn protection")
promod.read_script("script/module/nlmod/nl_fastscores.lua", "too fast scores protection")
promod.read_script("script/module/nlmod/nl_modifiedmap.lua", "modified map protection")
promod.read_script("script/module/nlmod/nl_badphrase.lua", "bad phrases protection")
promod.read_script("script/module/nlmod/nl_weapons.lua", "weapons protection")
promod.read_script("script/module/nlmod/nl_intercheck.lua", "intermission cheat protection")
promod.read_script("script/module/nlmod/nl_acccheck.lua", "accuracy check helper")
promod.read_script("script/module/nlmod/nl_longchainsaw.lua", "long chainsaw protection")
promod.read_script("script/module/nlmod/nl_invalidpickup.lua", "invalid pickup protection")

if server.nl_clanserver == 0 then promod.read_script("script/module/nlmod/nl_camping.lua", "camping protection") end
if server.nl_clanserver == 0 then promod.read_script("script/module/nlmod/nl_ping.lua", "ping protection") end
if server.nl_clanserver == 0 then promod.read_script("script/module/nlmod/nl_teamkiller.lua", "teamkiller protection") end
promod.read_script("script/module/nlmod/nl_killcounter.lua", "killcounter")
-- chainsaw hack protection
-- aimbot detection, errorlog
promod.read_script("script/module/nlmod/nl_aimbot.lua", "aimbot detection")
promod.read_script("script/module/nlmod/nl_errorlog.lua", "error log writing")   
-- admin and player commands
promod.read_script("script/module/nlmod/nl_warn.lua", "warnings")
promod.read_script("script/module/nlmod/nl_changeteam.lua", "changeteam control")
if server.nl_clanserver == 1 then
	promod.read_script("script/module/nlmod/nl_war.lua", "clanwar control")
end
promod.read_script("script/module/nlmod/nl_silence.lua", "silence control")
promod.read_script("script/module/nlmod/nl_who.lua", "who is playing")
promod.read_script("script/module/nlmod/nl_god.lua", "admin only")
promod.read_script("script/module/nlmod/nl_access.lua", "accesscommands")

-- nooblounge services framework
promod.read_script("script/module/nlservices/repository.lua", "services repository")
promod.read_script("script/module/nlservices/servers.lua", "servers")
promod.read_script("script/module/nlservices/date.lua", "date")
promod.read_script("script/module/nlservices/mapbattle.lua", "mapbattle")
promod.read_script("script/module/nlservices/basicprofile.lua", "basicprofile")

--ufo test--
promod.read_script("script/module/nlmod/nl_gift.lua", "gift")

-- manual penalty box
if server.nl_clanserver == 0 then
	promod.read_script("script/module/nlmod/nl_penaltybox.lua", "penalty box")
end

-- Serversucks, teamsucks. April April!
promod.read_script("script/module/nlmod/nl_serversucks.lua", "serversucks")
promod.read_script("script/module/nlmod/nl_teamsucks.lua", "teamsucks")

-- Dieses Spiel nur auf der NL4
if server.nl_clanserver == 0 then
	promod.read_script("script/module/nlmod/nl_moves.lua", "checks cool moves")
	promod.read_script("script/module/nlmod/nl_pizzagame.lua", "the pizza game")
	promod.read_script("script/module/nlmod/nl_serverstartgame.lua", "the server start game")
end

-- coop, entities, particles, map portal
promod.read_script("script/module/nlmod/nl_coop.lua", "coop edit functions")
promod.read_script("script/module/nlmod/nl_entities.lua", "entities framework")
promod.read_script("script/module/nlmod/nl_particles.lua", "particles framework")
promod.read_script("script/module/nlmod/nl_mapportal.lua", "map portal")
