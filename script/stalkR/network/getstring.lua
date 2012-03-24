function getstring (buffer)
	local null = string.find(buffer, "\0")
	
	if null then
		return string.sub(buffer, 1, null-1), null
	end
	
	return buffer, string.len(buffer)
end

