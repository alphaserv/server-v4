/*
	This file is included from and is a part of "fpsgame/server.cpp".
*/
#ifdef INCLUDE_EXTSERVER_CPP

int sv_text_hit_length = 0;
int sv_sayteam_hit_length = 0;
int sv_mapvote_hit_length = 0;
int sv_switchname_hit_length = 0;
int sv_switchteam_hit_length = 0;
int sv_kick_hit_length = 0;
int sv_remip_hit_length = 0;
int sv_newmap_hit_length = 0;
int sv_spec_hit_length = 0;

string ext_admin_pass = "";

struct disconnect_info
{
	int cn;
	int code;
	int session_id;
	std::string reason;
};

static int execute_disconnect(void * info_vptr)
{
	disconnect_info * info = reinterpret_cast<disconnect_info *>(info_vptr);
	clientinfo * ci = getinfo(info->cn);
	if(!ci || ci->sessionid != info->session_id)
	{
		delete info;
		return 0;
	}
	ci->disconnect_reason = info->reason;
	disconnect_client(info->cn, info->code);
	delete info;
	return 0;
}

void disconnect(int cn, int code, std::string reason)
{
	clientinfo * ci = get_ci(cn);

	disconnect_info * info = new disconnect_info;
	info->cn = cn;
	info->session_id = ci->sessionid;
	info->code = code;
	info->reason = reason;
	
	sched_callback(&execute_disconnect, info);
}

void changetime(int remaining)
{
	gamelimit = gamemillis + remaining;
	if(remaining > 0) sendf(-1, 1, "ri2", N_TIMEUP, remaining / 1000);
	next_timeupdate = gamemillis + (remaining % (60*1000));
	if(gamemillis < next_timeupdate)
	{
		event_timeupdate(event_listeners(), boost::make_tuple(get_minutes_left(), get_seconds_left()));
	}
}

int get_minutes_left()
{
	return (gamemillis>=gamelimit ? 0 : (gamelimit - gamemillis + 60000 - 1)/60000);
}

void set_minutes_left(int mins)
{
	changetime(mins * 1000 * 60);
}

int get_seconds_left()
{
	return (gamemillis>=gamelimit ? 0 : (gamelimit - gamemillis) / 1000);
}

void set_seconds_left(int seconds)
{
	changetime(seconds * 1000);
}

void player_msg(int cn,const char * text)
{
	get_ci(cn)->sendprivtext(text);
}

int player_id(lua_State * L)
{
	int cn = luaL_checkint(L, 1);
	clientinfo * ci = get_ci(cn);
		
	luaL_Buffer buffer;
	luaL_buffinit(L, &buffer);
	
	if(ci->state.aitype == AI_NONE)
	{
		uint ip_long = getclientip(get_ci(cn)->clientnum);
		luaL_addlstring(&buffer, reinterpret_cast<const char *>(&ip_long), sizeof(ip_long));
		luaL_addlstring(&buffer, ci->name, strlen(ci->name)); 
	}
	else
	{
		luaL_addstring(&buffer, "bot");
		luaL_addlstring(&buffer, reinterpret_cast<const char *>(&ci->sessionid), sizeof(ci->sessionid));   
	}
	
	luaL_pushresult(&buffer);
	return 1;
}

int player_sessionid(int cn)
{
	clientinfo * ci = getinfo(cn);
	return (ci ? ci->sessionid : -1);
}

const char * player_name(int cn){return get_ci(cn)->name;}

void player_rename(int cn, const char * newname, bool public_rename)
{
	char safenewname[MAXNAMELEN + 1];
	filtertext(safenewname, newname, false, MAXNAMELEN);
	if(!safenewname[0]) copystring(safenewname, "unnamed");
	
	clientinfo * ci = get_ci(cn);
	
	if (!ci || cn >= 128) return;
	
	putuint(ci->messages, N_SWITCHNAME);
	sendstring(safenewname, ci->messages);
	
	vector<uchar> switchname_message;
	putuint(switchname_message, N_SWITCHNAME);
	sendstring(safenewname, switchname_message);
	
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putuint(p, N_CLIENT);
	putint(p, ci->clientnum);
	putint(p, switchname_message.length());
	p.put(switchname_message.getbuf(), switchname_message.length());
	sendpacket(ci->clientnum, 1, p.finalize(), (public_rename ? -1 : ci->clientnum));
	
	char oldname[MAXNAMELEN+1];
	copystring(oldname, ci->name, MAXNAMELEN+1);
	
	copystring(ci->name, safenewname, MAXNAMELEN+1);
	
	if(public_rename)
	{
		event_renaming(event_listeners(), boost::make_tuple(ci->clientnum, 0));
		event_rename(event_listeners(), boost::make_tuple(ci->clientnum, oldname, ci->name));
	}
}

std::string player_displayname(int cn)
{
	clientinfo * ci = get_ci(cn);
	
	std::string output;
	output.reserve(MAXNAMELEN + 5);
	
	output = ci->name;
	
	bool is_bot = ci->state.aitype != AI_NONE;
	bool duplicate = false;
	
	if(!is_bot)
	{
		loopv(clients)
		{
			if(clients[i]->clientnum == cn) continue;
			if(!strcmp(clients[i]->name, ci->name))
			{
				duplicate = true;
				break;
			}
		}
	}
	
	if(is_bot || duplicate)
	{
		char open = (is_bot ? '[' : '(');
		char close = (is_bot ? ']' : ')');
		
		output += "\fs" MAGENTA " ";
		output += open;
		output += boost::lexical_cast<std::string>(cn);
		output += close;
		output += "\fr";
	}
	
	return output;
}

const char * player_team(int cn)
{
	if(!m_teammode) return "";
	return get_ci(cn)->team;
}

const char * player_ip(int cn)
{
	return get_ci(get_ci(cn)->ownernum)->hostname();
}

unsigned long player_iplong(int cn)
{
	return ntohl(getclientip(get_ci(get_ci(cn)->ownernum)->clientnum));
}

