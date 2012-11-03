module("as.team", package.seeall)

local teams = {}

function getList()
	return teams
end

local Team = newclass("Team")
Team.name = ""
Team.players = {}
function Team:getPlayers()

end

function Team:addPlayer()

end

function Team:removePlayer()

end
