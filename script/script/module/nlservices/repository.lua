services.add(

	-- service name
	"repository",
	
	-- description
	"Service Repository",
	
	-- category
	"main",

	-- execute
	function(cn)
		services.sendcommand(cn, "repository", 'register_category "main"')
		services.sendcommand(cn, "repository", 'register_category "admin"')
		services.sendcommand(cn, "repository", 'register_category "profile"')
		services.sendcommand(cn, "repository", 'register_category "gameplay"')
		services.sendcommand(cn, "repository", 'register_category "weapon"')
		for service_name, description in pairs(services.descriptions) do
			services.sendcommand(cn, "repository", string.format('register_service "%s" "com.nooblounge.net" "28787" "%s" "%s"', service_name, services.categories[service_name], description))
		end
	end,
	
	-- activate
	function(cn)
		services.sendcommand(cn, "repository", 'register_category "main"')
		services.sendcommand(cn, "repository", 'register_category "admin"')
		services.sendcommand(cn, "repository", 'register_category "profile"')
		services.sendcommand(cn, "repository", 'register_category "gameplay"')
		services.sendcommand(cn, "repository", 'register_category "weapon"')
		for service_name, description in pairs(services.descriptions) do
			services.sendcommand(cn, "repository", string.format('register_service "%s" "com.nooblounge.net" "28787" "%s" "%s"', service_name, services.categories[service_name], description))
		end
	end,
	
	-- deactivate
	function(cn)
		services.sendcommand(cn, "repository", 'reset_services')
	end

)

