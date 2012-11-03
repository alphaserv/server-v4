server.color1 = server.color1 or "\f7"
server.color2 = server.color2 or "\f0"
server.bad_color1 = server.bad_color1 or "\f7"
server.bad_color2 = server.bad_color2 or "\f3"

function servmsg(text)
	return getmsg(text)
end

function cmderr(text)
	if not text then text = "unknown reason" end
	return "\f7command execution \f3failed (\f7" .. text .. "\f3)"
end

errmsg = cmderr

function failmsg(cn)
	server.player_msg(cn, cmderr("insufficient access"))
  --error("!access")
end

function infomsg(text)
	server.msg(getmsg(text))
end

function togglemsg(what, active)
	if active then active = "\f0enabled" else active = "\f3disabled" end
	return server.color1 .. "> \f7" .. what .. " " .. active
end

function getmsg(text, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
       if arg1 then text = string.gsub(text, "{1}", server.color1 .. arg1 .. server.color2) end
       if arg2 then text = string.gsub(text, "{2}", server.color1 .. arg2 .. server.color2) end
       if arg3 then text = string.gsub(text, "{3}", server.color1 .. arg3 .. server.color2) end
       if arg4 then text = string.gsub(text, "{4}", server.color1 .. arg4 .. server.color2) end
       if arg5 then text = string.gsub(text, "{5}", server.color1 .. arg5 .. server.color2) end
       if arg6 then text = string.gsub(text, "{6}", server.color1 .. arg6 .. server.color2) end
       if arg7 then text = string.gsub(text, "{7}", server.color1 .. arg7 .. server.color2) end
       if arg8 then text = string.gsub(text, "{8}", server.color1 .. arg8 .. server.color2) end
       if arg9 then text = string.gsub(text, "{9}", server.color1 .. arg9 .. server.color2) end
       if arg10 then text = string.gsub(text, "{10}", server.color1 .. arg10 .. server.color2) end
       if arg11 then text = string.gsub(text, "{11}", server.color1 .. arg11 .. server.color2) end
       if arg12 then text = string.gsub(text, "{12}", server.color1 .. arg12 .. server.color2) end
       if arg13 then text = string.gsub(text, "{13}", server.color1 .. arg13 .. server.color2) end
       if arg14 then text = string.gsub(text, "{14}", server.color1 .. arg14 .. server.color2) end
       if arg15 then text = string.gsub(text, "{15}", server.color1 .. arg15 .. server.color2) end
	return server.color1 .. "> " .. server.color2 .. text
end

function badmsg(text, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
       if arg1 then text = string.gsub(text, "{1}", server.bad_color1 .. arg1 .. server.bad_color2) end
       if arg2 then text = string.gsub(text, "{2}", server.bad_color1 .. arg2 .. server.bad_color2) end
       if arg3 then text = string.gsub(text, "{3}", server.bad_color1 .. arg3 .. server.bad_color2) end
       if arg4 then text = string.gsub(text, "{4}", server.bad_color1 .. arg4 .. server.bad_color2) end
       if arg5 then text = string.gsub(text, "{5}", server.bad_color1 .. arg5 .. server.bad_color2) end
       if arg6 then text = string.gsub(text, "{6}", server.bad_color1 .. arg6 .. server.bad_color2) end
       if arg7 then text = string.gsub(text, "{7}", server.bad_color1 .. arg7 .. server.bad_color2) end
       if arg8 then text = string.gsub(text, "{8}", server.bad_color1 .. arg8 .. server.bad_color2) end
       if arg9 then text = string.gsub(text, "{9}", server.bad_color1 .. arg9 .. server.bad_color2) end
       if arg10 then text = string.gsub(text, "{10}", server.bad_color1 .. arg10 .. server.bad_color2) end
       if arg11 then text = string.gsub(text, "{11}", server.bad_color1 .. arg11 .. server.bad_color2) end
       if arg12 then text = string.gsub(text, "{12}", server.bad_color1 .. arg12 .. server.bad_color2) end
       if arg13 then text = string.gsub(text, "{13}", server.bad_color1 .. arg13 .. server.bad_color2) end
       if arg14 then text = string.gsub(text, "{14}", server.bad_color1 .. arg14 .. server.bad_color2) end
       if arg15 then text = string.gsub(text, "{15}", server.bad_color1 .. arg15 .. server.bad_color2) end
	return server.bad_color1 .. "> " .. server.bad_color2 .. text
end

server.no_setmaster_msg = cmderr("/auth required")
server.map_suggest_msg = getmsg("{1} suggests {2} on map '{3}'", "%%s", "%%s", "%%s")
server.modified_map_msg = getmsg("{1} modified map '{2}'!", "%%s", "%%s")
server.client_disc_reason_msg = getmsg("player {1} disconnected because {2}", "%%s", "%%s")
server.set_mastermode_msg = getmsg("{1} set mastermode to {2} ({3})", "%%s", "%%s", "%%d")
server.clearbans_msg = getmsg("{1} cleared all bans", "%%s")

server.cmd_err_msg = cmderr()
server.cmd_not_found_msg = cmderr("unknown command")
