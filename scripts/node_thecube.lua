
-- TEST only

v.p = 0
v.pt = 0
v.AngleX = 0
v.AngleY = 0
v.AngleZ = 0


function init(me)

    --local cube = superfx.createCube(225, 12)

    ----- spiral
    --local cube = {}
    --for i = -30, 30 do
    --    table.insert(cube, { z = 200 * math.sin(i / 4), y = 200 * math.cos(i / 4), x = i * 13, s = 1} )
    --end
    
    local cube = superfx.loadModel("sphere128", 300)
    
    local used = superfx.initPoints(#cube)
    for _, p in pairs(used) do
        p.e = createEntity("fx_fire")
        p.alpha = 0.2
    end
    
    v.p = cube
    v.pt = used
    
    v.ox, v.oy = node_getPosition(me)
end

local function drawPoints(me, thr)
    local nx, ny = node_getPosition(me)
    thr = -2 * thr

    for i, pt in pairs(v.pt) do
        entity_setPosition(pt.e, pt[1] + nx, pt[2] + ny)
        entity_scale(pt.e, pt[4], pt[4])
        
        if pt[3] > thr then
            entity_alpha(pt.e, pt.alpha)
        
            if pt[3] > 0 and pt.f then
                pt.f = false
                entity_switchLayer(pt.e, -3)
            elseif pt[3] <= 0 and not pt.f then
                pt.f = true
                entity_switchLayer(pt.e, 1)
            end
            
        else
            entity_alpha(pt.e, 0)
        end

    end
end

local P2 = 2 * 3.1415926


function update(me, dt)

    v.AngleX = v.AngleX + dt * 0.7
    v.AngleY = v.AngleY + dt 
    v.AngleZ = v.AngleZ + dt * 1.5
    
    if v.AngleX > P2 then v.AngleX = v.AngleX - P2 end
    if v.AngleY > P2 then v.AngleY = v.AngleY - P2 end
    if v.AngleZ > P2 then v.AngleZ = v.AngleZ - P2 end
    
    local camz = 400 / getZoom()
    
    superfx.transform(v.p, v.pt, v.AngleX, v.AngleY, v.AngleZ, camz)
    --superfx.scale(v.pt, 1 + math.sin(v.AngleX / 4))
    
    --superfx.scaleXYZ(v.pt, 1 + math.sin(v.AngleZ) / 2, 1 + math.cos(v.AngleX) / 2, 1 + math.cos(v.AngleY) / 2)
    
    drawPoints(me, camz)
    
    --node_setPosition(me, v.ox + 500 * math.sin(v.a), v.oy)

end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
