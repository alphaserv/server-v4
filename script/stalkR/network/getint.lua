function getint (buffer)
	
	if type(buffer) ~= "string"
	or string.len(buffer) < 1 then
		error("not a buffer", 4)
	end
	
	local length, c = string.len(buffer), string.byte(buffer, 1)
	print(c)
	if c == 0x80 then
		if length < 3 then
			error("buffer too short", 4)
		end
		
		local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100
		
		if ret > 0x7F00 then
			return ret - 0x10000, 3
		end

		return ret, 3
	end
	
	if c == 0x81 then
		if length < 5 then
			error("buffer too short", 4)
		end
		
		local ret = string.byte(buffer, 2) + string.byte(buffer, 3)*0x100 + string.byte(buffer, 4)*0x10000 + string.byte(buffer, 4)*0x1000000
		
		if ret > 0x7F000000 then
			return ret - 0x100000000, 5
		end

		return ret, 5
	end
	
	if c > 0x7F then
		return c - 0x100, 1
	end
	
	return c, 1
end
