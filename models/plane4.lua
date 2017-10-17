local step = 90
local a = 0
local p = {}
local tins = table.insert
while a < 360 do
    local x, y = vector_fromDeg(a)
    tins(p, { x, 0, y })
    a = a + step
end
return p
