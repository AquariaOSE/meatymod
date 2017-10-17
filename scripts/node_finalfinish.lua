
dofile("scripts/inc_mapsave.lua")

v.mia = 0
v.li = 0 -- "fake", the one that's on the map already
v.li2 = 0  -- "real" one, invisible at first
v.liIn = false
v.finalzone = 0
v.holdli = 0
v.n = 0
v.on = true
v.barrier = 0
v.sphere = 0

function init(me)
    v.mia = getEntity("mia")
    if v.mia == 0 then
        v.mia = createEntity("mia")
    end
    v.li = getEntity("li")
    if v.li == 0 then
        v.li = createEntity("li", "", node_getPosition(getNode("final_li"))) -- HACK in case this node gets inited first (see also node_final_li.lua)
    end
    if not entity_isfh(v.li) then
        entity_fh(v.li)
    end
    --entity_setState(v.li, STATE_PUPPET, -1, true)
    
    v.finalzone = getNode("finalzone")
    v.holdli = getNode("holdli")
    v.barrier = node_getNearestNode(me, "miabarrieroff")
    
    v.n = getNaija()
    
    v.li2 = createEntity("li")
    --entity_setState(v.li2, STATE_PUPPET, -1, true)
    entity_setName(v.li2, "li_real") -- rename to prevent node_final_li.lua from picking up this entity
    
    entity_alpha(v.mia, 0)
    entity_alpha(v.li2, 0)
    
    entity_msg(v.li2, "expr", "hurt")
    entity_setEntityType(v.mia, ET_ENEMY)
    entity_msg(v.mia, "damage", true)
    entity_setDamageTarget(v.mia, DT_AVATAR_ENERGYBLAST, true)
    entity_setDamageTarget(v.mia, DT_AVATAR_SHOCK, true)
    entity_setPosition(v.li2, node_getPosition(v.holdli))
    entity_setPosition(v.mia, node_getPosition(me))
    entity_animate(v.li2, "bent", -1)
    entity_animate(v.mia, "channel5", -1)
    
    entity_fh(v.mia)
    
    
    loadSound("mia-appear")
    loadSound("spirit-awaken")
    loadSound("13touch")
    loadSound("thunder")
    
    v.sphere = createEntity("3dmodel")
    entity_msg(v.sphere, "load", "sphere128", "fx_black", 400, 180)
end

-- copy-pasted from node_finish.lua...
local function updateMapTime()
    if PLAYTIME == 0 then
        return
    end
    
    local best = v.getSavedTime()
    if PLAYTIME < best or best == 0 then
        best = PLAYTIME
        debugLog("new map record: " .. best)
    end
    
    v.setSavedTime(nil, best)
end
------------------------------

local function prepareScene()
    entity_setInvincible(v.n, true)
    PLAYTIME_STOP = true
    updateMapTime()
end

local function createSphere()

    ---- done earlier to prevent lag
    --local sphere = createEntity("3dmodel")
    --entity_msg(sphere, "load", "sphere128", "fx_black", 400, 180)
    
    local sphere = v.sphere
    
    entity_setCull(sphere, false)
    
    local totaltime = 0
    -- called in 3dmodel's update() function
    local sin = math.sin
    local function calcCoords(sphere, dt)
        totaltime = totaltime + dt * 1.3
        local s = entity_getScale(sphere)
        return sin(totaltime * 1.1) * 2,
               sin(totaltime * 0.75) * 3.5,
               sin(totaltime * 0.2) * 6,
               s
    end
    
    entity_msg(sphere, "setfunc", calcCoords)
    
    local modelpoints = entity_msg(sphere, "getents")
    for _, e in pairs(modelpoints) do
        entity_alpha(e, 0)
        entity_alpha(e, 1, 2)
    end
    
    return sphere
end

local function scene(me)
    entity_stopInterpolating(v.li)
    if not entity_isfh(v.li) then
        entity_fh(v.li)
    end
    entity_idle(v.li)
    entity_msg(v.li, "expr", "laugh")
    node_activate(v.barrier)
    local x, y = node_getPosition(me)
    entity_setPosition(v.li, x, y, 1)
    wait(0.2)
    if not entity_isfh(v.li) then
        entity_fh(v.li)
    end
    wait(0.8)
    setMusicToPlay("inevitable")
    updateMusic()
    entity_animate(v.li, "holdup", -1)
    entity_alpha(v.li2, 1, 2)
    entity_playSfx(v.mia, "mia-appear")
    wait(1)
    setNaijaHeadTexture("shock", 3)
    emote(EMOTE_NAIJAUGH)
    wait(1)
    entity_alpha(v.li, 0, 3)
    entity_alpha(v.mia, 1, 2.3)
    wait(3)
    entity_color(v.li2, 0.001, 0, 0, 2)
    entity_initEmitter(v.li2, 0, "darkfocus")
    entity_startEmitter(v.li2, 0)
    wait(2)
    setNaijaHeadTexture("shock", 3)
    emote(EMOTE_NAIJAUGH)
    local sphere = createSphere()
    entity_setPosition(sphere, entity_getPosition(v.li2))
    entity_scale(sphere, 0.2, 0.2)
    entity_playSfx(sphere, "spirit-awaken")
    wait(0.3)
    entity_playSfx(sphere, "13touch")
    wait(0.7)
    entity_alpha(v.li2, 0, 3)
    wait(1.5)
    setNaijaHeadTexture("pain", 10)
    entity_stopEmitter(v.li2, 0)
    entity_scale(sphere, 0.85, 0.85, 3.5, 0, 0, 1)
    wait(3.5)
    entity_scale(sphere, 0.2, 0.2, 2, 0, 0, 1)
    wait(1.4)
    
    local q = createQuad("dark-full")
    quad_setPosition(q, entity_getPosition(sphere))
    quad_alpha(q, 0)
    quad_alpha(q, 1, 0.3)
    quad_scale(q, 0.1, 0.1)
    quad_scale(q, 30, 30, 2, 0, 0, 1)
    playSfx("thunder")
    wait(2)
    
    loadMap("final")
    --quad_alpha(q, 0, 7)
end
    
function update(me, dt)
    if v.on then
        if not v.liIn and node_isEntityIn(me, v.li) then
            v.liIn = true
        end
        if v.liIn and node_isEntityIn(v.finalzone, v.n) then
            v.on = false
            prepareScene()
            scene(me)
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
