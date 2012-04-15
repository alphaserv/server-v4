--[[
if not alpha then error("trying to load 'settings.lua' before alpha init."); return end

alpha.settings = {
	settings = {},
	init_setting = function (name, default_value, type_, description)
		if alpha.settings.settings[name] then error("this setting's name is already in use")end
		local t = 's'
		local typecast = function () end
		if type_ == "string" or type_ == "char" or type_ == "const char" --[ [ for c++ gurus ] ] then
			t = 's'
			default_value = tostring(default_value)
			typecast = tostring
		elseif type_ == "int" or type_ == "number" then
			t = 'i'
			default_value = tonumber(default_value)
			typecast = tostring
		elseif type_ == "bool" or type_ == "boolean" then
			t = 'b'
			default_value = tobool(default_value)
			typecast = tobool
		elseif string.gsub(type_, "table{(.-)}", function(arg1) a = arg1 end) and a then
			t = 't'
			default_value = default_value
			typecast = table_typecast(a)
		else
			error('unkown setting type')
		end
		
		alpha.settings.settings[name] = alpha.settings._new_setting(name, t, default_value, description or false, typecast)
	end,
	
	get = function(obj, name)
		if not obj.settings[name] then error("could not find setting", 1) end
		return obj.settings[name]:get()
	end,
	
	set = function(obj, name, value)
		if not obj.settings[name] then error("could not find setting", 1) end
		if value == nil then error("cannot set setting to nil") end
		return obj.settings[name]:set(value)
	end,
	
	_new_setting = function (name, type_, value, description, typecast)
		if value == nil then error("cannot make a nil variable") end
		return {
			name = name,
			t = type_,
			value = value,
			description = description,
			typecast = typecast,
			get = function (obj)
				if obj.value == nil then return false, "unvalid value: nil" end
				if triggers and triggers.get then
					local returning = obj.value
					for i, trigger in pairs(triggers.set) do
						local a = trigger(obj.value)
						if a ~= true or a ~= false then
							returning = a
						end
					end
					
					return a
				else
					if obj.t == "table" then
						obj.typecast(to_table(obj.value or "{ error(\"value is nil\") }"))
					else
						return obj.typecast(obj.value)
					end
				end

				return obj.typecast(obj.value)
			end,
			set = function (obj, value)
				if value == nil then error("cannot set nil to this variable") end
				if obj.t == "table" then
					value = to_table(value)
				end

				if triggers and triggers.set then
					local allow_change = true
					for i, trigger in pairs(triggers.set) do
						if not trigger(obj.value, obj.typecast(value), obj.name) then
							allow_change = false
						end
					end
					
					if allow_change then
						obj.value = obj.typecast(value or 0)
					end
				else
					obj.value = obj.typecast(value or 0)
				end
			end,
			triggers = {} --change triggers
		}
	end,
	_write_config = function(filename, header)
		file = io.open(filename, "w")
		if header then
			file:write(header)
		end
		
		for i, setting in pairs(alpha.settings.settings) do
			if setting.t == 'i' then
				setting.t = 'number (int)'
			elseif setting.t == 's' then
				setting.t = 'string'
			elseif setting.t == 'b' then
				setting.t = 'boolean'
			elseif setting.t == 't' then
				setting.t = 'table'
			else
				setting.t = 'unkown'
			end
			
			--auto newline
			description = string.gsub(setting.description, "\n", "\n# ** ")
			
			file:write(string.format("\n\n#--------------------------\n# %s\n#--------------------------\n#\n# Name: %s\n# Description: %s\n# Type: %s\n\n", setting.name, setting.name, description, setting.t))
			file:write(string.format("cfg %q %q", setting.name, tostring(setting.value)))

			--print to screen for debugging
			--print(string.format("\n#--------------------------\n# %s\n#--------------------------\n#\n# Name: %s\n# Description: %s\n# Type: %s\n\n", setting.name, setting.name, setting.description, setting.t))			

			--print(string.format("cfg %q %q", setting.name, setting.value))
		end

		file:close()
	end,
	load = function(file)
		if not alpha.standalone then
			exec(file) --just simple cubescript
		else
			cubescript_library.exec(file)
		end
		print("#Succesfully loaded config file: "..file)
	end
}

--cubescript set api
function server.cfg(name, value)
	alpha.settings:set(name, value)
end
function server.cfg_get(name)
	return alpha.settings:get(name)
end]]
