--[[
	script/module/nl_mod/nl_init.lua
	Derk Haendel
	20-Sep-2010
	License: GPL3
	
	Starten der NoobLounge-Module
	Zum Start sind teilweise noch zusaetzliche Einstellungen in der server.conf zu machen
	
]]

--[[
  Variablen und Events

  server.conf:
		global nl_event_debug 0
]]
server.botlimit = 0
load_once("../nl_mod/nl_core")

--[[
  Nameprotection

  server.conf:
]]
load_once("../nl_mod/nl_protect")

--[[
  mySQL-Stats (nl_players, nl_games, nl_teams, nl_playertotals)

	server.conf:
		global stats_enabled 1
		global stats_servername "nl4"
		global stats_mysql_hostname "localhost"
		global stats_mysql_port 3306
		global stats_mysql_database "webspell"
		global stats_mysql_username "justice"
		global stats_mysql_password "jus56stice"
		global stats_demo_filename "leer"
		global stats_enabled_gamemodes [
			"ffa"
			"teamplay"
			"instagib"
			"instagib team"
			"efficiency"
			"efficiency team"
			"tactics"
			"tactics teams"
			"capture"
			"regen capture"
			"ctf"
			"insta ctf"
			"efficiency ctf"
			"protect"
			"insta protect"
			"efficiency protect"
			"hold"
			"insta hold"
			"efficiency hold"
		]
]]
load_once("../nl_mod/nl_stats")

--[[
  Balance mit Spielergewichtung

  server.conf:
		global bonus_score 100
		global bonus_steal 20
		global bonus_reset 5
		global bonus_frag 1
		global bonus_teamkill 100
		global nl_enable_balance 1
]]
--load_once("nl_mod/balance_cmd")
load_once("../nl_mod/nl_balance")

--[[
  IRC-Bot
]]
load_once("nl_mod/nl_bot")
