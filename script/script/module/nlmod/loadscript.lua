local scripts = {}
local fails = {}
local succs = {}

local function fail(filename, name, text)
	server.log_error("error while loading promod script, filename '" .. (filename or "") .. "', name '" .. (name or "") .. "': " .. text)
	fails[name] = { filename = filename, text = text }
end

local function succ_infos(filename, name, type, name, desc)
	--server.log("successfully loaded script '" .. filename .. "', '" .. name .. "', type: " .. type .. ", name: " .. name .. ", desc: " .. desc)
	succs[name] = { filename = filename }
end

local function succ_no_infos(filename, name)
	--server.log("successfully loaded script '" .. filename .. "', '" .. name .. "', no infos")
	succs[name] = { filename = filename }
end

local function succ_fail_infos(filename, name)
	server.log_error("fail while reading infos from promod script '" .. filename .. "', '" .. name .. "'")
	server.log("successfully loaded script '" .. filename .. "', '" .. name .. "', failed reading infos")
	succs[name] = { filename = filename }
end

function promod.get_script_fails()
	return fails
end

function promod.clear_script_fail(name)
	fails[name] = nil
end

function promod.get_script_succs()
	return succs
end

function promod.clear_script_succ(name)
	succs[name] = nil
end

function promod.read_script(filename, name)
	name = name or filename
	if scripts[name] then fail(filename, name, "script name existing already"); return end
	
    local succ, infos = pcall(dofile, filename)
    if not succ then fail(filename, name, (infos or "")); return end
    
    if infos then
    	if infos.name and infos.desc and infos.help and infos.usage and infos.type and infos.load and infos.unload and infos.access then
			local succ, info = pcall(infos.load)
			if not succ then fail(filename, name, "error in .load(): " .. (info or "")); return end
			scripts[name] = {
				filename = filename,
				name = infos.name,
				desc = infos.desc,
				help = infos.help,
				usage = infos.usage,
				access = infos.access,
				load = infos.load,
				unload = infos.unload
			}
			succ_infos(filename, name, infos.type, infos.name, infos.desc)
		else
			scripts[name] = {
				filename = filename
			}
			succ_fail_infos(filename, name)
		end
    else
		scripts[name] = {
			filename = filename
		}
		succ_no_infos(filename, name)
	end
end

function promod.reload_script(name)
	local infos
	if not scripts[name] then
		for name_, infos_ in pairs(scripts) do
			if infos_.filename == name then infos = infos_; name = name_; break end
		end
		if not infos then return false, "no such script, '" .. name .. "'" end
	else
		infos = scripts[name]
	end
	if (not infos.load) or (not infos.unload) then return false, "no script infos" end
	local succ, info = pcall(infos.unload)
	if not succ then return false, "unloading failed: " .. info end
	
    local succ, infos = pcall(dofile, infos.filename)
    if not succ then return false, "reading file failed: " .. infos end

	local succ, info = pcall(infos.load)
	if not succ then return false, "loading failed: " .. info end
	scripts[name] = infos or { filename = filename }
	return true, name
end

server.event_handler("started", function()
	local fails = promod.get_script_fails()
	local succs = promod.get_script_succs()
	local scnt = 0
	local fcnt = 0
	
	for _, _ in pairs(succs) do
		scnt = scnt + 1
	end

	for name, content in pairs(fails) do
		fcnt = fcnt + 1
--[[
		if name ~= content.filename then name_ = " (" .. name .. ")"
		else name_ = "" end
		if fstr ~= "" then
			fstr = fstr .. ", " .. (content.filename or "(no filename given)") .. name_ .. ": " .. (content.text or "(no text given)")
		else
			fstr = (content.filename or "(no filename given)") .. name_ .. ": " .. (content.text or "(no text given)")
		end
]]
	end
	
	local fail_part = ""
	if fcnt > 0 then
		fail_part = ", fails: " .. fcnt
	end

	server.log("promod scripts loaded: " .. scnt .. fail_part)
	server.log_status("->> promod scripts loaded: " .. scnt .. fail_part .. " <<-")
end)
		
