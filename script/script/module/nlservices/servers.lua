services.add(

	-- service name
	"servers",
	
	-- description
	"Updates data from masterserver",
	
	-- category
	"main",

	-- execute
	function(cn)
		services.clear(cn)
	end,
	
	-- activate
	function(cn)
	end,
	
	-- deactivate
	function(cn)
	end

)

