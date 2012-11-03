function checkban(ip, name)
	a = 1
	while not (a > #name_ban_list) do
		if string.match(string.lower(name), string.lower(name_ban_list[a])) or string.find(string.lower(name_ban_list[a]), string.lower(name)) then
			return true
		end
		a = a + 1
	end
	a = 1
	while not (a > #ip_ban_list) do
		if string.match(ip, ip_ban_list[a]) or string.find(ip_ban_list[a], ip) then
			return true
		end
		a = a + 1
	end
	return false
end

function loadbans()
	nowfile = io.open("/var/www/name_bans.txt", "r")
	name_ban_list = {}
	if nowfile then
		line = ""
		while line do
			line = nowfile:read()
			if line then
				line = string.gsub(line, "\n","")
				if not string.match(line, "//.*") then
					if line ~= "" then
						name = string.match(line, "(%S+).*")
						name_ban_list[#name_ban_list + 1] = name
					end
				end
			end
		end
		nowfile:close()
	else
		log("could not read name_bans.txt!")
	end

	nowfile = io.open("/var/www/ip_bans.txt", "r")
	ip_ban_list = {}
	if nowfile then
		line = ""
		while line do
			line = nowfile:read()
			if line then
				line = string.gsub(line, "\n","")
				if not string.match(line, "//.*") then
					if line ~= "" then
						ip = string.match(line, "(%S+).*")
						ip_ban_list[#ip_ban_list + 1] = ip
					end
				end
			end
		end
		nowfile:close()
	else
		log("could not read ip_bans.txt!")
	end

	return name_ban_list, ip_ban_list
end

function server.add_permanent_ban(ip, name)
	nowfile = io.open("/var/www/ip_bans.txt", "r")
	local ip_ban_list = {}
	if nowfile then
		line = ""
		while line do
			line = nowfile:read()
			if line then
				ip_ban_list[#ip_ban_list + 1] = line
			end
		end
		nowfile:close()
	end

	nowfile = io.open("/var/www/ip_bans.txt", "w")
	if not nowfile then return end
	a = 1
	while not (a > #ip_ban_list) do
		if a == 1 then nowfile:write(ip_ban_list[a]) else nowfile:write("\n" .. ip_ban_list[a]) end
		a = a + 1
	end
	nowfile:write("\n" .. ip .. " // ban was added ingame, name: " .. name)
	nowfile:flush()
	nowfile:close()
	loadbans()
	log("added permanent ban for IP " .. ip .. "! name: " .. name)
end

function ban_update_loop()
	server.sleep(600000, function() ban_update_loop() end)
	name_ban_list, ip_ban_list = loadbans()
end

ban_update_loop()