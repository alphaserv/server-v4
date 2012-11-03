--[[  Balance Script
      
      script/module/nl_mod/nl_aimbot.lua
 
      Function:
         move one player from an team to an team with lesser players.
         It provieds to balance two up to four teams.
         Also an unbalance can be provided. 

      Last changed:
         Unbalance 

      Author: NuckChorris
      Created: 01/Feb/2011
      Last Modified: 18/Mar/2011
      Version: 0.05b

      returns:
       -1 if an error accures
       -2 if balance was applied
]]

balance = {}
balance.numberGood = 0        -- Wanted number of players team good. For unbalance
balance.numberEvil = 0        -- Wanted number of players team evil. For unbalance
balance.enabled = 0           -- Disables the balance inside the balance function
server.nl_balance_enabled = 0 -- Turns balance initial off


balance.running = 0           -- Sets if balance is running
balance.runerror = 0          -- If an error accures and balance.running is not resetted
balance.bestma = 0            -- If Bestmatch is activated 
balance.longtime = 0          -- If a longe "time" no balance forced

--[[ START
   Starts the balance script
]]
function balance.start(cn)
local return_value
--errorLog("############################# \n","balance.start")
--errorLog("Balance Started","balance.start")

   -- If balance is disabled ==> no balance is required
   if server.nl_balance_enabled == 0 or balance.running == 1 or balance.enabled == 0 then

    messages.debug(cn, players.admins(),"balance.start","Balance ended")
  
    errorLog("No balance required, NL Balance = "..tostring(server.nl_balance_enabled).." Balance Running = "..tostring(balance.running).." RunError = "..tostring(balance.runerror),"balance.start")

      -- If by any reason the balance.running is not setback to 0
      balance.runerror = balance.runerror + 1

      if balance.runerror >= 5 then    
         balance.running = 0 
         balance.runerror = 0
      end

      return -1
   else
      balance.running = 1  --set balance.running = 1 if balance is started

      messages.debug(-1, players.admins(),"balance.running=1 "..tostring(balance.running),"Balance ended")
      --errorLog("balance.running=1 "..tostring(balance.running),"balance.start")

      return_value = balance.main(cn)
      balance.running = 0  --set balance.running = 0 if balance is ended

      messages.debug(-1, players.admins(),"balance.running=0 "..tostring(balance.running),"Balance ended")
      --errorLog("balance.running = 0 "..tostring(balance.running),"balance.start")
      --errorLog("Balance ENDED RETURN= "..tostring(return_value).."\n ###########################","balance.main")
      return -1
   end
end


--[[ MAIN
   Main function of the Balance Script
   combine all function in the Script
]]
function balance.main(cn)

--errorLog("Balance Main is started","balance.main")

local player_id = -1
local teams = {}     --Array of team names
local teamcount = 0  --number of teams

local team1 = {}     --contains the index and the cn of team 1
local team2 = {}     --contains the index and the cn of team 2
local team3 = {}     --contains the index and the cn of team 3
local team4 = {}     --contains the index and the cn of team 4

local teamA = {}     --contains the index and the cn of the team with the fewest number of players
local teamB = {}
local teamC = {}
local teamD = {}     --contains the index and the cn of the team with the higest number of players

local plnumberA = 0
local plnumberB = 0
local plnumberC = 0
local plnumberD = 0

local teamCH = 0     -- to change the teams
local plnumberCH = 0 -- to change the numbers

local plnumbers = {0,0,0,0}   --total numbers of players in one team
local teamnumber = {1,2,3,4}  --number of the team for sorting

-- set all tables to zero
plnumbers[1]=0
plnumbers[2]=0
plnumbers[3]=0
plnumbers[4]=0

local unbalance = 0
local teamunbal = 0

--returns an array of team names  
teams = server.teams()            

-- fill the teams into the table and count the number of teams
if teams[1] ~= nil then
       team1=server.team_players(teams[1])
       teamcount = teamcount + 1
