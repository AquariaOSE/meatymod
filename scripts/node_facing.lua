
local LEFT = 0
local RIGHT = 1

v.needinit = true
v.ctr = 0
v.dir = LEFT

function init(me)
    local dir = node_getContent(me)
    if dir == "r" or dir == "right" then
        v.dir = RIGHT
    elseif dir == "l" or dir == "left" then
        v.dir = LEFT
    end
        
end

local function filterInside(e, me)
    return node_isEntityIn(me, e)
end

local function countAndFlip(e)
    v.ctr = v.ctr + 1
    if (not entity_isfh(e) and v.dir == RIGHT)
    or (entity_isfh(e) and v.dir == LEFT) then
        entity_fh(e)
    end
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        forAllEntities(countAndFlip, nil, filterInside, me)
        
        if v.ctr == 0 then
            centerText("WARNING: node_facing " .. node_getContent(me) .. " - no entity")
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
