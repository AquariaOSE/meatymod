
local DD = modlib_include("lib/datadumper.lua")

local function serialize_save(tab)
    return tostring(DD.dump(tab, true))
end

local function serialize_restore(s)
    local ok, ret = pcall(DD.restore, s)
    if not ok then
        return nil
    end
    return ret
end

return {
    serialize_restore = serialize_restore,
    serialize_save = serialize_save
}
