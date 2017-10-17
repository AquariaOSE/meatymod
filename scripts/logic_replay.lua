
-- replay recording, management, and playback
-- the common signal that the map was won is that NEXT_MAP is not false

-- TODO: add "replay only" mode

local REPLAYS_PER_MAP = 50

local R = {}
local Replay = dofile("scripts/inc_replay.lua")

R.startnode = 0
R.currentReplay = false
R.winningReplay = false
R.replaying = false -- if in this state, mouse click will transition to NEXT_MAP
R.replays = false
R.puppets = false -- entites available for replaying (to avoid excessive entity creation)

R.ignoreInputDelay = 0

R.changingMap = false

local function createCamCorners()
    local q
    local ox, oy = getScreenVirtualOff()
    
    q = createQuad("camcorner") -- upper left
    quad_setPosition(q, 50 - ox, 50 - oy)
    quad_followCamera(q, 1)
    quad_setLayer(q, LR_HUD)
    
    q = createQuad("camcorner") -- upper right
    quad_setPosition(q, 750 + ox, 50 - oy)
    quad_followCamera(q, 1)
    quad_rotate(q, 90)
    quad_setLayer(q, LR_HUD)
    
    q = createQuad("camcorner") -- lower right
    quad_setPosition(q, 750 + ox, 550 + oy)
    quad_followCamera(q, 1)
    quad_rotate(q, 180)
    quad_setLayer(q, LR_HUD)
    
    q = createQuad("camcorner") -- lower left
    quad_setPosition(q, 50 - ox, 550 + oy)
    quad_followCamera(q, 1)
    quad_rotate(q, 270)
    quad_setLayer(q, LR_HUD)
end

-- called if replays are started from the menu
local function doMenuReplaysHack()

    R.currentReplay = false -- this is important, else it goes into stack overflow
    
    -- try to find a winning replay
    for i = 1, REPLAYS_PER_MAP do
        local r = R.replays[i]
        if r and r.won then
            R.winningReplay = r
            break
        end
    end
    -- if no winning one was found, choose any
    if not R.winningReplay then
        for i = 1, REPLAYS_PER_MAP do
            local r = R.replays[i]
            if r then
                R.winningReplay = r
                break
            end
        end
    end
    if not R.winningReplay then
        --- waaaah! wtf! emergency exit!
        debugLog("replays emergency exit, wtf")
        enableInput()
        R.changingMap = true
        loadMap(NEXT_MAP)
    end

    -- can't call wait/watch here otherwise it will ignore keypresses forever
    entity_alpha(v.n, 0)
    R.ignoreInputDelay = 1.5
end