end
if teams[2] ~= nil then
       team2=server.team_players(teams[2])
       teamcount = teamcount + 1
end
if teams[3] ~= nil then 
       team3=server.team_players(teams[3])
       teamcount = teamcount + 1
end
if teams[4] ~= nil then
       team4=server.team_players(teams[4])
       teamcount = teamcount + 1
end
--errorLog("Teamcount = "..tostring(teamcount),"Balance")
--errorLog("Teams 1-4: "..tostring(team1).." "..tostring(team2).." "..tostring(team3).." "..tostring(team4).." ","balance.main")

-- Returns player numbers per team
if team1 ~= nil then plnumbers[1] = balance.playernumbers(team1) else plnumbers[1] = 0 end
if team2 ~= nil then plnumbers[2] = balance.playernumbers(team2) else plnumbers[2] = 0 end
if team3 ~= nil then plnumbers[3] = balance.playernumbers(team3) else plnumbers[3] = 0 end
if team4 ~= nil then plnumbers[4] = balance.playernumbers(team4) else plnumbers[4] = 0 end

--errorLog("Playernumbers team 1-4  = "..tostring(plnumbers[1]).." "..tostring(plnumbers[2]).." "..tostring(plnumbers[3]).." "..tostring(plnumbers[4]),"balance.main")

team = {team1,team2,team3,team4}

--errorLog("Playernumbers team 1-4  = "..tostring(plnumbers[1]).." "..tostring(plnumbers[2]).." "..tostring(plnumbers[3]).." "..tostring(plnumbers[4]),"balance.main")

-- If a unbalanced is required the teamnumbers are changed
   if balance.numberGood and balance.numberEvil and balance.numberGood > 0 and balance.numberEvil > 0 then

      --errorLog("Balance GOOD= "..tostring(balance.numberGood).." Balance EVIL= "..tostring(balance.numberEvil).."\n","balance.main")

      unbalance = plnumbers[1] + plnumbers[2]
      if balance.numberGood > balance.numberEvil then
            teamunbal = math.ceil(unbalance *((balance.numberEvil)/(balance.numberEvil+balance.numberGood)))
            if plnumbers[1] < (unbalance - teamunbal) then
               plnumbers[1]=(unbalance - teamunbal)
               plnumbers[2]=(teamunbal)
            elseif plnumbers[1] > (unbalance - teamunbal) then
               plnumbers[1] = (teamunbal)
               plnumbers[2] = (unbalance - teamunbal)
            elseif plnumbers[1] == (unbalance - teamunbal) then
               plnumbers[1] = 0
               plnumbers[2] = 0
            end
      elseif balance.numberGood < balance.numberEvil then
            teamunbal = math.ceil(unbalance *((balance.numberGood)/(balance.numberEvil+balance.numberGood)))
            if plnumbers[2] < (unbalance - teamunbal) then
               plnumbers[2]=(unbalance - teamunbal)
               plnumbers[1]=(teamunbal)
            elseif plnumbers[2] > (unbalance - teamunbal) then
               plnumbers[2] = (teamunbal)
               plnumbers[1] = (unbalance - teamunbal)
            elseif plnumbers[2] == (unbalance - teamunbal) then
               plnumbers[1] = 0
               plnumbers[2] = 0
            end
      end
  end

