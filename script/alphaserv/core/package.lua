--[[
local package = {
	dependics = {},
	name = "",
	description = "",
}

local host = {
	url = "",
	connection_type = "",
	
	list = {},
	fetchlist = function(obj)
		if connection_type == "http_get" then
			local url = obj.connection_type:gsub("(\\?\\t)", "list") --?list=?n
			url = url:gsub("(\\?\\n)", "list") --?list=list
			
			http.client.get(url, function(body, status)
				
				if not body then
					error("failed to fetch package list from: "..url)
				end
				
				local data = Json.Decode(body)
				
				for i, package in pairs(data.list) do
				
				end
				
				print("Updated package list from: "..url)
        end
    end)
		end
	end

}]]

module("alpha.package", package.seeall)

local loaded = {}
local package_path = alpha.module_prefix.."packages/"

function loadpackage(name, version)
	if not version or version == nil then
		version = "L"
	end
	
	if loaded[string.format('%s_%s', name, version)] then
		return true
	end
	
	local info = dofile(string.format(package_path.."%s_%s/info.lua", name, version))
	
	
	for _, dependic in pairs(info.dependics or {}) do
		if type(dependic) == "string" then dependic = {name = dependic} end
		depend(dependic.name, dependic.version or "")
	end
	
	local_package_path = string.format("%s%s_%s/", package_path, name, version)
	
	for _, file in pairs(info.load) do
		alpha.load.file(local_package_path..file, true)
	end
	
	loaded[string.format('%s_%s', name, version)] = true
	
	return true
end

function depend(name, version)
	if not loadpackage(name) and false then
		error("could not find dependic %(1)q version: %(2)q" % { name, version })
	end
end
