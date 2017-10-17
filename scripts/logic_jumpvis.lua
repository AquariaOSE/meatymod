
-- jump visualizer - estimates jump angle based on mouse position and visualized the direction.

local M = {}

M.q = 0

M.init = function()
    M.q = createQuad("vector")
    quad_scale(M.q, 1.2, 1.6)
end

M.postInit = function()
end
    

M.update = function(dt)
    local x, y = entity_getPosition(v.n)
    local mx, my = getMouseWorldPos()
    quad_setPosition(M.q, x, y)
    
    local vx, vy = makeVector(x, y, mx, my)
    vx, vy = vector_normalize(vx, vy)
    local len = vector_getLength(vx, vy)
    --local nx, ny = getWallNormal(x, y)
    local nx, ny = entity_getNormal(v.n)
    nx, ny = vector_normalize(nx, ny)
    
    local gx = 0.75 * vx + 0.25 * nx
    local gy = 0.75 * vy + 0.25 * ny
    
    local ga = vector_getAngleDeg(gx, gy)
    quad_rotate(M.q, ga)
    
end


v.logic.jumpvis = M
