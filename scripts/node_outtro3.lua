
dofile("scripts/inc_timerqueue.lua")

v.n = 0
v.fg = 0
v.on = true
v.noinput = false


local function createCube()
    local model = createEntity("3dmodel", "", node_getPosition(getNode("cubepos")))
    entity_msg(model, "loadfunc", function() return superfx.createCube(130, 9) end, "fx_black", 400)
    local totaltime = 0
    local sin = math.sin
    local cos = math.cos
    entity_msg(model, "setfunc", function(sphere, dt)
        totaltime = totaltime + dt
        local s = entity_getScale(model)
        return sin(totaltime * 0.9) * 2,
               cos(totaltime * 0.55) * 3.5,
               sin(totaltime * 0.4) * 6,
               s
    end)
    
    local es = entity_msg(model, "getents")
    for _, e in pairs(es) do
        entity_alpha(e, 0)
        entity_alpha(e, 0.4, 3)
    end
    
    entity_offset(model, 0, -8)
    entity_offset(model, 0, 8, 0.3)
    entity_scale(model, 0.4, 0.4)
    entity_scale(model, 0.6, 0.6, 2.5, -1, 1, 1)
end


function init(me)
    v.n = getNaija()
    v.fg = createEntity("mia", "", node_getPosition(getNode("thepos")))
    entity_msg(v.fg, "move")
    entity_animate(v.fg, "sitlazy", -1)
    bone_alpha(entity_getBoneByIdx(v.fg, 14), 0)
end

local function blah(txt, tm)
    setControlHint(txt, false, false, false, tm or 6)
end

local function doScene(me)
    v.noinput = true
    disableInput()
    setCutscene(true, true)
    entity_clearVel(v.n)
    entity_idle(v.n)
    entity_setState(v.n, 12345)
    playSfx("naijagasp")
    watch(1)
    entity_swimToNode(v.n, getNode("npos"))
    entity_watchForPath(v.n)
    cam_toEntity(v.fg)
    overrideZoom(1.05, 3)
    setGameSpeed(0.7, 1, 0, 0, 1)
    setNaijaHeadTexture("smile", 3)
    watch(1.5)
    entity_flipToEntity(v.n, v.fg)
    entity_animate(v.n, "kick")
    debugLog("kick")
    watch(1.4 + 0.2) -- transition delay of 0.2 + until keyframe
    shakeCamera(5, 1)
    entity_push(v.fg, -3000, -200, 0.3, 5000)
    entity_setWeight(v.fg, 500)
    watch(1.2)
    entity_idle(v.n)
    setGameSpeed(1, 1, 0, 0, 1)
    watch(2)
    entity_swimToNode(v.n, getNode("npos2"))
    -- pointer mess... luckily still valid
    entity_delete(v.fg, 2)
    musicVolume(0, 2)
    v.fg = createEntity("fgcameo",  "", entity_getPosition(v.fg))
    entity_animate(v.fg, "liesmashed", -1, 0, -1) -- instant
    cam_toEntity(v.fg) -- important: exchange entity
    entity_alpha(v.fg, 0)
    entity_alpha(v.fg, 1, 2)
    watch(2)
    emote(EMOTE_NAIJAUGH)
    setNaijaHeadTexture("shock", 1.8)
    musicVolume(1, 1)
    setMusicToPlay("gullet")
    updateMusic()
    watch(1.5)
    local t = entity_animate(v.fg, "smashed")
    watch(t/2)
    blah("Uuuh... Ouch! What the heck was this?")
    watch(t/2)
    t = entity_animate(v.fg, "energyburst")
    entity_setPosition(v.fg, entity_x(v.fg), entity_y(v.n), t, 0, 0, 1)
    watch(t)
    t = entity_animate(v.fg, "headpain")
    watch(t * 0.5)
    emote(EMOTE_NAIJAGIGGLE)
    watch(t * 0.18)
    entity_fh(v.fg)
    watch(t * 0.33)
    blah("Hey! You! You're not supposed to be here!")
    watch(entity_animate(v.fg, "ack"))
    entity_animate(v.fg, "pushforward")
    entity_idle(v.n)
    cam_toEntity(v.n)
    watch(1)
    blah("Because if you're here it means I must have missed the ending! Oh noes!")
    entity_setPosition(v.fg, entity_x(v.n) - 150, entity_y(v.n), 1.5)
    v.pushTQ(1.5, function() entity_animate(v.fg, "idle", -1) overrideZoom(0) end)
    
    watch(4)
    blah("Listen, this whole thing wasn't meant personally. Don't blame me for it please!")
    watch(5.3)
    blah("Eh... now, I have to work on a project and also dream about cubes. Off you go - see you next time!", 12)
    watch(1.5)
    
    -- And this is actually true. Probably the last lines of code for now. University demands.
    
    
    entity_swimToNode(v.fg, getNode("thepos2"))
    entity_watchForPath(v.fg)
    if entity_isfh(v.fg) then
        entity_fh(v.fg)
    end
    
    entity_animate(v.fg, "sitlazy2", -1)
    wait(1)
    bone_setTexture(entity_getBoneByIdx(v.fg, 1), "naija/fg-head-blink")
    
    createCube()
    
    
    setCutscene(false)
    v.noinput = false
    enableInput()
    entity_setState(v.n, STATE_IDLE)
    debugLog("scene done")
    
    v.pushTQ(2, function() entity_msg(v.fg, "enabletalk") end)
end

function update(me, dt)
    v.updateTQ(dt)
    
    if v.noinput and isInputEnabled() then
        debugLog("force input off")
        disableInput()
    end

    if v.on and node_isEntityIn(me, v.n) then
        v.on = false
        v.pushTQ(0.1, doScene, me)
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
