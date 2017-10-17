
dofile("scripts/inc_timerqueue.lua")

v.needinit = false -- set via activate()
v.on = false
v.turtle = 0
v.chair = 0
v.delayT = 5
v.dummy = 0
v.doDrink = false
v.doEat = false
v.animT = -1
v.mouthT = -1
v.bottle = 0 -- front hand
v.shroom = 0 -- front hand
v.shroom2 = 0 -- back hand
v.incut = false
v.overlay = 0
v.lasttext = false
v.dozoom = true
v.dosnap = false


function activate(me)
    v.needinit = true
    setStringFlag("seen_intro", "1") -- for node_versioncheck.lua
    debugLog("scene_intro2 activated")
end

function init(me)
    v.n = getNaija()
    v.turtle = node_getNearestEntity(me, "transturtle")
    v.chair = entity_getBoneByIdx(v.turtle, 13)
    v.bottle = entity_getBoneByIdx(v.n, 15)
    v.shroom = entity_getBoneByIdx(v.n, 19)
    v.shroom2 = entity_getBoneByIdx(v.n, 18)
    bone_setVisible(v.shroom, true)
    bone_setVisible(v.shroom2, true)
    loadSound("bass")
end

local function waitForAnim()
    while v.animT > 0 do
        watch(FRAME_TIME)
    end
end

local function drink(w)
    debugLog("drink")
    v.doDrink = true
    v.animT = 1 -- HACK
    if w then waitForAnim() end
end

local function eat(w, expr, exprT)
    debugLog("eat")
    v.animT = 1 -- HACK
    v.doEat = true
    v.pushTQ(3.3, function() bone_alpha(v.shroom2, 1, 0.5) end)
    v.pushTQ(4.6, function() bone_alpha(v.shroom2, 0, 0.1) bone_alpha(v.shroom, 1, 0.1) end)
    v.pushTQ(7.26, function() bone_alpha(v.shroom, 0, 0.5) end)
    if expr then
        v.pushTQ(0.5, function() setNaijaHeadTexture(expr, exprT or 5) end)
    end
    if w then waitForAnim() end
end

local function dropBottle()
    local e = createEntity("bottle", "", bone_getWorldPosition(v.bottle))
    entity_rotate(e, bone_getWorldRotation(v.bottle))
    bone_alpha(v.bottle, 0)
    return e
end

local function createOverlay()
    local q = createQuad("particles/tripper")
    quad_alpha(q, 0)
    quad_scale(q, 2.5, 2.5)
    quad_scale(q, 3.5, 3.5, 3, -1, 1, 1)
    quad_rotate(q, 360, 5, -1)
    quad_followCamera(q, 1)
    quad_setPosition(q, 400, 300)
    v.overlay = q
end

local function adjustOverlay(a, r, g, b, t)
    if not t then t = 2 end
    if a then
        quad_alpha(v.overlay, a, t)
    end
    if r and g and b then
        quad_color(v.overlay, r, g, b, t)
    end
end

local function showText(file, y)
    if v.lasttext then
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
    obj_alpha(txt, 1, 1.5)
    obj_setLayer(txt, LR_HUD)
    v.lasttext = txt
end

