
module("as.filters", package.seeall)

TeamFilter = newclass("TeamFilter", UserFilter)
function TeamFilter:match(user)
	if type(self.options) == "table" then
		if self.options.team then
			self.options = self.options.team
			return self:match(user)
		else
			local teams = self.options.teams or self.options
			
			for i, team in pairs(teams) do
				if user:getTeamName() == team then
					return true
				end
			end
			
			return false	
		end
	end
	return user:getTeamName() == self.options
end
