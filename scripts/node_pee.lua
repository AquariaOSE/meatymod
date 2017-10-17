
-- particle effect entity

function init(me)
    local pe = node_getContent(me)
    local layer = node_getAmount(me)
    local e = createEntity("empty", "", node_getPosition(me))
    entity_alpha(e, 0.001)
    entity_initEmitter(e, 0, pe)
    entity_startEmitter(e, 0)
    entity_switchLayer(e, layer)
    entity_setCull(e, false)
end

function update(me, dt)
end

function song()
end

function songNote()
end

function songNoteDone()
end