-- Put the Teamnumbers and PLNUMBERS in the errorLog 
            for key,tab in pairs(teamnumber) do
               errorLog("Teamnumbers : "..tostring(tab),"balance.balance")
            end
            for key,tab in pairs(plnumbers) do
               errorLog("PLNUMBERS : "..tostring(tab),"balance.balance")
            end

            -- sort the team in respect to the playernumber per team
            team,plnumbers=balance.sortPlayers(team,plnumbers)

            for key,tab in pairs(teamnumber) do
               errorLog("Teamnumbers : "..tostring(tab),"balance.balance")
            end
            for key,tab in pairs(plnumbers) do
               errorLog("PLNUMBERS : "..tostring(tab),"balance.balance")
            end

            errorLog("Teams A-D: "..tostring(team1).." "..tostring(team2).." "..tostring(team3).." "..tostring(team4).."         ","balance.main")
            errorLog("NUMBERS Team 1 = "..tostring(plnumbers[1]).." Team 2 = "..tostring(plnumbers[2]).." Team 3 = "..tostring(plnumbers[3]).." Team 4 = "..tostring(plnumbers[4]).."\n","balance.main")

   if teamcount == 0 or teamcount > 4 then
      balance.running = 0            
      return -1
   -- Balance the highest and the lowest team
   elseif teamcount == 1 then k = balance.balance(team[3],team[4],plnumbers[3],plnumbers[4],-2) 
   elseif teamcount == 2 then k = balance.balance(team[3],team[4],plnumbers[3],plnumbers[4],cn)
   elseif teamcount == 3 then k = balance.balance(team[3],team[4],plnumbers[2],plnumbers[4],cn)
   elseif teamcount == 4 then k = balance.balance(team[3],team[4],plnumbers[1],plnumbers[4],cn)
   end

   if k == -1 then
      balance.running = 0            
      return -1 
   elseif k == -2 or k == -3 then  
      balance.running = 0            
      return -2 
   end

    balance.running = 0            
    return -3 
end


--[[ BALANCE
   Balance is applied to the two given teams
   TeamB is the team with more players
]]
function balance.balance(teamA,teamB,plnumberA,plnumberB,cn)
local teamweightA = 0
local teamweightB = 0
local teampwA = {}
local teampwB = {}
local balcn = -2
local diffCount = 0           --distance between teamweightA and teamweightB
local cn = tonumber(cn)
local plnumberA_test = 0
local plnumberB_test = 0
local player_id

errorLog("Enter balance script","balance.balance")

-- test if balance is required
if math.abs(plnumberA-plnumberB) == 0 then
   messages.debug(-1, players.admins(),"BALANCE","No balance required, difference is 0. Balance ended")
   errorLog("No balance required, difference is 0. Balance ended\n","balance.balance")
   return -1
elseif math.abs(plnumberA-plnumberB)<=1 then
   messages.debug(-1, players.admins(),"BALANCE","No balance required, difference is 1. Balance ended")
   errorLog("No balance required, difference is 1. Balance ended\n","balance.balance")
   return -1
end

-- put the teams in the error log
for key,tab in pairs(teamA) do
   errorLog("TeamA CN= "..tostring(tab).." "..tostring(server.player_name(tab)),"balance.balance")
end

for key,tab in pairs(teamB) do
   errorLog("TeamB CN= "..tostring(tab).." "..tostring(server.player_name(tab)),"balance.balance")
end
   errorLog("plnumberB= "..tostring(plnumberB),"balance.balance")

--calculate for both teams the teamweight variable from the playerweight-function
--variable for each player from the playerweight()function
--!!!!!On every sort or change on any team-table teamcn-table must also bean changed!!!!!
if teamA ~= nil then 
   teamweightA,teampwA = balance.filltables(teamA)
else
   teamweightA = 0
   teampwA = {}
end
if teamB ~= nil then 
   teamweightB,teampwB = balance.filltables(teamB)
else
   teamweightB = 0
   teampwB = {}
end

   --errorLog("TeamA weight= "..tostring(teamweightA),"balance.balance")
   --errorLog("TeamB weight= "..tostring(teamweightB),"balance.balance")

-- Difference between the skills of team i and team j


   --errorLog("diffCount= "..tostring(diffCount),"balance.balance")

