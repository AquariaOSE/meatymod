
v.on = true

function init(me)
    setupEntity(me, "ingredients/legendary-cake")
    entity_setEntityType(me, ET_NEUTRAL)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 1)
    entity_initEmitter(me, 0, "glowbits")
    entity_setCollideRadius(me, 64)
    entity_setCanLeaveWater(me, true)
    --entity_scale(me, 0.5, 0.5)
    entity_setInvincible(me, true)
    
    esetv(me, EV_BEASTBURST, 0) -- allow pickup while beast form jump!
end

function postInit(me)
    entity_startEmitter(me, 0)
    entity_setPosition(me, entity_x(me), entity_y(me) + 5, 0.7, -1, 1, 1)
end

local function pickup(me)
    playSfx("naijayum")
    entity_alpha(me, 0, 0.2)
    v.on = false
    entity_setState(me, STATE_COLLECTED)
end

function update(me, dt)
    if v.on then
        if entity_touchAvatarDamage(me, entity_getCollideRadius(me)) then
            pickup(me)
        end
        entity_updateMovement(me, dt)
    end
end

function msg(me, s)
    if s == "reinit" then
        v.on = true
        entity_alpha(me, 1, 0.3)
        entity_setState(me, STATE_IDLE)
    end
end

function hitSurface() end
function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
