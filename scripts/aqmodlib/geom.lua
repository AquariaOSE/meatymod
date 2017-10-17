
-- geometry related functions

local function isLineObstructed(xstart, ystart, xend, yend, prt, prtEnd)

    local isObstructed = isObstructed
    local spawnParticleEffect = spawnParticleEffect
    
    local vx, vy = makeVector(xstart, ystart, xend, yend)
    local sx, sy = vector_setLength(vx, vy, TILE_SIZE) -- normalize to tile size
    local steps = vector_getLength(vx, vy) / TILE_SIZE
    
    local spawn = 70 -- more is never visible on screen
    
    local x, y = xstart, ystart
    for i = 0, steps do
        if isObstructed(x, y) then
            if prtEnd then
                spawnParticleEffect(prtEnd, x, y)
            end
            return getObstruction(x, y), x, y
        end
        if prt and spawn > 0 then
            spawnParticleEffect(prt, x, y)
            spawn = spawn - 1
        end
        x = x + sx
        y = y + sy
    end
    return false, x, y
end

local toPolarAngle = math.atan2
local DEGTORAD = 3.14159265359 / 180.0

-- center* : center point (map coords)
-- d* : direction vector from circle center (which counts as zero-angle) -- relative!
-- angle:  max. allowed angles between [-up ... +down]
-- p* : target point (map coords)
local function isPointInArc(centerx, centery, dx, dy, angleUp, angleDown, px, py)

    -- if in right quadrant, angles must be swapped to deliver correct result
    if dx > 0 then
        angleUp, angleDown = angleDown, angleUp
    end
    
    local prx, pry = makeVector(centerx, centery, px, py) -- point relative vector from center
    prx, pry = vector_normalize(prx, pry)
    dx, dy = vector_normalize(dx, dy)
    local ppol = toPolarAngle(prx, pry)
    local dpol = toPolarAngle(dx, dy)
    
    local aup = DEGTORAD * angleUp
    local adown = DEGTORAD * angleDown
    
    local a = ppol - dpol
    --if a >= -aup and a <= adown then spawnParticleEffect("awesomedebug2", px, py) else spawnParticleEffect("awesomedebug", px, py) end
    return a >= -aup and a <= adown
    
end

return {
    isLineObstructed = isLineObstructed,
    isPointInArc = isPointInArc,
}
