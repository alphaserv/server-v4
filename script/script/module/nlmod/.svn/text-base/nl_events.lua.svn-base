--[[
      EVENT HANDLERS
]]

-- signal_connecting(ci->clientnum, ci->hostname(), ci->name, pwd, is_reserved) == -1
function nl.blah (cn, host, name, pass, is_reserved)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_connecting(clientnum=%i, hostname=%s, name=%s, pwd=%s, is_reserved=%s)", cn, host, name, pass, tostring(is_reserved)))
	end
	nl.createPlayer(cn)
	if string.len(tostring(pass)) > 0 then
		nl.updatePlayer(cn, "slotpass", pass, "set")
  end
	nl.check_player_status(cn, pass, "sauer")
	--irc_say(string.format("Status von %s = %s", nl.getPlayer(cn, "statsname"), nl.getPlayer(cn, "nl_status")))
	if nl.getPlayer(cn, "nl_status") == "banned" then	return 4 end -- Verbindung zurückweisen
	if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "admin" then return 5 end -- Verbindung mit reservierten Slots zulassen
end
--[[
server.event_handler("connecting", function(cn, host, name, pass, is_reserved)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_connecting(clientnum=%i, hostname=%s, name=%s, pwd=%s, is_reserved=%s)", cn, host, name, pass, tostring(is_reserved)))
	end
	nl.createPlayer(cn)
	if string.len(tostring(pass)) > 0 then
		nl.updatePlayer(cn, "slotpass", pass, "set")
  end
	nl.check_player_status(cn, pass, "sauer")
	--irc_say(string.format("Status von %s = %s", nl.getPlayer(cn, "statsname"), nl.getPlayer(cn, "nl_status")))
	if nl.getPlayer(cn, "nl_status") == "banned" then	return 4 end -- Verbindung zurückweisen
	if nl.getPlayer(cn, "nl_status") == "user" or nl.getPlayer(cn, "nl_status") == "admin" then return 5 end -- Verbindung mit reservierten Slots zulassen
end)
]]

