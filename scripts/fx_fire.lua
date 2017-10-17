
-- TEST only


function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)
    --entity_setTexture(me, "bigblaster/core")
    esetv(me, EV_LOOKAT, 0)
    entity_setAllDamageTargets(me, false)
    --entity_setUpdateCull(me, -1)

    entity_initEmitter(me, 0, "learntest")
    entity_alpha(me, 0.001)
    entity_setInvincible(me, true)
    entity_setCollideRadius(me, 0)
end

function postInit(me)
    entity_startEmitter(me, 0)
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