int player_status_code(int cn)
{
	return get_ci(cn)->state.state;
}

int player_ping(int cn)
{
	return get_ci(cn)->ping;
}

int player_ping_update(int cn)
{
	return get_ci(cn)->lastpingupdate;
}

int player_lag(int cn)
{
	return get_ci(cn)->lag;
}

int player_real_lag(int cn)
{
	return totalmillis - get_ci(cn)->lastposupdate;
}

int player_maploaded(int cn)
{
	return get_ci(cn)->maploaded;
}

int player_deathmillis(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->state.lastdeath;
}


int player_frags(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->state.frags + ci->state.suicides + ci->state.teamkills;
}

int player_score(int cn)
{
	return get_ci(cn)->state.frags;
}

int player_deaths(int cn)
{
	return get_ci(cn)->state.deaths;
}

int player_suicides(int cn)
{
	return get_ci(cn)->state.suicides;
}

int player_teamkills(int cn)
{
	return get_ci(cn)->state.teamkills;
}

int player_damage(int cn)
{
	return get_ci(cn)->state.damage;
}

int player_damagewasted(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->state.explosivedamage + ci->state.shotdamage - ci->state.damage;
}

int player_maxhealth(int cn)
{
	return get_ci(cn)->state.maxhealth;
}

int player_health(int cn)
{
	return get_ci(cn)->state.health;
}

int player_armour(int cn)
{
	return get_ci(cn)->state.armour;
}

int player_armour_type(int cn)
{
	return get_ci(cn)->state.armourtype;  
}

int player_gun(int cn)
{
	return get_ci(cn)->state.gunselect;
}

int player_hits(int cn)
{
	return get_ci(cn)->state.hits;
}

int player_misses(int cn)
{
	return get_ci(cn)->state.misses;
}

int player_shots(int cn)
{
	return get_ci(cn)->state.shots;
}

int player_accuracy(int cn)
{
	clientinfo * ci = get_ci(cn);
	int shots = ci->state.shots;
	int hits = shots - ci->state.misses;
	return static_cast<int>(roundf(static_cast<float>(hits)/std::max(shots,1)*100));
}

int player_accuracy2(int cn)
{
	clientinfo * ci = get_ci(cn);
	return static_cast<int>(roundf(static_cast<float>(ci->state.damage*100/max(ci->state.shotdamage,1))));
}

bool player_is_spy(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->spy;
}

int player_clientmillis(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->clientmillis;
}

int player_timetrial(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->timetrial >= 0 ? ci->timetrial : -1;
}

int player_privilege_code(int cn)
{
	return get_ci(cn)->privilege;
}

const char * player_privilege(int cn)
{
	switch(get_ci(cn)->privilege)
	{
		case PRIV_MASTER: return "master";
		case PRIV_ADMIN: return "admin";
		default: return "none";
	}
}

const char * player_status(int cn)
{
	switch(get_ci(cn)->state.state)
	{
		case CS_ALIVE: return "alive";
		case CS_DEAD: return "dead"; 
		case CS_SPAWNING: return "spawning"; 
		case CS_LAGGED: return "lagged"; 
		case CS_SPECTATOR: return "spectator";
		case CS_EDITING: return "editing"; 
		default: return "unknown";
	}
}

int player_connection_time(int cn)
{
	return (totalmillis - get_ci(cn)->connectmillis)/1000;
}

int player_timeplayed(int cn)
{
	clientinfo * ci = get_ci(cn);
	return (ci->state.timeplayed + (ci->state.state != CS_SPECTATOR ? (lastmillis - ci->state.lasttimeplayed) : 0))/1000;
}

int player_win(int cn)
{
	clientinfo * ci = get_ci(cn);
	
	if(!m_teammode)
	{
		loopv(clients)
		{
			if(clients[i] == ci || clients[i]->state.state == CS_SPECTATOR) continue;
			
			bool more_frags = clients[i]->state.frags > ci->state.frags;
			bool eq_frags = clients[i]->state.frags == ci->state.frags;
			
			bool less_deaths = clients[i]->state.deaths < ci->state.deaths;
			bool eq_deaths = clients[i]->state.deaths == ci->state.deaths;
			
			int p1_acc = player_accuracy(clients[i]->clientnum);
			int p2_acc = player_accuracy(cn);
			
			bool better_acc = p1_acc > p2_acc;
			bool eq_acc = p1_acc == p2_acc;
			
			bool lower_ping = clients[i]->ping < ci->ping;
			
			if( more_frags || (eq_frags && less_deaths) ||
				(eq_frags && eq_deaths && better_acc) || 
				(eq_frags && eq_deaths && eq_acc && lower_ping)) return false;			
		}
		return true;
	}
	else return team_win(ci->team);
}

void player_slay(int cn)
{
	clientinfo * ci = get_ci(cn);
	if(ci->state.state != CS_ALIVE) return;
	ci->state.state = CS_DEAD;
	sendf(-1, 1, "ri2", N_FORCEDEATH, cn);
}

bool player_changeteam(int cn,const char * newteam)
{
	clientinfo * ci = get_ci(cn);
	
	if(!m_teammode || (smode && !smode->canchangeteam(ci, ci->team, newteam)) ||
		event_chteamrequest(event_listeners(), boost::make_tuple(cn, ci->team, newteam))) 
	{
		return false;
	}
	
	if(smode || ci->state.state==CS_ALIVE) suicide(ci);
	event_reteam(event_listeners(), boost::make_tuple(ci->clientnum, ci->team, newteam));
	
	copystring(ci->team, newteam, MAXTEAMLEN+1);
	sendf(-1, 1, "riis", N_SETTEAM, cn, newteam);
	
	if(ci->state.aitype == AI_NONE) aiman::dorefresh = true;
	
	return true;
}

int player_rank(int cn){return get_ci(cn)->rank;}
bool player_isbot(int cn){return get_ci(cn)->state.aitype != AI_NONE;}

