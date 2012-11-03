--[[
	script/module/nl_mod/nl_gift.lua
	ufono (GSTF-clan)
	Created: 07.01.11	
	Last Modified: 27.04.12
	

	Funktionen:
		Gifts an spieler versenden

	Commands:
		#cookie <CN>		Schickt ein cookie an den Spieler mit der entsprechenden CN
 		#hi5 <CN>			Schickt ein high-five an den Spieler mit der entsprechenden CN
		#hug <CN>  			Schickt ein hug an den Spieler mit der entsprechenden CN
		#slap <CN>			Schickt ein slap an den Spieler mit der entsprechenden CN
		#kiss <CN>			Schickt ein kiss an den Spieler mit der entsprechenden CN
		#pwnd <CN>			Schickt ein pwnd an den Spieler mit der entsprechenden CN
]]




function server.playercmd_cookie(cn, tocn)
	give(cn, tocn, "cookie")
end

function server.playercmd_hi5(cn, tocn)
	give(cn, tocn, "hi5")
end

function server.playercmd_slap(cn, tocn)
	give(cn, tocn, "slap")
end

function server.playercmd_hug(cn, tocn)
	give(cn, tocn, "hug")
end

function server.playercmd_kiss(cn, tocn)
	give(cn, tocn, "kiss")
end

function server.playercmd_pwnd(cn, tocn)
	give(cn, tocn, "pwnd")
end

function give(cn, tocn, item) 
	if hasaccess(cn, user_access) then
		if not server.valid_cn(tocn) then 
			server.player_msg(cn, cmderr(string.format( "%s is not a valid cn", tostring(tocn)) ))
			return
		end
		if tostring(cn) == tostring(tocn) then
			messages.info(cn, {cn}, "GIFT", string.format("\f3 ERROR \f0 You can't use #%s with your own cn!", item))
			return
		end
		if tostring(item) == "cookie" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f1%s \f5has given \f2%s \f5a cookie!",server.player_name(cn), server.player_name(tocn) ))
			end
		end
		if tostring(item) == "hi5" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f1%s \f0got \f6high fived \f0by \f2%s ",server.player_name(tocn), server.player_name(cn) ))
			end
		end
		if tostring(item) == "slap" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f1%s \f3got slapped \f0by \f2%s ",server.player_name(tocn), server.player_name(cn) ))
			end
		end
		if tostring(item) == "hug" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f6%s \f5got hugged \f0by \f2%s ",server.player_name(tocn), server.player_name(cn) ))
			end
		end
		if tostring(item) == "kiss" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f6%s \f5got kissed \f0by \f2%s ",server.player_name(tocn), server.player_name(cn) ))
			end
		end
		if tostring(item) == "pwnd" then
			for _, mcn in pairs(players.all()) do
				server.player_msg(mcn, string.format( "\f6%s \f5got pwnd \f0by \f2%s ",server.player_name(tocn), server.player_name(cn) ))
			end
		end
	else
		messages.info(cn, {cn}, "GIFT", string.format("\f3 ERROR \f0 To use #%s please register your name here:\f2 www.nooblounge.net", item))
	end
end


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
]]
