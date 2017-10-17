
function init(me)
    setupEntity(me, "particles/blackglow")
    entity_setEntityType(me, ET_NEUTRAL)
    esetv(me, EV_LOOKAT, 0)
    entity_setAllDamageTargets(me, false)
    entity_setCollideRadius(me, 0)
    entity_setInvincible(me, true)
end

function postInit(me)
end

function update(me)
end

function song(me, s)
end

function songNote(me, note)
end

function songNoteDone(me, note, tm)
end

function shiftWorlds(me, old, new)
end

function msg()
end

function enterState()
end

function exitState()
end

function damage()
    return false
end
