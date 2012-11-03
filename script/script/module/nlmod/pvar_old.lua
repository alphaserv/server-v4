function server.player_pvar(cn, var, rval)
	if not server.valid_cn(cn) then return end
	if not cn then server.log_error("error in use of server.player_pvar() function: missing cn!") end
	if not var then server.log_error("error in use of server.player_pvar() function: missing varname!") end
	cn = tostring(cn)
	var = string.gsub(var, " ", "_")
	if rval ~= nil then
		val = rval
		server.eval_lua("server.player_vars(" .. cn .. ")." .. var .. " = val")
	else
		server.eval_lua("if server.player_vars(" .. cn .. ")." .. var .. " then pvar_return = server.player_vars(" .. cn .. ")." .. var .. " else pvar_return = nil end")
		return pvar_return
	end
end

function server.player_unsetpvar(cn, var)
	if not server.valid_cn(cn) then return end
	if not cn then server.log_error("error in use of server.player_unsetpvar() function: missing cn!") end
	if not var then server.log_error("error in use of server.player_unsetpvar() function: missing varname!") end
	cn = tostring(cn)
	var = string.gsub(var, " ", "_")
	server.eval_lua("server.player_vars(" .. cn .. ")." .. var .. " = nil")
end
