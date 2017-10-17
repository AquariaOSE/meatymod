
-- TODO: make this callbacks: startSwim, stopSwim

local function toggleMoving(ai, mv)
    if mv and not ai.moving then
        ai:cb("moveStart")
    elseif not mv and ai.moving then
        ai:cb("moveStop")
    end
    ai.moving = mv
end

-- roughly based on the original Li script
-- this supporty only underwater for now.
local function doMovementToPoint(ai, dt, x, y, range)
    local me = ai.e
    
    local amt = 300

    if entity_isPositionInRange(me, x, y, range) then
        entity_setMaxSpeedLerp(me, 0.2, 1)
        entity_doFriction(me, dt, 200)
        toggleMoving(ai, false)
    else
        entity_setMaxSpeedLerp(me, 1, 0.2)
        toggleMoving(ai, true)

        if entity_isPositionInRange(me, x, y, 512) then
            entity_moveTowards(me, x, y, dt, amt)
        else
            entity_moveTowards(me, x, y, dt, amt*2)
        end
    end
        
    --if math.abs(entity_velx(me)) > 20 or math.abs(entity_vely(me)) > 20 then
        entity_doFriction(me, dt, 200)
    --end
    
    if math.abs(entity_velx(me)) > 10 then
        entity_flipToVel(me)
    end
    
    if entity_getVelLen(me) > 7 then
        entity_rotateToVel(me, 0.1)
    else
        entity_fhToX(me, x)
        -- prevent excessive rotation
        local r = entity_getRotation(me)
        if r > 180 then
            entity_rotate(me, r - 360)
        end
        entity_rotate(me, 0, 0.2)
    end
end

local function doMovementToEntity(ai, dt, e, range)
    if entity_isUnderWater(e) then
        local x, y = entity_getPosition(e)
        return doMovementToPoint(ai, dt, x, y, range)
    end
end

rawset(_G, "_ai_doMovementToPoint", doMovementToPoint)
rawset(_G, "_ai_doMovementToEntity", doMovementToEntity)
rawset(_G, "_ai_toggleMoving", toggleMoving)