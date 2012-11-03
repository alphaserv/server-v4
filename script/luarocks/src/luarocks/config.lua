return {
	use_extensions = false,
	local_cache = BASE_DIR.."/../.cache/luarocks",
	rocks_servers = {
		{
			"http://www.luarocks.org/repositories/rocks",
			"http://luarocks.giga.puc-rio.br/",
			"http://luafr.org/luarocks/rocks",
		},
	},
	external_deps_dirs = {
		BASE_DIR,
		"/usr/local",
		"/usr"
	},
}
