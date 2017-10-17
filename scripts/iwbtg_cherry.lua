

v.n = 0

function init(me)
    setupEntity(me, "iwbtg/cherry", -3)
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    --entity_setCull(me, false)
    entity_setMaxSpeed(me, 6000)
    entity_setDeathSound(me, "")
    entity_setCollideRadius(me, 42)
    --entity_scale(me, 2, 2)
    entity_setInvincible(me, true)
end

function postInit(me)
    v.n = getNaija()
    entity_offset(me, -2, -2, 0.2, -1, 1)
end

function update(me, dt)
    if entity_touchAvatarDamage(me, entity_getCollideRadius(me)) then
        entity_hugeDamage(v.n)
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
        entity_delete(me, 0.1)
    elseif s == "noportal" then
        return true
    end
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
