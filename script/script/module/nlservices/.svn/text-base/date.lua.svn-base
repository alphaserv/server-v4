require "os"

services.add(

	-- service name
	"date",
	
	-- description
	"Get date and time from server",
	
	-- category
	"main",
	
	-- execute
	function(cn)
		services.sendvar(cn, "date", "date", os.date("%Y-%m-%d"))
		services.sendvar(cn, "date", "time", os.date("%H:%M:%s"))
		services.sendvar(cn, "date", "year", os.date("%Y"))
		services.sendvar(cn, "date", "month", os.date("%m"))
		services.sendvar(cn, "date", "day", os.date("%d"))
		services.sendvar(cn, "date", "hour", os.date("%H"))
		services.sendvar(cn, "date", "minute", os.date("%M"))
		services.sendvar(cn, "date", "second", os.date("%s"))
	end,
	
	-- activate
	function(cn)
		services.write(cn, "date", [=[
register_gui "Date" [
  guititle "Time and Date"
] [
  guititle $__services__date__date
  guititle $__services__date__time
] [
  guilist [
    guibutton "Update!" [ execute_service "date" ]
  ]
]
__DATE_OPEN = [
  showgui "Date"
]
register_key "DATE_OPEN" "" "__DATE_OPEN"
]=])
	end,
	
	-- deactivate
	function(cn)
		services.resetvar(cn, "date", "date")
		services.resetvar(cn, "date", "time")
		services.resetvar(cn, "date", "year")
		services.resetvar(cn, "date", "month")
		services.resetvar(cn, "date", "day")
		services.resetvar(cn, "date", "hour")
		services.resetvar(cn, "date", "minute")
		services.resetvar(cn, "date", "second")
		services.sendcommand(cn, "date", 'unregister_gui "Date"')
		services.sendcommand(cn, "date", 'unregister_key "DATE_OPEN"')
	end

)

