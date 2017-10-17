
local M = {}

M.init = function()
    -- hide chair & mushrooms
    bone_alpha(entity_getBoneByIdx(v.n, 17), 0)
    bone_alpha(entity_getBoneByIdx(v.n, 18), 0)
    bone_alpha(entity_getBoneByIdx(v.n, 19), 0)
    
    -- hide boosters
    bone_alpha(entity_getBoneByName(v.n, "Booster"), 0)
    bone_alpha(entity_getBoneByName(v.n, "Booster2"), 0)
    
    
    -- restore element layer visibility (important when leaving final boss)
    setElementLayerVisible(2, true)
    setElementLayerVisible(1, true)
    setElementLayerVisible(0, true)
    setElementLayerVisible(15, true)
    setElementLayerVisible(14, true)
    setElementLayerVisible(13, true)
    setElementLayerVisible(11, true)
    setElementLayerVisible(10, true)
    setElementLayerVisible(9, true)
end

M.postInit = function()
    v.logic.misc = nil
end
    

M.update = function(dt)
end


v.logic.misc = M
