
-- TODO: use timers or something to bring CPU usage down a bit

local function engage(ai, e)
    if _ai_doCombatWithEntity(ai, e) then
        if e == 0 then
            debugLog("AGGR: " .. entity_getName(ai.e) .. " stop aggro")
        else
            debugLog("AGGR: " .. entity_getName(ai.e) .. " engage " .. entity_getName(e))
            ai.lastFoeHp = entity_getHealth(e)
            ai.lastFoeHpT = 5 -- TODO: make this configurable
        end
    end
end

local function update(tr, dt, ai)
    local me = ai.e
    
    if ai:isInCombat() then
        local d = entity_getDistanceToEntity(me, ai.combatEntity)
        if d < ai.attack_range then
            ai:cb("attack", ai.combatEntity)
            entity_doFriction(me, dt, 150)
            
            if entity_getHealth(ai.combatEntity) < ai.lastFoeHp then
                ai.lastFoeHpT = 5 + dt -- TODO: here again
            end
            
            if ai.lastFoeHpT > 0 then
                ai.lastFoeHpT = ai.lastFoeHpT - dt
                if ai.lastFoeHpT <= 0 then
                    -- urg, been attacking the target but nothing happened. give up and find another one
                    ai.ignoreFoeName = "!" .. entity_getName(ai.combatEntity)
                    engage(ai, 0)
                end
            end
        else
            _ai_doMovementToEntity(ai, dt, ai.combatEntity, ai.combat_range)
        end
    else
        -- FIXME: should also support enemy AI... in this case we can't search for ET_ENEMY here
        local foe = entity_getNearestEntity(me, ai.ignoreFoeName, ai.aggro_range, ET_ENEMY, ai.damageType)
        engage(ai, foe)
    end
    
    -- TODO: if some wall s blocking the way, use entity_doCollisionAvoidance with big radius and dt to unstuck?
    
    entity_doCollisionAvoidance(me, dt, 2, 1, 100, 1, true)
    entity_doEntityAvoidance(me, dt, 20, 0.25)
    entity_updateMovement(me, dt)
end

local function damage(tr, ai, damageType, attacker, bone, dmg)
    if attacker ~= ai.e and entity_isDamageTarget(ai.e, damageType) and dmg > 0 then
        -- HACK: switch target
        engage(ai, 0)
        engage(ai, attacker)
    end
end

local function new()
    return {
        update = update,
        damage = damage
    }
end

return new
