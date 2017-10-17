
-- zoom glitch abuse script
-- when using a negative zoom, the scene camera flips upside down.
-- controls in water are inverted, but jumping on land works as it used to.
-- because of the immense brain screw this causes while playing,
-- i decided this mod *must* abuse this glitch as gameplay mechanic :D
-- (but hey, i didn't actually use this in water, only on land, where it isn't as disturbing)

-- the reason i'm not using a simple "zoom" node for this is because when leaving said node,
-- the camera *slowly* reverts back to default zoom, risking a divide by zero.
-- to make the transition instant, it needs to be scripted.

local M = {}
M.nodes = false
M.wasIn = false

M.init = function()
    M.nodes = {}
    forAllNodes(function(node)
        if node_getLabel(node) == "izoom" then
            M.nodes[node] = tonumber(node_getContent(node)) or 0.52
        end
    end)
    
end

M.postInit = function()
end
    

M.update = function(dt)
    local isin = false
    for node, z in pairs(M.nodes) do
        if node_isEntityIn(node, v.n) then
            isin = true
            overrideZoom(-z)
            break
        end
    end
    
    if not isin and M.wasIn then
        overrideZoom(0.52)
        overrideZoom(0)
        M.wasIn = false
    end
    
    M.wasIn = isin
end


v.logic.glitches = M