-- Sort the team and teampw table
teamB,teampwB=balance.sortPlayers(teamB,teampwB)

    --choose the right function to balance
   if balance.bestma == 0 then
      errorLog("FindLowest function called ","balance.balance")
      balcn = balance.findLowest(teamB,teampwB,cn)
   elseif balance.bestma == 1 then
      diffCount = math.abs(teamweightA-teamweightB)
      balcn = balance.bestMatch(teamB,teampwB,diffCount,cn)
   end
   
   if balcn < 0 then
      errorLog("Balcn is less than zero: "..tostring(balcn),"balance.balance")
      return
   end
      

   player_id = server.player_sessionid(balcn)
   if nl_players[player_id] then
      gotsw = nl_players[player_id].got_switched
   else
      gotsw = false
   end

      --errorLog("balcn "..tostring(balcn).." cn "..tostring(cn).." balance.longtime "..tostring(balance.longtime),"balance.balance")

      -- if balance is forced (cn=-1) or if longe time is no player matched do switch
      if gotsw == false or balance.longtime > 3 then
         balance.changeTeam(balcn)
         balance.longtime = 0
         messages.debug(cn, players.all(), "BALANCE", "Balance performed.Player balanced")
         errorLog("Balance performed.Player balanced\n".." balance.longtime "..tostring(balance.longtime),"balance.balance")
         return -2
      else      
         messages.debug(-1, players.all(), "BALANCE", "Balance performed. No player balanced, NO MATCH")
         -- errorLog("Balance performed. No player balanced, NO MATCH","balance.balance")  
         return -3
      end
end


--[[ PLAYERNUMBERS
   Returns the numbers of entry in the given table
]]
function balance.playernumbers(playertable)
local players = playertable
local number = 0
   if players ~= nil then 
      for key,cn in pairs(players) do
         number = number + 1
      end
   end
   return number
end

--[[ FILLTABLES
returns the teamweight, and a table with the playerweight of every player.
]]
function balance.filltables(teamtab)
local plweight = 0
local teamweight = 0
local teamtable = {}
local plweights = {}
teamtable = teamtab
   
   for key,cn in pairs(teamtable) do
      plweight = balance.playerweight(cn)
      --errorLog("CN: "..tostring(cn).." PLWEIGHT: "..tostring(plweight),"balance.filltables")
      if plweight ~= (-1) then
         teamweight=teamweight+plweight   --Variable for all skills of one team             
         table.insert(plweights,plweight)    --table for the player skillsw
      else
         teamweight=teamweight+0          
         table.insert(plweights,0)  
      end    
   end
   return teamweight,plweights
end

--[[ BESTMATCH
   returns the best matching player (his playercn) to switch if there is an unbalance in team count and all count
]]
function balance.bestMatch(team1,teampw1,diff,balcn)
local diffBetween = 0
local team = team1
local teampw = teampw1
local sorted = {}   
local match=diff/2    --divides diff by 2, and find the closest player
local playercn

   for key,all in pairs(teampw) do
      playercn = team[key]
      diffBetween = 0
      diffBetween=math.abs(all-match)   -- calculates the difference between playerweigt und diff/2
      table.insert(sorted,diffBetween)  --write the diffBetween in the new table to sort it
      messages.debug(cn, players.all(), "BALANCE","diffBetween for CN= "..tostring(playercn).." diffBetween= "..tostring(diffBetween))
      --errorLog("diffBetween for CN= "..tostring(playercn).." diffBetween= "..tostring(diffBetween),"Bestmatch")
   end       

team,sorted = balance.sortPlayers(team,sorted) -- use sortPlayers to sort the new list
playercn = balance.findLowest(team,sorted,balcn)
if playercn == -1 then
   return -2
end
return playercn
end

