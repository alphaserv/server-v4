local name_mask = false

function match_name(name)
	if name_mask then
		if string.match(name.lower(), name_mask.lower()) or string.find(name_mask.lower(), name.lower()) then
			return true
		else
			return false
		end
	end
end

function server.playercmd_namemask(cn, mask)
	if not mask then
		name_mask = false
		server.msg(getmsg("{1} unset the namemask", server.player_displayname(cn)))
	else
		name_mask = mask
		server.msg(getmsg("{1} set namemask '{2}'", server.player_displayname(cn), mask))
	end
end
