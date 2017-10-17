

v.n = 0
v.initx = 0
v.inity = 0
v.stop = 0
v.rotating = false
v.stopped = false

function init(me)
    setupEntity(me)
    entity_initSkeletal(me, "barrel")
    --entity_scale(me, 0.2, 0.2)
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    entity_setCull(me, false)
    entity_setMaxSpeed(me, 500)
    entity_animate(me, "idle", -1)
    entity_scale(me, 1.5, 1.5)
    entity_generateCollisionMask(me)
    entity_setInvincible(me, true)
    
    v.stop = getNode("barrelstop")
end

function postInit(me)
    v.n = getNaija()
    v.initx, v.inity = entity_getPosition(me)
    entity_rotate(me, 0)
end

local function startRotating(me)
    if v.rotating then
        return
    end
    v.rotating = true
    entity_rotate(me, 0)
    entity_rotate(me, 360, 9.5, -1)
    entity_setPosition(me, 99999, v.inity, -280)
end

local function stop(me)
    v.stopped = true
    entity_stopInterpolating(me)
    local r = entity_getRotation(me)
    if r < 180 then
        entity_rotate(me, 0, 2)
    else
        entity_rotate(me, 360, 2)
    end
end


function update(me, dt)

    -- TODO: collide vs other entities?
    local bone = entity_collideSkeletalVsCircle(me, v.n)
    if bone ~= 0 then
        if avatar_isLockable() and entity_setBoneLock(v.n, me, bone) then
            startRotating(me)
        end
    end
    
    if v.stopped then
        stop(me) -- smooth out
    end
    
    entity_handleShotCollisionsSkeletal(me)
    
    if node_isEntityIn(v.stop, me) then
        stop(me)
    end
    
end

function damage(me)
    return false
end


function enterState(me)
end

function exitState()
end


function msg(me, s)
    if s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
        entity_rotate(me, 0)
        v.stopped = false
        v.rotating = false
    end
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
