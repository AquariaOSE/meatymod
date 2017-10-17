
dofile("scripts/template_drop.lua")

v.touch = false

function init(me)
    v.commonInit(me, "particles/bubble", "drip-splish-red")
    entity_color(me, 0.79, 0.2, 0.2)
end

function v.onDestroy(me, uw)
    local q = createQuad("particles/splat" .. math.random(1, 2))
    local x, y = entity_getPosition(me)
    quad_alphaMod(q, 0.7)
    local s = math.random(110, 150) / 100
    quad_scale(q, s, s)
    quad_rotate(q, math.random(360))
    quad_setLayer(q, LR_ENTITIES0)
    
    if uw then
        quad_setPosition(q, x, y)
        local t = 3
        quad_setPosition(q, x + math.random(-70, 70), y + 250, t)
        quad_scale(q, s * 6, s * 6, t)
        quad_delete(q, t)
    else
        local vx, vy = entity_getVel(me)
        vx, vy = vector_setLength(vx, vy, math.random(9, 24))
        quad_setPosition(q, x+vx, y+vy)
        quad_delete(q, 150)
    end
end
