
require "script.env"

local native_os_execute = os.execute

function os.execute(command)
	print ("Executing:", command)
	return native_os_execute(command)
end

--[[
	TODO:
	
	require "as.console"
	as(BASEPATH, "console"):run()
]]

local config = dofile(BASEPATH.."/base_config.lua")

--[[
	TODO: get id from database
]]

local id = 1

local destination_root = BASEPATH.."/instances/"..id
local template_root = BASEPATH.."/instances/template"

local boundVars = {}

function bindVar(name, value)
	boundVars[name] = value
end

local createHandlers = {
	link = function(destination, from)
		os.execute("ln -s "..from.." "..destination)
	end,

	copy = function(destination, from)
		os.execute("cp "..from.." "..destination)
	end,

	parse = function(destination, from)
		local file = assert(io.open(from, "r"))
		local content = file:read("*all")
		file:close()
		
		for name, value in pairs(boundVars) do
			name = "%{"..name:gsub("%.", "%%.").."%}"
			
			print ("replacing", name, "with", value)
			content = content:gsub(name, value)			
		end
	
		file = assert(io.open(destination, "w"))
		file:write(content)
		file:close()		
	end,
	
	dir = function(destination)
		os.execute("mkdir "..destination)
	end,
}

function parseHandler(row)
	local destination = row[1]
	local action = row[2]
	local from = row[3] or destination
	
	destination = destination_root .."/".. destination

	if from:sub(0, 2) ~= "//" then
		from = template_root .. "/".. from
	else
		from = BASEPATH .. from:gsub("//", "/")
	end		
	
	destination = destination:gsub("//", "/")
	
	createHandlers[action](destination, from)
end

function executeHandlers()
	for i, row in pairs(dofile(template_root.."/files.lua")) do
		parseHandler(row)
	end
end

bindVar("as.serverPath", destination_root)
bindVar("as.basePath", BASEPATH)
bindVar("config.port", id * 10000)
bindVar("config.id", id)

executeHandlers()

print "Successfully created instance!"
print ("You may now edit instances/"..id.."/settings.lua ")

