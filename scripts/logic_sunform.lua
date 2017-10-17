
-- sun form boost - increase normal circle light range

local S = {}

S.q = 0

S.init = function()
    S.q = createQuad("softglow-add", 13)
    quad_alpha(S.q, 0)
    quad_setBlendType(S.q, BLEND_ADD)
    quad_scale(S.q, 12, 12)
end

S.postInit = function()
end
    

S.update = function(dt)
    local a = 0
    if isForm(FORM_SUN) then
        a = 1
    end
    quad_alpha(S.q, a, 0.7)
    quad_setPosition(S.q, entity_getPosition(v.n))
end


v.logic.sunform = S
