if not alpha then error("trying to load 'loader.lua' before alpha init."); return end

module("alpha.load", package.seeall)

files_loaded = {}

file = function (filename, no_prefix)

	if not no_prefix then
		filename = alpha.module_prefix..filename..alpha.module_extention
	end
	
	if files_loaded[filename] then
		error("Could not load file, file is already loaded", 2)
	end

    files_loaded[filename] = {
    	loaded = false,
    	filename = filename,
    }
    	
	if not server.file_exists (filename) then
		error("Could not load file, file not found. path: %(1)s" % {filename}, 2)
			return false
	end
    
    local success, normalreturn = native_pcall(dofile, filename)
    
    if not success then
    	error("Could not load file %(1)s,\n %(2)s" % { filename, tostring(normalreturn or "")}, 2)
    end
    
    files_loaded[filename].loaded = true
    
    if type(normalreturn) == 'table' then
    	files_loaded[filename].returned = normalreturn
    	
    	if normalreturn['init'] then
    		normalreturn.init()
    	end
    end
    
    if alpha.log and alpha.log.debug then --debuging core loaded
    	alpha.log.debug(alpha.log.debuglevels.INFO, "loaded file: %(1)s" % {filename})
    	if alpha.spamstartup then print("loaded file: %(1)s" % {filename}) end
    end
	return normalret
end

local function on_started ()
	local failed = 0
	local success = 0
	
	--	print(table_to_string(load, true).."<")
	
	for i, file in pairs(files_loaded) do
		if file.loaded then
			success = success + 1
		else
			failed = failed + 1
		end
	
		files_loaded[i] = true --clean up useless stuff
	end

	if failed > 0 and success > 0 then
		print(string.format("-> Successfully loaded %i scripts, %i failed, %i successfully loaded", #files_loaded, success, failed))
	elseif failed > 0 then
		print(string.format("-> No Scripts where correctly loaded! %i failed", failed))
	else
		print(string.format("-> Successfully loaded %i scripts", success))
	end
end

if not alpha.standalone then
	server.event_handler("started", on_started)
else
	event.event("started"):add_listner(on_started)
end
