
dofile("scripts/inc_timerqueue.lua")

v.on = false
v.n = 0
v.grouper = 0
v.li = 0
v.cradle = 0
v.noinput = false

local function shoveMushrooms(last)
    local x, y = entity_getPosition(v.cradle)
    local m = createEntity("mushroom_end", "", x, y - 30)
    entity_addVel(m, -300, -250)
    
    if last then
        entity_setTexture(v.cradle, "cradle-empty")
        entity_animate(v.li, "idle", -1)
    end
end

local function doScene(me)
    debugLog("outtro2 start")
    
    v.noinput = true
    
    overrideZoom(0.75, 3)
    setCameraLerpDelay(1)
    cam_toNode(getNode("campos"))
    
    local max = 1
    entity_animate(v.li, "shove", max)
    for i = 0, max do
        v.pushTQ(i * 1.5 + 0.8, shoveMushrooms)
    end
    entity_swimToNode(v.n, getNode("naijapos"))
    entity_watchForPath(v.n)
    changeForm(FORM_SUN)
    
    watch(2.3)
    
    emote(EMOTE_NAIJALI)
    watch(0.2)
    
    entity_animate(v.li, "idle", -1)
    entity_fh(v.li)
    watch(1.2)
    emote(EMOTE_NAIJAUGH)
    watch(0.5)
    
    entity_fh(v.li)
    
    max = 2
    entity_animate(v.li, "shove", max)
    for i = 0, max do
        v.pushTQ(i * 1.5 + 0.8, shoveMushrooms, i == max)
    end
    
    watch(2)
    
    cam_toEntity(v.grouper)
    
    watch(2)
    
    entity_msg(v.li, "expr", "laugh")
    
    local t = 0.4
    for i = 1, 2 do
        entity_color(v.grouper, 0.1, 1, 0.2, t) watch(t)
        entity_color(v.grouper, 0.4, 0.4, 1, t) watch(t)
        entity_color(v.grouper, 1, 0.65, 0.1, t) watch(t)
        entity_color(v.grouper, 1, 0.2, 0.9, t) watch(t)
        entity_color(v.grouper, 1, 0, 0, t) watch(t)
        if i == 1 then
            emote(EMOTE_NAIJAWOW)
        end
    end
    setOverrideMusic("nyan_echo")
    updateMusic()
    entity_color(v.grouper, 1, 1, 1, 3, 0, 0, 1)
    entity_offset(v.grouper, 0, 0, 0.2)
    watch(0.2)
    entity_offset(v.grouper, 10, 0, 0.1, -1, 1)
    watch(0.5)
    local sx, sy = entity_getScale(v.grouper)
    entity_scale(v.grouper, sx * 1.5, sy * 1.1, 0.3)
    watch(0.3)
    entity_scale(v.grouper, sx * 1.1, sy * 1.5, 0.4, -1, 1, 1)
    
    watch(2)
    debugLog("shove end")
    setCameraLerpDelay(0)

    entity_color(v.grouper, 0.1, 1, 0.2, t, -1, 1, 1)
    entity_rotate(v.grouper, 60, 2, 0, 0, 1)
    entity_setCanLeaveWater(v.grouper, true)
    entity_setMaxSpeedLerp(v.grouper, 3)
    watch(1.5)
    entity_addVel(v.grouper, -400, -1000)
    entity_playSfx(v.grouper, "speedup", 0.8)
    watch(0.5)
    entity_scale(v.grouper, 0, 0, 2)
    watch(2)
    entity_clearVel(v.grouper)
    spawnParticleEffect("linestar", entity_getPosition(v.grouper))
    entity_msg(v.li, "expr", "happy")
    entity_damage(v.grouper, v.grouper, 999) -- takes 2 sec before internal camera pointers get invalid
    v.grouper = 0
    watch(1.3)
    
    setMusicToPlay("hopeofwinter")
    setOverrideMusic("")
    updateMusic()
    emote(EMOTE_NAIJALAUGH)
    watch(0.6)
    
    debugLog("back to naija")
    
    cam_toEntity(v.n)
    setCameraLerpDelay(0)
    
    watch(0.3)
    changeForm(FORM_NORMAL)
    setNaijaHeadTexture("smile", 99)
    watch(0.3)
    
    entity_flipToEntity(v.li, v.n)
    watch(1.5)
    entity_msg(v.li, "forcehug")
    setCameraLerpDelay(0)
    
    -- TODO: credits roll
    
    
    learnSong(SONG_LI)
    setStringFlag("DONE_OUTTRO2", "1")
    
    -- we leave the map in that script, so, no
    --v.noinput = false
    --enableInput()
    
    debugLog("outtro2 done")   
    
    updateMusic()
    
    
    node_activate(getNode("outtro2credits"))

end

function init(me)
    v.n = getNaija()
    
    v.on = getStringFlag("DONE_OUTTRO2") == ""
    
    v.cradle = createEntity("mushroomcradle_end", "", node_getPosition(getNode("cradlepos")))
    
    v.li = getEntity("li")
    
    if v.on then
        v.grouper = createEntity("grouper_end", "", node_getPosition(getNode("grouperpos")))
        if v.li == 0 then
            v.li = createEntity("li", "", node_getPosition(getNode("lipos")))
        end
        --entity_setState(v.li, STATE_PUPPET)
        entity_setTexture(v.cradle, "shroomcradle")
    else
        --v.grouper = createEntity("grouper_end", "", node_getPosition(getNode("grouperpos2")))
    end
end



function update(me, dt)

    v.updateTQ(dt)
    
    if v.noinput then
        disableInput()
    end

    if v.on and node_isEntityIn(me, v.n) then
        v.pushTQ(1.5, doScene, me)
        v.on = false
    end
    
end




function song()
end

function songNote()
end

function songNoteDone()
end
