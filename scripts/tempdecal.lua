
dofile("scripts/entities/brokenpiece.lua")

v.t = 30
v.uw = false

local function updateUWState(me)
    if v.uw then
        entity_setMaxSpeed(me, 500)
        entity_setWeight(me, 120)
        entity_addVel(me, entity_velx(me) * -0.8, entity_vely(me) * -0.8)
        entity_setBounce(me, 0)
    else
        entity_setMaxSpeed(me, 1000)
        entity_setWeight(me, 500)
        entity_setBounce(me, 0.5)
    end
end

local oldpostInit = postInit
function postInit(me)
    oldpostInit(me)
    v.uw = entity_isUnderWater(me)
    updateUWState(me)
end

local oldupdate = update
function update(me, dt)
    oldupdate(me, dt)
    
    local uw = entity_isUnderWater(me)
    if uw ~= v.uw then
        v.uw = uw
        spawnParticleEffect("drip-splish", entity_getPosition(me))
        entity_playSfx(me, "splish")
        updateUWState(me)
    end
    
    v.t = v.t - dt
    if v.t < 0 then
        entity_alpha(me, 0, 5)
        v.t = 5
        if entity_getAlpha(me) < 0.1 then
            entity_delete(me, 0.1)
        end
    end
end

function msg() end