--[[ FINDLOWEST
find the player with the lowest 'all', whichever have no flag and scored fewest
return the player's playercn
i = maximum on players
]]
function balance.findLowest(team1,teampw1,balcn1)
local team = {}
local teampw = {}
local balcn=balcn1
team = team1
teampw = teampw1

   i=0   --counter for the max players
   for key,tab in pairs(team) do
      i=i+1   
   end

   ---errorLog("balcn = "..tostring(balcn),"Findlowest")
   k=1      
      for key,tab in pairs(team) do    -- searched the team table to find a matching player
            playercn=tab  --takes the cn out of the team table
            player_id = server.player_sessionid(playercn)  
 
            --errorLog("Playercn is : "..tostring(playercn),"Findlowest")
            --errorLog("Got_switched is : "..tostring(nl_players[player_id].got_switched),"Findlowest")


            if (balcn == playercn or balcn == -1 or balcn == -2) and nl_players[player_id].got_switched == false then           
               --errorLog("Playercn got_switched not set: "..tostring(playercn),"Findlowest")
               return playercn           
            elseif (k == math.floor(i/2+0.5) or balcn == -2 ) and (nl_players[player_id].got_switched == false or balance.longtime > 3) then -- if half the team is searched and no matching found took lowest player
               playercn = team[1] -- took the lowest player
               --errorLog("Playercn lowest got switched: "..tostring(playercn),"Findlowest")

                     if nl_players[player_id].flagholder == true then
                        playercn = team[2] -- took the lowest player
                        --errorLog("Player hold the flag second lowest got switched: "..tostring(playercn),"Findlowest")
                     end
      
               return playercn   
            end
         k=k+1
      end

   balance.longtime = balance.longtime + 1
   --errorLog(" balance.longtime is "..tostring(balance.longtime),"Findlowest")

   errorLog("No lowest player","Findlowest")
   return -2 --if there is no matched player found
end



--[[ CHANGETEAM
change the player which is given by the playercn
]]
function balance.changeTeam(balcn1)
local balcn = -1
local oteam = "good"
balcn = balcn1

   if balcn >= 0 then 
      player_id = server.player_sessionid(balcn)
      if  player_id then
         nl_players[player_id].got_switched = true
      end
      oteam = balance.oppositeteam(balcn)
      
      player_id = server.player_sessionid(balcn)   
      tab = nl_players[player_id]
      -- test if the player currently hold the flag

      if tab.flagholder ~= true  then         
         -- wait 0.5sec before switching the player   
               server.player_slay(balcn)               
               server.sleep(500, function()
               changeteam.changeteam(balcn,oteam,true)
               messages.info(-1, players.all(), "BALANCE", string.format("%s got fired but the other team hired him.(autobalance)", nl.getPlayer(balcn, "name")))
               end)
         else
               messages.debug(cn, players.all(), "BALANCE","Player CN= "..tostring(balcn).." Player Holds the flag")
               --errorLog("Player CN= "..tostring(balcn).."Player Holds the flag","Changeteam")
         end
      messages.debug(cn, players.all(), "BALANCE","Change Player CN= "..tostring(balcn))
      --errorLog("Change Player CN= "..tostring(balcn),"Changeteam")
   else 
      --errorLog("No change Team","Changeteam") 
      messages.debug(cn, players.all(), "BALANCE","No change Team")
   end
end

--[[ SORTPLAYERS
sort the players from smallest to the greatest by there 'all' number.
]]
function balance.sortPlayers(team1,teampw1)
local team = {}
local teampw = {}
team=team1
teampw=teampw1

   errorLog("Sortplayers ","balance.sortPlayers") 

--sort tableset
   for key1,tab1 in pairs(teampw) do
      for key2,tab2 in pairs(teampw) do
         if tab1 < tab2 then
            change=teampw[key1]
            teampw[key1]=teampw[key2]
            teampw[key2]=change

            if team[key1] and team[key2] then
               change=team[key1]
               team[key1]=team[key2]
               team[key2]=change
            end
         end
      end
   end

   errorLog("TEAM : "..tostring(team1).." PW table "..tostring(teampw1),"balance.sortPlayers") 

return team,teampw
end

--[[ NL.OPPOSITETEAM
find out the opposite team of the player given by the playercn
returns the opposite team
]]
function balance.oppositeteam(balcn1)
local balcn = 0
balcn = balcn1

   team = server.player_team(balcn)
   if team=="good" then
      team="evil"
   else
      team="good"
   end
   return team
