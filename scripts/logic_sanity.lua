
-- misc sanity checks on maps

local M = {}

M.init = function()
end


M.postInit = function()
    
    local bandaids = 0
    forAllNodes(function() bandaids = bandaids + 1 end, nil, "bandaid")
    
    local bandaidsSet = v.getBandaidCount()
    
    if bandaidsSet ~= bandaids then
        centerText(string.format("\n\n\nWARNING: Bandaids found: %d, expected: %d (as set in inc_mapmgr.lua)!", bandaids, bandaidsSet))
    end
    
    v.logic.sanity = nil
end

v.logic.sanity = M