void changemap(const char * map,const char * mode = "",int mins = -1)
{
	int gmode = (mode[0] ? modecode(mode) : gamemode);
	if(!m_mp(gmode)) gmode = gamemode;
	sendf(-1, 1, "risii", N_MAPCHANGE, map, gmode, 1);
	changemap(map,gmode,mins);
}

int getplayercount()
{
	return numclients(-1, false, true);
}

int getbotcount()
{
	return numclients(-1, true, false) - numclients();
}

int getspeccount()
{
	return getplayercount() - numclients();
}

void team_msg(const char * team,const char * msg)
{
	if(!m_teammode) return;
	loopv(clients)
	{
		clientinfo *t = clients[i];
		if(t->state.state==CS_SPECTATOR || t->state.aitype != AI_NONE || strcmp(t->team, team)) continue;
		t->sendprivtext(msg);
	}
}

void player_force_spec(int cn)
{
	clientinfo * ci = get_ci(cn);
	ci->allow_self_unspec = false;
	setspectator(ci, true);
}

void player_spec(int cn)
{
	clientinfo * ci = get_ci(cn);
	ci->allow_self_unspec = true;
	setspectator(ci, true);
}

void player_unspec(int cn)
{
	setspectator(get_ci(cn), false);
}

void spec_all()
{
	loopv(clients)
	{
		clientinfo * ci = clients[i];
		if(ci->state.aitype != AI_NONE || ci->state.state == CS_SPECTATOR) continue;
		player_spec(ci->clientnum);
	}
}

int player_bots(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->bots.length();
}

int player_pos(lua_State * L)
{
	int cn = luaL_checkint(L,1);
	vec pos = get_ci(cn)->state.o;
	lua_pushnumber(L, pos.x);
	lua_pushnumber(L, pos.y);
	lua_pushnumber(L, pos.z);
	return 3;
}

void cleanup_masterstate(clientinfo * master)
{
	int cn = master->clientnum;
	
	if(cn == mastermode_owner)
	{
		mastermode = MM_OPEN;
		mastermode_owner = -1;
		mastermode_mtime = totalmillis;
		allowedips.setsize(0);
	}
	
	if(gamepaused && cn == pausegame_owner) pausegame(false);
	
	if(master->state.state==CS_SPECTATOR) aiman::removeai(master);
}

void unsetmaster()
{
	if(currentmaster != -1)
	{
		clientinfo * master = getinfo(currentmaster);
		
		defformatstring(msg)("The server has revoked your %s privilege.", privname(master->privilege));
		master->sendprivtext(msg);
		
		int old_priv = master->privilege;
		master->privilege = 0;
		int oldmaster = currentmaster;
		currentmaster = -1;
		masterupdate = true;
		
		cleanup_masterstate(master);
		
		event_privilege(event_listeners(), boost::make_tuple(oldmaster, old_priv, static_cast<int>(PRIV_NONE)));
	}
}

void unset_player_privilege(int cn)
{
	if(currentmaster == cn)
	{
		unsetmaster();
		return;
	}
	
	clientinfo * ci = get_ci(cn);
	if(ci->privilege == PRIV_NONE) return;
	
	int old_priv = ci->privilege;
	ci->privilege = PRIV_NONE;
	sendf(ci->clientnum, 1, "ri4", N_CURRENTMASTER, ci->clientnum, PRIV_NONE, mastermode);
	
	cleanup_masterstate(ci);
	
	event_privilege(event_listeners(), boost::make_tuple(cn, old_priv, static_cast<int>(PRIV_NONE)));
}

void set_player_privilege(int cn, int priv_code, bool public_priv = false)
{
	clientinfo * player = get_ci(cn);
	
	public_priv = !player->spy && public_priv;
	
	if(player->privilege == priv_code) return;
	if(priv_code == PRIV_NONE) unset_player_privilege(cn);
	
	if(cn == currentmaster && !public_priv)
	{
		currentmaster = -1;
		masterupdate = true;
	}
	
	int old_priv = player->privilege;
	player->privilege = priv_code;
	
	if(public_priv)
	{
		currentmaster = cn;
		masterupdate = true;
	}
	else
	{
		sendf(player->clientnum, 1, "ri4", N_CURRENTMASTER, player->clientnum, player->privilege, mastermode);
	}
	
	const char * change = (old_priv < player->privilege ? "raised" : "lowered");
	defformatstring(msg)("The server has %s your privilege to %s.", change, privname(priv_code));
	player->sendprivtext(msg);
	
	event_privilege(event_listeners(), boost::make_tuple(cn, old_priv, player->privilege));
}

bool set_player_master(int cn)
{
	set_player_privilege(cn, PRIV_MASTER, true);
	return true;
}

void set_player_admin(int cn)
{
	set_player_privilege(cn, PRIV_ADMIN, true);
}

void set_player_private_admin(int cn)
{
   set_player_privilege(cn, PRIV_ADMIN, false);
}

void set_player_private_master(int cn)
{
	set_player_privilege(cn, PRIV_MASTER, false);
}

void player_freeze(int cn)
{
	clientinfo * ci = get_ci(cn);
	sendf(ci->clientnum, 1, "rii", N_PAUSEGAME, 1);
}

void player_unfreeze(int cn)
{
	clientinfo * ci = get_ci(cn);
	sendf(ci->clientnum, 1, "rii", N_PAUSEGAME, 0);
}

static void execute_addbot(int skill)
{
	clientinfo * owner = aiman::addai(skill, -1);
	if(!owner) return;
	event_addbot(event_listeners(), boost::make_tuple(-1, skill, owner->clientnum));
	return;
}

void addbot(int skill)
{
	get_main_io_service().post(boost::bind(&execute_addbot, skill));
}

static void execute_deletebot(int cn)
{
	clientinfo * ci = getinfo(cn);
	if(!ci) return;
	aiman::deleteai(ci);
	return;
}

void deletebot(int cn)
{
	if(get_ci(cn)->state.aitype == AI_NONE) 
		luaL_error(get_lua_state(), "not a bot player");
	get_main_io_service().post(boost::bind(&execute_deletebot, cn));
}

