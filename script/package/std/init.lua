--[[! File: library/core/std/lua/init

    About: Author
        q66 <quaker66@gmail.com>

    About: Copyright
        Copyright (c) 2011 OctaForge project

    About: License
        This file is licensed under MIT. See COPYING.txt for more information.

    About: Purpose
        OctaForge standard library loader (Lua extensions).

        Exposes "min", "max", "clamp", "abs", "floor", "ceil", "round" and the
        bitwise functions from math and "switch", "case", "default" and
        "match" from util into globals, as they are widely used and the
        default syntax is way too verbose. The bitwise functions are globally
        named "bitlsh", "bitrsh", "bitor", "bitand" and "bitnot".
]]

--log(DEBUG, ":::: Safe FFI.")
--sffi = require("std.ffi")

--log(DEBUG, ":::: Engine variables.")
--var = require("std.var")

--log(DEBUG, ":::: Class system.")
--class = require("std.class")

--log(DEBUG, ":::: Lua extensions: table")
require("std.table")

--log(DEBUG, ":::: Lua extensions: string")
require("std.string")

--log(DEBUG, ":::: Lua extensions: math")
require("std.math")

--log(DEBUG, ":::: Type conversions.")
conv = require("std.conv")

--log(DEBUG, ":::: Library.")
--library = require("std.library")

--log(DEBUG, ":::: Utilities.")
util = require("std.util")

-- Useful functionality exposed into globals

--[[
max   = math.max
min   = math.min
abs   = math.abs
floor = math.floor
ceil  = math.ceil
round = math.round
clamp = math.clamp

bitlsh  = math.lsh
bitrsh  = math.rsh

bitor  = math.bor
bitxor = math.bxor
bitand = math.band

bitnot = math.bnot

match   = util.match
switch  = util.switch
case    = util.case
default = util.default
]]
