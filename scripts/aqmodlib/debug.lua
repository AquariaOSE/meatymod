
local debug = rawget(_G, "debug")


local MATCH_WARN = "[^_%u%d]" -- NOT any of: _, uppercase, digits

local function isAllowedGlobalName(s)
    return s == "v" or isInterfaceFunction(s) or not s:match(MATCH_WARN)
end


local function forcestring(x)

    local t = type(x)

    -- try to convert to string (respects metatables)
    local ok, s = pcall(tostring, x)
    if ok then
        return "[type: " .. t .. "]: " .. s
    end
    
    -- if that didn't work, check the type
    if t == "nil" then
        return "<Nil>"
    elseif t == "function" then
        return "(function)"
    elseif t == "userdata" then
        return "(userdata)"
    elseif t == "table" then
        return "(table)"
    elseif x == true then
        return "true"
    elseif x == false then
        return "false"
    elseif t == "thread" then
        return "(thread)"
    elseif t == "number" or t == "string" then
        return tostring(x)
    end
    return t
end

local function dumptab(t, lvl, s)
    if type(t) ~= "table" then
        puts("dumptab: " .. forcestring(t))
        return
    end
    s = s or ""
    lvl = lvl or 0
    for i, x in pairs(t) do
        debugLog(s .. forcestring(i) .. " => " .. forcestring(x))
        if lvl > 0 and type(x) == "table" then
            dumptab(x, lvl - 1, s .. "  ")
        end
    end
end

local function formatStack(lvl)
    if debug then
        if not lvl then lvl = 1 end
        return debug.traceback("", lvl) or "[No traceback available]"
    end
    return "[No debug library available]"
end

-- first, be sure there is a table to use as meta table
local meta = getmetatable(_G)
if not meta then
    meta = {}
end

-- first time we are here and the meta table is untouched,
-- save it for later.
local oldmeta = rawget(_G, "_G_oldmeta_")
if not oldmeta then
    rawset(_G, "_G_oldmeta_", meta)
    oldmeta = meta
end

-- create a new metatable for _G
meta = {}
setmetatable(_G, meta)

-- install overrides to the new metatable:
-- either use the original metatable entries, or, if those do not exist, custom functions.

local f_index = oldmeta.__index or function(tab, key)
    debugLog("WARNING: script tried to get/call undefined global variable " .. key)
end

local f_newindex = oldmeta.__newindex or function(tab, key, val)
    debugLog("WARNING: script set global " .. type(val) .. " " .. key)
    rawset(tab, key, val)
end


-- put override functions into the new metatable.
-- this enhances existing script warnings and adds callstack info to the displayed message box.

function meta.__index(tab, key)
    if not isAllowedGlobalName(key) then
        local detail = key .. "\n\n" .. formatStack(3)
        return f_index(tab, detail)
    end
    -- f_index returns nil anyways, if the key was known we wouldn't have ended up here.
    -- TODO: return dummy function to silence warnings?
end

function meta.__newindex(tab, key, val)

    if isAllowedGlobalName(key) then
        -- all fine!
        rawset(tab, key, val)
        return val
    end
    
    local detail = key .. "\n\n-> To: " .. forcestring(val) .. "\n" .. formatStack(3)
    
    -- okay, this is going to be sick.
    -- the C-function l_newindexWarnGlobal sets the key to the given value no matter what,
    -- so we have it set a bogus value and a detail string as index, so that the message box prints all of that.
    -- later we do the correct set ourselves.
    -- note: this does incorrectly report the code position where the set happened - check the callstack instead.
    f_newindex(tab, detail, val)
    
    -- remove the value again if necessary - will not trigger a warning this time
    f_newindex(tab, detail, nil)
    
    -- do the actual set
    rawset(tab, key, val)
    
    return val
end
