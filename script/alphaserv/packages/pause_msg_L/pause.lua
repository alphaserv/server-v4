
core.overrides.pause = function(cn)
	if not cn then
		cn = -1
	end
	
	messages.load("pause", "pause", {default_type = "info", default_message = "blue<the game was> green<paused> blue<by> green<name<%(1)i>>"})
		:format(cn)
		:send()
	
	core.pause()
end


core.overrides.resume = function(cn, cdown)
	if not cn then
		cn = -1
	end
	
	if cdown then
		local msg = messages.load("pause", "countdown", {default_type = "info", default_message = "the game will start in green<%(1)i>"})
		msg:format(cdown):send()
		server.interval(1000, function()
			cdown = cdown - 1
			if cdown < 0 then
				server.resume(cn)
				return -1
			else
				msg:format(cdown):send()
			end
		end)	
	else
		messages.load("pause", "resumed", {default_type = "info", default_message = "blue<the game was> green<resumed> blue<by> green<name<%(1)i>>"})
			:format(cn)
			:send()
		
		core.resume()
	end

end
