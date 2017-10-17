

-- FIXME: does not handle loops/self-refs currently
function table.copy(t)
    local new = {}
    setmetatable(new, table.copy(getmetatable(t)))
    for i, x in pairs(t) do
        if type(x) == "table" then
            new[i] = table.copy(x)
        else
            new[i] = x
        end
    end
    return new
end

