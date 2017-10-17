
dofile("scripts/inc_timerqueue.lua")

v.on = true
v.n = 0

function init(me)
    v.n = getNaija()
    
    if getStringFlag("DONE_OUTTRO") ~= "" then
        node_setCursorActivation(me, true)
        local x, y = node_getPosition(me)
        spawnParticleEffect("sparkle", x, y)
        spawnParticleEffect("glowbits", x, y)
        spawnParticleEffect("sparkspurple", x, y)
        
        local q = createQuad("rune-black")
        quad_setPosition(q, x, y)
        quad_alpha(q, 0.6)
        quad_rotate(q, 360, 2, -1)
        quad_scale(q, 1.5, 1.5)
        quad_scale(q, 1.7, 1.7, 1, -1, 1, 1)
    end
end

function update(me, dt)
    v.updateTQ(dt)
end

local function doScene(me)
    node_setCursorActivation(me, false)
    local x, y = node_getPosition(me)
    entity_setPosition(v.n, x, y, 0.5)
    spawnParticleEffect("sparkssuck", x, y)
    playSfx("regen")
    watch(1)
    playSfx("spirit-return")
    esetv(v.n, EV_NOINPUTNOVEL, 0)
    entity_push(v.n, 0, -4000, 4, 9999, 0)
    playSfx("naijazapped")
    watch(0.2)
    shakeCamera(10, 2)
    fade(1, 1, 0, 0, 0)
    watch(0.8)
    loadMap("outtroscene")
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
