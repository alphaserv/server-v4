module("as.geoip", package.seeall)

-- Check if the file is already loaded
if _G['__AS_GEOIP_LOADED'] then
	return;
else
	_G['__AS_GEOIP_LOADED'] = true;
end

local geoip = require("geoip")
require "config"

local setting = config.loadSection("geoip", {
	geoIpFile = "./share/GeoIp.dat",
	geoCityFile = "./share/GeoCity.dat",
	printLoad = true,
})

function echo(...)
	if setting.printLoad then
		print(...)
	end
end

if geoip.load_geoip_database(setting.geoIpFile) then
	echo("|sucessfully loaded geoip db file")
else
	if as.color then
		echo(string.char(27).."[31m | could not load geoip db file"..string.char(27).."[0m")
	else
		echo(" | could not load geoip db file")
	end
end
if geoip.load_geocity_database(setting.geoCityFile) then
	echo("|sucessfully loaded geocity db file")
else
	if as.color then
		echo(string.char(27).."[31m | could not load geocity db file"..string.char(27).."[0m")
	else
		echo(" | could not load geocity db file")
	end
end
