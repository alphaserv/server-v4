require "utils.table"
require "std"

function pack(...) return arg end

function hashPassword(cn, sid, password)
   	return crypto.tigersum(string.format("%i %i %s", cn, sid, password))
end

function to_table(a)
	if type(a) ~= "table" and string.sub(a, 1, 1) == "{" then
		return assert(loadstring("return "..a))(), true
	else return {a}, false end
end

local function coloured_text_function(colour_code)
	return function(text)
		if text then
		    return "\fs\f" .. colour_code .. text .. "\fr"
		else
		    return "\fs\f" .. colour_code
		end
	end
end

color = {
	green    = coloured_text_function(0),
	blue     = coloured_text_function(1),
	yellow   = coloured_text_function(2),
	red      = coloured_text_function(3),
	grey     = coloured_text_function(4),
	magenta  = coloured_text_function(5),
	orange   = coloured_text_function(6),
	white    = coloured_text_function(7)
}

-- Copied from http://lua-users.org/wiki/SimpleRound
function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function isValidCcn(cn)
	local cn = tonumber(cn)
    return server.player_sessionid(cn or -1) ~= -1 and not server.player_is_spy(cn or -1)
end
