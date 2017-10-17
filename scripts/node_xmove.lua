
-- xmove <ang> <speed>  (until next xmove node is hit)

v.s = 0
v.ang = 0

v.ents = false -- [_, ent]

local function registerEnt(e)
    table.insert(v.ents, e)
end

function init(me)
    v.ents = {}
    v.ang = tonumber(node_getContent(me)) or 0
    v.s = -node_getAmount(me)
    
    forAllEntities(registerEnt, nil, isMapObject)
    if next(v.ents) == nil then
        errorLog(node_getName(me) .. "\n- no entities")
    end
end

local function go(e)
    local x, y = entity_getPosition(e)
    local vx, vy = vector_fromDeg(v.ang, 99999)
    x = x + vx
    y = y + vy
    entity_setPosition(e, x, y, v.s)
end
    
function update(me, dt)
    for _, ent in pairs(v.ents) do
        if node_isEntityIn(me, ent) then
            go(ent)
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
