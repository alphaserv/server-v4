--[[! File: library/core/std/lua/math.lua

    About: Author
        q66 <quaker66@gmail.com>

    About: Copyright
        Copyright (c) 2011 OctaForge project

    About: License
        This file is licensed under MIT. See COPYING.txt for more information.

    About: Purpose
        Lua math module extensions. Functions are inserted directly into the
        math module.
    
]]

--local bit = require("bit")

--[[ ! Function: math.lsh
    Bitwise left shift of a by b (both arguments are integral). Globally
    available as "bitlsh".
]]
--math.lsh = bit.lshift

--[[ ! Function: math.rsh
    Bitwise right shift of a by b (both arguments are integral). Globally
    available as "bitrsh".
]]
--math.rsh = bit.rshift

--[[ ! Function: math.bor
    Bitwise OR of variable number of integral arguments. Globally available
    as "bitor".
]]
--math.bor = bit.bor

--[[ ! Function: math.bxor
    Bitwise XOR of variable number of integral arguments. Globally available
    as "bitxor".
]]
--math.bxor = bit.bxor

--[[ ! Function: math.band
    Bitwise AND of variable number of integral arguments. Globally available
    as "bitand".
]]
--math.band = bit.band

--[[ ! Function: math.bnot
    Bitwise NOT of an integral argument. Globally available as "bitnot".
]]
--math.bnot = bit.bnot

--[[! Function: math.round
    Rounds a given number and returns it. Globally available.
]]
math.round = function(v)
    return (type(v) == "number"
        and math.floor(v + 0.5)
        or nil
    )
end

--[[! Function: math.clamp
    Clamps a number value given by the first argument between third and
    second argument. Globally available.
]]
math.clamp = function(val, low, high)
    return math.max(low, math.min(val, high))
end

--[[! Function: math.sign
    Returns a sign of a numerical value
    (-1 for < 0, 0 for 0 and 1 for > 0).
]]
math.sign = function(v)
    return (v < 0 and -1 or (v > 0 and 1 or 0))
end

--[[! Function: math.lerp
    Performs a linear interpolation between the two
    numerical values, given a weight.
]]
math.lerp = function(first, other, weight)
    return first + weight * (other - first)
end

--[[! Function: math.magnet
    If the distance between the two numerical values is in given radius,
    the second value is returned, otherwise the first is returned.
]]
math.magnet = function(value, other, radius)
    return (math.abs(value - other) <= radius) and other or value
end

--[[! Function: math.frandom
    Returns a pseudo-random floating point value in the bounds of min and max.
]]
math.frandom = function(_min, _max)
    return math.random() * (_max - _min) + _min
end

--[[! Function: math.norm_vec3
    Returns a normalized <Vec3> of random components from -1 to 1.
]]
math.norm_vec3 = function()
    local ret = nil

    while not ret or ret:length() == 0 do
        ret = math.Vec3(
            math.frandom(-1, 1),
            math.frandom(-1, 1),
            math.frandom(-1, 1)
        )
    end

    return ret:normalize()
end

--[[! Function: math.distance
    Returns a distance between two <Vec3>.
]]
math.distance = function(a, b)
    return math.sqrt(
        math.pow(a.x - b.x, 2) +
        math.pow(a.y - b.y, 2) +
        math.pow(a.z - b.z, 2)
    )
end