end






--[[PLAYERWEIGHT ######################################################### 
Calculates an number for each player to make the player skills matchable.

Choose the game mode and calculate depanding on the mode the playerweight.
possible game modes:
["ctf","insta ctf","efficiency ctf","efficiency hold","insta hold","efficienty protect",
"insta protect","protect","regen capture","capture"]

modes which are currently not available
["ffa","coop-edit","teamplay","instagib","inteagib team","efficiency","efficiency team","tactics","tactics team"]

Author: NuckChorris
Last Modified: 18/Nov/2010
Version: 0.02a

return value -1 if the the player doesn't exist.
return playerweight value.
]]

function balance.playerweight(playercn)
local cn = -1
--Gamemodes with only two teams:
            if maprotation.game_mode == "ctf" or maprotation.game_mode == "hold" or maprotation.game_mode == "protect" then
--CTF HOLD PROTECT
            local dpdw  = 1.0    --Damage per Damage wasted
            local spts  = 1.0    --scores per total scores of team
            local frpfs = 1.0    --flag reset by player per flag stolen by enemy team
            local spd   = 1.0    --suicides per deaths
            local all   = 1.0    --number for player

                player_id = server.player_sessionid(playercn)
                     if player_id == -1 or player_id==nil then
                           return -1
                     else 
                           local tab = nl_players[player_id]
                           local scores = tab.flags_scored
                           local flagreturned = tab.flags_returned
                           local totalScored = tab.total_scored
                           local flagsGone = tab.flags_gone
                           local damage = server.player_damage(playercn)
                           local damagewasted = server.player_damagewasted(playercn)
                           local suicides = player_suicides(cn)
                           local deaths = server.player_deaths(cn) 

                           -- calculate damage per damagewasted
                           if damage==0 or damage==nil then dpdw = 0 else
                              dpdw = damage/damagewasted
                           end
                           -- calculate scores
                           if scores == 0 or scores==nil then spts = 0  else
                              spts = scores 
                           end
                           -- calculate flagreturns of the player to flagsgone by wholeteam
                           if flagreturned == 0 or flagreturned==nil then frpfs = 0 else 
                              frpfs = flagreturned/flagsGone          
                           end
                           -- calculates suicides per deaths
                           if suicides == 0 or suicides==nil then spd = 0 else
                              spd = suicides/deaths
                           end

                           all = dpdw + spts + frpfs -spd -- calculate all variable
                           if all < 0 then all = 0 end -- in the case one player do only teamkills

messages.debug(cn, players.admins(),"BALANCE","playercn "..tostring(playercn).." all= "..tostring(all).." CTF,HOLD,PROTECT")
                        return all     
                  end

            elseif maprotation.game_mode == "insta ctf" or maprotation.game_mode == "insta hold"  or maprotation.game_mode == "insta protect" then
--INSTA CTF INSTA HOLD INSTA PROTECT
            local fps   = 1.0    --kills per hits
            local spts  = 1.0    --scores per total scores of team
            local frpfs = 1.0    --flag reset by player per flag stolen by enemy team
            local tkps  = 1.0    --teamkills per hits
            local all   = 1.0    --number for player

                player_id = server.player_sessionid(playercn)
                     if player_id == -1 or player_id==nil then
                           return -1
                     else 
                        
                           local tab = nl_players[player_id]
                           local frags = tab.frags
                           local shots = tab.shots
                           local scores = tab.flags_scored
                           local teamkills = tab.tk_made
                           local flagreturned = tab.flags_returned
                           local totalScored = tab.total_scored
                           local flagsGone = tab.flags_gone
                         
                           -- calculate the weighting number
                           if frags==0 or frags==nil then fps = 0 else
                              fps = frags/shots
                           end
                           -- calculate scores
                           if scores == 0 or scores==nil then spts = 0  else
                              spts = scores   
                           end
                           -- calculate flagreturns of the player to flagsgone by wholeteam
                           if flagreturned == 0 or flagreturned==nil then frpfs = 0 else 
                              frpfs = flagreturned/flagsGone          
                           end
                           -- calculates teamkills to shots
                           if teamkills == 0 or teamkills==nil then tkps =0 else
                              tkps = teamkills/shots
                           end

                           all = fps + spts + frpfs - tkps -- calculate all variable
                           if all < 0 then all = 0 end -- in the case one player do only teamkills
