
dofile("scripts/inc_flags.lua")
dofile("scripts/inc_mapsave.lua")

v.n = 0
v.on = true
v.targetmap = false
v.wzT = -1

function init(me)
    v.n = getNaija()
    v.targetmap = node_getContent(me)
    if v.targetmap == "" then
        --errorLog("undefined warp zone!")
        v.on = false
        return
    end
    
    spawnParticleEffect("warpspiral-blue-small", node_getPosition(me))
    
    --[[local q = createQuad("softglow-add", 13)
    quad_setBlendType(q, BLEND_ADD)
    quad_setPosition(q, node_getPosition(me))
    quad_scale(q, 2, 2)]]
end


-- blatantly copied fro node_wmap.lua
local function doWarpZone(me)
    v.on = false
    v.noinput = true
    
    entity_clearVel(v.n)
    disableInput()
    
    local q = createQuad("particles/warpzone")
    quad_alpha(q, 0)
    quad_alpha(q, 1, 0.5)
    quad_followCamera(q, 1)
    quad_setPosition(q, 400, 300)
    quad_scale(q, 2.5, 2.5)
    quad_rotate(q, 360)
    quad_rotate(q, 0, 1.8, -1)
    quad_setLayer(q, LR_HUD)
    spawnParticleEffect("warpzone", entity_getPosition(v.n))
    
    entity_setState(v.n, 12345)
    entity_animate(v.n, "frozen", -1)
    entity_rotate(v.n, entity_getRotation(v.n) - 360, 0.6, -1)
    entity_setPosition(v.n, node_x(me), node_y(me), 1)
    
    playSfx("warpzone_noise", nil, 0.25)
    playSfx("warpzone_sq", nil, 0.6)
    
    v.wzT = 2
    -- WTF: watch() does not work here for some reason
    
end

function update(me, dt)
    if v.on and node_isEntityIn(me, v.n) then
        v.on = false
        debugLog("warpzone " .. v.targetmap)
        doWarpZone(me)
    end
    
    if v.wzT >= 0 then
        v.wzT = v.wzT - dt
        if v.wzT <= 0 then
            local x, y = entity_getPosition(v.n)
            spawnParticleEffect("spirit-big", x, y + 20)
            playSfx("spirit-beacon")
            watch(0.5)
            loadMap(v.targetmap)
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
