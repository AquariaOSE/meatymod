
local function update(tr, dt, ai)
    local me = ai.e
    _ai_doMovementToEntity(ai, dt, ai.nearestFriend, ai.friend_mindist)
    
    entity_doCollisionAvoidance(me, dt, 2, 1, 100, 1, true)
    entity_doEntityAvoidance(me, dt, 50, 0.25)
    entity_updateMovement(me, dt)
end

local function new()
    return {
        update = update,
    }
end

return new
