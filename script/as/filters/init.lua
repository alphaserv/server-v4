
module("as.filters", package.seeall)

require "class"
require "as.filters.base"
require "as.filters.option"
require "as.filters.team"

addFilter("option", OptionFilter)
addFilter("team", TeamFilter)
