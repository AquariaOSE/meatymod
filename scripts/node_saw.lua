

function init(me)
    
    local r = node_getAmount(me) -- [2]
    local c = node_getContent(me) -- [3]
    local a = node_getName(me):explode(" ", true)
    local special = a[4]
    
    local e = createEntity("saw", "", node_getPosition(me))
    
    if special then
        entity_msg(e, "special", special)
    end
    
    
    local sx, _ = node_getSize(me)
    entity_msg(e, "sz", sx)
    
    if r == 0 then
        r = c
    else
        entity_msg(e, "layer", c)
    end
    entity_msg(e, "rot", tonumber(r) or 0)
end

function update(me, dt)
end

function song()
end

function songNote()
end

function songNoteDone()
end
