require "os"

function service_execute_votemap(cn, ip)
	local cs = [=[
log "SERVICE" "info" "updating map votings"

_VOTEMAP_POINTS_hallo = ]=] .. votemap_points["hallo"] .. [=[

_VOTEMAP_POINTS_reissen = ]=] .. votemap_points["reissen"] .. [=[

_VOTEMAP_POINTS_face_capture = ]=] .. votemap_points["face-capture"] .. [=[

_VOTEMAP_POINTS_flagstone = ]=] .. votemap_points["flagstone"] .. [=[

_VOTEMAP_POINTS_shipwreck = ]=] .. votemap_points["shipwreck"] .. [=[

_VOTEMAP_POINTS_urban_c = ]=] .. votemap_points["urban_c"] .. [=[

_VOTEMAP_POINTS_dust2 = ]=] .. votemap_points["dust2"] .. [=[

_VOTEMAP_POINTS_berlin_wall = ]=] .. votemap_points["berlin_wall"] .. [=[

_VOTEMAP_POINTS_akroseum = ]=] .. votemap_points["akroseum"] .. [=[

_VOTEMAP_POINTS_damnation = ]=] .. votemap_points["damnation"] .. [=[

_VOTEMAP_POINTS_redemption = ]=] .. votemap_points["redemption"] .. [=[

_VOTEMAP_POINTS_tejen = ]=] .. votemap_points["tejen"] .. [=[

_VOTEMAP_POINTS_capture_night = ]=] .. votemap_points["capture_night"] .. [=[

_VOTEMAP_POINTS_l_ctf = ]=] .. votemap_points["l_ctf"] .. [=[

_VOTEMAP_POINTS_forg = ]=] .. votemap_points["forg"] .. [=[

_VOTEMAP_POINTS_campo = ]=] .. votemap_points["campo"] .. [=[

_VOTEMAP_POINTS_wdcd = ]=] .. votemap_points["wdcd"] .. [=[

_VOTEMAP_POINTS_core_transfer = ]=] .. votemap_points["core_transfer"] .. [=[

_VOTEMAP_POINTS_recovery = ]=] .. votemap_points["recovery"] .. [=[

_VOTEMAP_POINTS_frostbyte = ]=] .. votemap_points["frostbyte"] .. [=[

_VOTEMAP_POINTS_killcore3 = ]=] .. votemap_points["killcore3"] .. [=[

_VOTEMAP_POINTS_fc4 = ]=] .. votemap_points["fc4"] .. [=[

]=]
	return "send", cs
end

function service_activate_votemap(cn, ip)
	local cs = [=[

register_key "VOTEMAP_OPEN" "F3" "_VOTEMAP_OPEN"
register_gui "VoteMap" [
  guititle "Vote for the next map!"
] [
  guilist [
    _VOTEMAP_LISTMAPS "hallo reissen face-capture flagstone shipwreck urban_c dust2 berlin_wall"
    _VOTEMAP_LISTMAPS "akroseum damnation redemption tejen capture_night l_ctf forge"
    _VOTEMAP_LISTMAPS "campo wdcd core_transfer recovery frostbyte killcore3 fc4"
      guibar
      guilist [
        guitext (at $guirollovername 0)
        guiimage (concatword "packages/base/" (at $guirollovername 0) ".jpg") $guirolloveraction 4 1 "data/cube.png"
      ]
  ]
] [
  guilist [
    guibutton "Update" [ execute_service "votemap" ]
    guibutton "New Voting" [ say "#votemap new" ]
    guibutton "Stop Voting" [ say "#votemap stop" ]
  ]
]

// renders a list of map buttons
// arg1: list of names of the map
_VOTEMAP_LISTMAPS = [
  guilist [
    loop _VOTEMAP_NUM (listlen $arg1) [
      _VOTEMAP_MAPNAME = (at $arg1 $_VOTEMAP_NUM)
      if (list_contains "_VOTEMAP_VOTEDFOR" $_VOTEMAP_MAPNAME) [
        guitext (concatword @_VOTEMAP_MAPNAME " " (getalias (concatword "_VOTEMAP_POINTS_" @_VOTEMAP_MAPNAME)))
      ] [
        guibutton (concatword @_VOTEMAP_MAPNAME " " (getalias (concatword "_VOTEMAP_POINTS_" @_VOTEMAP_MAPNAME))) [_VOTEMAP_VOTE @@_VOTEMAP_MAPNAME]
      ]
    ]
  ]
]

_VOTEMAP_RESET = [
  _VOTEMAP_VOTING = 0
  loop _VOTEMAP_NUM (listlen $arg1) [
    _VOTEMAP_MAPNAME = (at $arg1 $_VOTEMAP_NUM)
    (concatword "_VOTEMAP_POINTS_" $_VOTEMAP_MAPNAME) = 0
  ]
]

// arg1: mapname
_VOTEMAP_VOTE = [
  _VOTEMAP_VOTING = 0
  sleep 1100 [
    say (concatword "#votemap " @arg1 " " $_VOTEMAP_POINTS)
    _VOTEMAP_POINTS = (- $_VOTEMAP_POINTS 1)
    list_insert "_VOTEMAP_VOTEDFOR" @arg1
  ]
  sleep 2600 [
    _VOTEMAP_VOTING = 1
    _VOTEMAP_LOOP
  ]
]

_VOTEMAP_BEGIN = [
  _VOTEMAP_RESET "hallo reissen face-capture flagstone shipwreck urban_c dust2 berlin_wall akroseum damnation redemption tejen capture_night l_ctf forge campo wdcd core_transfer recovery frostbyte killcore3 fc4"
  _VOTEMAP_VOTING = 1
  _VOTEMAP_VOTEDFOR = ""
  _VOTEMAP_POINTS = 5
  _VOTEMAP_LOOP
]

_VOTEMAP_END = [
  _VOTEMAP_VOTING = 0
]
subscribe_event "ON_MAPCHANGE" "_VOTEMAP_END"

_VOTEMAP_LOOP = [
  if (= $_VOTEMAP_VOTING 1) [
    execute_service "votemap"
    sleep 2500 _VOTEMAP_LOOP
  ]
]

_VOTEMAP_OPEN = [
  showgui "VoteMap"
  _VOTEMAP_END
  sleep 2600 [
    _VOTEMAP_BEGIN
  ]
]

]=]
	return "send", cs
end

function service_deactivate_votemap(cn, ip)
	local cs = [=[
unregister_key "VOTEMAP_OPEN"
unregister_gui "VoteMap"
unsubscribe_event "ON_MAPCHANGE" "_VOTEMAP_END"
_VOTEMAP_VOTE = ""
_VOTEMAP_RESET = ""
_VOTEMAP_OPEN = ""
_VOTEMAP_LOOP = ""
_VOTEMAP_BEGIN = ""
_VOTEMAP_END = ""
_VOTEMAP_LISTMAP = ""

]=]
	return "send", cs
end

