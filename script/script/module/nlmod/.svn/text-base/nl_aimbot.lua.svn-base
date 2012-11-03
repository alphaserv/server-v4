--[[  Anti aimbot script

	   script/module/nl_mod/nl_aimbot.lua
      
      Function:

      Author: NuckChorris
      Created: 01/feb/2011
      Last Modified: 01/feb/2011
      Version: 0.01a
   
      12.02.2011 
      --changed the level to 10 percent
]]

aimbot = {}
aimbot.start = 0
aimbot.running = 1

--[[ AIMBOT.MAIN
   
]]
function aimbot.main(cn)

local accuracy_mean = 0  -- The mean value of the accuracy at every shot
local d_misses_mean = 0  -- The mean value of the misses between two shots


local accuracy_std_deviation = 0  -- Standard diviation
local d_misses_deviation = 0  -- Standard diviation
local d_misses      = 0  -- previouse value of the misses

local hits          = 0  -- Number of hits of the player
local shots         = 0  -- Number of shots from the player
local miss          = 0  -- Number of total misses from th player
local bad_credit    = 0


   -- Gets the proper values from the core lua   
   hits = nl.getPlayer(cn,"hits_made")
   shots = nl.getPlayer(cn,"shots")
   miss = nl.getPlayer(cn,"misses")
   bad_credit = nl.getPlayer(cn,"bad_credit")
   accuracy_mean = nl.getPlayer(cn,"accuracy_mean")
   d_misses_mean = nl.getPlayer(cn,"d_misses_mean")

   -- Calculate the standard deviation from the variance
   accuracy_std_deviation  = math.sqrt(nl.getPlayer(cn,"accuracy_var"))
   d_misses_deviation      = math.sqrt(nl.getPlayer(cn,"d_misses_var"))
   d_misses      = nl.getPlayer(cn,"d_misses")

   if true then
      if hits/shots > accuracy_mean*0.9 and hits/shots < accuracy_mean*1.1 and accuracy_mean >= 0.5 then
         bad_credit = bad_credit + 1
      elseif bad_credit >= 1 then
         bad_credit = bad_credit - 1
      end
   end
   if true then
      if d_misses_mean <= 1.0 then
         bad_credit = bad_credit + 1
      elseif bad_credit > 1 then
         bad_credit = bad_credit - 1
      end
   end

      nl.updatePlayer(cn,"bad_credit",bad_credit, "set")
      
      if bad_credit >= 1 then
      messages.debug(cn,players.admins(),"AIMBOT","Player: "..tostring(server.player_name(cn).." own "..tostring(bad_credit).."  bad_credit Points"))
      end

end

--[[ AIMBOT.CALC
   Calculates the mean values of the player and updates the variables
]]
function aimbot.calc(cn)
local value_count   = 0  -- Counts the number of values recorded

local accuracy_mean = 0  -- The mean value of the accuracy at every shot
local accuracy_var  = 0  -- The variance of the accuracy 
      
local d_misses      = 0  -- previouse value of the misses
local d_misses_mean = 0  -- The mean value of the misses between two shots
local d_misses_var  = 0  -- The variance of the misses between two shots

