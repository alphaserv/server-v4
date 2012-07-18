--[[!B
	Return: list of files and directories to copy/symlink
]]

return {
	{"", "dir"},
	{"bin", "dir"},
	{"data", "dir"},
	{"script", "dir"},
	{"data/log", "dir"},
	
	{"script/init.lua", "copy"},
	{"script/env.lua", "parse", "script/env.template.lua"},
	
	{"settings.lua", "parse", "settings.template.lua"},
	
	{"//bin/env.sh", "link"},
	
	--somehow needed?	
	{"//bin/sauer_server", "copy"},
	{"//bin/server", "copy"},
	{"//bin/monitor", "copy"},
	
	{"//lib", "link"},
	
	--[[!
		TODO: make this unneeded (use a file locator)
	]]
	{"//share", "link"},
	{"//mapinfo", "link"},
}
