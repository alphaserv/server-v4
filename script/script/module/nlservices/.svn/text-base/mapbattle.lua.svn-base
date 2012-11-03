services.add(

	-- service name
	"mapbattle",
	
	-- description
	"Map Battle with GUI",
	
	-- category
	"gameplay",
	
	-- execute
	function(cn)
		services.sendvar(cn, "mapbattle", "names_map1", mapbattle.names.map1)
		services.sendvar(cn, "mapbattle", "names_map2", mapbattle.names.map2)
		services.sendvar(cn, "mapbattle", "votes_map1", mapbattle.voting.map1)
		services.sendvar(cn, "mapbattle", "votes_map2", mapbattle.voting.map2)
		services.sendvar(cn, "mapbattle", "votes_none", mapbattle.voting.none)
	end,
	
	-- activate
	function(cn)
		services.sendvar(cn, "mapbattle", "names_map1", mapbattle.names.map1)
		services.sendvar(cn, "mapbattle", "names_map2", mapbattle.names.map2)
		services.sendvar(cn, "mapbattle", "votes_map1", mapbattle.voting.map1)
		services.sendvar(cn, "mapbattle", "votes_map2", mapbattle.voting.map2)
		services.sendvar(cn, "mapbattle", "votes_none", mapbattle.voting.none)
	end,
	
	-- deactivate
	function(cn)
		services.resetvar(cn, "mapbattle", "names_map1")
		services.resetvar(cn, "mapbattle", "names_map2")
		services.resetvar(cn, "mapbattle", "votes_map1")
		services.resetvar(cn, "mapbattle", "votes_map2")
		services.resetvar(cn, "mapbattle", "votes_none")
	end

)

