
dofile("scripts/inc_timerqueue.lua")
dofile("scripts/inc_flags.lua")

local BG = 0
local FG = 1
local OVER = 2

v.n = 0
v.sleep = 0
v.qs = 0
v.rot = 0
v.lr = BG
v.maxq = 12
v.sz = 0
v.halfsz = 0
v.initx = 0
v.inity = 0
v.lava = false

-- save some symbols for speed
local isMapObject = isMapObject
local entity_isState = entity_isState
local entity_getVectorToEntity = entity_getVectorToEntity
local vector_getLength = vector_getLength
local entity_getCollideRadius = entity_getCollideRadius
local entity_isEntityInRange = entity_isEntityInRange

local function isEntityIn(me, e) -- no longer used.
    local dx, dy = entity_getVectorToEntity(me, e)
    local d = vector_getLength(dx, dy)
    --return d <= v.sz * 0.5
    return d < v.halfsz
end

local function calcScale()
    local s = (1/500) * v.sz
    if v.lava then
        s = s * 1.1 -- HACK: because the image is a bit smaller -.-
    end
    return s
end

local function updateScale(obj)
    local s = calcScale()
    obj_scale(obj, s, s)
end

local function updateLayer(obj)
    -- this is kinda broken but i won't change it anymore.
    -- Can still use a switchlayer node if exact layer selection is needed.
    if v.lr == BG then
        obj_setLayer(obj, LR_ENTITIES_MINUS3)
    elseif v.lr == FG then
        -- default looks ok
    elseif v.lr == OVER then
        obj_setLayer(obj, LR_ENTITIES2)
    end
end

local function updateRot(obj)
    if v.rot > 0 then
        obj_rotate(obj, 360, 360/v.rot, -1)
    elseif v.rot < 0 then
        obj_rotate(obj, 360)
        obj_rotate(obj, 0, -360/v.rot, -1)
    end
end

local function makeq(me, tex)

    local q = createQuad(tex)

    updateRot(q)
    updateLayer(q)
    
    local s = calcScale(me)
    quad_scale(q, s, s)
    quad_setPosition(q, entity_getPosition(me))
    
    table.insert(v.qs, q)
    return q
end

local function addBlood(me)

    if CFG_GORE_LEVEL <= 0 then
        return
    end
    
    if v.lava then
        return
    end

    if #v.qs > v.maxq then
        return
    end
    
    makeq(me, "sawbladeblood1")
    
    local q = makeq(me, "sawbladeblood2")
    
    -- FIXME: adjust rotation to not cover sawtooth gaps ??
    --quad_rotateOffset(q, 360 - quad_getRotation(v.qs[1])) --- hmm ??
    
end

function init(me)
    setupEntity(me, "sawblade")
    entity_setEntityType(me, ET_NEUTRAL)
    
    entity_setMaxSpeed(me, 2000)
    entity_setCanLeaveWater(me, true)
    entity_setInvincible(me, true)
    
    v.qs = {}
end

function postInit(me)
    v.n = getNaija()
    updateLayer(me)
    
    v.initx, v.inity = entity_getPosition(me)
end

local function tryDamage(e, me)
    if   not entity_isInvincible(e)
         --and isEntityIn(me, e) -- probably not as fast as the line below
         and entity_isEntityInRange(e, me, entity_getCollideRadius(e) + v.halfsz)
         and not entity_isState(e, STATE_DEATHSCENE)
         and not isMapObject(e)
    then
        if e == v.n and NEXT_MAP and NEXT_MAP ~= "" then
            -- skip (although i think this hack is no longer needed)
        else
            if entity_hugeDamage(e, me) then
                if CFG_GORE_LEVEL > 0 then
                    entity_playSfx(e, "squishy-die")
                    if v.lava then
                        entity_playSfx(e, "sizzle")
                        spawnParticleEffect("smoke-tmp", entity_getPosition(e))
                    end
                end
                
                if e == v.n then
                    v.sleep = DEATH_IDLE_TIME
                    addBlood(me)
                end
                
                debugLog("saw -- " .. entity_getName(e))
            end
        end
    end
end

function update(me, dt)
    v.updateTQ(dt)
    if v.sleep >= 0 then
        v.sleep = v.sleep - dt
    end
    
    if v.sleep <= 0 then
        forAllEntities(tryDamage, me)
    end
    
    local x, y = entity_getPosition(me)
    for _, q in pairs(v.qs) do
        quad_setPosition(q, x, y)
    end
    
    entity_handleShotCollisions(me)
end

function msg(me, s, x)
    if s == "noportal" then
        return true
    elseif s == "rot" then
        v.rot = x
        updateRot(me)
        for _, q in pairs(v.qs) do
            updateRot(q)
        end
    elseif s == "layer" then
        if x == "fg" then
            v.lr = FG
        elseif x == "bg" then
            v.lr = BG
        elseif x == "over" then
            v.lr = OVER
        end
        updateLayer(me)
        for _, q in pairs(v.qs) do
            updateLayer(q)
        end
    elseif s == "sz" then
        v.sz = x
        v.halfsz = x * 0.5
        entity_setCollideRadius(me, v.halfsz)
        updateScale(me)
        for _, q in pairs(v.qs) do
            updateScale(q)
        end
    elseif s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
    elseif s == "special" then
        if x == "lava" then
            entity_setTexture(me, "sawblade-lava")
            v.lava = true
            updateScale(me)
        end
    end
end

function hitSurface(me)
    errorLog("OOPS: (stationary) saw hitsurface should never be called")
end

function damage(me, attacker, bone, damageType, dmg)
    return false
end

function song()
end

function songNote()
end

function songNoteDone()
end

function enterState(me)
end

function exitState(me)
end