void update_mastermask()
{
	bool autoapprove = mastermask & MM_AUTOAPPROVE;
	mastermask &= ~(1<<MM_VETO) & ~(1<<MM_LOCKED) & ~(1<<MM_PRIVATE) & ~MM_AUTOAPPROVE;
	mastermask |= (allow_mm_veto << MM_VETO);
	mastermask |= (allow_mm_locked << MM_LOCKED);
	mastermask |= (allow_mm_private << MM_PRIVATE);
	if(autoapprove) mastermask |= MM_AUTOAPPROVE;
}

const char * gamemodename()
{
	return modename(gamemode,"unknown");
}

namespace cubescript{
std::vector<int> make_client_list(bool (* clienttype)(clientinfo *))
{
	std::vector<int> result;
	result.reserve(clients.length());
	loopv(clients) if(clienttype(clients[i])) result.push_back(clients[i]->clientnum);
	return result;
}
} //namespace cubescript

namespace lua{
int make_client_list(lua_State * L,bool (* clienttype)(clientinfo *))
{
	lua_newtable(L);
	int count = 0;
	
	loopv(clients) if(clienttype(clients[i]))
	{
		lua_pushinteger(L,++count);
		lua_pushinteger(L,clients[i]->clientnum);
		lua_settable(L, -3);
	}
	
	return 1;
}
}//namespace lua

bool is_player(clientinfo * ci){return ci->state.state != CS_SPECTATOR && ci->state.aitype == AI_NONE;}
bool is_spectator(clientinfo * ci){return ci->state.state == CS_SPECTATOR; /* bots can't be spectators*/}
bool is_bot(clientinfo * ci){return ci->state.aitype != AI_NONE;}
bool is_any(clientinfo *){return true;}

std::vector<int> cs_player_list(){return cubescript::make_client_list(&is_player);}
int lua_player_list(lua_State * L){return lua::make_client_list(L, &is_player);}

std::vector<int> cs_spec_list(){return cubescript::make_client_list(&is_spectator);}
int lua_spec_list(lua_State * L){return lua::make_client_list(L, &is_spectator);}

std::vector<int> cs_bot_list(){return cubescript::make_client_list(&is_bot);}
int lua_bot_list(lua_State *L){return lua::make_client_list(L, &is_bot);}

std::vector<int> cs_client_list(){return cubescript::make_client_list(&is_any);}
int lua_client_list(lua_State * L){return lua::make_client_list(L, &is_any);}

std::vector<std::string> get_teams()
{
	std::set<std::string> teams;
	loopv(clients) teams.insert(clients[i]->team);
	std::vector<std::string> result;
	std::copy(teams.begin(),teams.end(),std::back_inserter(result));
	return result;
}

int lua_team_list(lua_State * L)
{
	lua_newtable(L);
	std::vector<std::string> teams = get_teams();
	int count = 0;
	for(std::vector<std::string>::iterator it = teams.begin(); it != teams.end(); ++it)
	{
		lua_pushinteger(L, ++count);
		lua_pushstring(L, it->c_str());
		lua_settable(L, -3);
	}
	return 1;
}

int get_team_score(const char * team)
{
	int score = 0;
	if(smode) return smode->getteamscore(team);
	else loopv(clients)
		if(clients[i]->state.state != CS_SPECTATOR && !strcmp(clients[i]->team,team))
			score += clients[i]->state.frags;
	return score;
}

std::vector<int> get_team_players(const char * team)
{
	std::vector<int> result;
	loopv(clients)
		if(clients[i]->state.state != CS_SPECTATOR && clients[i]->state.aitype == AI_NONE && !strcmp(clients[i]->team,team))
			result.push_back(clients[i]->clientnum);
	return result;
}

int lua_team_players(lua_State * L)
{
	std::vector<int> players = get_team_players(luaL_checkstring(L,1));
	lua_newtable(L);
	int count = 0;
	for(std::vector<int>::iterator it = players.begin(); it != players.end(); ++it)
	{
		lua_pushinteger(L, ++count);
		lua_pushinteger(L, *it);
		lua_settable(L, -3);
	}
	
	return 1;
}

int team_win(const char * team)
{
	std::vector<std::string> teams = get_teams();
	int score = get_team_score(team);
	for(std::vector<std::string>::iterator it = teams.begin(); it != teams.end(); ++it)
	{
		if(*it == team) continue;
		if(get_team_score(it->c_str()) > score) return false;
	}
	return true;
}

int team_draw(const char * team)
{
	std::vector<std::string> teams = get_teams();
	int score = get_team_score(team);
	for(std::vector<std::string>::iterator it = teams.begin(); it != teams.end(); ++it)
	{
		if(*it == team) continue;
		if(get_team_score(it->c_str()) != score) return false;
	}
	return true;
}

int team_size(const char * team)
{
	int count = 0;
	loopv(clients) if(strcmp(clients[i]->team, team)==0) count++;
	return count;
}

void recorddemo(const char * filename)
{
	if(demorecord) return;
	else setupdemorecord(false, filename);
}

