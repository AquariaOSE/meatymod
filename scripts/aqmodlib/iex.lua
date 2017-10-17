
-- interface extensions
-- warning: madness lies ahead.


-- f: original function
-- h: hook function, or table of hook functions
-- returns wrapped function
local function wrap(f, h, fallback)
    local newfunc
    -- FIXME: not sure. this part can be done nicer.
    --        if an interface function does not exist and we are wrapping it this way, the engine thinks it existed.
    --        i think if it does not exist, it makes no sense wrapping it...
    if not f then
        f = fallback
    end
    if type(h) == "function" then
        newfunc = function(...)
            h(...)
            return f(...) -- important: proper tail call here
        end
    elseif type(h) == "table" then
        newfunc = function(...)
            for _, x in pairs(h) do
                x(...)
            end
            return f(...) -- here too
        end
    else
        debugLog("IEX: wrap: improper hook")
        return false
    end
    return newfunc
end

local function cleanupFuncTable(ft)
    -- restore original functions if saved
    if ft._fg_orig then
        for i, f in pairs(ft._fg_orig) do
            ft[i] = f
        end
    else -- if not saved, save them.
        local t = {}
        for i, f in pairs(ft) do
            t[i] = f
        end
        ft._fg_orig = t
    end
end


--[[ table format:
{
    "name-of-hook" => { name = "name-of-interface-func", hook = hookFunc } }
    ...
}
]]

local entityhooks = rawget(_G, "_iex_entityhooks")

-- ".../scripts/rock.lua" => ft
local function applyEntityHooksTo(ft)

    cleanupFuncTable(ft)
    
    for i, h in pairs(entityhooks) do
        debugLog("... hook: " .. i .. " => ".. h.name)
        ft[h.name] = wrap(ft[h.name], h.hook, h.fallback)
    end
end

local function isNodeScript(s)
    -- could be done with string.match too
    local parts = s:explode("/", true)
    return parts[#parts]:startsWith("node_")
end

local function doHookScript(sc, functable)
    if isNodeScript(sc) then
        -- NYI
    else
        debugLog("IEX: hooking entity: " .. sc)
        applyEntityHooksTo(functable) -- at this point, we assume that all hooks
        debugLog("IEX: done.")
    end
end

-- this function must never raise an error, otherwise the program will crash
local function onCreateScript(tab, sc, functable)
    local ok, err = pcall(doHookScript, sc, functable)
    if not ok then
        debugLog("IEX: _scriptfuncs metatable ERROR: " .. err)
    end
    -- do the set, or it will crash
    rawset(tab, sc, functable)
end

local function beginEntityInterfaceHooks()
    debugLog("IEX: beginEntityInterfaceHooks() ...")
    entityhooks = {}
    rawset(_G, "_iex_entityhooks", entityhooks)
    debugLog("IEX: done.")
end

-- name for hook (arbitrary but unique), interface function name, hook function
local function enqueueEntityInterfaceHook(ident, fname, hook, fallback)
    entityhooks[ident] = { name = fname, hook = hook, fallback = fallback }
end

-- to be called everytime a map is loaded.
-- after calling this, using enqueueEntityInterfaceHook will have no immediate effect anymore
local function applyEntityInterfaceHooks()

    -- hook all that are created up to now
    debugLog("IEX: processing remaining hooks...")
    for i, tf in pairs(_scriptfuncs) do
        doHookScript(i, tf)
    end
    
    -- whenever a script is created, hook its interface immediately.
    debugLog("IEX: setting _scriptfuncs metatable...")
    setmetatable(_scriptfuncs, {
        __newindex = onCreateScript
    })
    
    debugLog("IEX: done.")
end


return {
    beginEntityInterfaceHooks = beginEntityInterfaceHooks,
    enqueueEntityInterfaceHook = enqueueEntityInterfaceHook,
    applyEntityInterfaceHooks = applyEntityInterfaceHooks,
}