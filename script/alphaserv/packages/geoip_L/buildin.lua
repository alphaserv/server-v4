module("geoip", package.seeall)

local geoipmodule = require "geoip"

function ip_to_country(ip)
	return geoipmodule.ip_to_country(ip) or nil
end
