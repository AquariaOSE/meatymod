
local REPLAY_FORMAT_VERSION = 0

-- replay control opcodes
local RPL_TIME = 0
local RPL_POS = 1
local RPL_ROT = 2
local RPL_ANIM = 3
local RPL_WIN = 4
local RPL_FAIL = 5
local RPL_FH = 6
local RPL_NOFH = 7
local RPL_ANIM_EX = 8 -- any animation that is not on the default layer
local RPL_ROTOFFS = 9

-- Builtin -- defined in Avatar.cpp
local ANIMLAYER_FLOURISH = ANIMLAYER_FLOURISH
local ANIMLAYER_OVERRIDE = ANIMLAYER_OVERRIDE
local ANIMLAYER_ARMOVERRIDE = ANIMLAYER_ARMOVERRIDE -- left arm
local ANIMLAYER_UPPERBODYIDLE = ANIMLAYER_UPPERBODYIDLE


local CHECKED_ANIMLAYERS = { ANIMLAYER_FLOURISH, ANIMLAYER_OVERRIDE, ANIMLAYER_ARMOVERRIDE, ANIMLAYER_UPPERBODYIDLE }


local tins = table.insert
local pairs = pairs

local eanim = entity_getAnimationName
local epos = obj_getPosition
local erot = obj_getRotation
local erotoffs = obj_getRotationOffset
local eisfh = obj_isfh
local eisanim = entity_isAnimating

local esetpos = obj_setPosition
local esetrot = obj_rotate
local esetrotoffs = obj_rotateOffset
local esetanim = entity_animate
local estopanim = entity_stopAnimation
local efh = obj_fh


local R = {}

local meta = { __index = R }


R.new = function(s)
    local rpl = {
        -- current state
        r = 0,
        ro = 0,
        anim = "idle",
        animex = {},
        x = 0,
        y = 0,
        t = 0, -- total time
        app = true, -- if false, nothing has changed, and the last timestamp can be overridden
        done = false, -- if true, do not record or playback
        won = false,
        final = false, -- if true, do not record or modify
        fh = false,
        wasPosSet = false, -- true as soon as first position was assigned
        
        -- prev states -- plain array
        -- use this initial filling for up/downwards compatibility in case i need to change something
        data = { REPLAY_FORMAT_VERSION },
        
        -- playback
        e = 0,
        i = 2, -- read index
        
        -- callbacks
        onEnd = nil, -- function(rpl, won)

        
    }
    setmetatable(rpl, meta)
    
    if s then
        if not rpl:_load(s) then
            return nil
        end
    end
        
    return rpl
end

