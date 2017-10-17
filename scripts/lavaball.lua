

local EXPLODE_SOUND = "pistolshrimp-fire"
local EXPLODE_SOUND2 = "mantis-bomb"
local SPLASH_RADIUS = 60
local MOVE_SPEED = 700

v.n = 0
v.exploded = false
v.shotT = 0
v.life = 10

function init(me)
    setupEntity(me, "particles/lavaball")
    esetv(me, EV_LOOKAT, 1)
    entity_setCanLeaveWater(me, true)
    entity_setWeight(me, 1400) -- default - can still be overridden by node_lavaball.lua
    entity_initEmitter(me, 0, "lavaball-trail")
    --entity_setCull(me, false)
    entity_setMaxSpeed(me, 2000)
    entity_setDeathSound(me, "")
    entity_setCollideRadius(me, 35) -- 32
    entity_scale(me, 2, 2)
    
    entity_setCullRadius(me, 2200)
    entity_setInvincible(me, true)
end

function postInit(me)
    if isObstructed(entity_getPosition(me)) then
        entity_delete(me, 0.1)
        return
    end
    
    v.n = getNaija()
    --entity_setTarget(me, v.n)
    entity_startEmitter(me, 0)
end

-- slight opitimzation - avoid overusing particle effects if not visible
local function spawnPrt(me)
    -- TODO: use toWindowFromWorld(), and check for screen boundaries. might be better.
    if entity_isEntityInRange(me, v.n, 2500) then
        return spawnParticleEffect("lavaballexplode", entity_getPosition(me))
    end
end

function update(me, dt)

    entity_updateMovement(me, dt)
    entity_rotateToVel(me, dt)
    
    if v.shotT >= 0 then
        v.shotT = v.shotT - dt
        if v.shotT <= 0 then
            v.shotT = v.shotT + 0.05
            createShot("trigger", me)
        end
    end
    
    if entity_touchAvatarDamage(me, entity_getCollideRadius(me)) then
        spawnPrt(me)
        entity_playSfx(me, "sizzle")
        entity_hugeDamage(v.n)
        entity_setState(me, STATE_DEAD)
    end
    
    if entity_checkSplash(me) and entity_isUnderWater(me) then
        entity_playSfx(me, "sizzle")
        entity_setState(me, STATE_DEAD)
    end
    
    v.life = v.life - dt
    if v.life <= 0 then
        entity_delete(me, 0.1)
    end
end

function damage(me)
    return false
end

function hitSurface(me)
    entity_playSfx(me, "energyblasthit", nil, 1.3, nil, nil, 1500)
    entity_setState(me, STATE_DEAD)
    spawnPrt(me)
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
    elseif entity_isState(me, STATE_DEAD) then
        -- TODO: particle effect
    end
end

function exitState()
end

function msg(me, s)
    if s == "reinit" then
        entity_delete(me, 0.1)
    end
end

-- use the invisible helper shot to detect collision with other entities, and if so, explode
function shotHitEntity(me, who)
    entity_hugeDamage(who)
    entity_playSfx(me, "sizzle")
    spawnPrt(me)
    entity_setState(me, STATE_DEAD)
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