local function scene()
    setCutscene(true, true)
    --overrideZoom(1.4, 4)
    setCameraLerpDelay(0.5)
    createOverlay()
    cam_toEntity(v.n)
    
    drink(true)
    watch(4)
    showText("intro4")
    drink(true)
    drink(true)
    
    -- let bottle fall
    dropBottle()
    watch(0.8)
    setNaijaHeadTexture("pain", 1.5)
    emote(EMOTE_NAIJASADSIGH)
    watch(2.5)
    
    showText(false)
    setCameraLerpDelay(0)
 
    
    local a = 0.25
    local c = 1
    
    v.pushTQ(6.4, function() playSfx("naijaew2") setNaijaHeadTexture("singing", 0.4) end)
    eat(true)

    adjustOverlay(a, 1, c, c, 5)
    emote(EMOTE_NAIJAGIGGLE)
    watch(1.5)
    
    a = a + 0.3
    c = c - 0.3
    eat(true, "smile")
    adjustOverlay(a, 1, c, c, 4)
    emote(EMOTE_NAIJALAUGH)
    watch(0.8)
    
    a = a + 0.4
    eat(true, "singing", 3)
    adjustOverlay(a, 1, c, c, 3)
    playSfx("naijasigh3")
    
    -- happy
    setMusicToPlay("overworld")
    updateMusic()
    musicVolume(1.7, 2)
    
    showText("intro5")
    setNaijaHeadTexture("smile2", 99)
    watch(0.5)
    setNaijaHeadTexture("smile2", 99) -- just in case
    
    local i = 0
    while true do
        i = i + 1
        local node = getNode("nyan" .. i)
        if node == 0 then
            break
        end
        createEntity("nyan", "", node_getPosition(node))
    end
    
    watch(4)
    
    -- happy (green)
    adjustOverlay(a, 0.1, 1, 0.2, 1.5)
    emote(EMOTE_NAIJAGIGGLE)
    watch(2.5)
    
    -- happy (blue)
    adjustOverlay(a, 0.4, 0.4, 1, 1.5)
    emote(EMOTE_NAIJALAUGH)
    watch(2)
    
    showText(false)
    
    -- happy (yellow/orange)
    adjustOverlay(a, 1, 0.65, 0.1, 1.5)
    emote(EMOTE_NAIJAGIGGLE)
    watch(2.5)
    
    
    -- oops (purple)
    adjustOverlay(a, 1, 0.2, 0.9, 1.5)
    playSfx("naijaugh4")
    setNaijaHeadTexture("pain", 99)
    watch(3.5)
    
    musicVolume(1, 1)

    
    --setCutscene(false)
    
    v.dozoom = false
    v.dosnap = true
    
    -- baaaad (red)
    adjustOverlay(a, 1, 0, 0, 1.2)
    watch(0.5)
    setMusicToPlay("nyan_echo")
    updateMusic()
    setNaijaHeadTexture("shock", 2.5)
    local sfx = playSfx("bass")   
    --musicVolume(1, 2)
    watch(0.3)
    playSfx("naijaugh3", nil, 2)
    shakeCamera(3, 5)
    watch(0.15)
    overrideZoom(8, 1.2)
    fade2(0, 0, 0, 0, 0)
    fade2(1, 1, 0, 0, 0)
    watch(0.5)
    playSfx("naijalow1", nil, 2)
    watch(0.5)
    fade2(1, 0.15, 1, 1, 1)
    watch(0.3)
    
    fade2(0, 3, 1, 1, 1)
    musicVolume(1, 4)

    setElementLayerVisible(8, false)
    setElementLayerVisible(9, false)
    watch(0.25)
    overrideZoom(0)
    
    --[[local black = createQuad("black")
    quad_scale(black, 30, 30)
    quad_followCamera(black, 1)
    quad_setPosition(black, 400, 300)]]
    
    local function makeface(s)
        local face = createQuad(s)
        quad_followCamera(face, 1)
        quad_setPosition(face, 400, 300)
        quad_setBlendType(face, BLEND_ADD)
        return face
    end
    
    for i = 1,3 do
        local face = makeface("gameover-0001")
        quad_scale(face, 1.7, 1.7)
        quad_scale(face, 1.2, 1.2, 3)
        quad_alpha(face, 0.4)
        quad_alpha(face, 0, 2)
        watch(0.2)
    end
    watch(0.2)
    for i = 1,3 do
        local face = makeface("gameover-0002")
        quad_scale(face, 1.2, 1.2)
        quad_scale(face, 1.7, 1.7, 3)
        quad_alpha(face, 0)
        quad_alpha(face, 0.4, 3)
        watch(0.2)
    end

    watch(2)
    
    setCutscene(false)
    
    loadMap("introtunnel")
end


function update(me, dt)
    
    if v.needinit then
        v.needinit = false
        v.dummy = createEntity("empty")
        
        bone_alpha(v.bottle, 1)
        setNaijaHeadTexture("smile", 999)
        avatar_toggleCape(false)
        
        entity_setPosition(v.n, entity_getPosition(v.dummy))
        entity_setBoneLock(v.n, v.dummy)
        
        v.on = true
    end
    
    if not v.on then
        return
    end
    
    v.updateTQ(dt)
    
    if isInputEnabled() then
        disableInput()
    end
    
    local cx, cy = bone_getWorldPosition(v.chair)
    local cr = bone_getWorldRotation(v.chair)
    entity_setPosition(v.dummy, cx + 15, cy)
    entity_rotate(v.dummy, cr)
    entity_rotate(v.n, cr)
    entity_setState(v.n, 12345, 0, true)
    
    if v.delayT >= 0 then
        v.delayT = v.delayT - dt
        if v.delayT <= 0 then
            scene()
        end
    elseif v.dozoom then
        overrideZoom(1.4, 2)
    end
    
    if v.dosnap then
        cam_snap()
    end
    
    if v.doDrink then
        v.doDrink = false
        v.animT = entity_animate(v.n, "sitlazydrink")
        v.mouthT = 0.75
    end
    
    if v.doEat then
        v.doEat = false
        v.animT = entity_animate(v.n, "sitlazygrab")
        v.mouthT = 7.3
    end
    
    if v.mouthT >= 0 then
        v.mouthT = v.mouthT - dt
        if v.mouthT <= 0 then
            setNaijaHeadTexture("singing", 1.2)
        end
    end
    
    if v.animT <= 0 then
        if entity_getAnimationName(v.n) ~= "sitlazy2" then
            entity_animate(v.n, "sitlazy2", -1)
            setNaijaHeadTexture("smile", 999)
        end
    else
        v.animT = v.animT - dt
    end
    
    setCameraLerpDelay(1.5)
    
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