messages.debug(cn, players.admins(),"BALANCE","playercn "..tostring(playercn).." all= "..tostring(all).." INSTA")
                        return all     
                  end

            elseif maprotation.game_mode == "efficiency ctf" or maprotation.game_mode == "efficiency hold" or maprotation.game_mode == "efficienty protect" then
--EFFICIENCY CTF EFFICIENCY HOLD EFFICIENCY PROTECT
            local dpdw  = 1.0    --Damage per Damage wasted
            local spts  = 1.0    --scores per total scores of team
            local frpfs = 1.0    --flag reset by player per flag stolen by enemy team
            local spd   = 1.0    --suicides per deaths
            local all   = 1.0    --number for player

                player_id = server.player_sessionid(playercn)
                     if player_id == -1 or player_id==nil then
                           return -1
                     else 

                           local tab = nl_players[player_id]
                           local scores = tab.flags_scored
                           local flagreturned = tab.flags_returned
                           local totalScored = tab.total_scored
                           local flagsGone = tab.flags_gone
                           local damage = server.player_damage(playercn)
                           local damagewasted = server.player_damagewasted(playercn)
                           local suicides = player_suicides(cn)
                           local deaths = server.player_deaths(cn) 
                        
                           -- calculate damage per damagewasted
                           if damage==0 or damage==nil then dpdw = 0 else
                              dpdw = damage/damagewasted
                           end
                           -- calculate scores
                           if scores == 0 or scores==nil then spts = 0  else
                              spts = scores   
                           end
                           -- calculate flagreturns of the player to flagsgone by wholeteam
                           if flagreturned == 0 or flagreturned==nil then frpfs = 0 else 
                              frpfs = flagreturned/flagsGone          
                           end
                           -- calculates suicides per deaths
                           if suicides == 0 or suicides==nil then spd = 0 else
                              spd = suicides/deaths
                           end
                           all = dpdw + spts + frpfs - spd -- calculate all variable
                           if all < 0 then all = 0 end -- in the case one player do only teamkills                     
messages.debug(cn, players.admins(),"BALANCE","playercn "..tostring(playercn).." all= "..tostring(all).." EFFICIENCY")
                        return all     
                  end

--Gamemodes with more or equal than two teams
elseif   maprotation.game_mode == "regen capture"      then
   messages.debug(cn, players.admins(),"BALANCE","Playerweight REGEN CAPTURE processed")
elseif   maprotation.game_mode == "capture"            then
   messages.debug(cn, players.admins(),"BALANCE","Playerweight CAPTURE processed")
else
   messages.debug(cn, players.admins(),"BALANCE","Playerweight not processed")
   return 0
end

end
--######################################################### 

--[[
write an error log, with the given values
]]
function errorLog(errString,func)
file = io.open ("log/balance.log","a+")

--[[
			write in balance.log
]]
	if errString ~= nil and func ~= nil then
	   file:write(os.date("[%a %d %b %X] ",os.time()))
      file:write(func)
      file:write("  ")	  
      file:write(errString)
	   file:write("\n")
	   file:flush()
      file:close()
   end
end
--#################################################################################################

--[[
Balance toggle for the above balance skript

Derk Haendel
09-Oct-2010
License: GPL3
last-modified 19/Nov/2010
   last-modified 21/Jan/2011 NuckChorris
]]

