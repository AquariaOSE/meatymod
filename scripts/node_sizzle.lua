
v.n = 0
v.t = 0
v.timer = 2
v.st = 0

v.bones = false

v.snd = 0


local function doHeatDamage(e)

    if entity_isInvincible(e) then
        return false
    end
    
    playSfx("sizzle")
    
    -- not using entity_damage here() intentionally, to overcome Naija's damage multiplier in various forms,
    -- and to be sure the damage immmunity timer does not kick in.
    entity_changeHealth(e, -0.5)
    entity_heal(e, 0) -- HACK: force display damage overlay

    entity_playSfx(e, "hit" .. v.snd)
    v.snd = v.snd + 1
    if v.snd > 8 then
        v.snd = 1
    end
        
    --entity_playSfx(e, "pain")
    
    if v.bones then
        for _, b in pairs(v.bones) do
            spawnParticleEffect("sizzle", bone_getWorldPosition(b))
        end
    end
    
    entity_damageFlash(e)
    return true
end


function init(me)
    v.n = getNaija()
    v.timer = tonumber(node_getContent(me)) or 2
    if v.timer == 0 then
        v.timer = 2
    end
    loadSound("sizzle")
    
    if CFG_GORE_LEVEL > 0 then
        v.bones = {
            entity_getBoneByName(v.n, "RightArm"),
            entity_getBoneByName(v.n, "LeftFoot"),
            entity_getBoneByName(v.n, "RightFoot"),
        }
    end
end

function update(me, dt)
    if node_isEntityIn(me, v.n) and avatar_isOnWall() and entity_getBoneLockEntity(v.n) == 0 then
        v.t = v.t + dt
        if v.t > v.timer then
            if v.st <= 0 then
                --entity_damage(v.n, v.n, 0.5) -- still has an internal invulnerability timer so no problem spamming this. BUT TRIGGERS DAMAGE ANIM GRRRR
                doHeatDamage(v.n) -- HACK: own function that does not trigger damage taken anim
                v.st = 2
            end
        end
        if v.st >= 0 then
            v.st = v.st - dt
        end
            
    else
        v.t = 0
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
