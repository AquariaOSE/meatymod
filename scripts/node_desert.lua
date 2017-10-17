
local DELAY = 3

v.n = 0
v.delayT = DELAY
v.q = 0
v.q2 = 0
v.hasq = false
v.aughdone = false
v.lowdone = false
v.sighT = -1
v.sighdone = false
v.isVolcano = false -- lazyness wins :)

function init(me)
    v.n = getNaija()
end

function update(me, dt)
    local t = 1.2
    local a = 0
    local nature = isForm(FORM_NATURE)
    if node_isEntityIn(me, v.n) then
        local t
        if not v.isVolcano and entity_isUnderWater(v.n) then
            v.delayT = DELAY
            
            if v.lowdone and not v.sighdone then
                v.sighdone = true
                v.sighT = 2
            end
            
            if v.sighT >= 0 then
                v.sighT = v.sighT - dt
                if v.sighT <= 0 then
                    --emote(EMOTE_NAIJASIGH)
                    playSfx("naijasigh3", nil, 1.5)
                    v.sighdone = true
                end
            end
        else
            if v.delayT > 0 then
                v.delayT = v.delayT - dt
                if v.delayT < 0 then
                    v.delayT = 0
                elseif v.delayT <= 1.2 and not v.aughdone then
                    emote(EMOTE_NAIJAUGH)
                    v.aughdone = true
                end
            elseif not nature then
                entity_damage(v.n, v.n, 0.3)
                
                if not v.lowdone and not nature and entity_getHealth(v.n) <= 3.5 and entity_getHealth(v.n) > 2.8 then
                    playSfx("naijalow4")
                    v.lowdone = true
                end
            end
            t = 0.4
            

        end
        a = 1 - (v.delayT / DELAY)
        --debugLog(string.format("q alpha: %.3f", a))
    end
    
    
    
    if nature then
        v.delayT = DELAY / 2
        if a > 0.27 then
            a = 0.27
        end
    end
    
    -- HACK
    if v.isVolcano then
        if nature then
            v.delayT = DELAY
            a = 0
        end
        
        if v.delayT > 0 then
            a = 0
        end
        
        fade3(a * 0.75, t * 2.5, 1, 0.2, 0)
        
    elseif v.hasq then
        quad_alpha(v.q, a, t)
        quad_alpha(v.q2, a, t)
        
        
        -- delete quads if not in use to prevent burning fillrate unnecessarily
        -- (desert already burns enough fillrate due to massive half-transparent overlays)
        if quad_getAlpha(v.q2) < 0.001 and a <= 0 then
            quad_delete(v.q)
            quad_delete(v.q2)
            v.q = 0
            v.q2 = 0
            debugLog("desert quad deleted")
            v.hasq = false
        end
    else
        if a >= 0.001 and not v.isVolcano then
            v.q = createQuad("particles/tripper")
            quad_setBlendType(v.q, BLEND_ADD)
            quad_scale(v.q, 5, 5)
            quad_followCamera(v.q, 1)
            quad_setPosition(v.q, 400, 300)
            quad_alpha(v.q, 0)
            quad_color(v.q, 1, 0.4, 0.2)
            quad_alphaMod(v.q, 0.4)
            quad_setLayer(v.q, LR_SCENE_COLOR)
            
            v.q2 = createQuad("white")
            quad_setBlendType(v.q2, BLEND_ADD)
            quad_scale(v.q2, 40, 40)
            quad_followCamera(v.q2, 1)
            quad_setPosition(v.q2, 400, 300)
            quad_alpha(v.q2, 0)
            quad_alphaMod(v.q2, 0.4)
            quad_setLayer(v.q2, LR_SCENE_COLOR)
            
            debugLog("desert quad created")
            v.hasq = true
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
