
-- this script is a mess. sorry for that :/

-- works in conjunction with node_miaendbrain.lua

dofile("scripts/inc_timerqueue.lua")

local STATE_FIRE = 1000
local STATE_MISSILE = 1001
local STATE_SAW = 1002
local STATE_SUCK = 1003
local STATE_MAX = 1003
------ below special ----
local STATE_ANGRY = 1004
local STATE_MIA = 1005
local STATE_FINAL = 1006
local STATE_REALMAX = 1006

local PRT_FIRE = 0
local PRT_MISSILE = 1
local PRT_SAW = 2
local PRT_SUCK = 3
local PRT_ANGRY = 4
local PRT_MIA = 5
local PRT_FINAL = 6
local PRT_MAX = 6

local SCALEOFFS_SPHERE = 0.8
local SCALEOFFS_GLOW = 1.8
local SCALEOFFS_SAW = 0.9
local PULSE_WIDTH = 1.25
local BASE_COLLIDE_RADIUS = 150
local SAW_EXTRA_COLLIDE_RADIUS = 50

local SCALE_MIN = 0.4
local SCALE_MAX = 2.0
local SCALE_PER_HIT = 0.11
local HP = 5

local FIGHT_ZOOM = 0.33

local FRICTION_NORMAL = 80
local FRICTION_END = 800
local FRICTION_SAW = 250
local FRICTION_ANGRY = 120

local ACCEL_NORMAL = 300
local ACCEL_ANGRY = 430
local ACCEL_SAW = 700

v.n = 0
v.mia = 0
v.key = 0
v.touchDelay = 1
v.model = 0
v.modelpoints = 0
v.glow = 0
v.health = HP
v.hits = 0
v.maxhealth = HP
v.lockedEnts = false -- table { entity => lockTime }
v.initx = 0
v.inity = 0
v.sawq = 0
v.haskey = true
v.zoom = FIGHT_ZOOM
v.friction = FRICTION_NORMAL
v.accel = ACCEL_NORMAL

local doMiaScene1, doMiaScene2, doMiaScene3, doMiaScene4 -- functions set at EOF


local function createSphere(me)
    local sphere = createEntity("3dmodel", "", entity_getPosition(me))
    entity_msg(sphere, "load", "sphere128", "fx_black", 300, 180)
    
    local totaltime = 0
    -- called in 3dmodel's update() function
    local sin = math.sin
    local function calcCoords(sphere, dt)
        totaltime = totaltime + dt
        local s = entity_getScale(sphere)
        return sin(totaltime * 1.1) * 2,
               sin(totaltime * 0.75) * 3.5,
               sin(totaltime * 0.2) * 6,
               s
    end
    
    entity_msg(sphere, "setfunc", calcCoords)
    
    entity_initEmitter(sphere, PRT_FIRE, "sparksfire")
    entity_initEmitter(sphere, PRT_MISSILE, "sparksmissile")
    entity_initEmitter(sphere, PRT_SAW, "sparkssaw")
    entity_initEmitter(sphere, PRT_SUCK, "sparkssuck")
    entity_initEmitter(sphere, PRT_ANGRY, "sparksred")
    entity_initEmitter(sphere, PRT_MIA, "sparksgreen")
    entity_initEmitter(sphere, PRT_FINAL, "sparkspurple")
    
    v.modelpoints = entity_msg(sphere, "getents")
    
    entity_setCull(sphere, false)
    
    v.model = sphere
end

local function setGlow(on)
    if on then
        quad_alpha(v.glow, 1, 1)
    else
        quad_alpha(v.glow, 0, 1)
    end
end

local function getHealthPerc()
    return v.health / v.maxhealth
end

local function getPulseTime(me)
    local p = getHealthPerc()
    return 0.2 + (p * 0.5)
end

local function getScaleForHealth(me)
    local p = getHealthPerc()
    local s = SCALE_MIN + (v.hits * SCALE_PER_HIT)
    if s > SCALE_MAX then
        s = SCALE_MAX
    end
    debugLog("healthperc " .. p .. " -- scale " .. s)
    return s
end

local function _setPulse(me, incr, t, scale)
    -- HACK
    if v.lockedEnts[v.n] then
        return
    end
    entity_scale(me, scale, scale)
    entity_scale(me, scale * incr, scale * incr, t, -1, 1, 1)
end

