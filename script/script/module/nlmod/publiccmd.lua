local function process_command(cn, text)
	text = string.match(text, "!(.+)")
	if not text then return end
	cmd = string.match(text, "(%S+)")
	if string.find(text, " ") then text = string.match(text, "^" .. cmd .. " (.*)") end
	server.eval_lua("if server.playercmd_" .. cmd .. " then continue = true else continue = false end")
	if not continue then return end
	argstring = ""
	while string.find(text, " ") do
		arg, text = string.match(text, "(%S+) (.*)")
		if tonumber(arg) then
			argstring = argstring .. ", " .. arg
		else
			argstring = argstring .. ", \"" .. arg .. "\""
		end
	end
	if text ~= "" and text ~= cmd then
		arg = text
		if tonumber(arg) then
			argstring = argstring .. ", " .. arg
		else
			argstring = argstring .. ", \"" .. arg .. "\""
		end
	end
	server.eval_lua("server.playercmd_" .. cmd .. "(" .. cn .. argstring .. ")")
end

local function check_command(cn, text)
	if string.match(text, "^!.+") then process_command(cn, text) end
end

server.event_handler("text", check_command)
server.event_handler("sayteam", check_command)