int lua_gamemodeinfo(lua_State * L)
{
	int gamemode_argument = gamemode;
	
	if(lua_gettop(L) > 0 && lua_type(L, 1) == LUA_TSTRING)
	{
		gamemode_argument = modecode(lua_tostring(L, 1));
		if(gamemode_argument == -1) return 0;
	}
	
	lua_newtable(L);
	
	lua_pushboolean(L, m_check(gamemode_argument, M_NOITEMS));
	lua_setfield(L, -2, "noitems");
	
	lua_pushboolean(L, m_check(gamemode_argument,  M_NOAMMO|M_NOITEMS));
	lua_setfield(L, -2, "noammo");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_INSTA));
	lua_setfield(L, -2, "insta");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_TACTICS));
	lua_setfield(L, -2, "tactics");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_EFFICIENCY));
	lua_setfield(L, -2, "efficiency");
	
	lua_pushboolean(L, m_check(gamemode_argument,  M_CAPTURE));
	lua_setfield(L, -2, "capture");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_CAPTURE | M_REGEN));
	lua_setfield(L, -2, "regencapture");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_CTF));
	lua_setfield(L, -2, "ctf");
	
	lua_pushboolean(L, m_checkall(gamemode_argument, M_CTF | M_PROTECT));
	lua_setfield(L, -2, "protect");
	
	lua_pushboolean(L, m_checkall(gamemode_argument, M_CTF | M_HOLD));
	lua_setfield(L, -2, "hold");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_TEAM));
	lua_setfield(L, -2, "teams");
	
	lua_pushboolean(L, m_check(gamemode_argument, M_OVERTIME));
	lua_setfield(L, -2, "overtime");
	
	lua_pushboolean(L, m_checknot(gamemode_argument, M_DEMO|M_EDIT|M_LOCAL));
	lua_setfield(L, -2, "timed");
	
	return 1;
}

bool selectnextgame()
{
	event_setnextgame(event_listeners(), boost::make_tuple());
	if(next_gamemode[0] && next_mapname[0])
	{
		int next_gamemode_code = modecode(next_gamemode);
		if(m_mp(next_gamemode_code))
		{
			mapreload = false;
			sendf(-1, 1, "risii", N_MAPCHANGE, next_mapname, next_gamemode_code, 1);
			changemap(next_mapname, next_gamemode_code, next_gametime);
			next_gamemode[0] = '\0';
			next_mapname[0] = '\0';
			next_gametime = -1;
		}
		else
		{
			std::cerr<<next_gamemode<<" game mode is unrecognised."<<std::endl;
			sendf(-1, 1, "ri", N_MAPRELOAD);
		}
		return true;
	}else return false;
}

void send_auth_challenge(int cn, int id, const char * domain, const char * challenge)
{
	clientinfo * ci = get_ci(cn);
	sendf(ci->clientnum, 1, "risis", N_AUTHCHAL, domain, id, challenge);
}

void send_auth_request(int cn, const char * domain)
{
	clientinfo * ci = get_ci(cn);
	sendf(ci->clientnum, 1, "ris", N_REQAUTH, domain);
}

static bool compare_player_score(const std::pair<int,int> & x, const std::pair<int,int> & y)
{
	return x.first > y.first;
}

static void calc_player_ranks(const char * team)
{
	if(m_edit) return;
	
	if(m_teammode && !team)
	{
		std::vector<std::string> teams = get_teams();
		for(std::vector<std::string>::const_iterator it = teams.begin();
			 it != teams.end(); it++) calc_player_ranks(it->c_str());
		return;
	}
	
	std::vector<std::pair<int,int> > players;
	players.reserve(clients.length());
	
	loopv(clients) 
		if(clients[i]->state.state != CS_SPECTATOR && (!team || !strcmp(clients[i]->team,team)))
			players.push_back(std::pair<int,int>(clients[i]->state.frags, i));
	
	std::sort(players.begin(), players.end(), compare_player_score);
	
	int rank = 0;
	for(std::vector<std::pair<int,int> >::const_iterator it = players.begin();
		it != players.end(); ++it)
	{
		rank++;
		if(it != players.begin() && it->first == (it-1)->first) rank--;
		clients[it->second]->rank = rank;
	}
}

void calc_player_ranks()
{
	return calc_player_ranks(NULL);
}

void script_set_mastermode(int value)
{
	int old_mastermode = mastermode;
	
	mastermode = value;
	mastermode_owner = -1;
	mastermode_mtime = totalmillis;
	allowedips.setsize(0);
	if(mastermode >= MM_PRIVATE)
	{
		loopv(clients) allowedips.add(getclientip(clients[i]->clientnum));
	}
	
	event_setmastermode(event_listeners(), boost::make_tuple(-1, mastermodename(old_mastermode), mastermodename(value)));
}

int get_mastermode()
{
	return mastermode;
}

void add_allowed_ip(const char * hostname)
{
	ENetAddress addr;
	if(enet_address_set_host(&addr, hostname) != 0)
		luaL_error(get_lua_state(), "invalid hostname given");
	allowedips.add(addr.host);
}

void suicide(int cn)
{
	suicide(get_ci(cn));
}

bool compare_admin_password(const char * x)
{
	return !strcmp(x, adminpass);
}

bool send_item(int type, int recipient) 
{
	int ent_index = sents_type_index[type];
	if(interm > 0 || !sents.inrange(ent_index)) return false;
	clientinfo *ci = getinfo(recipient);
	if(!ci || (!ci->local && !ci->state.canpickup(sents[ent_index].type))) return false;
	sendf(-1, 1, "ri3", N_ITEMACC, ent_index, recipient);
	ci->state.pickup(sents[ent_index].type);
	return true;
}

class player_token
{   
public:
	player_token(clientinfo * ci)
	:m_cn(ci->clientnum), m_session_id(ci->sessionid)
	{
		
	}
	
	clientinfo * get_clientinfo()const
	{
		clientinfo * ci = getinfo(m_cn);
		if(!ci) return NULL;
		if(!ci || ci->sessionid != m_session_id) return NULL;
		return ci;
	}
private:
	int m_cn;
	int m_session_id;	   
};

int deferred_respawn_request(void * arg)
{
	player_token * player = reinterpret_cast<player_token *>(arg);
	clientinfo * ci = player->get_clientinfo();
	delete player;
	if(!ci) return 0;
	try_respawn(ci, ci);
	return 0;
}

void try_respawn(clientinfo * ci, clientinfo * cq)
{
	if(!ci || !cq || cq->state.state!=CS_DEAD || cq->state.lastspawn>=0 || (smode && !smode->canspawn(cq))) return;
	if(!ci->clientmap[0] && !ci->mapcrc) 
	{
		ci->mapcrc = -1;
	}
	if(cq->state.lastdeath)
	{
		if(event_respawnrequest(event_listeners(), boost::make_tuple(cq->clientnum, cq->state.lastdeath)))
		{
			return;
		}
		
		flushevents(cq, cq->state.lastdeath + DEATHMILLIS);
		cq->state.respawn();
	}
	cleartimedevents(cq);
	sendspawn(cq);
}

