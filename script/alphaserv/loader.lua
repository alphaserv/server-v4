if not alpha then error("trying to load 'loader.lua' before alpha init."); return end

module("alpha.load", package.seeall)



local load = {}
load.files = {}

fatal = function (file, errorstring, ...)
	errorstring = string.format(errorstring, unpack(arg or {}))
	
	error(string.format("\n\tERROR: could not load: "..file.." error: %s\n", errorstring))
end

file = function (filename, name, description, no_prefix)
	if not name then
		name = filename
	end
	if not description then
		--for auto documentation
		description = "<none>"
	end
	
	if not no_prefix then
		filename = alpha.module_prefix..name..alpha.module_extention
	end
	
	if load.files[filename] then
		fatal(filename, "file is already loaded")
	end

    load.files[filename] = {
    	loaded = false,
    	name = name,
    	description = description
    }
    	
	if not server.file_exists (filename) then
			fatal (filename, "File not found, path: %s", filename)
			return false
	end
    
    _G['#'] = alpha
    local success, normalreturn = native_pcall(dofile, filename)
    _G['#'] = nil
    
    if not success then
    	fatal(filename, "error on load, %q", tostring(normalreturn or ""))
    end
    
    load.files[filename] = {
    	loaded = true,
    	name = name,
    	description = description
    }
    
    if type(normalreturn) == 'table' then
    	load.files[filename]['returned'] = normalreturn
    	if normalreturn['init'] then
    		normalreturn.init()
    	end
    end
    
    if alpha.log and alpha.log.debug then --debuging core loaded
    	alpha.log.debug(alpha.log.debuglevels.NOTICE, string.format("loaded file: %s(%s) %s", name, filename, description or "<none>"))
    	if alpha.spamstartup then print(string.format("loaded file: %s(%s) %s", name, filename, description or "<none>")) end
    end
	return normalret
end

server.event_handler("started", function()
	local failed = 0
	local success = 0
	
--	print(table_to_string(load, true).."<")
	
	for i, file in pairs(load.files) do
		if file.loaded then
			success = success + 1
		else
			failed = failed + 1
		end
		
	end

	if failed > 0 and success > 0 then
		print(string.format("-> Successfully loaded %i scripts, %i failed, %i successfully loaded", #load.files, success, failed))
	elseif failed > 0 then
		print(string.format("-> No Scripts where correctly loaded! %i failed", failed))
	else
		print(string.format("-> Successfully loaded %i scripts", success))
	end

end)
