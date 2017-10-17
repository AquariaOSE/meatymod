
dofile("scripts/inc_timerqueue.lua")

v.n = 0
v.noinput = true
v.firstOut = true
v.li = 0

local function doPoisonEffect()
    playSfx("poison")
    spawnParticleEffect("poisonbubbles", entity_getPosition(v.n))
    entity_color(v.n, 0.5, 1, 0.5, 0.3, 1, 1)
end

local function doWakeupScene()

    doPoisonEffect()
    
    if v.firstOut then
        doPoisonEffect()
        v.pushTQ(2, doPoisonEffect)
        watch(5)
    else
        watch(1)
    end
    
    setNaijaHeadTexture("")
    watch(2)
    
    entity_animate(v.n, "facedowngetup")
    
    while entity_isAnimating(v.n) do
        watch(FRAME_TIME)
    end
    
    if v.li ~= 0 then
        entity_msg(v.li, "idle")
        esetv(v.li, EV_LOOKAT, 1)
    end
    
    entity_setState(v.n, STATE_IDLE)
    v.noinput = false
    enableInput()
    overrideZoom(0)
    setStringFlag("DONE_OUTTRO", "1")
    
    -- if warped here from boss
    setOverrideMusic("")
    -- but do not update - so it stays until map is changed
end

function init(me)

    v.n = getNaija()

    -- if warped here from another map, naija starts in the "naijastart" node, which is placed inside of this node.
    -- so we know whether to start the scene or not.
    if not node_isEntityIn(me, v.n) then
        v.noinput = false
        return
    end
    
    setStringFlag("ACTIVE_POWERUP", "")
    
    local sf = getStringFlag("DONE_OUTTRO") -- TODO: set this somewhere
    if sf ~= "" then
        v.firstOut = false
    end
    
    if not entity_isfh(v.n) then
        entity_fh(v.n)
    end
    if not isForm(FORM_NORMAL) then
        changeForm(FORM_NORMAL)
    end

    local pos = getNode("naijawakeup")
    entity_setPosition(v.n, node_getPosition(pos))
    
    overrideZoom(1.3)
    entity_setState(v.n, 12345)
    setNaijaHeadTexture("blink", 999)
    cam_snap()
    
    fade2(1, 0, 0, 0, 0)
    fade2(0, 3, 0, 0, 0)
    
    setSceneColor(0.5, 0.5, 1)
    
    v.pushTQ(1, doWakeupScene)
    
    -- HACK - need to delay so that it will be executed in update() - important because Li init happens during init() (see node_hasli.lua)
    v.pushTQ(0, function()
        entity_animate(v.n, "facedown", -1)
        entity_updateSkeletal(v.n, 1)
    
        -- he will be there after outtroscene2 was seen
        v.li = getEntity("li")
        if v.li ~= 0 then
            esetv(v.li, EV_LOOKAT, 0)
            entity_offset(v.li, 0, 0)
            entity_setInternalOffset(v.li, 0, 0)
            entity_clearVel(v.li)
            entity_setPosition(v.li, entity_x(v.n) - 10, entity_y(v.n) - 10,0.1)
            entity_animate(v.li, "sleep", -1, 0, -1)
        end
    end)
    
end


function update(me, dt)

    v.updateTQ(dt)
    
    avatar_toggleCape(false)
    
    if v.noinput then
        disableInput()
    end
    
end


function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function song()
end