local function updateCollideRadius(me)
    local s = entity_getScale(me)
    local r = BASE_COLLIDE_RADIUS
    if entity_isState(me, STATE_SAW) then
        r = r + SAW_EXTRA_COLLIDE_RADIUS
    end
    --debugLog("coll radius: " .. s .. " x " .. r .. " -- " .. (s * r))
    entity_setCollideRadius(me, s * r)
end

local function doScale(me, s, overrideTime)
    local pt = overrideTime or getPulseTime()
    entity_scale(me, s, s, pt)
    quad_scale(v.sawq, s * SCALEOFFS_SAW, s * SCALEOFFS_SAW, pt)
    
    v.pushTQ(pt, function()
        _setPulse(me, PULSE_WIDTH, pt, s)
        updateCollideRadius(me)
    end)
end

local function updateScale(me)
    -- HACK
    if v.lockedEnts[v.n] then
        return
    end

    return doScale(me, getScaleForHealth(me))
end

local function reset(me)
    v.clearTQ()
    v.health = HP
    v.maxhealth = HP
    v.hits = 0
    v.lockedEnts = {}
    enableInput()
    v.touchDelay = 1
    entity_setPosition(me, v.initx, v.inity)
    entity_clearVel(me)
    updateScale(me)
    entity_setState(me, STATE_IDLE)
    entity_color(v.n, 1, 1, 1)
    v.haskey = true
    v.zoom = FIGHT_ZOOM
    entity_setTarget(me, v.n)
    entity_setPosition(v.key, 0, 0)
    v.friction = FRICTION_NORMAL
    -- HACK: because the mia script does not set this (because it breaks the finish node otherwise)
    entity_animate(v.mia, "channel4", -1)
    
    entity_color(v.mia, 1, 1, 1)
    entity_alpha(v.mia, 1)
    
    cam_toEntity(v.n)
    musicVolume(1, 1)
end

function init(me)
    setupEntity(me, "")
    esetv(me, EV_LOOKAT, 1)
    entity_setCanLeaveWater(me, true)
    entity_setMaxSpeed(me, 1000) -- FIXME
    entity_setDeathSound(me, "")
    entity_setCollideRadius(me, BASE_COLLIDE_RADIUS)
    entity_alpha(me, 0.001)
    entity_setEntityType(me, ET_ENEMY)
    
    entity_setBounceType(me, BOUNCE_REAL)
    
    entity_setHealth(me, 999) -- we handle this ourselves
    
    esetv(me, EV_LOOKAT, 1)
    esetv(me, EV_BEASTBURST, 0) -- collide with beast even if bursting
    
    loadSound("airship-boost")
    loadSound("pistolshrimp-fire")
    loadSound("mantis-bomb")
    loadSound("licage-shatter")
    loadSound("bass")
    
    setElementLayerVisible(2, false) -- chain fence
end

function postInit(me)
    v.n = getNaija()
    v.mia = getEntity("mia")
    entity_setTarget(me, v.n)
    
    v.initx, v.inity = entity_getPosition(me)
    
    v.glow = createQuad("softglow-add", 13)
    quad_setBlendType(v.glow, BLEND_ADD)
    quad_scale(v.glow, 1.8, 1.8)
    
    v.sawq = createQuad("sawblade")
    quad_rotate(v.sawq, -720, 1, -1)
    quad_alpha(v.sawq, 0)
    quad_setLayer(v.sawq, LR_ENTITIES)
    
    reset(me)  
    
    -- this sucks. The game manages its entities in a std::vector,
    -- and is iterating over that during the postInit() phase.
    -- If we create too many entities at once here, it will crash if
    -- the vector reallocates. So that needs to be delayed until
    -- the regular update loop starts.
    v.pushTQ(0, function()
        v.key = createEntity("key") -- in (0, 0)
        createSphere(me)
        updateScale(me)
        entity_setStateTime(me, 2)
    end)
end

