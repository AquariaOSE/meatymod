
-- move <ang> <speed> <limitNode>

v.s = 0
v.ang = 0

v.needinit = true

v.ents = false -- [ent, flipDir]
v.nodes = false -- [_, node]

local function isMapObjectInMe(e, me)
    return isMapObject(e) and node_isEntityIn(me, e)
end

function init(me)
    v.ents = {}
    local a = node_getName(me):explode(" ", true)
    v.ang = tonumber(a[2]) or 0
    v.s = -(tonumber(a[3]) or 0)
    local limit = a[4]
    if not limit then
        return
    end
    v.nodes = {}
    forAllNodes(function(node) table.insert(v.nodes, node) end, nil,
                function(node) return node_getLabel(node) == limit end)
                
    if #v.nodes < 2 then
        errorLog(node_getName(me) .. "\n- only " .. #v.nodes .. " " .. limit .. " nodes present")
    end
end

local function registerEnt(e)
    v.ents[e] = false
end

local function go(e, flip)
    local x, y = entity_getPosition(e)
    local vx, vy = vector_fromDeg(v.ang, 9999)
    if flip then
        x = x - vx
        y = y - vy
    else
        x = x + vx
        y = y + vy
    end

    entity_setPosition(e, x, y, v.s)
end

local function reset(me)
    for ent, _ in pairs(v.ents) do
        v.ents[ent] = false
        go(ent)
    end
end
    
function update(me, dt)
    if v.needinit then
        v.needinit = false
        forAllEntities(registerEnt, nil, isMapObjectInMe, me)
        if next(v.ents) == nil then
            errorLog(node_getName(me) .. "\n- no entities")
        end
        reset(me)
    end
    
    if v.nodes then
        for ent, flip in pairs(v.ents) do
            for _, node in pairs(v.nodes) do
                if node_isEntityIn(node, ent) then
                    v.ents[ent] = not flip
                    go(ent, not flip)
                    break
                end
            end
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end

-- instead of "reinit" msg
function activate(me)
    reset(me)
end
