
v.density = 160
v.scale = 1.4

v.xmove = 0


local function spawn(me)
    local nx, ny = node_getPosition(me)
    local w, h = node_getSize(me)
    
    local xs = nx - w/2
    local xe = nx + w/2
    local ys = ny - h/2
    local ye = ny + h/2
    
    local random = math.random
    local xo = v.density / 4.5
    local yo = v.density / 8
    
    local function createTile(x, y)
        local e = createEntity("lavatile", "", x + random(-xo, xo), y + random(-yo, yo))
        local s = v.scale * (1 + (random(-60, 60) / 1000))
        entity_rotate(e, 270)
        entity_scale(e, s, s)
        return e
    end
    
    -- one backgrond row with slight offset
    for x = xs, xe, v.density do
        createTile(x, ys - 25)
    end
    
    -- not using for loops to have some variation
    local y = ys
    while y < ye do
        local x = xs
        while x < xe do
            local e = createTile(x, y)
            entity_switchLayer(e, 1) -- overlay
            x = x + v.density * (1 + (random(-100, 100) / 1000))
        end
        y = y + v.density * (1 + (random(-100, 100) / 1000))
    end

    if v.xmove ~= 0 then
        node_activate(v.xmove)
    end
end

function init(me)
    local c = tonumber(node_getContent(me)) or 0
    local s = node_getAmount(me)
    --v.xmove = node_getNearestNode(me, "xmove")
    if c > 0 then
        v.density = c
    end
    if s > 0 then
        v.scale = 1
    end
    
    spawn(me)
end
   
function update(me, dt)
end

function song()
end

function songNote()
end

function songNoteDone()
end

function activate(me)
    spawn(me)
end