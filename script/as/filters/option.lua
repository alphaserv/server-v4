module("as.filters", package.seeall)

OptionFilter = newclass("OptionFilter", UserFilter)
function OptionFilter:match(user)
	return User:getOption(self.options.option) == self.options.value
end
