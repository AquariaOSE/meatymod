
dofile("scripts/inc_timerqueue.lua")
dofile("scripts/inc_mapsave.lua")
dofile("scripts/inc_flags.lua")


--== BANDAID/CAKE REWARD TABLE ==--
-- each function in here is called with no param when checked if it should be executed again later with true as param
-- (-> return true if form was not yet learned, etc)
-- 5: shield
-- 10: jelly costume
-- 15: portal form
local BANDAID_REWARDS =
{
    [5] = function(doit)
        if not doit then
            return not hasSong(SONG_SHIELD)
        end
        
        playSfx("collectible")
        learnSong(SONG_SHIELD)
        setControlHint("For collecting 5 cakes, you have learned the Shield song!", false, false, false, 6, nil, SONG_SHIELD)
        watch(6)
    end,
    
    [10] = function(doit)
        if not doit then
            return isFlag(FLAG_COLLECTIBLE_JELLYCOSTUME, 0)
        end
        
        playSfx("collectible")
        changeForm(FORM_NORMAL)
        setCostume("jelly")
        setFlag(FLAG_COLLECTIBLE_JELLYCOSTUME, 1)
        setControlHint("For collecting 10 cakes, you have reeived the Jelly costume!", false, false, false, 6, "collectibles/jelly-costume")
        watch(6)
    end,
    
    [15] = function(doit)
        if not doit then
            return getStringFlag("HAS_PORTALFORM") == ""
        end
        
        playSfx("collectible")
        setStringFlag("HAS_PORTALFORM", "1")
        learnSong(SONG_PORTALFORM)
        changeForm(FORM_PORTAL)
        setControlHint("For collecting 15 cakes, you have learned the Portal Form song! Hold the right mouse button to aim, then click left to shoot portals!",
            false, false, false, 8, nil, SONG_PORTALFORM)
        watch(8)
    end,
}
----------------------------------------


v.miafloating = false
v.timertext = 0
v.n = 0
v.item = false -- if not false, an item is the reward, and not mia/li
v.itemEnt = 0
v.canzoom = true

v.doBandaidReward = false -- later set to a FUNCTION to execute if applicable

local function doZoom(z, t)
    if v.canzoom then
        overrideZoom(z, t)
    end
end

local function warpAway(e)
    spawnParticleEffect("spirit-big", entity_getPosition(e))
    entity_playSfx(e, "spirit-beacon")
    entity_alpha(e, 0, 0.3)
end

local function liexpr(ep)
    return entity_msg(v.li, "expr", ep)
end

local function aplus()
    local q = createQuad("aplus")
    quad_alpha(q, 0)
    local s = 0.7
    quad_scale(q, 0, s)
    quad_scale(q, s, s, 0.3)
    quad_alpha(q, 1, 0.2)
    quad_setPosition(q, 400, 80)
    quad_followCamera(q, 1)
    quad_setLayer(q, LR_HUD)
    playSfx("invincible")
    v.pushTQ(3, function() quad_delete(q, 1) end)
end

local function doBandaid()
    local q = createQuad("ingredients/legendary-cake")
    quad_alpha(q, 0)
    local s = 1.5
    quad_alpha(q, 0)
    quad_rotate(q, 360, 0.8)
    quad_scale(q, 0, 0)
    quad_scale(q, s, s, 0.8)
    quad_alpha(q, 1, 0.2)
    quad_setPosition(q, 400, 120)
    quad_followCamera(q, 1)
    quad_setLayer(q, LR_HUD)
    v.pushTQ(3, function() quad_delete(q, 1) end)
end

local function updateMapTime()
    if PLAYTIME == 0 then
        return
    end
    
    local best = v.getSavedTime()
    if PLAYTIME < best or best == 0 then
        best = PLAYTIME
        debugLog("new map record: " .. best)
    end
    
    v.setSavedTime(nil, best)
    
    local par = v.getParTime()
    
    if best <= par then
        aplus()
    end
    
end

