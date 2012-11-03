function access(cn)
	local access = server.access(cn)
	if server.player_priv(cn) == "master" and access < master_access then access = master_access
	elseif server.player_priv(cn) == "admin" and access < admin_access then access = admin_access end
	return access
end

function hasaccess(cn, access_)
	if not cn then return false end
	if not access_ then access_ = 1 end
	access_ = tonumber(access_)
	if access(cn) == access_ or access(cn) > access_ then
		return true
	else
		failmsg(cn)
		return false
	end
end
