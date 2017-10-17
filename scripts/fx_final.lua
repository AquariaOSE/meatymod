
-- TEST only


function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)
    esetv(me, EV_LOOKAT, 0)
    entity_setAllDamageTargets(me, false)
    entity_alpha(me, 0.001)
    entity_setInvincible(me, true)
    entity_setCollideRadius(me, 0)
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

function msg(me, s, x)
    if s == "emit" then
        entity_initEmitter(me, 0, x)
        entity_startEmitter(me, 0)
    end
end

function enterState()
end

function exitState()
end
