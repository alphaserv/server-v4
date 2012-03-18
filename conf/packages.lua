
--alpha.package.loadpackage("serverexec")
--alpha.package.loadpackage("cd")
--alpha.package.loadpackage("messages")
--alpha.package.loadpackage("ban")

--[[
############################################
# Banner module
############################################
]]
alpha.package.loadpackage("banners")

--create a banner
banners.create_banner("test", "blue<This server is running> green<Alphaserv> yellow<V4> orange<Prealpha>")

--start banner rotation
banners.start_auto_banner()

--[[
]]
