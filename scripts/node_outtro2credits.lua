
-- blatant copy of node_scene_intro1.lua

dofile("scripts/inc_timerqueue.lua")

v.needinit = true
v.on = false
v.dummy = 0
v.pathidx = 0
v.campath = 0
v.targetx = 0
v.targety = 0
v.lastspeed = 300
v.lasttext = false
v.moving = false
v.campoints = 0

local function nodesort(a, b)
    return tonumber(node_getContent(a)) < tonumber(node_getContent(b))
end

local function buildCamPath(me)
    local path = node_getNearestNode(me, "campath")
    if path == 0 then
        errorLog("FAIL")
        return
    end
    v.campath = {}
    local x, y
    local i = 0
    while true do
        x, y = node_getPathPosition(path, i)
        i = i + 1
        if x == 0 and y == 0 then
            break
        end
        table.insert(v.campath, { x, y } )
    end
    debugLog("Found " .. #v.campath .. "cam nodes")
end

local function findCamPoints()
    v.campoints = {}
    for _, n in pairs(getAllNodes()) do
        if node_getLabel(n) == "campoint" then
            table.insert(v.campoints, n)
        end
    end
end

local function camReachedPoint()
    return entity_isPositionInRange(v.dummy, v.targetx, v.targety, 30)
end

local function nextNode(speed)
    if not speed then
        speed = v.lastspeed
    end
    debugLog("next node, speed: " .. speed) 
    v.pathidx = v.pathidx + 1
    local pos = v.campath[v.pathidx]
    if not pos then
        --errorLog("path end. " .. v.pathidx)
        return
    end
    local x, y = unpack(pos)
    entity_setPosition(v.dummy, x, y, -speed)
    v.targetx = x
    v.targety = y
    
    if speed ~= 0 then
        v.lastspeed = speed
    end
end

local function showText(file, y)
    if v.lasttext then
        obj_alphaMod(v.lasttext, 0.6) -- hackish because it's set back to 1
        obj_delete(v.lasttext, 1.5)
        v.lasttext = false
    end
    if not file then
        return
    end
    local txt = createQuad("text/" .. file)
    obj_scale(txt, 0.8, 0.8)
    obj_setPosition(txt, 400, y or 300)
    obj_followCamera(txt, 1)
    obj_alpha(txt, 0)
    obj_alpha(txt, 0.6, 1.5)
    obj_setLayer(txt, LR_HUD)
    v.lasttext = txt
end

local function startCam()
    debugLog("starting cam path")
    v.pathidx = 0
    nextNode(0)
    cam_toEntity(v.dummy)
    cam_snap()
    v.moving = true
end

local function setSpeed(s)
    v.lastspeed = s
end

local POINTEVENTS =
{
    hidetext = function()
        showText(false)
    end,
    
    normalcam = function()
        setCameraLerpDelay(0)
        --setCutscene(false)
    end,
    
    final = function()
        errorLog("campath reached final, should not happen!")
    end
}

local function addShowText(file, y)
    POINTEVENTS[file] = function() showText(file, y) end
end

addShowText("credits1")
addShowText("credits2")
addShowText("credits3")
addShowText("credits4")


local function onCamPointReached(pt)
    local f = POINTEVENTS[pt]
    if not f then
        errorLog("unk point event: " .. pt)
        return
    end
    f()
end

local function checkCamPoints()
    for i, n in pairs(v.campoints) do
        if node_isEntityIn(n, v.dummy) then
            v.campoints[i] = nil
            onCamPointReached(node_getContent(n))
            return
        end
    end
end
    
function init(me)
    v.n = getNaija()
    buildCamPath(me)
    findCamPoints(me)
    
    --node_setCursorActivation(me, true)
end


local function initScene()
    setCameraLerpDelay(0.5)
    startCam()

    --setCutscene(true, true)

end

function update(me, dt)

    v.updateTQ(dt)
    
    if v.needinit then
        v.needinit = false
        v.on = true
        v.dummy = createEntity("empty")
        -- DEBUG
        --entity_setTexture(v.dummy, "missingimage")
        --entity_alpha(v.dummy, 1)
        
        -- CAM START HERE --
        --initScene()
    end
    
    if not v.on then
        return
    end
    
    if v.moving then
        checkCamPoints()
        if camReachedPoint() then
            nextNode()
        end
        
        entity_setPosition(v.li, entity_x(v.dummy), entity_y(v.dummy), 0.5)
        
        if isInputEnabled() then
            disableInput()
        end
    end
    
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function activate(me)
    v.li = getEntity("li")
    if v.li == 0 then
        errorLog("LI NOT FOUND")
        return
    end
    initScene(me)
end