local function onDamageByEntity(me, attacker)
    if attacker ~= 0 and not entity_isState(me, STATE_SUCK) and not entity_isState(me, STATE_IDLE) and not entity_isState(me, STATE_ANGRY) then
        local name = entity_getName(attacker)
        debugLog("onDamageByEntity " .. name)
        local hit = (name == "missile" and not entity_isState(me, STATE_MISSILE))
                 or (name == "lavaball" and not entity_isState(me, STATE_FIRE))
                 or (name == "sawshot" and not entity_isState(me, STATE_SAW))
        if hit then
            debugLog("really damaged by " .. name)
            v.hits = v.hits + 1
            v.health = v.health - 1
            if v.health < 0 then
                v.health = 0
            end
            updateScale(me)
            entity_setState(me, STATE_IDLE)
            fade2(0.8, 0, 1, 1, 1)
            fade2(0, 0.6, 1, 1, 1)
            entity_playSfx(me, "licage-shatter", nil, 1.65, nil, 1.8, 3000)
            shakeCamera(18, 1)
            v.pushTQ(1, emote, EMOTE_NAIJAEVILLAUGH)
            
            local vx, vy = entity_getVectorToEntity(attacker, me)
            vx, vy = vector_setLength(vx, vy, 500)
            entity_addVel(me, vx, vy)
            
            if v.health <= 0 and v.haskey then
                v.haskey = false
                entity_setPosition(v.key, entity_getPosition(me))
                entity_setState(me, STATE_ANGRY)
            end
            
            return true
        end
    end
    return false
end

