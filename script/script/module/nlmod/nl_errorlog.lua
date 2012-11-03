--[[ ERROR LOG

	   script/module/nl_mod/nl_errorlog.lua
      
      Function:

      Author: NuckChorris
      Created: 01/feb/2011
      Last Modified: 01/feb/2011
      Version: 0.01
]]

errorlog = {}
--[[ errorlog.cvswrite
   Writes a table of numbers in to a CVS file
]]
function errorlog.cvswrite(file,tab_data)
local number_col = 0  -- column numbers
local line       = "" -- current line date
local str_data   = ""

   file = errorlog.open(file)
   if file ~= -1 then
	      if tab_data ~= nil and file ~= nil then
            for ind,data in pairs(tab_data) do 
               str_data=tostring(data)
               str_data=string.gsub(str_data,"%.",",")           
               line=line..str_data..";"             	  
            end
               line = line:sub(1,(line:len()-1)) -- removes the last semicolumn
               file:write(line)
               file:write("\n")
	            file:flush()
               file:close()
         end
   end
end

--[[ errorlog.write
   Write a error log in the given file or create it.
]]
function errorlog.write(file,errString,func)
   file = errorlog.open(file)
   if file ~= -1 then
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
end

--[[ errorlog.open

]]
function errorlog.open(file)
   if file ~= nil then
      activefile = io.open("log/aimbot_data/"..file,"a+")
      return activefile
   else
      return -1
   end
end