local hits          = 0  -- Number of hits of the player
local shots         = 0  -- Number of shots from the player
local miss          = 0  -- Number of total misses from the player
local d_miss        = 0  -- Distance between the new misses and the previous ones
local tab_data      = {} -- All data in a table
local namebool      = 0

   -- Gets the proper values from the core lua   
   hits = nl.getPlayer(cn,"hits_made")
   shots = nl.getPlayer(cn,"shots")
   miss = nl.getPlayer(cn,"misses")

   value_count = nl.getPlayer(cn,"value_count")
   accuracy_mean = nl.getPlayer(cn,"accuracy_mean")
   accuracy_var  = nl.getPlayer(cn,"accuracy_var")
   d_misses      = nl.getPlayer(cn,"d_misses")
   d_misses_mean = nl.getPlayer(cn,"d_misses_mean")
   d_misses_var  = nl.getPlayer(cn,"d_misses_var")
   bad_credit = nl.getPlayer(cn,"bad_credit")
   -- Calculate the values 

      d_miss = math.abs(miss - d_misses)
      if value_count >= 0 then
         if shots > 0 then
            accuracy_mean = (value_count*accuracy_mean + hits/shots)/(value_count + 1)
         end
         d_misses_mean = (value_count*d_misses_mean + d_miss)/(value_count + 1)
      end

      if value_count >= 1 and shots > 0 then
         accuracy_var  = ((value_count-1)*accuracy_var + math.pow((hits/shots-accuracy_mean),2))/(value_count)
         d_misses_var  = ((value_count-1)*d_misses_var + math.pow((d_miss-d_misses_mean),2))/(value_count)
      end
      
      value_count = value_count + 1

   -- Put the new values into the player variables
   nl.updatePlayer(cn,"value_count",value_count, "set")
   nl.updatePlayer(cn,"accuracy_mean",accuracy_mean, "set")
   nl.updatePlayer(cn,"accuracy_var",accuracy_var, "set")
   nl.updatePlayer(cn,"d_misses_mean",d_misses_mean, "set")
   nl.updatePlayer(cn,"d_misses_var",d_misses_var, "set")
   nl.updatePlayer(cn,"d_misses",miss,"set")
   
   str = server.player_name(cn)
   str = str:lower()
   
   if str then
      for line in io.lines("script/module/nlmod/aimbot_players.text") do
         if str:find(line) ~= nil then
            namebool = 1
         end 
      end
   end
   
   if namebool == 1 and str then 
      if value_count == 1 then       
         tab_data = {"value_count","accuracy_mean","accuracy_var","d_misses_mean","d_misses_var","miss","bad_credit"}
         errorlog.cvswrite(str..".cvs",tab_data)
         tab_data = {os.date("[%a %d %b %X] ",os.time()),value_count,accuracy_mean,accuracy_var,d_misses_mean,d_misses_var,miss} 
      else
         tab_data = {os.date("[%a %d %b %X] ",os.time()),value_count,accuracy_mean,accuracy_var,d_misses_mean,d_misses_var,miss,bad_credit}   
      end
      errorlog.cvswrite(str..".cvs",tab_data)
      namebool = 0
   end
      --messages.debug(-1,players.admins(),"AIMBOT","Player: "..tostring(server.player_name(cn).." own "..tostring(accuracy_mean).." accuracy_mean Points"))
      --messages.debug(cn,players.admins(),"AIMBOT","Player: "..tostring(server.player_name(cn).." own "..tostring(accuracy_var).." accuracy_var Points"))
      --messages.debug(cn,players.admins(),"AIMBOT","Player: "..tostring(server.player_name(cn).." own "..tostring(d_misses_mean).." d_misses_mean Points"))
      --messages.debug(cn,players.admins(),"AIMBOT","Player: "..tostring(server.player_name(cn).." own "..tostring(d_misses_var).." d_misses_var Points"))

end

--[[ COMMANDS FOR THE SCRIPT

]]
function server.playercmd_aimbot(cn,arg1,argcn)

local cn1 = -1
      cn1 = cn
   if argcn then
      argcn = tonumber(argcn)
   else
      argcn = -1
   end

   if arg1 then
      arg1=string.lower(tostring(arg1))
   else
      server.player_msg(cn, string.format(red("ERROR: #aimbot arg1 ;1=on, 0=off")))
      if access(cn) < admin_access then return end
      server.player_msg(cn, string.format(red("ERROR: #aimbot arg1 ;f=force, t=toggle, i=info")))
      return -1
   end

   if cn and arg1 == "1" then
      server.player_msg(cn,string.format(red(tostring(server.player_name(tonumber(cn)))..": Your aimbot have been activated")))
      return -1    
   elseif cn and arg1 == "0" then
      server.player_msg(cn,string.format(red(tostring(server.player_name(tonumber(cn)))..": Your aimbot have been deactivated")))
      return -1        
   end

   if access(cn) < admin_access then return end

   if hasaccess(cn, balance_access) then 
         if arg1 == "t" then
            aimbot.running = math.abs(aimbot.running - 1)
         end

         if arg1 == "i" or arg1 == "t" then

            if aimbot.running == 1 then
               server.player_msg(cn, string.format(red("INFO: Aimbot detection is enabled")))
            elseif aimbot.running == 0 then
               server.player_msg(cn, string.format(red("INFO: Aimbot detection is disabled")))
            end

         elseif arg1 == "f" then 
               for key,value in pairs(server.players()) do
                   if argcn == tonumber(value) then
                     cn1 = tonumber(argcn)
                   end               
               end                 
            aimbot.calc(cn1)
            server.player_msg(cn, string.format(red("INFO: Player "..tostring(server.player_name(tonumber(cn1))).." recorded")))
         elseif arg1 == "pli" then --Shows the actual values for the player
               for key,value in pairs(server.players()) do
                   if argcn == tonumber(value) then
                     cn1 = tonumber(argcn)
                   end               
               end
            server.player_msg( cn,string.format( tostring(server.player_name(tonumber(cn1))).." accuracy_mean= "..tostring(nl.getPlayer(tonumber(cn1),"accuracy_mean")).." d_misses_mean= "..tostring(nl.getPlayer(tonumber(cn1),"d_misses_mean")).." bad_credit= "..tostring(nl.getPlayer(tonumber(cn1),"bad_credit")) ))                 
         end
   return -1
   end

end


--[[ EVENTS
   
]]

server.event_handler("shot", function(cn, gun, hit)
   if aimbot.running == 1 then   
      if tostring(hit)=="1" then
         --update the values
         aimbot.calc(cn)
	   end
      if nl.getPlayer(cn,"value_count") >= 10 then
         aimbot.main(cn)
      end
   else
      messages.debug(-1,players.admins(),"AIMBOT","Aimbot Script deactivated")
      return -1
   end
end)