local function handleTouch(e, me)
    if v.lockedEnts[e] then
        if entity_getAlpha(e) < 0.9 then
            v.lockedEnts[e] = nil
        end
        return
    end
    
    -- all shot entities and Mia are ET_AVATAR (that's the default if not set. fireball, sawshot, etc),
    -- except missiles. but these can take damage and will die.
    if entity_getAlpha(e) < 0.9 or entity_getEntityType(e) == ET_NEUTRAL then
        return
    end
    
    -- special for ending scene
    if entity_isState(me, STATE_MIA) and e == v.n then
        return
    end
    
    local name = entity_getName(e)
    debugLog("touched " .. name)
    if entity_isState(me, STATE_SAW) then
        onDamageByEntity(me, e)
        entity_hugeDamage(e)
    else
        if e == v.n then
            entity_setState(e, 12345)
            playSfx("naijalow2", nil, 1.3)
            avatar_fallOffWall()
            if entity_isState(me, STATE_FINAL) then
                v.lockedEnts[e] = 999
                -- will change map after this
                v.pushTQ(0, doMiaScene4, me)
            else
                setNaijaHeadTexture("pain", 2)
                v.hits = 0
                entity_color(v.n, 0, 0, 0, 1)
                doScale(me, SCALE_MIN, 1)
                v.health = v.maxhealth
                playSfx("energy", 0.6) -- lower pitch
                v.lockedEnts[e] = 1.5
            end
        elseif e == v.mia then
            v.lockedEnts[e] = 999 -- will not really be killed
            v.pushTQ(0, doMiaScene2, me)
        else
            -- HACK: sometimes attacker == 0 in damage(), but the collision was always registered here before.
            -- we switch to (invincible) STATE_IDLE right after, so triggering damage twice is no problem.
            if not onDamageByEntity(me, e) then
                v.lockedEnts[e] = 1.5
                debugLog("locked " .. name)
            end
        end
    end
end

local function updateChildren(me, dt)
    if v.model == 0 then
        return
    end
    local x, y = entity_getPosition(me)
    entity_setPosition(v.model, x, y)
    quad_setPosition(v.glow, x, y)
    quad_setPosition(v.sawq, x, y)
    local sx, sy = entity_getScale(me)
    entity_scale(v.model, sx * SCALEOFFS_SPHERE, sy * SCALEOFFS_SPHERE)
    quad_scale(v.glow, sx * SCALEOFFS_GLOW, sy * SCALEOFFS_GLOW)
    --quad_scale(v.sawq, sx * SCALEOFFS_SAW, sy * SCALEOFFS_SAW)
end

local function updateLocked(me, dt)
    local x, y = entity_getPosition(me)
    for e, tm in pairs(v.lockedEnts) do
        entity_setPosition(e, x, y)
        if tm <= 0 then
            debugLog("expiring " .. entity_getName(e))
            v.lockedEnts[e] = nil
            if e == v.n then
                v.touchDelay = 2 -- HACK: dunno wtf
                if entity_isState(me, STATE_FIRE) then
                    DEATH_EFFECT = "death-lava"
                end
            end
            entity_hugeDamage(e)
        else
            v.lockedEnts[e] = v.lockedEnts[e] - dt
            if e == v.n then
                disableInput()
                if entity_getAnimationName(e) ~= "energystruggle" then
                    entity_animate(e, "energystruggle", -1)
                end
            end
        end
    end
end

-- because entity_pullEntities() doesn't cut it
local function doSuck(me, dt)
    local range = 3000
    local strength = 1000 * dt
    local e = getFirstEntity()
    local getnext = getNextEntity
    local vx, vy
    
    while e ~= 0 do
        if e ~= me then
            vx, vy = entity_getVectorToEntity(e, me)
            if vector_getLength(vx, vy) < range then
                vx, vy = vector_setLength(vx, vy, strength)
                entity_addVel(e, vx, vy)
            end
        end
        e = getnext()
    end
end

local function isInSphere(e, me)
    return entity_isEntityInRange(e, me, entity_getCollideRadius(me) + entity_getCollideRadius(e))
end

function update(me, dt)

    v.updateTQ(dt)
    
    if entity_isState(me, STATE_SUCK) then
        doSuck(me, dt)
    --elseif entity_isState(me, STATE_ANGRY) then
    --    dt = dt * 1.33
    end
    
    entity_moveTowardsTarget(me, dt, v.accel)
    entity_updateMovement(me, dt)
    entity_doFriction(me, dt, v.friction)
    entity_doCollisionAvoidance(me, dt * 0.5, entity_getCollideRadius(me) / 20, 0.3) -- 20 is map square size, use a bit higher value here
    entity_doCollisionAvoidance(me, dt, entity_getCollideRadius(me) / 40, 0.7)

    if v.touchDelay >= 0 then
        v.touchDelay = v.touchDelay - dt
    --elseif entity_touchAvatarDamage(me, entity_getCollideRadius(me)) then
    --    handleTouch(me, v.n)
    else
        forAllEntities(handleTouch, me, isInSphere, me)
    end
    
    updateChildren(me, dt)
    
    updateLocked(me, dt)
    
    entity_handleShotCollisions(me)
    
    overrideZoom(v.zoom, 2)
end

function damage(me, attacker, bone, damageType, dmg)
    if attacker == v.n and (damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK) then
        v.hits = v.hits + 1
        updateScale(me)
    else
        onDamageByEntity(me, attacker)
    end

    return false
end

local function doEmitter(prt, on)
    if prt < 0 then
        return
    end
    if on then
        entity_startEmitter(v.model, prt)
        if prt == PRT_SAW then
            quad_alpha(v.sawq, 0.7, 0.1)
            --quad_enableMotionBlur(v.sawq)
        end
    else
        entity_stopEmitter(v.model, prt)
        if prt == PRT_SAW then
            --quad_disableMotionBlur(v.sawq)
            quad_alpha(v.sawq, 0, 0.1)
        end
    end
end

local function getEmitterForState(s)
    return s - 1000
end

local function getOut(me, vx, vy, extra)
    return vector_setLength(vx, vy, entity_getCollideRadius(me) + (extra or 0))
end

local function shootMissile(me)
    if entity_isState(me, STATE_MISSILE) then
        local x, y = entity_getPosition(me)
        local ex, ey = entity_getVectorToEntity(me, v.n)
        local mvx, mvy = entity_getVel(me)
        mvx, mvy = vector_setLength(mvx, mvy, 180)
        local vx, vy = vector_setLength(ex, ey, 180)
        local dirx = mvx + vx
        local diry = mvy + vy
        local outx, outy = getOut(me, ex, ey, 60)
        local m = createEntity("missile", "", x + outx, y + outy)
        entity_addVel(m, dirx, diry)
        entity_playSfx(me, "airship-boost", nil, 1.45, nil, 1.8, 3000)
        entity_rotateToVel(m, 1)
    end
end

local function shootLavaball(me)
    if entity_isState(me, STATE_FIRE) then
        local x, y = entity_getPosition(me)
        local ex, ey = math.random(300, 700), 0
        if chance(50) then ex = -ex end
        local mvx, mvy = entity_getVel(me)
        local L = math.random(100, 300)
        mvx, mvy = vector_setLength(mvx, mvy, L + 400)
        local vx, vy = vector_setLength(ex, ey, L)
        local dirx = mvx + vx
        local diry = mvy + vy
        if diry < 0 then
            diry = 0
        end
        diry = diry + 200
        local outx, outy = getOut(me, dirx, diry, 70)
        local m = createEntity("lavaball", "", x + outx, y + outy)
        
        entity_addVel(m, dirx, diry)
        entity_playSfx(me, "energyblastfire")
    end
end


-- all layers are in the order they appear in the game (higher over lower)
local function setVolcanoLayers(on)
    -- topmost parallax layer is brickwall
    setElementLayerVisible(14, on)
    setElementLayerVisible(13, on)
    -- here would be shadow layer, ignore
    setElementLayerVisible(11, on)
    setElementLayerVisible(10, on)
    setElementLayerVisible(9, on)
end

local function resetElementLayers()
    setElementLayerVisible(2, false) -- chain fence
    setElementLayerVisible(1, true) -- trellis
    setElementLayerVisible(0, true) -- city boiler bg
    setElementLayerVisible(15, false) -- brickwall
    setVolcanoLayers(false)
    -- below: volcano/lava
end

local function setupLayersForState(s)
    if s == STATE_FIRE then
        setElementLayerVisible(2, false) -- chain fence
        setElementLayerVisible(1, false) -- trellis
        setElementLayerVisible(0, false) -- city boiler bg
        setElementLayerVisible(15, false) -- brickwall
        setVolcanoLayers(true)
    elseif s == STATE_MISSILE then
        setElementLayerVisible(2, false) -- chain fence
        setElementLayerVisible(1, false) -- trellis
        setElementLayerVisible(0, true) -- city boiler bg
        setElementLayerVisible(15, false) -- brickwall
        setVolcanoLayers(false)
    elseif s == STATE_SAW then
        setElementLayerVisible(2, true) -- chain fence -- can see through, keep the other layers as they are
        setElementLayerVisible(1, false) -- trellis
    elseif s == STATE_SUCK then
        setElementLayerVisible(2, false) -- chain fence
        setElementLayerVisible(1, false) -- trellis
        setElementLayerVisible(0, false) -- city boiler bg
        setElementLayerVisible(15, true) -- brickwall
        setVolcanoLayers(false)
    elseif s == STATE_IDLE then
        setElementLayerVisible(2, false) -- chain fence -- can see through
        setElementLayerVisible(1, true) -- trellis -- keep rest as it is (can see through)
    else
        resetElementLayers()
    end
    
    fade(0, 0.3, 0, 0, 0)
end

local function updateLayersForState(s)
    fade(0, 0, 0, 0, 0)
    fade(0.7, 0.18, 0, 0, 0)
    v.pushTQ(0.18, setupLayersForState, s)
end

local function updatePhysicsForState(s)
    if s == STATE_SAW then
        v.accel = ACCEL_SAW
        v.friction = FRICTION_SAW
    elseif s == STATE_ANGRY then
        v.friction = FRICTION_ANGRY
        v.accel = ACCEL_ANGRY
    else
        v.accel = ACCEL_NORMAL
        if s >= 1000 and s <= STATE_MAX then -- prevent overriding end friction
            v.friction = FRICTION_NORMAL
        end
    end
end

function enterState(me)
    local s = entity_getState(me)
    doEmitter(getEmitterForState(s), true)
    updateLayersForState(s)
    updatePhysicsForState(s)
    
    if s == STATE_IDLE then
        entity_setStateTime(me, 3)
    elseif s == STATE_SAW then
        entity_setStateTime(me, 8)
    elseif s == STATE_FIRE then
        for i = 1, 8, 0.5 do
            v.pushTQ(i, shootLavaball, me)
        end
        entity_setStateTime(me, 10)
    elseif s == STATE_MISSILE then
        for i = 1, 5 do
            v.pushTQ(i, shootMissile, me)
        end
        entity_setStateTime(me, 10)
    elseif s == STATE_SUCK then
        entity_setStateTime(me, 6)
    elseif s == STATE_MIA then
        entity_setTarget(me, v.mia)
        doMiaScene1(me)
    elseif s == STATE_FINAL then
        entity_setTarget(me, v.n)
    end
    
    updateCollideRadius(me)
end

function exitState(me)
    local s = entity_getState(me)
    doEmitter(getEmitterForState(s), false)
    if s == STATE_IDLE then
        entity_setState(me, math.random(1000, STATE_MAX))
    elseif s >= 1000 and s <= STATE_MAX then
        entity_setState(me, STATE_IDLE)
    end
end

function msg(me, s)
    if s == "reinit" then
        reset(me)
    elseif s == "targetmia" then -- sent by node_miaendbrain
        if not (entity_isState(me, STATE_MIA) or entity_isState(me, STATE_FINAL)) then
            debugLog("target mia!")
            entity_setState(me, STATE_MIA)
        end
    elseif s == "noportal" then
        return true
    end
end

function hitSurface(me)
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end


-- triggered when the sphere crosses the miaendbrain node.
doMiaScene1 = function(me)
    debugLog("doMiaScene1 start")
    local mia = v.mia
    v.zoom = 0.68
    setCameraLerpDelay(0.3)
    cam_toEntity(me)
    entity_animate(mia, "channel6", -1)
    
    entity_setInvincible(v.n, true)
    
    setGameSpeed(0.6, 2)
    
    fadeOutMusic(5)
    
    disableInput()
    
    local vx, vy = entity_getVectorToEntity(me, mia)
    vx, vy = vector_setLength(vx, vy, 450)
    entity_clearVel(me)
    entity_addVel(me, vx, vy)
    
    debugLog("doMiaScene1 end")
end

-- triggered when the sphere locks in mia
doMiaScene2 = function(me)
    debugLog("doMiaScene2 start")
    local mia = v.mia
    local naijaend = getNode("naijaend")
    
    avatar_fallOffWall()
    
    if entity_x(v.n) > node_x(naijaend) then
        entity_swimToNode(v.n, naijaend)
    end
    
    v.friction = FRICTION_END
    setGameSpeed(1, 4)
    entity_animate(mia, "energystruggle", -1)
    v.pushTQ(1, doMiaScene3, me)
    
    debugLog("doMiaScene2 end")
end

-- triggered shortly after
doMiaScene3 = function(me)
    local mia = v.mia
    debugLog("doMiaScene3 start")
    
    entity_msg(mia, "expr", "pain")
    
    setCameraLerpDelay(0.4)
    cam_toEntity(v.n)
    
    emote(EMOTE_NAIJAUGH)
    entity_msg(mia, "expr", "pain")
    doScale(me, SCALE_MIN * 1.3, 0.8)
    entity_faceLeft(v.n)
    watch(0.5)
    if not isForm(FORM_NORMAL) then
        changeForm(FORM_NORMAL)
    end
    entity_clearVel(me) -- just in case
    entity_swimToPosition(v.n, entity_x(mia) + 185, entity_y(mia))
    while entity_isInterpolating(v.n) do
        watch(FRAME_TIME)
    end
    v.zoom = 1 
    watch(0.2)
    
    -- WTF. it sometimes ignores it ?!
    while entity_isfh(v.n) do
        entity_fh(v.n)
        debugLog("fh hack") -- FIXME
        watch(FRAME_TIME)
    end
    watch(0.5)
    playSfx("naijagasp")
    setNaijaHeadTexture("shock", 1.8)
    v.zoom = 1.1
    watch(2)
    entity_color(mia, 0, 0, 0, 1)
    doEmitter(PRT_MIA, false)
    
    entity_playSfx(me, "energy", 0.6) -- lower pitch
    watch(1)
    v.zoom = 1.2
    doScale(me, SCALE_MIN, 0.7)
    watch(0.5)

    setNaijaHeadTexture("shock", 1.8)
    entity_alpha(mia, 0, 0.3)
    watch(0.3)
    doScale(me, SCALE_MIN / 3, 0.4)
    watch(1)
    emote(EMOTE_NAIJAWOW)
    watch(2)
    setNaijaHeadTexture("smile", 1.5)
    watch(0.7)
    emote(EMOTE_NAIJAGIGGLE)
    watch(1.25)
    
    debugLog("setting final state")
    v.touchDelay = 1 -- MUST NOT catch naija before this function has exited, otherwise everything breaks
    entity_setState(me, STATE_FINAL)
    doScale(me, SCALE_MIN * 1.8, 0.4)
    watch(0.5)
    setNaijaHeadTexture("shock", 1.8)
    watch(0.3)
    emote(EMOTE_NAIJAUGH)
    
    v.friction = FRICTION_NORMAL
    local vx, vy = entity_getVectorToEntity(me, v.n)
    vx, vy = vector_setLength(vx, vy, 300)
    entity_clearVel(me)
    entity_addVel(me, vx, vy)
    
    disableInput()

    v.touchDelay = 0
    debugLog("doMiaScene3 end")
end

doMiaScene4 = function(me)
    debugLog("doMiaScene4 start")
    setNaijaHeadTexture("pain", 999)
    shakeCamera(5, 5)
    playSfx("bass")
    
    watch(3)
    fade3(0,0,1,1,1)
    fade3(1,0.1,1,1,1)
    playSfx("memory-flash")
    playSfx("naijazapped")
    watch(2)
    fade3(0,2.5,1,1,1)
    fade(1,0,0,0,0)
    
    watch(3.5)
    
    setOverrideMusic("mystery")
    updateMusic()
    
    watch(4.5)
    
    loadMap("outtroscene")

    debugLog("doMiaScene4 end")
end