function server.playercmd_balance(cn,arg1,farg2,farg3)--Playercn, function , function argument 1 ,function argument 2
	local err = false
	local action = "i"
   local number1 = 0
   local number2 = 0

	if not hasaccess(cn, balance_access) then return end

   if not arg1 then arg1 = "error" end
   if farg2 then number1 = tonumber(farg2) else farg2 = 0 end
   if farg3 then number2 = tonumber(farg3) else farg3 = 0 end

	--errorLog("Arg1= "..tostring(arg1).."\n","command")
   --errorLog("Farg2= "..tostring(farg2).."\n","command")
   --errorLog("Farg3= "..tostring(farg3).."\n","command")


	   if arg1 then
		      if tostring(arg1) == "f" or tostring(arg1) == "force" then
               action = "f"
			   elseif tostring(arg1) == "t" or tostring(arg1) == "toggle" then
				   action = "t"
			   elseif tostring(arg1) == "i" or tostring(arg1) == "info" then
				   action = "i"
            elseif tostring(arg1) == "u" or tostring(arg1) == "unbalance" then
               action = "u"
			   elseif tostring(arg1) == "b" or tostring(arg1) == "best" then
               action = "b"
            else
			   err = true
		      end
	   end

	   if err then
		   server.player_msg(cn, string.format(red("Argument could only be: f or force or t or toggle or i or info")))
	   elseif action == "t" then
			   if server.nl_balance_enabled == 1 then
				   server.nl_balance_enabled = 0
               balance.enabled = 0
               balance.numberGood = 0 
               balance.numberEvil = 0
				   server.player_msg(cn, string.format(red("Autobalance disabled")))
			   else
				   server.nl_balance_enabled = 1
               balance.enabled = 1
				   server.player_msg(cn, string.format(red("Autobalance enabled")))
			   end
		end

	   if action == "f" then
			   server.player_msg(cn, string.format(red("Autobalance forced")))
			   balance.start(-1)
	   end
	   if action == "i" then
			   if server.nl_balance_enabled == 1 then
				   server.player_msg(cn, string.format(red("INFO: Autobalance is enabled")))
               if balance.numberGood > 0 and balance.numberEvil > 0 then
                  server.player_msg(cn, string.format(red("INFO: Auto UNbalance is enabled GOOD "..tostring(balance.numberGood).." EVIL "..tostring(balance.numberEvil)))) 
               end
			   else
				   server.player_msg(cn, string.format(red("INFO: Autobalance is disabled")))
			   end
	   end
      if action == "b" then
         balance.bestma = math.abs(balance.bestma - 1)

         if balance.bestma == 0 then
            server.player_msg(cn, string.format(red("INFO: Bestmatch autobalance is disabled")))
         elseif balance.bestma == 1 then
            server.player_msg(cn, string.format(red("INFO: Bestmatch autobalance is enabled")))
         end

      end

      if action == "u" then
			   if server.nl_balance_enabled == 1 and number1 and number2 then
               if number1 > 0 and number2 > 0 then
                  balance.numberGood = number1 
                  balance.numberEvil = number2
                  server.player_msg(cn, string.format(red("INFO: Auto UNbalance is activated! GOOD "..tostring(number1).." EVIL "..tostring(number2))))
               else
                  if balance.numberGood > 0 and balance.numberEvil > 0 then
                     server.player_msg(cn, string.format(red("INFO: Auto UNbalance is disabled"))) 
                     balance.numberGood = 0 
                     balance.numberEvil = 0
                  end
               end
			   end
	   end
end
server.playercmd_bal = server.playercmd_balance

--[[
Server-Events for the above balance skript

Derk Haendel
15-Oct-2010
License: GPL3

]]

--  cn is the shooting player, targetcn is the death player
server.event_handler("frag", function(cn) balance.start(cn) end)

server.interval(15000, function()
      
      balance.start(-1)   
end)

server.interval(60000, function()
      
      balance.start(-2)   
end)

