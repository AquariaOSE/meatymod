
local function include(file)
    debugLog("modlib: include: " .. file)
    local ok, ret = pcall(include_once, "scripts/aqmodlib/" .. file)
    if ok then
        return ret
    else
        errorLog("modlib: include(" .. file .. ") error: \n" .. ret)
    end
end

local function globalize(tab)
    if not tab then return end
    for i, x in pairs(tab) do
        if type(i) == "string" and type(x) == "function" then
            debugLog("modlib: add global function: " .. i)
            rawset(_G, i, x)
        end
    end
end

local function import(file)
    return globalize(include(file .. ".lua"))
end

local cleanupfuncs = {}

-- must be called when entering a new map,
-- so that cached values valid only on one map can be erased
rawset(_G, "modlib_cleanup", function()
    for _, f in pairs(cleanupfuncs) do
        f()
    end
    cleanupfuncs = {}
end)

rawset(_G, "modlib_onClean", function(f)
    table.insert(cleanupfuncs, f)
end)

rawset(_G, "modlib_import", import)
rawset(_G, "modlib_include", include)


if not MOD_RELEASE_VERSION then
    -- this enables lots of extra debugging and
    -- makes things slow on weak hardware.
    -- use with care.
    --import "debug"
end

import "defs"
import "math"
import "rng"
import "string"
import "table"
import "functional"
import "interface"
import "vector"
import "geom"
import "entity"
import "bone"
import "node"
import "camera"
import "iex"
import "ai"
import "serialize"
import "lookup"
import "superfx"
