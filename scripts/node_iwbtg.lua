
-- 
v.n = 0
v.dir = false
v.spd = 0
v.cherry = 0
v.rot = 0
v.gfx = 0
v.insideOnly = false

local function spawn(me)
    v.cherry = createEntity("iwbtg_cherry", "", node_getPosition(me))
    entity_rotate(v.cherry, v.rot)
    -- HACK
    if v.gfx ~= "cherry" then
        entity_setTexture(v.cherry, "iwbtg/" .. v.gfx)
        entity_offset(v.cherry, 0, 0)
    end
end

function init(me)
    loadSound("cherry")
    local a = node_getName(me):explode(" ", true)
    v.gfx = a[2] or "cherry"
    v.rot = tonumber(a[3])
    v.dir = a[4]
    v.spd = tonumber(a[5] or 0) or 0
    
    v.n = getNaija()
    
    spawn(me)
    
    if v.spd == 0 then
        v.spd = 1000
    end
    
    -- Xi ? srip i, keep X
    if v.dir:sub(2, 2) == "i" then
        v.dir = v.dir:sub(1, 1)
        v.insideOnly = true
    end
end

local function go(x, y)
    local cx, cy = entity_getPosition(v.cherry)
    entity_setPosition(v.cherry, cx + (x * 99999), cy + (y * 99999), -v.spd)
    entity_playSfx(v.cherry, "cherry")
    v.cherry = 0
end


function update(me, dt)

    if v.cherry == 0 or not entity_isEntityInRange(v.cherry, v.n, 1000) then
        return
    end
    
    local w2, h2 = node_getSize(me)
    w2 = w2 / 2
    h2 = h2 / 2
    local x, y = node_getPosition(me)
    
    entity_setPosition(v.cherry, x, y)
    
    local l = x - w2
    local r = x + w2
    local u = y - h2
    local d = y + h2
    
    local dir = v.dir
    
    local nx, ny = entity_getPosition(v.n)
    local innode = node_isEntityIn(me, v.n)
    
    if dir == "u" then
        if (not v.insideOnly and nx >= l and nx <= r and ny <= d) or innode then
            go(0, -1)
        end
    elseif dir == "d" then
        if (not v.insideOnly and nx >= l and nx <= r and ny >= u) or innode then 
            go(0, 1)
        end
    elseif dir == "l" then
        if (not v.insideOnly and nx <= r and ny <= d and ny >= u) or innode then
            go(-1, 0)
        end
    elseif dir == "r" then
        if (not v.insideOnly and nx >= l and ny <= d and ny >= u) or innode then
            go(1, 0)
        end
    end
    
end

function damage(me)
    return false
end


function enterState(me)
end

function exitState()
end

function activate(me)
    spawn(me)
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
