
-- TEST only

v.p = 0
v.slices = 0
v.pt = 0
v.AngleX = 0
v.AngleY = 0
v.AngleZ = 0

local function createSlice(x, y, offs, eff)
    local slice = createEntity("3dmodel", "", x, y)
    -- ent, cmd, model, pointEntity, camDist, initScale
    entity_msg(slice, "load", "plane4", "fx_final", 400, 370)
    
    local totaltime = offs
    -- called in 3dmodel's update() function
    local function calcCoords(slice, dt)
        totaltime = totaltime + dt
        return 0, math.sin(totaltime * 0.75) * 3.5, 0
    end
    
    entity_msg(slice, "setfunc", calcCoords)
    
    for _, e in pairs(entity_msg(slice, "getents")) do
        entity_msg(e, "emit", eff)
    end
    
    return slice
end


function init(me)

    local x, y = node_getPosition(me)
    local w, h = node_getSize(me)
    local step = 80
    
    v.p = {}
    v.slices = {}
    --local cols = { "finalfx_r", "finalfx_g", "finalfx_b" }
    local cols = { "finalfx_g" }
    local t = 0
    local emit = 0
    for i = -h/2, h/2, step do
        createSlice(x, y + i, t, cols[(emit % #cols) + 1])
        t = t + 0.07
        emit = emit + 1
    end

end



function update(me, dt)

end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