local function loadReplays()
    debugLog("LoadReplays() ...")
    local m = getMapName()
    R.replays = {}
    local i = 0
    while i < REPLAYS_PER_MAP do
        i = i + 1
        local flag_replay = "replay_" .. m .. "_" .. i
        local s = getStringFlag(flag_replay)
        if s and s ~= "" then
            local rpl = Replay.new(s)
            if rpl then
                debugLog("Loaded " .. flag_replay)
                R.replays[i] = rpl
            else
                debugLog("Failed to load " .. flag_replay)
            end
        else
            debugLog("Nothing in " .. flag_replay)
        end
    end
    debugLog("Loaded " .. #R.replays .. " replays for map " .. m)
    
    -- pre-spawn entities, otherwise there is a lag phase when the replay view is started
    --for i = 1, #R.replays do
    for i = 1, REPLAYS_PER_MAP do -- less lag when recording next if all are preloaded
        local e = createEntity("naija2")
        entity_alpha(e, 0)
        table.insert(R.puppets, e)
    end
end


local function storeReplay(rpl)
    
    local m = getMapName()
    local flag_nextslot = "replay_" .. m .. "_nextslot"
    local slot = tonumber(getStringFlag(flag_nextslot)) or 1
    
    debugLog("Saving replay " .. slot)
    setStringFlag(flag_nextslot, tostring((slot % REPLAYS_PER_MAP) + 1))
    
    local s = rpl:save()
    local flag_replay = "replay_" .. m .. "_" .. slot
    setStringFlag(flag_replay, s)
    
    R.replays[slot] = rpl
    
    -- for later
    local e = createEntity("naija2")
    entity_alpha(e, 0)
    table.insert(R.puppets, e)
    
    debugLog("Done saving replay " .. slot)
    
    UNSAVED_PROGRESS = true
end

local function doReplays()
    PLAYTIME_STOP = false
    PLAYTIME = 0.001 -- HACK: playtime == 0 waits for left mouseclick
    local total = 0
    for i, rpl in pairs(R.replays) do
        local e = table.remove(R.puppets)
        if e then
            entity_alpha(e, 1, 0.2)
            if entity_isfh(e) then
                entity_fh(e)
            end
        else
            e = createEntity("naija2")
        end
        
        -- follow winning run
        if rpl == R.winningReplay then
            overrideZoom(0.3, 0.3)
            setCameraLerpDelay(0)
            cam_toEntity(e)
        end
        -- REPLAY FINISH callback function
        local f = function(r, won)
            local e = r.e
            entity_alpha(e, 0, 0.1)
            if won then
                spawnParticleEffect("spirit-big", entity_getPosition(e))
                --entity_playSfx(e, "spirit-beacon") -- does not go too well with positional audio... left it for now
            else
                -- TODO: what about lava particle effect? move to extra function or extend doDeathEffect() ?
                if CFG_GORE_LEVEL > 0 then
                    if entity_isUnderWater(e) then
                        spawnParticleEffect("replay_blood_uw", entity_getPosition(e))
                    else
                        spawnParticleEffect("replay_blood", entity_getPosition(e))
                    end
                end
            end
            -- this was set by the outer scope
            total = total - 1
            
            -- return entity so it can be reused
            table.insert(R.puppets, e)
            
            -- all runs done? Repeat.
            if total <= 0 then
                v.pushTQ(1.5, doReplays)
            end
        end
        rpl:initPlayback(e, f)
        total = total + 1
    end
    
    if not R.replaying then
        createCamCorners()
        setControlHint("Left click or hit Space for the next level.", true, false, false, 3)
    end
    
    R.replaying = true
    
    resetMap()
end

R.init = function()

    -- HACK: this is in node_finish.lua ... should be always false when entering a map,
    -- so we set this here too in case there is no finish node
    NEXT_MAP = false

    -- deactivate & unhook on "overworld" maps and the like
    if v.isSpecialMap() then
        v.logic.replay = nil
        return
    end
    
    --R.finishnode = getNode("finish")
    R.startnode = getNode("naijastart")
    if R.startnode == 0 then
        centerText("logic_replay: Error: No 'naijastart' node!")
    end
    
    R.puppets = {}
    loadReplays()
    
end


R.postInit = function()
    
    -- won't start recording the replay otherwise
    -- also this is to prevent spawning on the finish node when editing, which is annoying
    entity_setPosition(v.n, node_getPosition(R.startnode))
end

R.update = function(dt)

    v.updateTQ(dt)
    
    if not R.currentReplay and not NEXT_MAP then
        if node_isEntityIn(R.startnode, v.n) then
            R.currentReplay = Replay.new()
            debugLog("start recording replay")
        end
    end
    
    if R.currentReplay then
        R.currentReplay:recordFrame(dt)
        --debugLog("replay data: " .. #R.currentReplay.data)
        
        if NEXT_MAP then
            if isMapName(NEXT_MAP) then -- this hack is used by logic_ui.lua (same map name)
                doMenuReplaysHack()
            else
                -- really a new map.
                R.currentReplay:finish(true) -- yay, won
                R.winningReplay = R.currentReplay
                storeReplay(R.currentReplay)
            end
            R.currentReplay = false
            doReplays()
        end
    end
    
    if R.replaying then
        for _, rpl in pairs(R.replays) do
            disableInput()
            rpl:playback(dt)
        end
    end
    
    if R.ignoreInputDelay >= 0 then
        R.ignoreInputDelay = R.ignoreInputDelay - dt
    end
    
    if NEXT_MAP and not MENU_OPEN and MENU_OPEN_DELAY <= 0 and isLeftMouse() and not R.changingMap and R.ignoreInputDelay <= 0 then
        enableInput()
        R.changingMap = true
        loadMapTrans(NEXT_MAP)
    end
    
end

R.onDeath = function()
    if not R.currentReplay then
        return
    end
    
    R.currentReplay:finish(false) -- failed
    storeReplay(R.currentReplay)
    R.currentReplay = false
end



v.logic.replay = R
