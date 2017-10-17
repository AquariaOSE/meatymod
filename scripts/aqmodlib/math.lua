
-- scale t from [lower, upper] into [rangeMin, rangeMax]
local function rangeTransform(t, lower, upper, rangeMin, rangeMax)

    if t < lower then
        return rangeMin
    end
    if t > upper then
        return rangeMax
    end
    
    local d = (upper - lower)
    if d == 0 then
        return rangeMin
    end

    t = t - lower
    t = t / d
    t = t * (rangeMax - rangeMin)
    t = t + rangeMin
    return t
end



return {
    rangeTransform = rangeTransform,
}