void player_respawn(int cn)
{
	clientinfo * ci = getinfo(cn);
	try_respawn(ci, ci);
}

int revision()
{
#if defined(REVISION) && (REVISION + 0)
	return REVISION;
#endif
	return -1;
}

const char *version()
{
	static char buf[40];
	formatstring(buf)("%s %s", __TIME__, __DATE__);
	return buf;
}

const char *extfiltertext(const char *src)
{
	static string dst; 
	filtertext(dst, src);
	return dst;
}

// copied from noobmod:

bool player_sendmap(int cn)
{
	clientinfo * ci = getinfo(cn);
	if(ci)
	{
		if(mapdata)
		{
			sendfile(cn, 2, mapdata, "ri", N_SENDMAP);
			return true;
		}
	}
	
	return false;
}


void player_changemap(int cn, const char * map, const char * mode)
{
	int gmode = (mode[0] ? modecode(mode) : gamemode);
	if(!m_mp(gmode)) gmode = gamemode;
	clientinfo * ci = getinfo(cn);
	if(!ci) return;
	sendf(ci->ownernum, 1, "risii", N_MAPCHANGE, map, gmode, 1);
}

void unset_shown_priv()
{
	currentmaster = -1;
	masterupdate = true;
}

void set_shown_priv(int cn)
{
	currentmaster = cn;
	masterupdate = true;
}

void send_x_hitpush(int cn, int damage, int power, int gun)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, ci->clientnum, gun, damage, power, 0, 0);
}

void send_y_hitpush(int cn, int damage, int power, int gun)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, ci->clientnum, gun, damage, 0, power, 0);
}

void send_z_hitpush(int cn, int damage, int power, int gun)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, ci->clientnum, gun, damage, 0, 0, power);
}

void send_hitpush(int cn, int x, int y, int z)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, ci->clientnum, 5, 100, x, y, z);
}

void send_x_hitpush_as(int cn, int ocn, int power)
{
	clientinfo * ci = get_ci(cn);
	clientinfo * oi = get_ci(ocn);
	if (!ci || !oi) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, oi->clientnum, 5, 100, power, 0, 0);
}

void send_y_hitpush_as(int cn, int ocn, int power)
{
	clientinfo * ci = get_ci(cn);
	clientinfo * oi = get_ci(ocn);
	if (!ci || !oi) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, oi->clientnum, 5, 100, 0, power, 0);
}

void send_z_hitpush_as(int cn, int ocn, int power)
{
	clientinfo * ci = get_ci(cn);
	clientinfo * oi = get_ci(ocn);
	if (!ci || !oi) return;
	sendf(ci->ownernum, 1, "ri7", N_HITPUSH, oi->clientnum, 5, 100, 0, 0, power);
}

void spawn_player(int cn)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendspawn(ci);
}

void spawn_mod_player(int cn)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	gamestate &gs = ci->state;
	gs.lifesequence = (gs.lifesequence + 1)&0x7F;
	sendf(ci->ownernum, 1, "rii7v", N_SPAWNSTATE, ci->clientnum, gs.lifesequence,
		gs.health, gs.maxhealth,
		gs.armour, gs.armourtype,
		gs.gunselect, GUN_PISTOL-GUN_SG+1, &gs.ammo[GUN_SG]);
	gs.lastspawn = gamemillis;
}

void change_player_health(int cn, int health, int maxhealth)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	gamestate &gs = ci->state;
	gs.health = health;
	gs.maxhealth = maxhealth;
}

void send_player_ammo(int cn, int gun, int ammo)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(-1, 1, "ri6", N_BASEREGEN, ci->clientnum, ci->state.health, ci->state.armour, gun, ammo);
}

void change_player_ammo(int cn, int gun, int ammo, int gunselect = GUN_FIST)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	gamestate &gs = ci->state;
	gs.ammo[gun] = ammo;
	gs.gunselect = gunselect;
}

void send_player_gunselect(int cn, int gun)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(-1, 1, "ri5si", N_CLIENT, ci->clientnum, 100/*should be safe*/, N_GUNSELECT, gun);
}

void change_player_gunselect(int cn, int gunselect)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	gamestate &gs = ci->state;
	gs.gunselect = gunselect;
}

int player_gunselect(int cn)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return -1;
	return ci->state.gunselect;
}

void reset_player_gamestate(int cn)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	gamestate &gs = ci->state;
	gs.respawn();
	gs.spawnstate(gamemode);
}

void frag_player(int t_cn, int a_cn)
{
	clientinfo * target = get_ci(t_cn);
	clientinfo * actor = get_ci(a_cn);

	if(!target) return;
	if(!actor) return;

	target->state.deaths++;
	target->state.suicides += actor==target;
	if(actor!=target && isteam(actor->team, target->team))
	{
		actor->state.teamkills++;
		event_teamkill(event_listeners(), boost::make_tuple(actor->clientnum, target->clientnum));
	}
	actor->state.frags++;
	sendf(-1, 1, "ri4", N_DIED, target->clientnum, actor->clientnum, actor->state.frags);
	target->position.setsize(0);
	if(smode) smode->died(target, actor);
	gamestate &ts = target->state;
	ts.state = CS_DEAD;
	ts.lastdeath = gamemillis;
}

void send_shot(int cn, int ocn, int gun)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	clientinfo * oci = get_ci(ocn);
	if (!oci) return;
	vec pos = ci->state.o;
	vec opos = oci->state.o;
	loopv(clients)
	{
		sendf(clients[i]->ownernum, 1, "ri9x", N_SHOTFX, ci->clientnum, gun,
			pos.x, pos.y, pos.z, //from x, y, z
			opos.x, opos.y, opos.z, //to x, y, z
			ci->ownernum);
	}
}