--[[! Function: math.normalize_angle
    Normalizes an angle to be within +-180 degrees of some value.
    Useful to know if we need to turn left or right in order to be
    closer to something (we just need to check the sign, after normalizing
    relative to that angle).

    For example, for angle 100 and rel_to 300, this function returns 460
    (as 460 is within 180 degrees of 300, but 100 isn't).
]]
math.normalize_angle = function(angle, rel_to)
    while angle < (rel_to - 180.0) do
          angle =  angle  + 360.0
    end

    while angle > (rel_to + 180.0) do
          angle =  angle  - 360.0
    end

    return angle
end

--[[ ! Function: math.floor_distance
    By default returns the distance to the floor below some given
    position, with maximal distance equal to max_dist. If radius
    is given, it finds the distance to the highest floor in given
    radius. If the fourth optional argument is true, it finds the
    lowest floor instead of highest floor.
]]
--[[
math.floor_distance = function(pos, max_dist, radius, lowest)
    local rt = CAPI.rayfloor(pos, max_dist)

    if not radius then
        return rt
    end

    local tbl = {
       -radius / 2, 0,
        radius / 2
    }

    local f = math.min
    if lowest then
        f = math.max
    end

    for x = 1, #tbl do
        for y = 1, #tbl do
            rt = f(rt, CAPI.rayfloor(pos:add_new(math.Vec3(
                tbl[x],
                tbl[y], 0
            )), max_dist))
        end
    end

    return rt
end]]

--[[ ! Function: math.is_los
    Returns true is the line between two given positions is clear
    (if there are no obstructions). Returns false otherwise.
]]
--math.is_los = CAPI.raylos

--[[! Function: math.yaw_to
    Calculates the yaw from an origin to a target. Done on 2D data only.
    If the last "reverse" argument is given as true, it calculates away
    from the target. Returns the yaw.
]]
math.yaw_to = function(origin, target, reverse)
    return (reverse
        and math.yaw_to(target, origin)
        or  math.deg(-(math.atan2(target.x - origin.x, target.y - origin.y)))
    )
end

--[[! Function: math.pitch_to
    Calculates the pitch from an origin to a target. Done on 2D data only.
    If the last "reverse" argument is given as true, it calculates away
    from the target. Returns the pitch.
]]
math.pitch_to = function(origin, target, reverse)
    return (reverse
        and math.pitch_to(target, origin)
        or (
            360.0 * (
                math.asin(
                    (target.z - origin.z) / math.distance(origin, target)
                )
            ) / (2.0 * math.pi)
        )
    )
end

--[[! Function: math.compare_yaw
    Checks if the yaw between two points is within acceptable error range.
    Useful to see whether a character is facing closely enough to the target,
    for example. Returns true if it is within the range, false otherwise.
]]
math.compare_yaw = function(origin, target, yaw, acceptable)
    return (math.abs(
        math.normalize_angle(
            math.yaw_to(origin, target), yaw
        ) - yaw
    ) <= acceptable)
end

--[[! Function: math.compare_pitch
    Checks if the pitch between two points is within acceptable error range.
    Useful to see whether a character is facing closely enough to the target,
    for example. Returns true if it is within the range, false otherwise.
]]
math.compare_pitch = function(origin, target, pitch, acceptable)
    return (math.abs(
        math.normalize_angle(
            math.pitch_to(origin, target), pitch
        ) - pitch
    ) <= acceptable)
end

--[[! Function: math.is_nan
    Returns true if the given value is nan, false otherwise.
]]
math.is_nan = function(n)
    return (n ~= n)
end

--[[! Function: math.is_inf
    Returns true if the given value is infinite, false otherwise.
]]
math.is_inf = function(n)
    return (n == 1/0)
end

--[[! Class: math.Vec3
    A standard 3 component vector with x, y, z components.

    (start code)
        a = math.Vec3(5, 10, 15)
        echo(a.x)
    (end)
]]
math.Vec3 = table.classify({
    --[[! Constructor: __init
        Constructs the vector. Besides self, there can be either one more
        argument, which then has to be either another vector or associative
        array with x, y, z keys or an array with length 3, or 3 more arguments,
        which then are the x, y, z components themselves.
    ]]
    __init = function(self, x, y, z)
        if type(x) == "table" then
            if (x.is_a and x:is_a(math.Vec3)) or (x.x and x.y and x.z) then
                self.x = tonumber(x.x)
                self.y = tonumber(x.y)
                self.z = tonumber(x.z)
            elseif #x == 3 then
                self.x = tonumber(x[1])
                self.y = tonumber(x[2])
                self.z = tonumber(x[3])
            else
                self.x = 0
                self.y = 0
                self.z = 0
            end
        else
            self.x = x or 0
            self.y = y or 0
            self.z = z or 0
        end
    end,

    --[[! Function: __tostring
        Causes tostring(some_vec) result in "Vec3 <x, y, z>".
    ]]
    __tostring = function(self)
        return string.format(
            "%s <%s, %s, %s>",
             self.name,
             tostring(self.x),
             tostring(self.y),
             tostring(self.z)
        )
    end,

    --[[! Function: length
        Returns the vector length (aka sqrt(x*x + y*y + z*z)).
    ]]
    length = function(self)
        return math.sqrt(
            self.x * self.x +
            self.y * self.y +
            self.z * self.z
        )
    end,

    --[[! Function: normalize
        Normalizes the vector. It must not be zero length.
    ]]
    normalize = function(self)
        local len  = self:length()
        if    len ~= 0 then
            self:mul(1 / len)
        else
            log(ERROR, "Can't normalize a vector of zero length.")
        end
        return self
    end,

    --[[! Function: cap
        Caps the vector length.
    ]]
    cap = function(self, max_len)
        local len = self:length()
        if len > max_len then
            self:mul(max_len / len)
        end
        return self
    end,

    --[[! Function: sub_new
        Returns a new vector that equals "this - other".
    ]]
    sub_new = function(self, v)
        return math.Vec3(
            self.x - v.x,
            self.y - v.y,
            self.z - v.z
        )
    end,

    --[[! Function: add_new
        Returns a new vector that equals "this + other".
    ]]
    add_new = function(self, v)
        return math.Vec3(
            self.x + v.x,
            self.y + v.y,
            self.z + v.z
        )
    end,

    --[[! Function: mul_new
        Returns a new vector that equals "this * other".
    ]]
    mul_new = function(self, v)
        return math.Vec3(
            self.x * v,
            self.y * v,
            self.z * v
        )
    end,

    --[[! Function: sub
        Subtracts a given vector from this one.
    ]]
    sub = function(self, v)
        self.x = self.x - v.x
        self.y = self.y - v.y
        self.z = self.z - v.z
        return self
    end,

    --[[! Function: add
        Adds a given vector to this one.
    ]]
    add = function(self, v)
        self.x = self.x + v.x
        self.y = self.y + v.y
        self.z = self.z + v.z
        return self
    end,

    --[[! Function: mul
        Multiplies this with a given vector.
    ]]
    mul = function(self, v)
        self.x = self.x * v
        self.y = self.y * v
        self.z = self.z * v
        return self
    end,

    --[[! Function: copy
        Returns a copy of this vector.
    ]]
    copy = function(self)
        return math.Vec3(self.x, self.y, self.z)
    end,

    --[[! Function: to_array
        Returns an array of components of this vector.
    ]]
    to_array = function(self)
        return { self.x, self.y, self.z }
    end,

    --[[! Function: from_yaw_pitch
        Initializes the vector using given yaw and pitch.
    ]]
    from_yaw_pitch = function(self, yaw, pitch)
        self.x = -(math.sin(math.rad(yaw)))
        self.y =  (math.cos(math.rad(yaw)))

        if pitch ~= 0 then
            self.x = self.x * math.cos(math.rad(pitch))
            self.y = self.y * math.cos(math.rad(pitch))
            self.z = math.sin(math.rad(pitch))
        else
            self.z = 0
        end

        return self
    end,

    --[[! Function: to_yaw_pitch
        Calculates yaw and pitch from the vector's components.
    ]]
    to_yaw_pitch = function(self)
        local mag = self:length()
        if mag < 0.001 then
            return { yaw = 0, pitch = 0 }
        end
        return {
            yaw = math.deg(-(math.atan2(self.x, self.y))),
            pitch = math.deg(math.asin(self.z / mag))
        }
    end,

    --[[! Function: is_close_to
        Optimized way to check if two positions are close. Faster than
        "a:sub(b):length() <= dist". Avoids the sqrt and may save some
        of the multiplications.
    ]]
    is_close_to = function(self, v, dist)
        dist = dist * dist
        local temp, sum

        -- note order: we expect z to be less
        -- important, as most maps are 'flat'
        temp = self.x - v.x
        sum = temp * temp
        if sum > dist then return false end

        temp = self.y - v.y
        sum = sum + temp * temp
        if sum > dist then return false end

        temp = self.z - v.z
        sum = sum + temp * temp
        return (sum <= dist)
    end,

    --[[! Function: dot_product
        Calculates a dot product of this and some other vector.
    ]]
    dot_product = function(self, v)
        return self.x * v.x + self.y * v.y + self.z * v.z
    end,

    --[[! Function: cross_product
        Calculates a cross product of this and some other vector.
    ]]
    cross_product = function(self, v)
        return math.Vec3(
            (self.y * v.z) - (self.z * v.y),
            (self.z * v.x) - (self.x * v.z),
            (self.x * v.y) - (self.y * v.x)
        )
    end,

    --[[! Function: project_along_surface
        Projects the vector along a surface defined by a normal.
        Returns this, the modified vector.
    ]]
    project_along_surface = function(self, surf)
        return self:sub(surf:mul_new(self:dot_product(surf)))
    end,

    --[[! Function: lerp
        Performs a linear interpolation between the two
        vectors, given a weight. Returns the new vector.
        Does not modify the original.
    ]]
    lerp = function(self, other, weight)
        return self:add_new(other:sub_new(self):mul(weight))
    end,

    --[[! Function: is_zero
        Returns true if each component is 0, false otherwise.
    ]]
    is_zero = function(self)
        return (self.x == 0 and self.y == 0 and self.z == 0)
    end
}, "Vec3")

--[[! Class: math.Vec4
    A standard 4 component vector with x, y, z components.
    Inherits from <math.Vec3> and contains exactly the same
    methods, with additions documented here.

    (start code)
        a = math.Vec4(5, 10, 15, 20)
        echo(a.x)
    (end)
]]
math.Vec4 = table.subclass(math.Vec3, {
    __init = function(self, x, y, z, w)
        if type(x) == "table" then
            if (x.is_a and x:is_a(math.Vec4)) or
               (x.x and x.y and x.z and x.w)
            then
                self.x = tonumber(x.x)
                self.y = tonumber(x.y)
                self.z = tonumber(x.z)
                self.w = tonumber(x.w)
            elseif #x == 4 then
                self.x = tonumber(x[1])
                self.y = tonumber(x[2])
                self.z = tonumber(x[3])
                self.w = tonumber(x[4])
            else
                self.x = 0
                self.y = 0
                self.z = 0
                self.w = 0
            end
        else
            self.x = x or 0
            self.y = y or 0
            self.z = z or 0
            self.w = w or 0
        end
    end,

    __tostring = function(self)
        return string.format(
            "%s <%s, %s, %s, %s>",
             self.name,
             tostring(self.x),
             tostring(self.y),
             tostring(self.z),
             tostring(self.w)
        )
    end,

    length = function(self)
        return math.sqrt(
            self.x * self.x +
            self.y * self.y +
            self.z * self.z +
            self.w * self.w
        )
    end,

    sub_new = function(self, v)
        return math.Vec4(
            self.x - v.x,
            self.y - v.y,
            self.z - v.z,
            self.w - v.w
        )
    end,

    add_new = function(self, v)
        return math.Vec4(
            self.x + v.x,
            self.y + v.y,
            self.z + v.z,
            self.w + v.w
        )
    end,

    mul_new = function(self, v)
        return math.Vec4(
            self.x * v,
            self.y * v,
            self.z * v,
            self.w * v
        )
    end,

    sub = function(self, v)
        self.x = self.x - v.x
        self.y = self.y - v.y
        self.z = self.z - v.z
        self.w = self.w - v.w
        return self
    end,

    add = function(self, v)
        self.x = self.x + v.x
        self.y = self.y + v.y
        self.z = self.z + v.z
        self.w = self.w + v.w
        return self
    end,

    mul = function(self, v)
        self.x = self.x * v
        self.y = self.y * v
        self.z = self.z * v
        self.w = self.w * v
        return self
    end,

    copy = function(self)
        return math.Vec4(self.x, self.y, self.z, self.w)
    end,

    to_array = function(self)
        return { self.x, self.y, self.z, self.w }
    end,

    --[[! Function: to_yaw_pitch_roll
        Calculates yaw, pitch and roll from the vector's components.
    ]]
    to_yaw_pitch_roll = function(self)
        if math.abs(self.z) < 0.99 then
            local r = self:to_yaw_pitch()
            r.roll = math.deg(self.w)
            return r
        else
            return {
                yaw = math.deg(self.w) * (self.z < 0 and 1 or -1),
                pitch = self.z > 0 and -90 or 90,
                roll = 0
            }
        end
    end,

    is_zero = function(self)
        return (self.x == 0 and self.y == 0 and self.z == 0 and self.w == 0)
    end
}, "Vec4")
