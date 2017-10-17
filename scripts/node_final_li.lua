
v.on = true
v.li = 0
v.liend = 0

v.inv = false


function init(me)
    v.n = getNaija()
    v.liend = getNode("liend")
    
    v.li = getEntity("li")
    if v.li == 0 then
        v.li = createEntity("li", "", node_getPosition(me))
    end
    if not entity_isfh(v.li) then
        entity_fh(v.li)
    end
    
    entity_setState(v.li, STATE_PUPPET, -1, true)
end
    
function update(me, dt)
    if v.on and node_isEntityIn(me, v.n) then
        v.on = false
        entity_msg(v.li, "expr", "surprise")
        fadeOutMusic(4)
        playSfx("naijasigh3")
        node_activate(node_getNearestNode(me, "miabarrieroff"))
        entity_heal(v.n, 99)
        entity_setInvincible(v.n, true)
        v.inv = true
        wait(1.5)
        
        entity_msg(v.li, "expr", "happy")
        entity_swimToNode(v.li, v.liend)
        wait(0.5)
        
        emote(EMOTE_NAIJALI)
    end
    
    if v.inv then
        entity_setInvincible(v.n, true)
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
