if not v then v = {} end

dofile("scripts/inc_flags.lua")

v.speed = 0
v.scale = 1
v.needinit = true
v.gear = 0


function init(me)
    
    local c = node_getContent(me)
    if c and c ~= "" then
        v.speed = tonumber(c)
    end
    v.scale = node_getAmount(me)
    v.gear = createEntity("geargeneric", "", node_getPosition(me))
    
    --entity_initSkeletal(v.gear, "gear", "gearbg") -- messes up rotation
    bone_setTexture(entity_getBoneByIdx(v.gear, 0), "gear/geardark")
    entity_switchLayer(v.gear, -3)
    
    if v.scale == 0 then
        local ns, _ = node_getSize(me) -- assume circle node
        v.scale = ns / (TILE_SIZE * 10.3) -- rough guess
        --debugLog("node size: " .. ns .. " - gear scale: " .. v.scale)
    end
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        
        if v.gear ~= 0 then -- may happen if the node was just placed in the editor
            entity_scale(v.gear, v.scale, v.scale)
            entity_msg(v.gear, "setdata", v.speed)
            
            entity_msg(v.gear, "bg")
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
