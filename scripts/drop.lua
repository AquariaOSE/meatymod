
dofile("scripts/template_drop.lua")

function init(me)
    v.commonInit(me, "particles/bubble", "drip-splish")
    entity_color(me, 0.7, 0.7, 1)
end
