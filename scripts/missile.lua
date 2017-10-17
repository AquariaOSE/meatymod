

local EXPLODE_SOUND = "pistolshrimp-fire"
local EXPLODE_SOUND2 = "mantis-bomb"
local SPLASH_RADIUS = 60
local MOVE_SPEED = 700

v.n = 0
v.exploded = false
v.shotT = 0.2

function init(me)
    setupEntity(me)
    entity_initSkeletal(me, "missile")
    esetv(me, EV_LOOKAT, 1)
    entity_setEntityType(me, ET_ENEMY)
    entity_setCanLeaveWater(me, true)
    entity_setDeathScene(me, true)
    --entity_initEmitter(me, 0, "fire")
    entity_initEmitter(me, 0, "fire_uw")
    entity_initEmitter(me, 1, "exhaust")
    entity_setCull(me, false)
    entity_generateCollisionMask(me)
    entity_setDeathSound(me, "")
    entity_scale(me, 0.6, 0.6)
end

local function adjustUnderWaterState(me)
    if entity_isUnderWater(me) then
        entity_startEmitter(me, 0)
        entity_stopEmitter(me, 1)
        entity_setMaxSpeed(me, 1500)
        entity_setWeight(me, 100)
    else
        entity_startEmitter(me, 1)
        entity_stopEmitter(me, 0)
        entity_setMaxSpeed(me, 2000)
        entity_setWeight(me, 250)
    end
end

function postInit(me)
    v.n = getNaija()
    entity_setTarget(me, v.n)
    
    if isObstructed(entity_getPosition(me)) then
        entity_damage(me, me, 999)
        return
    end
    
    adjustUnderWaterState(me)
end

local function explode(me)
    if not v.exploded then
        v.exploded = true
        entity_damage(me, me, 999)
    end
end

function update(me, dt)

    local bone = entity_collideSkeletalVsCircle(me, v.n)
    if bone ~= 0 then
        entity_hugeDamage(v.n)
        explode(me)
    end
    entity_moveTowardsTarget(me, dt * 2, MOVE_SPEED)
    entity_updateMovement(me, dt)
    entity_rotateToVel(me, dt)
    
    if v.shotT >= 0 then
        v.shotT = v.shotT - dt
        if v.shotT <= 0 then
            v.shotT = v.shotT + 0.05
            createShot("trigger", me)
        end
    end
    
    entity_handleShotCollisionsSkeletal(me)
    
    if entity_checkSplash(me) then
        adjustUnderWaterState(me)
    end
end

function damage(me, attacker, bone, damageType, dmg)
    -- prevent beast wake from eliminating missiles
    if damageType == DT_AVATAR_BITE then
        return false
    end
    explode(me)
    return true
end

function hitSurface(me)
    return explode(me)
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
    elseif entity_isState(me, STATE_DEATHSCENE) then
        if entity_isUnderWater(me) then
            spawnParticleEffect("missile-expl-uw", entity_getPosition(me))
        else
            spawnParticleEffect("missile-expl", entity_getPosition(me))
        end
        entity_playSfx(me,  EXPLODE_SOUND, nil, 1.1, nil, nil, 3000)
        entity_playSfx(me, EXPLODE_SOUND2, nil, 1.1, nil, nil, 3000)
        if entity_isEntityInRange(me, v.n, SPLASH_RADIUS) then
            entity_hugeDamage(v.n)
            shakeCamera(60, 0.7)
        else
            shakeCamera(8, 0.7)
        end
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
    explode(me)
    entity_hugeDamage(who)
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
