
v.above = true
v.emitT = -1

function init(me)
    setupEntity(me, "bottle")
    entity_scale(me, 0.2, 0.2)
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    entity_setWeight(me, 700)
    entity_initEmitter(me, 0, "bubblesmini")
    entity_setCull(me, false)
end

function postInit(me)
    entity_startEmitter(me, 0)
end

function update(me, dt)
    if v.above and entity_y(me) > getWaterLevel() then
        entity_clearVel(me)
        entity_setWeight(me, 50)
        v.above = false
        v.emitT = 3.5
        spawnParticleEffect("splash", entity_getPosition(me))
        playSfx("splish")
    end
    
    if v.emitT >= 0 then
        v.emitT = v.emitT - dt
        if v.emitT <= 0 then
            entity_stopEmitter(me, 0)
        end
    end
    entity_updateMovement(me, dt)
end


function hitSurface() end
function enterState() end
function exitState() end
function animationKey() end
function msg() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