--signal_connect(ci->clientnum)
server.event_handler("connect", function(cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_connect(clientnum=%i)", cn))
	end
end)

--signal_disconnect(n, disc_reason_msg)
server.event_handler("disconnect", function(cn, reason_msg)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_disconnect(clientnum=%i, reason_msg=%s)", cn, reason_msg))
	end
end)

--signal_failedconnect(ci->hostname(), disc_reason_msg)
server.event_handler("failedconnect", function(hostname, reason_msg)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_failedconnect(hostname=%s, reason_msg=%s)", hostname, reason_msg))
	end
end)

--signal_maploaded(cp->clientnum)
server.event_handler("maploaded", function(cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_maploaded(clientnum=%i)", cn))
	end
end)

--signal_allow_rename(ci->clientnum, text)
server.event_handler("allow_rename", function(cn, text)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_allow_rename(clientnum=%i, text=%s)", cn, text))
	end
end)

--signal_rename(ci->clientnum, oldname, ci->name)
server.event_handler("rename", function(cn, oldname, name)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_rename(clientnum=%i, oldname=%s, name=%s)", cn, oldname, name))
	end
end)

--signal_renaming(ci->clientnum, futureId)
server.event_handler("renaming", function(cn, futureId)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_renaming(clientnum=%i, futureID=%i)", cn, futureId))
	end
end)

--signal_reteam(ci->clientnum, oldteam, text)
server.event_handler("reteam", function(cn, oldteam, text)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_reteam(clientnum=%i, oldteam=%s, text=%s)", cn, oldteam, text))
	end
end)

--signal_chteamrequest(wi->clientnum,wi->team,text) != -1)
server.event_handler("chteamrequest", function(cn, team, text)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_chteamrequest(clientnum=%i, team=%s, text=%s)", cn, team, text))
	end
end)

--signal_text(ci->clientnum, text)
server.event_handler("text", function(cn, text)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_text(clientnum=%i, text=%s)", cn, text))
	end
end)

--signal_sayteam(ci->clientnum,text)
server.event_handler("sayteam", function(cn, text)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_sayteam(clientnum=%i, text=%s)", cn, text))
	end
end)

--signal_intermission()
server.event_handler("intermission", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_intermission()"))
	end
end)

--signal_finishedgame()
server.event_handler("finishedgame", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_finishedgame()"))
	end
end)

--signal_timeupdate(get_minutes_left(), get_seconds_left())
server.event_handler("timeupdate", function(minutes, seconds)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_timeupdate(minutes=%i, seconds=%i)", minutes, seconds))
	end
end)

--signal_mapchange(smapname,modename(gamemode,"unknown"))
server.event_handler("mapchange", function(map, mode)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_mapchange(map=%s, mode=%s)", map, mode))
	end
end)

--signal_mapvote(ci->clientnum, text, modename(reqmode,"unknown"))
event.mapvote = server.event_handler("mapvote", function(cn, text, mode)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_mapvote(cn=%i, text=%s, mode=%s)", cn, text, mode))
	end
end)

--signal_setnextgame()
server.event_handler("setnextgame", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_setnextgame()"))
	end
end)

--signal_gamepaused()
server.event_handler("gamepaused", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_gamepaused()"))
	end
end)

--signal_gameresumed()
server.event_handler("gameresumed", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_gameresumed()"))
	end
end)

--signal_setmastermode(ci->clientnum, mastermodename(mastermode),mastermodename(mm))
server.event_handler("setmastermode", function(cn, val)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_setmastermode(cn=%i, val=%s)", cn, tostring(val)))
	end
end)

--signal_spectator(spinfo->clientnum, val) - val 0 or 1
server.event_handler("spectator", function(cn, val)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_spectator(cn=%i, val=%s)", cn, tostring(val)))
	end
end)

--signal_privilege(cn, old_priv, player->privilege)
server.event_handler("privilege", function(cn, old_priv, new_priv)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_privilege(cn=%i, old_priv=%s, new_priv=%s)", cn, old_priv, new_priv))
	end
end)

--signal_teamkill(actor->clientnum, target->clientnum)
server.event_handler("teamkill", function(cn, targetcn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_teamkill(cn=%i, targetcn=%i)", cn, targetcn))
	end
end)

--signal_frag(target->clientnum, actor->clientnum)
server.event_handler("frag", function(targetcn, cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_frag(targetcn=%i, cn=%i)", targetcn, cn))
	end
end)

--signal_authreq(ci->clientnum, user, domain)
server.event_handler("authreq", function(cn, user, domain)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_authreq(clientnum=%i, user=%s, domain=%s)", cn, user, domain))
	end
end)

--signal_authrep(ci->clientnum, id, val)
server.event_handler("authrep", function(cn, id, val)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_authrep(clientnum=%i, id=%i, val=%s)", cn, id, tostring(val)))
	end
end)

--PROMOD--
--signal_request_addbot(ci->clientnum)
server.event_handler("request_addbot", function(cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_request_addbot(clientnum=%i)", cn))
	end
	server.player_msg(cn, string.format(red("%s, bitte keine Bots ... "), server.player_displayname(cn)))
	return -1
end)

--signal_addbot(ci->clientnum, skill, boti->clientnum)
server.event_handler("addbot", function(cn, skill, botcn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_addbot(clientnum=%i, skill=%i, botcn=%i)", cn, skill, botcn))
	end
end)

--signal_delbot(ci->clientnum)
server.event_handler("delbot", function(botcn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_delbot(botcn=%i)", botcn))
	end
end)

--signal_botleft(ci->clientnum)
server.event_handler("botleft", function(botcn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_botleft(botcn=%i)", botcn))
	end
end)

--signal_beginrecord(demo_id, filename)
server.event_handler("beginrecord", function(demo_id, filename)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_beginrecord(demo_id=%i, filename=%s)", demo_id, filename))
	end
end)

--signal_endrecord(demo_id,len)
server.event_handler("endrecord", function(demo_id, len)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_endrecord(demo_id=%i, len=%i)", demo_id, len))
	end
end)

--signal_mapcrc(ci->clientnum, text, crc)
server.event_handler("mapcrc", function(cn, text, crc)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_mapcrc(cn=%i, text=%s, crc=%s)", cn, text, crc))
	end
end)

--signal_votepassed(best->map, modename(best->mode))
server.event_handler("votepassed", function(map, mode)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_votepassed(map=%s, mode=%s)", map, mode))
	end
end)

--signal_shot(ci->clientnum, gun, gs.hits - old_hits)
server.event_handler("shot", function(cn, gun, hit)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_shot(cn=%i, gun=%i, hit=%i)", cn, gun, hit))
	end
end)

--signal_suicide(ci->clientnum)
server.event_handler("suicide", function(cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_suicide(cn=%i)", cn))
	end
end)

--signal_takeflag(ci->clientnum, ctfflagteam(f.team))
server.event_handler("takeflag", function(cn, team)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_takeflag(cn=%i, team=%s)", cn, team))
	end
end)

--signal_dropflag(ci->clientnum, ctfflagteam(f.team))
server.event_handler("dropflag", function(cn, team)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_dropflag(cn=%i, team=%s)", cn, team))
	end
end)

--signal_scoreflag(ci->clientnum, ctfflagteam(flags[flagIndex].team))
server.event_handler("scoreflag", function(cn, team)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_scoreflag(cn=%i, team=%s)", cn, team))
	end
end)

--signal_returnflag(ci->clientnum, ctfflagteam(f.team))
server.event_handler("returnflag", function(cn, team)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_returnflag(cn=%i, team=%s)", cn, team))
	end
end)

--signal_resetflag(ctfflagteam(f.team))
server.event_handler("resetflag", function(team)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_resetflag(team=%s)", team))
	end
end)

--signal_scoreupdate(team, cs.total)
server.event_handler("scoreupdate", function(team, total)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_scoreupdate(team=%s, total=%i)", team, total))
	end
end)

--signal_maintenance()
server.event_handler("maintenance", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_maintenance()"))
	end
end)

--signal_spawn(cq->clientnum)
server.event_handler("spawn", function(cn)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_spawn(cn=%i)", cn))
	end
end)

--signal_damage(target->clientnum, actor->clientnum, damage, gun)
server.event_handler("damage", function(cn, actorcn, damage, gun)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_damage(cn=%i, actorcn=%i, damage=%i, gun=%i)", cn, actorcn, damage, gun))
	end
end)

--signal_setmastermode(ci->clientnum, mastermodename(mastermode),mastermodename(mm))
server.event_handler("setmastermode", function(cn, mm_old, mm_new)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_setmastermode(cn=%i, mm_old=%i, mm_new=%i)", cn, mm_old, mm_new))
	end
end)

--signal_respawnrequest(cq->clientnum, cq->state.lastdeath)
server.event_handler("respawnrequest", function(cn, laststate)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_respawnrequest(cn=%i, taststate=%s)", cn, laststate))
	end
end)

--signal_clearbans_request()
server.event_handler("clearbans_request", function()
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_clearbans_request()"))
	end
end)

--signal_kick_request(ci->clientnum, ci->name, 14400, victim, "")
server.event_handler("kick_request", function(cn, name, duration, victim, reason)
	if server.nl_event_debug==1 then
	  irc_say(string.format("signal_kick_request(cn=%i, name=%s, duration=%i, victim=%i, reason=%s)", cn, name, duration, victim, reason))
	end
end)

--signal_started()
server.event_handler("started", function()
	if server.nl_event_debug==1 then
	  nl.log_event("signal_started()")
	end
end)

--signal_shutdown(int)
server.event_handler("shutdown", function(var)
	if server.nl_event_debug==1 then
	  nl.log_event(string.format("signal_shutdown(var=%s)", tostring(var)))
	end
end)

--signal_shutdown_scripting()
server.event_handler("shutdown_scripting", function()
	if server.nl_event_debug==1 then
	  nl.log_event("shutdown_scripting()")
	end
end)

--signal_reloadhopmod()
server.event_handler("reloadhopmod", function()
	if server.nl_event_debug==1 then
	  nl.log_event("reloadhopmod()")
	end
end)

--signal_varchanged(m_id)
server.event_handler("varchanged", function(m_id)
	if server.nl_event_debug==1 then
	  nl.log_event(string.format("signal_varchanged(m_id=%s)", tostring(m_id)))
	end
end)

--[[

// MOD ...

extern boost::signal<int (int), proceed>                                                   signal_spawn;

extern boost::signal<int (int, const char *), proceed>									   signal_teamswitch_suicide;

extern boost::signal<int (int, const char *, const char *, const char *, int), maxvalue>   signal_connecting;

extern boost::signal<void (int,int,int,int,int)>                                           signal_chainsaw;

extern boost::signal<int (int), proceed>                     signal_request_reload;
extern boost::signal<int (int, int), proceed>                signal_request_setmastermode;
extern boost::signal<int (int), proceed>                     signal_request_clearbans;
extern boost::signal<int (int, int), proceed>                signal_request_kick;
extern boost::signal<int (int), proceed>                     signal_adminpriv;
extern boost::signal<int (int, int, int), proceed>           signal_request_spectator;
extern boost::signal<int (int, int, const char *), proceed>  signal_request_setteam;
extern boost::signal<int (int), proceed>                     signal_request_recorddemo;
extern boost::signal<int (int), proceed>                     signal_request_stopdemo;
extern boost::signal<int (int), proceed>                     signal_request_cleardemos;
extern boost::signal<int (int), proceed>                     signal_request_listdemos;
extern boost::signal<int (int), proceed>                     signal_request_getdemo;
extern boost::signal<int (int), proceed>                     signal_request_getmap;
extern boost::signal<int (int), proceed>                     signal_request_newmap;
extern boost::signal<int (int), proceed>                     signal_request_addbot;
extern boost::signal<int (int), proceed>                     signal_request_delbot;
extern boost::signal<int (int), proceed>                     signal_request_setbotlimit;
extern boost::signal<int (int), proceed>                     signal_request_setbotbalance;
extern boost::signal<int (int), proceed>                     signal_request_auth;
extern boost::signal<int (int), proceed>                     signal_request_pausegame;
extern boost::signal<int (int), proceed>                     signal_request_remip;

extern boost::signal<void (int)>                    							signal_sendclients;
extern boost::signal<void (int)>                    							signal_sendinitclient;
extern boost::signal<void (int)>												signal_sendcurrentmap;
extern boost::signal<void (int, const char *, const char *)>					signal_allowedconnect;

extern boost::signal<int (int, const char *, int), proceed>                     signal_check_flooding;

extern boost::signal<int (int, int, int, int), maxvalue>                     signal_multiplicate_damage;

extern boost::signal<void (int, int)>                                   					signal_set_mastermode_now;

extern boost::signal<int (int, int), proceed>                                   			signal_editmode;

extern boost::signal<int (int, int), proceed>                                   			signal_switchmodel;

// ... MOD

]]
