banners = {}
banners.list = {}
banners.current = 1
banners.timeout = 60000

function banners.add(banner)
	table.insert(banners.list, banner)
end

function banners.showbanner(num)
	if banners.list[num] == nil then return false end
	messages.info(num, players.all(), string.format(config.get("bannerinfo:template"), num, banners.list[num]), false)
end
function banners.show()
	if banners.current == #banners.list then
		banners.showbanner(banners.current)
		banners.current = 1
	else
		banners.showbanner(banners.current)
		banners.current = banners.current + 1
	end
	server.sleep(banners.timeout, banners.show)
end
server.sleep(banners.timeout, banners.show)
server.addbanner = banners.add

cmd.command_function("bannerinfo", function(cn, num)
	num = tonumber(num)
	if not num or not banners.list[num] or banners.list[num] == nil then return false, config.get("usage:bannerinfo") end
	messages.info(-1, {cn}, "green<"..tostring(num)..":> "..banners.list[num], true)
end)
