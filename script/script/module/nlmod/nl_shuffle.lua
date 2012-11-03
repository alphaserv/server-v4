--[[
Forced a shuffel for all players and returns two tables with the team.
Get all players from the server, calculate for each player the playerweight and
sort them into two nearly equaly skilled tables.

Author: NuckChorris
Last Modified: 13/Feb/2011
Version: 0.02

server.player_damage(cn)
server.player_damagewasted(cn)
server.player_accuracy(cn)

]]

shuffle = {}

function shuffle.skillshuffle()
local playercn = -1
local allplayers = {}
local shufflelist = {}
local allskills = {}
local team1 = {} --Is asspectet as team "good"
local team2 = {} --Is asspectet as team "evil"
local all = 0
local i=0
local j=0
local k=0
local l=0

math.randomseed(os.time())

   allplayers = players.active() -- fetches all cn from all the active playing humans in the game

   -- check if all players are connected and put only this ones into the shuffle-list which are exist 
   for key,playercn in pairs(allplayers) do   
      player_id = server.player_sessionid(playercn)
         if player_id == -1 or player_id==nil then
            messages.debug(-1, players.admins(),"SHUFFLE","Player don't exist, CN= "..tostring(playercn))
         else
            table.insert(shufflelist,playercn)
            messages.debug(-1, players.admins(),"SHUFFLE","Put player into shufflelist, CN= "..tostring(playercn))
         end 
   end
   
   -- If the Shufflelist is empty
   if shufflelist == nil then
      messages.debug(cn, players.admins(),"SHUFFLE","Shufflelist is NIL")
      return -1
   end

   -- calculates for each player the all variable and stores it to allskills table
   for key,playercn in pairs(shufflelist) do
      all = balance.playerweight(playercn)
      if all == -1 then
         all = 0 -- if an error accrued set all to zero and send error to log
         messages.debug(-1, players.admins(),"SHUFFLE","nl.playerweight returns -1, CN= "..tostring(playercn))
         table.insert(allskills,all)
      end
         table.insert(allskills,all)
   end
   
   --Sort the allskills list with the balance.sortPlayers(team,teamcn) function
   shufflelist,allskills = balance.sortPlayers(shufflelist,allskills)
   
   --Build the two teams on the base of the sorted allskills table
   i = math.random (1,2)
   for key,playercn in pairs(shufflelist) do
      j = i / 2 
      k,l = math.modf(j)
      if l > 0 then      
         team1 = {playercn}
         messages.debug(-1, players.admins(),"SHUFFLE","Team1 CN= "..tostring(playercn))
      else
         team2 = {playercn}
         messages.debug(-1, players.admins(),"SHUFFLE","Team2 CN= "..tostring(playercn))
      end
   i = i + 1
   end
   
   messages.debug(cn, players.admins(),"SHUFFLE","Shuffle ended")
   
   server.sleep(250, function()
         for key,balcn in pairs(team1) do
            for ind,plcn in pairs(server.players()) do
               if balcn and plcn == balcn then   
                  currentTeam = server.player_team(balcn) -- returns the player team
               end
            end         
            if currentTeam == "evil" then
               changeteam.changeteam(balcn,"good",true)
               messages.debug(-1, players.admins(),"SHUFFLE","Changeteam "..tostring(balcn).." EVIL GOOD")
            elseif currentTeam == "good" then
               changeteam.changeteam(balcn,"good",true)
               messages.debug(-1, players.admins(),"SHUFFLE","Changeteam "..tostring(balcn).." GOOD GOOD")
            else
               -- Team isn't "evil" neighter "good"
               messages.debug(-1, players.admins(),"SHUFFLE","Unknown Team1 "..tostring(balcn))
            end
         end

         for key,balcn in pairs(team2) do
            for ind,plcn in pairs(server.players()) do
               if balcn and plcn == balcn then   
                  currentTeam = server.player_team(balcn) -- returns the player team
               end
            end
            if currentTeam == "good" then
               changeteam.changeteam(balcn,"evil",true)
               messages.debug(-1, players.admins(),"SHUFFLE","Changeteam "..tostring(balcn).." GOOD EVIL")
            elseif currentTeam == "evil" then
               changeteam.changeteam(balcn,"evil",true)
               messages.debug(-1, players.admins(),"SHUFFLE","Changeteam "..tostring(balcn).." EVIL EVIL")
            else
               -- Team isn't "evil" neighter "good"
               messages.debug(-1, players.admins(),"SHUFFLE","Unknown Team2 "..tostring(balcn))
            end
         end
   end)
end

--[[
   EVENTS
   Event changingmap wird von nl_maprotation ausgeloest.
]]

server.event_handler("changingmap", function(map, mode)
	shuffle.skillshuffle()
end)

--[[
   SERVER COMMANDS
]]

--[[
   Command #shuffle arg
   arg:
      t - toggle - switches the module on or off
      f - force  - made a shuffle for all players
      i - info   - shows the shuffle script mode ON or OFF
]]
function server.playercmd_shuffle(playercn, arg1)
local action = "na"
	if not hasaccess(playercn, balance_access) then return end
      if       tostring(arg1) == "t" or tostring(arg1) == "toggle"  then
          action = "t"
      elseif   tostring(arg1) == "f" or tostring(arg1) == "force"   then   
          action = "f"
      elseif   tostring(arg1) == "i" or tostring(arg1) == "info"    then
          action = "i"
      else 
          server.player_msg(playercn, string.format(red("INFO: Bad argument #shuffle arg --t for toggle,f for force,i for info")))      
      end

   if action == "t" then
         if server.nl_shuffle_enabled == 1 then
            server.nl_shuffle_enabled = 0
            server.player_msg(playercn, string.format(red("INFO: Shuffle is disabled")))
         else
            server.nl_shuffle_enabled = 1
            server.player_msg(playercn, string.format(red("INFO: Shuffle is enabled")))
         end
   elseif action == "f" then
            shuffle.skillshuffle()
            server.player_msg(playercn, string.format(red("Shuffle forced")))
   elseif action == "i" then
         if server.nl_shuffle_enabled == 1 then
            server.player_msg(playercn, string.format(red("INFO: Shuffle is enabled")))
         else
            server.player_msg(playercn, string.format(red("INFO: Shuffle is disabled")))
         end  
   end

end


