
--[[
	script/module/nl_mod/nl_ufo.lua
	ufono (GSTF-clan)
	Created: 07.01.11	
       Last Modified: 07.01.11
	

	Funktionen:
		cookies an spieler versenden

	Commands:
		#cookie <CN> 			Schickt ein cookie an den Spieler mit der entsprechenden CN
	
	]]


--[[
		COMMANDS
]]

--[[    Zukunftsvision
		API

cookie = {}
cookie.limit = server.cookie_limit or 3
]]



function server.playercmd_cookie(cn, tocn)
	if hasaccess(cn, user_access) then
		if not server.valid_cn(tocn) then 
			server.player_msg(cn, cmderr(string.format( "%s is not a valid cn", tostring(tocn)) ));
			return
		end
		if tostring(cn) == tostring(tocn) then 
			server.player_msg(cn, red("You can't give yourself a cookie!"));
			return
		end
		for _, mcn in pairs(players.all()) do
			server.player_msg(mcn, string.format( "\f1 %s \f5 has given \f2 %s \f5a cookie!",server.player_name(cn), server.player_name(tocn) ))
		end
	else
		messages.info(cn, {cn}, "cookie", "\f3 ERROR \f0 To send cookies please register your name here:\f2 www.nooblounge.net")
	end
end

--[[-------TUT NIX ZUR SACHE!--------------------------------------------------
string.format( "%s has given %s a cookie!",                    ---richtig
string.format(("%s".red "has given")."(%s) a cookie!"),  --

(("%s".red "has given")."(%s) a cookie!")       --- falsch
------------------------------------------------------------]]

--[[
FARBEN!!!!!!!!!!
------------------------------------------------------------------------------------------------------------------------------
("das ist ein text ohne farbe")
("\f3das ist rot")
("\f<n> das ist die farbe mit der nummer <n>...")wobei <n> folgendes sein kann:
 0 grün
 1 blau
 2 gelb
 3 rot
 4 grau
 5 magenta
 6 orange
 7 weiss
 oder, bei hopmod, green(text), red(text), usw (grey() gibts nicht)
------------------------------------------------------------------------------------------------------------------------------------
]]


--[[  hankus hankus!!!

server.playercmd_cookie(cn, tocn)

	if  hasaccess(cn, admin_access) then
-- elseif return 
	if not server.valid_cn(tocn) then 
       server.player_msg(cn, cmderr(string.format( "%s is not a valid cn", tostring(tocn)) )); return end
	for _, mcn in pairs(players.all()) do
       server.player_msg(mcn, string.format( "\f1 %s \f5 has given \f2 %s \f5a cookie!",server.player_name(cn), server.player_name(tocn) ))
	end
end

]]
