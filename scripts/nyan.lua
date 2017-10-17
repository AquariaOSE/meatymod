
v.delT = -1

function init(me)
    setupEntity(me)
    entity_initSkeletal(me, "nyan")
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_setCollideRadius(me, 0)
    entity_setCanLeaveWater(me, true)
    entity_setMaxSpeed(me, 500)
    local s = 0.5
    entity_scale(me, s, s)
    entity_initEmitter(me, 0, "nyan")
    entity_setCull(me, false)
    entity_setInvincible(me, true)
end

function postInit(me)
    entity_animate(me, "idle", -1)
    entity_addVel(me, 300, 0)
    entity_alpha(me, 0)
    entity_alpha(me, 1, 0.5)
    entity_startEmitter(me, 0)
    entity_offset(me, 0, -4)
    entity_offset(me, 0, 4, 0.25, -1, 1, 1)
end

local function destroy(me)
    entity_stopEmitter(me, 0)
    entity_alpha(me, 0.001, 0.2)
    v.delT = 5
end

local sin = math.sin

function update(me, dt)
    entity_updateMovement(me, dt)
    
    if v.delT >= 0 then
        v.delT = v.delT - dt
        if v.delT <= 0 then
            entity_delete(me)
        end
    end
end

function hitSurface(me)
    return destroy(me)
end

function msg() end
function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
