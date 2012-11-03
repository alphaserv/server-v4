promod = {}

function string:split_(delimiter)
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find(self, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(self, from, delim_from-1))
		from  = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub(self, from))
	return result
end

log = server.log

function promod.gettextfromargs(arg_)
	local text = ""
	for _, item in ipairs(arg_) do
		item = tostring(item)
		if #item > 0 then
			if #text > 0 then
				text = text .. " "
			end

			text = text .. item
		end
	end
	return text
end
