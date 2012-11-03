server.event_handler("started", function()
  server.mumble_activate()
end)

server.event_handler("mumble_connected", function()
  print("LUA: MUMBLE CONNECTED")
  print("LUA: MUMBLE BOOTED SERVERS:")
  for index,value in ipairs(server.mumble_get_bootedservers()) do print(value) end
  print("LUA: MUMBLE CONNECTED USERS:")
  for index,value in ipairs(server.mumble_server_get_users(1)) do print(server.mumble_user_get_name(1, value)) end
  server.mumble_server_activate_signals(1)
end)

server.event_handler("mumble_disconnected", function()
  print("LUA: MUMBLE DISCONNECTED")
end)

server.event_handler("mumble_userconnected", function(server_id, session_id)
  print("LUA: MUMBLE USER " .. server.mumble_user_get_name(server_id, session_id) .. " CONNECTED FROM SERVER " .. server_id)
  print("LUA: MUMBLE USER -> userid " .. server.mumble_user_get_userid(server_id, session_id))
	irc_say(string.format("MUMBLE   User %s connected.", server.mumble_user_get_name(server_id, session_id)))
end)
