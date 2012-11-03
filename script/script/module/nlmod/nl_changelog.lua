--[[
	script/module/nl_mod/nl_changelog.lua
	Hankus (Derk Haendel)
	29-Jan-2011
	License: GPL3

	Funktionen:
		Stellt ein einfaches Changelog-System für z.B. die
		Website zur Verfügung.

	Commands:
		#clog <string category> <string description>
			Eintrag in nl_changelog-Tabelle erzeugen
			(siehe Changelog auf www.nooblounge.net)

]]



--[[
		API
]]

changelog = {}
changelog.categories = {}
changelog.categories["nl"] = "NoobMod"
changelog.categories["web"] = "Website"
changelog.categories["map"] = "MapLounge"

--[[
		COMMAND
]]

function server.playercmd_clog(cn, cat, desc)
	if hasaccess(cn, user_access) then
		if not cn or not desc then
			messages.info(cn, {cn}, "CLOG", "\f3 USAGE EXAMPLE:\f0 #clog nl \"Added a simple changelog-system\"")
			return
		end
		if not changelog.categories[cat] then
			messages.info(cn, {cn}, "CLOG", string.format("\f3 ERROR:\f0 %s is not in the category-list", cat))
		else
			local aktcat = changelog.categories[cat]
			db.insert("nl_changelog", { nickname=server.player_name(cn), category=aktcat, description=desc })
		end
	else
		messages.info(cn, {cn}, "CLOG", string.format("\f3 ERROR \f0 You need adminstatus to use #clog, %s", server.player_name(cn)))
	end
end

