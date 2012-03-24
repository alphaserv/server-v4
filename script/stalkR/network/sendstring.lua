--use these, as lua strings aren't null terminated!
function sendstring (str)
	local null = string.find(str, "\0")
	
	if null then
		return string.sub(buffer, 1, null)
	end
	
	return str .. "\0"
end
