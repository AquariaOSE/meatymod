
dofile("scripts/inc_timerqueue.lua")

v.on = true
v.n = 0
v.pos = 0
v.shroom = 0

function init(me)
    v.n = getNaija()
    node_setCursorActivation(me, true)
    v.pos = getNode("eatpos")
    v.shroom = entity_getBoneByIdx(v.n, 19)
end

function update(me, dt)
    v.updateTQ(dt)
end

local function doScene(me)
    node_setCursorActivation(me, false)
    
    overrideZoom(1.35, 3)
    
    entity_swimToNode(v.n, v.pos)
    entity_watchForPath(v.n)
    entity_flipToNode(v.n, me)
    
    local li = getEntity("li")
    if li ~= 0 then
        entity_msg(li, "expr", "angry")
        entity_setState(li, STATE_PUPPET) -- don't follow
        v.pushTQ(0.5, function() entity_animate(li, "facepalm", -1) end) -- weird.. have to delay it otherwise won't work.
    end
    
    emote(EMOTE_NAIJASADSIGH)
    entity_setState(v.n, 12345)
    entity_animate(v.n, "sitandeat", -1)
    bone_alpha(v.shroom, 0)
    bone_setVisible(v.shroom, true)
    bone_alpha(v.shroom, 1, 1)
    setNaijaHeadTexture("blink", 2)
    watch(1.2)
    setNaijaHeadTexture("singing", 5)
    fade(1, 1.5, 0, 0, 0)
    watch(1.5)
    emote(EMOTE_NAIJAEW)
    watch(1.5)
    emote(EMOTE_NAIJAEVILLAUGH)
    
    --loadMap("main_hub")
    loadMap("introtunnel", "naijastartshort")
    disableInput()
    
    -- screen is dark by now
    overrideZoom(0.52)
    overrideZoom(0)
    --fade(0, 1, 0, 0, 0)
end

function activate(me)
    v.pushTQ(0, doScene, me)
end

function song()
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
