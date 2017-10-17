

local __allnodes = false

local function getAllNodes()
    if __allnodes then
        return __allnodes
    end
    
    -- this function is veeeeery hacky. Don't look!
    local n = getNaija()
    local has = {} -- [ node => {x, y} ]
    
    local node
    while true do
        node = entity_getNearestNode(n)
        if has[node] then
            break
        end
        -- save old position and move it far away
        has[node] = { x = node_x(node), y = node_y(node) }
        node_setPosition(node, -999999, -999999)
    end -- as soon as we find a node we already have, we got all (hopefully)
    
    __allnodes = {}
    -- restore old positions
    for node, pos in pairs(has) do
        node_setPosition(node, pos.x, pos.y)
        table.insert(__allnodes, node)
    end
    return __allnodes
end

-- Runs a function for all nodes. Returns true if processing was stopped early.
-- * f:      function to run. once it returns true, stop processing.
-- * param:  passed as additional parameter, as in f(node, param)
-- * filter: if given, f will only be called if filter(node, fparam) returns true
-- * fparam: passed to the filter function
-- for convenience, if filter is a string, it will only process nodes with that name. (as long as the function node_getLabel() exists!)
local function forAllNodes(f, param, filter, fparam)
    local nodes = getAllNodes()
    if not filter then
        for _, n in pairs(nodes) do
            if f(n, param) == true then
                return true
            end
        end
    elseif type(filter) == "string" then
        local fstr = filter:lower()
        for _, n in pairs(nodes) do
            if node_getLabel(n) == fstr then
                if f(n, param) == true then
                    return true
                end
            end
        end
    else
        for _, n in pairs(nodes) do
            if filter(n, fparam) then
                if f(n, param) == true then
                    return true
                end
            end
        end
    end
    return false
end

-- note: works reliably only for rectangular nodes!
local function node_getRandomPoint(me)
    local xs, ys = node_getSize(me)
    local xc, yc = node_getPosition(me) -- center
    
    local x = xc - (xs / 2)
    local y = yc - (ys / 2)
    
    x = x + math.random() * xs
    y = y + math.random() * ys
    
    return x, y
end

-- i => 0:name, 1:content, 2:amount, ...
local function node_getParam(node, i)
    return string.explode(node_getName(node), " ", true)[i + 1] or ""
end


modlib_onClean(function()
    __allnodes = false
end)

return {
    getAllNodes = getAllNodes,
    forAllNodes = forAllNodes,
    node_getRandomPoint = node_getRandomPoint,
    node_getParam = node_getParam,
}
