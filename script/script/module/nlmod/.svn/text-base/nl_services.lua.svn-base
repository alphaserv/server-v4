--[[
	script/module/nl_mod/nl_services.lua
	Hanack (Andreas Schaeffer)
	Created: 28-Sep-2010
	Last Modified: 14-Nov-2010
	License: GPL3

	Funktion:
		* Bereitstellen von CubeScript fuer den Masterserver
		* Ausführen von Zeugs

	API-Methoden:

	Commands:
		#service <execute|activate|deactivate> <service1> [<service2> <service3> ...]
			call specific service execute, activation or deactivation command which returns a string containing
			executable cubescript which will be written into a file for a specific ip address

	Konfigurations-Variablen:

	Laufzeit-Variablen:

]]



--[[
		API
]]

services = {}
services.descriptions = {}
services.category = {}
services.functions = {}
services.functions.execute = {}
services.functions.activate = {}
services.functions.deactivate = {}
services.data = {}

function services.add(service_name, description, category, execute_function, activate_function, deactivate_function)
	services.descriptions[service_name] = description
	services.category[service_name] = category
	services.functions.execute[service_name] = execute_function
	services.functions.activate[service_name] = activate_function
	services.functions.deactivate[service_name] = deactivate_function
	services.data[service_name] = {}
end

function services.execute(cn, service_name)
	services.functions.execute[service_name](cn)
end

function services.activate(cn, service_name)
	services.functions.activate[service_name](cn)
end

function services.deactivate(cn, service_name)
	services.functions.deactivate[service_name](cn)
end

function services.write(cn, service_name, data)
	service.data[service_name][cn] = service.data[service_name][cn] .. "\n" .. data .. "\n"
end

function services.sendvar(cn, service_name, var_name, value)
	services.write(cn, service_name, string.format('__services__%s__%s = "%s"', service_name, var_name, value))
end

function services.resetvar(cn, service_name, var_name)
	services.write(cn, service_name, string.format('__services__%s__%s = ""', service_name, var_name))
end

function services.sendcommand(cn, service_name, command)
	services.write(cn, service_name, command)
end

function services.flush(cn)
	local target_filename = "/noob/com/clients/" .. server.player_ip(cn) .. ".cfg"
	local file = assert(io.open (target_filename,"w"))
	for service_name,data in pairs(services.data) do
		file:write(data[cn])
		data[cn] = ""
	end
	file:close()
end

function services.clear(cn)
	local target_filename = "/noob/com/clients/" .. server.player_ip(cn) .. ".cfg"
	os.remove(targetFilename)
	for service_name,data in pairs(services.data) do
		data[cn] = ""
	end
end



--[[
		COMMANDS
]]

function server.playercmd_service(cn, method, ...)
	if arg1 == nil then return end
	if arg1 ~= "execute" or arg1 ~= "activate" or arg1 ~= "deactivate" then return end
	local services = {...}
	for i, service_name in pairs(services) do
		if method == "execute" then
			services.execute(cn, service_name)
		elseif method == "activate" then
			services.activate(cn, service_name)
		elseif method == "deactivate" then
			services.deactivate(cn, service_name)
		end
		local functionName = "service_" .. arg1 .. "_" .. serviceName
		command, cs = _G["service"][functionName](cn,server.player_ip(cn))
		if command == "clear" then
			clear = 1
		end
		if command == "send" then
			data = data .. "\n" .. cs .. "\n"
		end
	end
	services.flush(cn)
end



--[[
		EVENTS
]]

server.event_handler("connect", function(cn)
	for service_name,data in pairs(services.data) do
		data[cn] = ""
	end
end)

server.event_handler("disconnect", function(cn)
	for service_name,data in pairs(services.data) do
		data[cn] = ""
	end
end)