local function doMapTrans(m)

    local lianim = entity_getAnimationName(v.li)
    local miaanim = entity_getAnimationName(v.mia)
    
    setCameraLerpDelay(0.5)
    cam_toEntity(v.mia)
    
    local mx, my = entity_getPosition(v.mia)
    local lx, ly = entity_getPosition(v.li)
    
    if v.miafloating then
        entity_setPosition(v.li, lx, ly + 55, 0.5)
    else
        entity_setPosition(v.li, lx, ly + 10, 0.5)
    end
    emote(EMOTE_NAIJALI)
    setNaijaHeadTexture("shock", 0.7)
    if v.lihangdown then
        entity_animate(v.li, "hangdownfall")
    else
        entity_animate(v.li, "grabfalldown")
    end
    entity_animate(v.mia, "channel", -1, nil, 0.3)
    --liexpr("surprise")
    watch(1)
    entity_animate(v.mia, "channel2", -1)
    watch(0.6)
    warpAway(v.li)
    watch(0.2)
    setNaijaHeadTexture("shock", 0.7)
    entity_playSfx(v.n, "naijalow1")
    entity_animate(v.mia, "channel3", -1)
    watch(0.6)
    warpAway(v.n)
    watch(0.2)
    entity_animate(v.mia, "channel5", -1)
    watch(0.6)
    warpAway(v.mia)
    
    watch(1)
    
    esetv(v.n, EV_NOINPUTNOVEL, 1)
    
    -- so that they will play normally when activate() is called on resetMap()
    entity_animate(v.mia, miaanim, -1)
    entity_animate(v.li, lianim, -1)
    
    if v.doBandaidReward then
        v.doBandaidReward(true)
    end
    
    doZoom(0)
    
    if m and m ~= "" then
        NEXT_MAP = m -- logic_replay.lua will now play replays, and continue on mouseclick. Also immunity to saws.
    else
        entity_alpha(v.n, 1)
        entity_alpha(v.li, 1)
        entity_alpha(v.mia, 1)
        v.done = false
    end
end

local function doMapTransItem(m)

    setCameraLerpDelay(0.5)
    cam_toEntity(v.itemEnt)
    entity_msg(v.itemEnt, "collect")
    
    while not entity_isState(v.itemEnt, STATE_COLLECTED) do
        watch(FRAME_TIME)
    end
    cam_toEntity(v.n)
    setNaijaHeadTexture("smile", 5)
    watch(0.5)
    emote(EMOTE_NAIJAWOW)
    watch(1.5)
    emote(EMOTE_NAIJALAUGH)
    watch(1)
    warpAway(v.n)
    watch(1)
    
    esetv(v.n, EV_NOINPUTNOVEL, 1)
    
    if v.doBandaidReward then
        v.doBandaidReward(true)
    end
    
    doZoom(0)
    
    if m and m ~= "" then
        NEXT_MAP = m -- logic_replay.lua will now play replays, and continue on mouseclick. Also immunity to saws.
    else
        entity_alpha(v.n, 1)
        v.done = false
    end
end

local function checkBandaid(e, t)
    if entity_isState(e, STATE_COLLECTED) then
        t.c = t.c + 1
        local node = entity_getNearestNode(e, "bandaid")
        if node ~= 0 then
            node_setFlag(node, 1)
        end
        
        if not t.anim then
            doBandaid()
            t.anim = true
        end
    end
end

local function updateBandaids()
    local t = { c = 0, anim = false }
    forAllEntities(checkBandaid, t, "bandaid")
    local was = v.getSavedBandaid()
    if t.c > was then
        v.setSavedBandaid(nil, t.c)
    end
    
    local total = v.getTotalBandaidsCollected()
    debugLog("updateBandaids() - " .. total .. " collected in total")
    
    for req, rewardFunc in pairs(BANDAID_REWARDS) do
        if total >= req then
            debugLog("got enough for " .. req)
            if rewardFunc(false) then
                v.doBandaidReward = rewardFunc -- called with true as param later
                debugLog("Need to do bandaid reward for " .. req)
                break
            end
        else
            debugLog("not yet " .. req)
        end
    end
end

local function nextMap()
    
    esetv(v.n, EV_NOINPUTNOVEL, 0) 
    entity_setInvincible(v.n, true)
    PLAYTIME_STOP = true
    doZoom(1.2, 0.7)
    entity_addVel(v.n, entity_velx(v.n) * -0.8, 0) -- speed down
    
    updateMapTime()
    updateBandaids()
    
    if v.item then
        debugLog("item map trans")
        doMapTransItem(v.getNextMapName())  
    else
        debugLog("normal map trans")
        doMapTrans(v.getNextMapName())
    end
end


v.n = 0
v.mia = 0
v.li = 0
v.needinit = true
v.miahand = 0
v.done = false
v.blockinput = true
v.forcefloat = false
v.liOffsY = 0
v.liOffsX = 0
v.lihangdown = false

local function appear()
    resetMap(true)
    local x, y = entity_getPosition(v.n)
    spawnParticleEffect("spirit-big", x, y + 20)
    playSfx("spirit-beacon")
    entity_heal(v.n, 100)
    entity_alpha(v.n, 1, 0.2)
    v.blockinput = false
    enableInput()
    fade2(0.6, 0, 1, 1, 1)
    fade2(0, 0.7, 1, 1, 1)
end

