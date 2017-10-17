
-- simple random number generator
-- Based on http://www.rgba.org/articles/sfrand/sfrand.htm

local M = {}

function M.new(x)
    local r = {}
    setmetatable(r, M)
    if not x then
        x = math.random(0, 0xFFFFFF)
    end
    r._init = x
    r:reset()
    return r
end

function M.reset(r)
    r._state = r._init
end

-- [0 .. 1]
local D = 2.0 / 23767
local i32 = 0xFFFFFFFF + 1
function M.next(r)
    local a = r._state * 16807
    r._state = a % i32
    a = (a / 0x8000) % 0x8000
    return ((1 + (D * a)) % 1)
end

-- same semantics as math.random()
function M.random(r, a, b)
    if a then
        if b then
            return math.floor(1 + a + (r:next() * (b - a)))
        end
        
        return math.floor(1 + (r:next() * a))
    end
    
    return r:next()
end

M.__index = M
M.__call = M.random

rawset(_G, "prandom", M)