void send_private_shot(int cn, int fcn, int gun)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	clientinfo * fci = get_ci(fcn);
	if (!fci) return;
	vec opos = ci->state.o;
	vec pos = fci->state.o;
	sendf(ci->ownernum, 1, "ri9x", N_SHOTFX, fci->clientnum, gun,
		pos.x, pos.y, pos.z, //from x, y, z
		opos.x, opos.y, opos.z, //to x, y, z
		ci->ownernum);
}

void update_health(int cn)
{
	clientinfo * target = get_ci(cn);
	if(!target) return;
	gamestate &ts = target->state;
	sendf(-1, 1, "ri6", N_DAMAGE, target->clientnum, target->clientnum, 0, ts.armour, ts.health);
}

void send_health(int cn, int health, int armour)
{
	clientinfo * target = get_ci(cn);
	if(!target) return;
	sendf(target->clientnum, 1, "ri6", N_DAMAGE, target->clientnum, target->clientnum, 0, armour, health);
}

void send_fake_damage(int cn, int ocn, int damage)
{
	clientinfo * target = get_ci(cn);
	if (!target) return;
	clientinfo * actor = get_ci(ocn);
	if (!actor) return;
	gamestate &ts = target->state;
	sendf(target->clientnum, 1, "ri6", N_DAMAGE, target->clientnum, actor->clientnum, damage, ts.armour, ts.health);
}

void send_current_mastermode(int cn)
{
	clientinfo * ci = get_ci(cn);
	if (!ci) return;
	sendf(ci->ownernum, 1, "rii", N_MASTERMODE, mastermode);
}

void send_fake_text(int cn, int fcn, const char * text)
{
	sendf(cn, 1, "riis", N_SAYTEAM, fcn, text);
}

void send_fake_text_(int cn, int ocn, const char * text)
{
	vector<uchar> message;
	putuint(message, N_TEXT);
	sendstring(text, message);
	
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putuint(p, N_CLIENT);
	putint(p, ocn);
	putint(p, message.length());
	p.put(message.getbuf(), message.length());
	sendpacket(cn, 1, p.finalize());
}

void sendclients(int cn)
{
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putint(p, N_RESUME);
	loopv(clients)
	{
		clientinfo *oi = clients[i];
		if(oi->clientnum==cn || !oi->spy) continue;
		putint(p, oi->clientnum);
		putint(p, oi->state.state);
		putint(p, oi->state.frags);
		putint(p, oi->state.flags);
		putint(p, oi->state.quadmillis);
		sendstate(oi->state, p);
	}
	putint(p, -1);
	welcomeinitclient(p, cn);
	sendpacket(cn, 1, p.finalize());
}

void sendinitclient_(int cn, int ocn)
{
	clientinfo * ci = get_ci(cn);
	clientinfo * oi = get_ci(ocn);
	if(!ci || !oi) return;
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putinitclient(oi, p);
	sendpacket(ci->clientnum, 1, p.finalize());
}


void send_disconnect(int cn)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(-1, 1, "ri2", N_CDIS, cn);
}

void send_fake_disconnect(int cn, int ocn)
{
	sendf(cn, 1, "ri2", N_CDIS, ocn);
}

void send_fake_connect(int cn, int ocn, const char * name, const char * team)
{
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putint(p, N_INITCLIENT);
	putint(p, ocn);
	sendstring(name, p);
	sendstring(team, p);
	putint(p, 0); // playermodel
	sendpacket(cn, 1, p.finalize());
}

void send_spectator(int cn, int val)
{
	clientinfo * ci = get_ci(cn);
	if(!ci || player_isbot(cn)) return;
	sendf(-1, 1, "ri3", N_SPECTATOR, ci->clientnum, val);
}

void send_fake_spectator(int cn, int ocn, int val)
{
	sendf(cn, 1, "ri3", N_SPECTATOR, ocn, val);
}

void sendinitmap(int cn)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putint(p, N_MAPCHANGE);
	sendstring(smapname, p);
	putint(p, gamemode);
	putint(p, notgotitems ? 1 : 0);
	if(!ci || (m_timed && smapname[0]))
	{
		putint(p, N_TIMEUP);
		putint(p, gamemillis < gamelimit && !interm ? max((gamelimit - gamemillis)/1000, 1) : 0);
	}
	if(!notgotitems)
	{
		putint(p, N_ITEMLIST);
		loopv(sents) if(sents[i].spawned)
		{
			putint(p, i);
			putint(p, sents[i].type);
		}
		putint(p, -1);
	}
	if(gamepaused)
	{
		putint(p, N_PAUSEGAME);
		putint(p, 1);
	}
	sendpacket(ci->clientnum, 1, p.finalize());
}

int player_flags(int cn)
{
	clientinfo * ci = get_ci(cn);
	return ci->state.flags;
}

void editvar(int cn, const char *var, int value) // by Thomas & pureascii, taken from hide and seek repository of hopmod
{
	clientinfo *ci = getinfo(cn);
	if (!ci) return;
	sendf(cn, 1, "ri5si", N_CLIENT, cn, 100/*should be safe*/, N_EDITVAR, ID_VAR, var, value);
}

void editf(int x, int y, int z)
{
	loopv(clients) {
		sendf(-1, 1, "ri4i9i6",
			N_CLIENT, clients[i]->clientnum, 100/*should be safe*/,
			N_EDITF + EDIT_FACE, x, y, z, 0, 0, 0, 3 /* gridpower*/, 1,
			0, 0, 0, 0, 1,
			0, 0);
	}
/*
	addmsg(N_EDITF + op, "ri9i6",
					   sel.o.x, sel.o.y, sel.o.z, sel.s.x, sel.s.y, sel.s.z, sel.grid, sel.orient,
					   sel.cx, sel.cxs, sel.cy, sel.cys, sel.corner,
					   arg1, arg2);
*/
}


void reset_maploaded(int cn)
{
	get_ci(cn)->maploaded = false;
}