function init(me)
    v.n = getNaija()
    local c = node_getContent(me)
    v.forcefloat = (c == "float")
    if c == "item" then
        debugLog("finish: has item!")
        local a = node_getName(me):explode(" ", true) -- "NAME" "item" *
        if a[3] then
            v.item = a[3]
            debugLog("... item is: " .. v.item)
        end
    end
    
    NEXT_MAP = false
    
    -- map preview -- part 1 --
    
    -- HACK #1 (otherwise this screws the camera)
    local izoom = node_getNearestNode(me, "izoom")
    if izoom ~= 0 and node_isPositionIn(izoom, node_getPosition(me)) then
        v.canzoom = false
    end
    
    setCameraLerpDelay(0)
    cam_toNode(me)
    entity_alpha(v.n, 0)
    
    -- HACK #2
    izoom = entity_getNearestNode(v.n, "izoom")
    if izoom == 0  or not node_isEntityIn(izoom, v.n) then
        overrideZoom(1.1)
        overrideZoom(0.3, 2)
    end
    


    
    v.pushTQ(1.5, function()
        if NEXT_MAP then return end -- HACK used by logic_ui for replay selection (do not spawn if replay already started)
        setCameraLerpDelay(0.4)
        doZoom(0)
        cam_toEntity(v.n)
        v.pushTQ(2, function()
            setCameraLerpDelay(0)
            appear()
        end)
    end)
        
    
end

local function createLiAndMia(me)
    v.li = getEntity("li")
    if v.li == 0 then
        v.li = createEntity("li")
    end
    v.mia = getEntity("mia")
    if v.mia == 0 then
        v.mia = createEntity("mia")
    end
    
    --entity_setState(v.li, STATE_PUPPET, -1, true)
    entity_moveToBack(v.li)
    
    if chance(50) then
        entity_fh(v.li)
    end
    
    local x, y = node_getPosition(me)
    
    v.miahand = entity_getBoneByIdx(v.mia, 15)
    local miaOffxY = 0
    local canhold = false
    
    if v.forcefloat then
        canhold = true
        v.miafloating = true
        
    elseif getWaterLevel() < node_y(me) or entity_isUnderWater(v.mia) then -- under water?
        entity_animate(v.mia, "grabbingneckfloat2", -1)
        miaOffxY = 30
        v.miafloating = true
    elseif chance(50) then
        v.miafloating = false
        canhold = true
    else
        v.miafloating = true
        canhold = true
    end
    
    local holding = false
    local strangling = false
    if canhold and chance(50) then
        -- holding upside down
        holding = true
        v.liOffsX = 1
        if v.miafloating then
            entity_animate(v.mia, "holdingfloat", -1)
            miaOffxY = 30
        else
            entity_animate(v.mia, "holdingstand", -1)
            miaOffxY = 0
        end
    else
        if v.miafloating then
            if chance(50) then
                entity_animate(v.mia, "grabbingneckfloat", -1)
            else
                entity_animate(v.mia, "stranglingfloat", -1)
                strangling = true
            end
            miaOffxY = 30
        else
            if chance(50) then
                entity_animate(v.mia, "grabbingneckstand", -1)
            else
                entity_animate(v.mia, "stranglingstand", -1)
                strangling = true
            end
            miaOffxY = 0
        end
    end
    
    if holding then
        entity_animate(v.li, "hangdown", -1)
        v.liOffsY = 60
    else
        if strangling then
            entity_animate(v.li, "strangled", -1)
            v.liOffsY = 28
            v.liOffsX = -3
        else
            entity_animate(v.li, "grabbedbyneck", -1)
            v.liOffsY = 23
        end
        
    end
    
    v.lihangdown = holding
    
    entity_setPosition(v.mia, x, y - miaOffxY)
    
    if strangling then
        liexpr("hurtred")
    else
        liexpr("hurt")
    end

end

local function createItem(me)
    local e = createEntity("item", "", node_getPosition(me))
    v.itemEnt = e
    entity_msg(e, "setitem", v.item)
end

local function postInit(me)
    if v.item then
        createItem(me)
    else
        createLiAndMia(me)
    end
end


function update(me, dt)
    v.updateTQ(dt)
    
    if v.blockinput then
        disableInput()
    end
    
    if v.needinit then
        postInit(me)
        v.needinit = false
    end
    
    if not v.done then
    
        if v.mia ~= 0 then
            local hx, hy = bone_getWorldPosition(v.miahand)
            local mx, my = entity_getPosition(v.mia)
            local vx, vy = makeVector(mx, my, hx, hy)
            vx = vx * 1.05
            vy = vy * 1.05
            entity_setPosition(v.li, mx + vx + v.liOffsX, my + vy + v.liOffsY)
            entity_fhToX(v.mia, entity_x(v.n))
        end
        
        if node_isEntityIn(me, v.n) then
            v.done = true
            nextMap()
        end
    end

end

function activate(me)
    if v.mia ~= 0 then
        entity_alpha(v.li, 1, 0.5)
        entity_alpha(v.mia, 1, 0.5)
    end
    if v.itemEnt ~= 0 then
        entity_alpha(v.itemEnt, 1, 0.5)
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
