--[[

	A player command to send a warning message
	player get banned when limit is reached

]]


local limit = server.warning_limit
local bantime = round(server.warning_bantime or 1800000 / 1000,0)

local usage = "warning (<cn>|\"<name>\") <text>"

return function(cn, tcn, ...)

	if not tcn then
		return false, usage
	end

	local text = table.concat(arg, " ")

    if not text then
        return false, usage
    end

	if text == "tk" then
		text = "Stop teamkilling. ONLY RED players are the enemies!"
	end

	if not server.valid_cn(tcn) then
		tcn = server.name_to_cn_list_matches(cn,tcn)

		if not tcn then
			return
		end
	end

	local warn_count = (server.player_vars(tcn).warning_count or 1)

	if warn_count <= limit then
		local msg = "Warning"

		if warn_count == limit and limit > 1 then
			msg = "Last " .. msg
		end

		server.player_msg(tcn," ")
		server.msg("(" .. red(msg) .. ")  " .. "(" .. green(server.player_displayname(tcn)) .. ")  " .. orange(text))
		server.player_msg(tcn," ")

		server.player_vars(tcn).warning_count = warn_count + 1
	else
		server.kick(tcn,bantime,server.player_name(cn),"warning limit reached")
		server.player_vars(tcn).warning_count = nil
	end

end
