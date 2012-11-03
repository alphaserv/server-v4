server.event_handler("started", function()
  server.mumble_activate();
end)

server.event_handler("mumble_init", function()
  print("LUA: MUMBLE INIT");
end)