void send_servinfo(int cn, const char * desc)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(ci->clientnum, 1, "ri5s", N_SERVINFO, ci->clientnum, PROTOCOL_VERSION, ci->sessionid, 0, desc);
}

void send_sessionid(int cn, int id)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(ci->clientnum, 1, "ri5s", N_SERVINFO, ci->clientnum, PROTOCOL_VERSION, id, 0, serverdesc);
}

void send_protocol_version(int cn, int version)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(ci->clientnum, 1, "ri5s", N_SERVINFO, ci->clientnum, version, ci->sessionid, 0, serverdesc);
}

void send_clientnum(int cn, int ncn)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return;
	sendf(ci->clientnum, 1, "ri5s", N_SERVINFO, ncn, PROTOCOL_VERSION, ci->sessionid, 0, serverdesc);
}

void send_fake_priv(int cn, int ocn, int priv)
{
	sendf(cn, 1, "ri4", N_CURRENTMASTER, ocn, priv, mastermode);
}

bool sendmap_from_file(int cn, const char * filename)
{
	clientinfo * ci = get_ci(cn);
	if(!ci) return false;
	stream *filestream = openfile(filename, "r");
	if(!filestream) return false;
	sendfile(ci->clientnum, 2, filestream, "ri", N_SENDMAP);
	return true;
}

void send_editmode(int cn, int val)
{
	clientinfo *ci = getinfo(cn);
	if (!ci) return;
	if(val ? ci->state.state!=CS_ALIVE && ci->state.state!=CS_DEAD : ci->state.state!=CS_EDITING) return;
	if(smode)
	{
		if(val) smode->leavegame(ci);
		else smode->entergame(ci);
	}
	if(val)
	{
		ci->state.editstate = ci->state.state;
		ci->state.state = CS_EDITING;
		ci->events.setsize(0);
		ci->state.rockets.reset();
		ci->state.grenades.reset();
	}
	else ci->state.state = ci->state.editstate;
	sendf(cn, 1, "ri5", N_CLIENT, cn, 100/*should be safe*/, N_EDITMODE, val);
}

void send_fake_editmode(int cn, int ocn, int val)
{
	sendf(cn, 1, "ri5", N_CLIENT, ocn, 100/*should be safe*/, N_EDITMODE, val);
}

void send_fake_switchmodel(int cn, int ocn, int val)
{
	sendf(cn, 1, "ri5", N_CLIENT, ocn, 100/*should be safe*/, N_SWITCHMODEL, val);
}

bool silent_changeteam(int cn, const char * newteam, bool suicide_)
{
	clientinfo * ci = get_ci(cn);
	
	if(!m_teammode || (smode && !smode->canchangeteam(ci, ci->team, newteam)) ||
		event_chteamrequest(event_listeners(), boost::make_tuple(cn, ci->team, newteam)) == -1) return false;
	
	if((smode || ci->state.state==CS_ALIVE) && suicide_/*&& signal_teamswitch_suicide(ci->clientnum, newteam) != -1*/) suicide(ci);
	event_reteam(event_listeners(), boost::make_tuple(ci->clientnum, ci->team, newteam));
	
	copystring(ci->team, newteam, MAXTEAMLEN+1);
	sendf(-1, 1, "riisi", N_SETTEAM, ci->clientnum, ci->team, -1);
	
	if(ci->state.aitype == AI_NONE) aiman::dorefresh = true;
	
	return true;
}

bool silent_changeteam(int cn, const char * newteam)
{
	return silent_changeteam(cn, newteam, false);
}


void send_fake_rename(int cn, int ocn, const char * newname)
{
	char safenewname[MAXNAMELEN + 1];
	filtertext(safenewname, newname, false, MAXNAMELEN);
	if(!safenewname[0]) copystring(safenewname, "unnamed");
	
	vector<uchar> switchname_message;
	putuint(switchname_message, N_SWITCHNAME);
	sendstring(safenewname, switchname_message);
	
	packetbuf p(MAXTRANS, ENET_PACKET_FLAG_RELIABLE);
	putuint(p, N_CLIENT);
	putint(p, ocn);
	putint(p, switchname_message.length());
	p.put(switchname_message.getbuf(), switchname_message.length());
	sendpacket(cn, 1, p.finalize());
}

// ... MOD


//alphaserv
//int cn, int chan, const char *format, ...
int lua_sendf(lua_State *L)
{
	int argc = lua_gettop(L);
	if(argc < 3)
	{
		luaL_error(L, "Not enough arguments.");
		return 0;
	}
	
	argc -= 3;
	
	int cn = luaL_checknumber(L, 1);
	int chan = luaL_checknumber(L, 1);
	const char *format = luaL_checkstring(L, 1);
	
	int exclude = -1;
	bool reliable = false;
	if(*format=='r') { reliable = true; ++format; }
	packetbuf p(MAXTRANS, reliable ? ENET_PACKET_FLAG_RELIABLE : 0);
	
	while(*format) switch(*format++)
	{
		//case 'x':
		//	exclude = va_arg(args, int);
		//	break;

		case 'v':
		{
			luaL_error(L, "non implemented option v");
			return 0;
			//int n = va_arg(args, int);
			//int *v = va_arg(args, int *);
			//loopi(n) putint(p, v[i]);
			//break;
		}

		case 'i': 
		{
			int n = isdigit(*format) ? *format++-'0' : 1;
			loopi(n) putint(p, luaL_checknumber(L, 1));
			break;
		}
		case 'f':
		{
			int n = isdigit(*format) ? *format++-'0' : 1;
			loopi(n) putfloat(p, (float)luaL_checknumber(L, 1));
			break;
		}
		case 's': sendstring(luaL_checkstring(L, 1), p); break;
		case 'm':
		{
			luaL_error(L, "non implemented option m");
			//int n = va_arg(args, int);
			//p.put(va_arg(args, uchar *), n);
			//break;
		}
	}
	
	ENetPacket *packet = p.finalize();
	sendpacket(cn, chan, packet, exclude);
	
	//packet->referenceCount > 0 ? packet : NULL;
	return 0;
}
#endif
