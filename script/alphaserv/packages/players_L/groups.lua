
module("players.groups", package.seeall)

function all()
	return server.players()
end

function except(who, except)
	if type(except) ~= "table" then
		except = {except}
	end
	
	for _, ecn in pairs(except) do
		for i, cn in pairs(who) do
			if ecn == cn then
				who[i] = nil
			end	
		end
	end
	
	return who
end
