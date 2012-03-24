function putint (n)
	n = tonumber(n)
	
	if not n then
		error("not a number", 1)
	end
	
	n = math.modf(n)
	
	if n > 2147483647
	or n < -2147483648 then
		error("n is not a 32 bits integer", 1)
	end
	
	local posn = n
	
	if n < 0 then
		posn = n + 0x100000000
	end
	
	local buffer = string.char(math.fmod(posn, 0x100))
	
	if n < 128
	and n > -127 then
		return buffer
	end
	
	buffer = buffer .. string.char(math.fmod(math.modf(posn/0x100), 0x100))
	
	if n < 0x8000
	and n >= -0x8000 then
		return string.char(0x80) .. buffer
	end
	
	return string.char(0x81) .. buffer .. string.char(math.fmod(math.modf(posn/0x10000), 0x100)) .. string.char(math.fmod(math.modf(posn/0x1000000), 0x100))
end
