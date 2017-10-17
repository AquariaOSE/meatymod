
-- point cloud holder entity
-- controlled via messages

v.on = false
v.p = false -- original point cloud
v.pt = false -- transformed point cloud
v.camDist = 400
v.AngleX = 0
v.AngleY = 0
v.AngleZ = 0
v.ents = false -- entity list

v._update = false -- function, set in msg()

function init(me)
    setupEntity(me)
    --entity_alpha(me, 0.001)
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    entity_setEntityType(me, ET_NEUTRAL)
    entity_alpha(me, 0.001)
    entity_setInvincible(me, true)
end

function postInit(me)
end


local function loadFunc(func, entName, camDistance)
    if not entName or type(func) ~= "function" then
        errorLog("3dmodel.lua: loadFunc() wrong params")
        return
    end
    
    debugLog("loadFunc... ")
    
    if camDistance then
        v.camDist = camDistance
    end
    
    local points = func()
    if type(points) ~= "table" then
        errorLog("3dmodel.lua: loadFunc(): need table, got " .. type(points))
        return
    end
    
    v.ents = {}
    
    local used = superfx.initPoints(#points)
    for _, p in pairs(used) do
        p.e = createEntity(entName)
        table.insert(v.ents, p.e)
    end
    
    v.p = points
    v.pt = used
end

local function loadModel(file, entName, camDistance, initScale)
    if not entName or not file then
        errorLog("3dmodel.lua: loadModel() missing params")
        return
    end
    
    debugLog("loadModel " .. file)
    
    if camDistance then
        v.camDist = camDistance
    end
    
    local points = superfx.loadModel(file, initScale)
    v.ents = {}
    
    local used = superfx.initPoints(#points)
    for _, p in pairs(used) do
        p.e = createEntity(entName)
        table.insert(v.ents, p.e)
    end
    
    v.p = points
    v.pt = used
end

local function drawPoints(me, thr)
    local nx, ny = entity_getPosition(me)
    thr = -2 * thr

    for i, pt in pairs(v.pt) do
        entity_setPosition(pt.e, pt[1] + nx, pt[2] + ny)
        entity_scale(pt.e, pt[4], pt[4])
        
        if pt[3] > thr then
            entity_alphaMod(pt.e, 1)
        
            if pt[3] > 0 and pt.f then
                pt.f = false
                entity_switchLayer(pt.e, -3)
            elseif pt[3] <= 0 and not pt.f then
                pt.f = true
                entity_switchLayer(pt.e, 1)
            end
            
        else
            entity_alphaMod(pt.e, 0)
        end

    end
end

function update(me, dt)
    if not (v._update and v.pt) then
        return
    end
    
    local ax, ay, az, sx, sy, sz = v._update(me, dt)
    
    local camz = v.camDist / getZoom()
    
    superfx.transform(v.p, v.pt, ax, ay, az, camz)
    if sx then
        if sy then
            superfx.scaleXYZ(v.pt, sx, sy, sz)
        else
            superfx.scale(v.pt, sx)
        end
    end
    
    drawPoints(me, camz)
end

function msg(me, s, x, ...)
    if s == "load" then
        loadModel(x, ...)
    elseif s == "setfunc" then
        v._update = x
    elseif s == "getents" then
        return v.ents
    elseif s == "loadfunc" then
        loadFunc(x, ...)
    end
end

function enterState(me)
end

function exitState(me)
end

function song()
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
