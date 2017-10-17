
v.sphere = 0
v.mia = 0
v.n = 0
v.barrier = 0
v.first = true

function init(me)
    
    v.n = getNaija()
    v.sphere = getEntity("evilsphere")
    v.mia = getEntity("mia")
    v.barrier = getNode("miabarrier")
    
end

function update(me, dt)
    
    if node_isEntityIn(me, v.sphere) then
        entity_msg(v.sphere, "targetmia")
        entity_msg(v.mia, "expr", "shock")
        node_activate(v.barrier)
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