R._load = function(rpl, s)
    if rpl.final then
        return true -- nothing to do
    end
    rpl.data = serialize_restore(s)
    
    if rpl.data[1] ~= REPLAY_FORMAT_VERSION then
        debugLog(string.format("Unsupported replay format version (%s) for file: %s", tostring(rpl.data[1]), tostring(s)))
        return false
    end
    rpl.i = rpl.i + 1
    
    rpl.won = rpl.data[#rpl.data] == RPL_WIN
    rpl.final = true
    return true
end

R.save = function(rpl)
    -- the safe way... but has lots of garbage, especially when dumped to XML, and is really slow too
    --return serialize_save(rpl.data)
    
    -- alternative way:
    -- try to shrink that down a little,
    -- and possibly be faster
    local floor = math.floor
    local tins = table.insert
    local strfmt = string.format
    local tconcat = table.concat
    local tostring = tostring
    local type = type 
    
    --local strhelp = {"[[", "", "]]"} -- use [[ ]] as separators here, otherwise TinyXML will replace it by "&quot;" in the save file, which is bloat
    local d = rpl.data
    local t = {}
    local x, s
    
    for i = 1, #d do
        x = d[i]
        if type(x) == "number" then
            if x % 1 == 0 then -- check for plain integer. Could also use x == floor(x) but this is probably the fastest variant. (http://lua-users.org/lists/lua-l/2008-11/msg00130.html)
                tins(t, x) -- it's an integer, just dump. string conversion is done on concatenation.
            else
                tins(t, strfmt("%.2f", x)) -- strip most of the mantissa, no useful data and just bloats save size
            end
        else -- assume string
            --strhelp[2] = x
            --tins(t, tconcat(strhelp)) -- str -> "str" -- could use string.format() here or other things but this should be faster
            
            -- TESTED: about 4 times faster than table.concat() !! (Test done with Lua 5.2, but still)
            tins(t, "[[" .. x .. "]]")
        end
    end
    
    -- fix head and tail to form a valid expression when concatenated
    t[1] = "return { " .. t[1]
    t[#t] = t[#t] .. " }"
    
    return tconcat(t, ",")
end

R.recordFrame = function(rpl, dt)
    if rpl.final then
        return
    end
    
    rpl.t = rpl.t + dt
    local n = getNaija()
    
    local anim = eanim(n)
    local x, y = epos(n)
    local r = erot(n)
    local ro = erotoffs(n)
    local fh = eisfh(n)
    local d = rpl.data
    local a = false
    
    -- timestamp (always first entry per cycle)
    -- append a new one only if the prev. one isn't a timestamp entry,
    -- otherwise the data blob would grow unnecessarily.
    if rpl.app then
        tins(d, RPL_TIME)
        tins(d, rpl.t)
    else
        d[#d] = rpl.t
    end
    
    if rpl.r ~= r then
        rpl.r = r
        tins(d, RPL_ROT)
        tins(d, r)
        a = true
    end
    if rpl.ro ~= ro then
        rpl.ro = ro
        tins(d, RPL_ROTOFFS)
        tins(d, ro)
        a = true
    end
    if rpl.x ~= x or rpl.y ~= y then
        rpl.x = x
        rpl.y = y
        tins(d, RPL_POS)
        tins(d, x)
        tins(d, y)
        a = true
    end
    if rpl.anim ~= anim then
        rpl.anim = anim
        tins(d, RPL_ANIM)
        tins(d, anim)
        --debugLog("anim now: " .. anim)
        a = true
    end
    if rpl.fh ~= fh then
        rpl.fh = fh
        if fh then
            tins(d, RPL_FH)
        else
            tins(d, RPL_NOFH)
        end
        a = true
    end
    
    -- This can be left out if max. performance is required
    for _, layer in pairs(CHECKED_ANIMLAYERS) do
        if eisanim(n, layer) then
            local animex = eanim(n, layer)
            if animex ~= "idle" and rpl.animex[layer] ~= animex then
                rpl.animex[layer] = animex
                tins(d, RPL_ANIM_EX)
                tins(d, animex)
                tins(d, layer)
                a = true
                --debugLog(string.format("animlayer %d now: %s", layer, animex))
            end
        elseif rpl.animex[layer] ~= "" then
            rpl.animex[layer] = ""
            tins(d, RPL_ANIM_EX)
            tins(d, "")
            tins(d, layer)
            a = true
        end
    end
    
    rpl.app = a
end

-- must be called at end of recording
R.finish = function(rpl, won)
    if won then
        tins(rpl.data, RPL_WIN)
    else
        tins(rpl.data, RPL_FAIL)
    end
    rpl.won = won
    rpl.final = true
end

R.initPlayback = function(rpl, e, endfunc)
    rpl.e = e
    rpl.onEnd = endfunc
    
    rpl.t = 0
    rpl.r = 0
    rpl.ro = 0
    rpl.x = 0
    rpl.y = 0
    rpl.i = 2 -- 1 is version ID
    rpl.done = false
    rpl.anim = "idle"
    rpl.animex = {}
    rpl.wasPosSet = false
    
    entity_rotate(e, 0)
    entity_animate(e, "idle", -1)
end

-- very crude playback function
-- hopefully fast enough
-- TODO: interpolate rot & movement according to diff between last and next keyframe
R.playback = function(rpl, dt)
    if rpl.done then
        return
    end
    
    local cmd, t
    local d = rpl.data
    local i = rpl.i
    local e = rpl.e
    
    cmd = d[i]
    t = d[i+1]

    if cmd ~= RPL_TIME then
        errorLog("REPLAY ERROR: cycle init cmd: " .. cmd .. " at index " .. (i-2))
        rpl.done = true
        return
    end
    
    if t > rpl.t then
        -- timestamp is in future, nothing to do but to adjust time
        rpl.t = rpl.t + dt
        return
    else
        i=i+2
    end
    
    -- update state until timestamp is in future
    while true do
        cmd = d[i]      i=i+1
        if cmd == RPL_TIME then
            t = d[i]
            i=i+1
            
            -- In future? Rewind back, timestamp must be read again in next round
            if t > rpl.t then
                i=i-2
                break
            end
        elseif cmd == RPL_ROT then
            esetrot(e, d[i])
            i=i+1
        elseif cmd == RPL_POS then
            esetpos(e, d[i], d[i+1])
            i=i+2
            if not rpl.wasPosSet then
                rpl.wasPosSet = true
                entity_updateMovement(e, 0) -- dummy update - prevents entity_checkSplash() from overrecating because it resets the internal underwater state
            end
        elseif cmd == RPL_FH then
            if not eisfh(e) then
                efh(e)
            end
        elseif cmd == RPL_NOFH then
            if eisfh(e) then
                efh(e)
            end
        elseif cmd == RPL_ANIM then
            --debugLog("set anim: " .. d[i])
            esetanim(e, d[i], -1)
            i=i+1
        elseif cmd == RPL_ANIM_EX then
            local ani =  d[i]
            --debugLog("set anim ex(" .. ani .. "): " .. d[i+1])
            if ani ~= "" then
                esetanim(e, ani, 0, d[i+1])
            else
                estopanim(e, d[i+1])
            end
            i=i+2
        elseif cmd == RPL_ROTOFFS then
            esetrotoffs(e, d[i])
            i=i+1
        elseif cmd == RPL_WIN or cmd == RPL_FAIL then
            break
        else
            errorLog("REPLAY ERROR: opcode: " .. cmd)
        end
    end
    
    entity_checkSplash(e)
     
    -- finish
    rpl.i = i
    rpl.t = rpl.t + dt
    
    if cmd == RPL_WIN or cmd == RPL_FAIL then
        rpl.done = true
        if rpl.onEnd then
            rpl:onEnd(cmd == RPL_WIN)
        end
    end
    
end

return R
