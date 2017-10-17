
if rawget(v, "__mapsave_loaded") then return end

dofile("scripts/inc_mapmgr.lua")

-- if m is given, return entry for that map, otherwise current map
local function getSavedEntry(m, entry)
    local name = v.getMapName(m)
    debugLog("getSavedEntry(" .. name .. " , " .. entry .. ")")
    
    local s = getStringFlag("mapsave_" .. name)
    if s ~= "" then
        local a = s:explode(" ")
        for i = 1, #a do
            if a[i] == entry then
                debugLog(" -- '" .. tostring(a[i+1]) .. "'")
                return a[i+1]
            end
        end
    end
    
    debugLog(" --- NOT PRESENT")
end

local function setSavedEntry(m, entry, val)
    local name = v.getMapName(m)
    debugLog("setSavedEntry(" .. name .. " , " .. entry .. " , " .. val .. ")")
    
    local flag = "mapsave_" .. name
    local s = getStringFlag(flag)
    local updated = false
    local a
    
    if s == "" then
        a = {}
    else
        a = s:explode(" ")
        for i = 1, #a do
            if a[i] == entry then
               a[i+1] = tostring(val)
               updated = true
               break
            end
        end
    end
    
    
    if not updated then
        table.insert(a, entry)
        table.insert(a, val)
    end
    
    s = table.concat(a, " ")
    setStringFlag(flag, s)
end

function v.getSavedTime(m)
    local x = getSavedEntry(m, "-time") or 0
    return tonumber(x) or 0
end

function v.setSavedTime(m, t)
    return setSavedEntry(m, "-time", t)
end

function v.hasParTime(m) -- whether player has achieved par time
    local t = v.getSavedTime(m)
    return t > 0 and v.hasSeenMap(m) and (t <= v.getParTime(m))
end

function v.getSavedDeaths(m)
    local x = getSavedEntry(m, "-deaths") or 0
    return tonumber(x) or 0
end

function v.setSavedDeaths(m, t)
    return setSavedEntry(m, "-deaths", t)
end

function v.hasBeatenMap(m)
    return v.getSavedTime(m) > 0
end

function v.hasSeenMap(m)
    local x = getSavedEntry(m, "-seen") or false
    return x
end

function v.setSeenMap(m)
    setSavedEntry(m, "-seen", 1)
end

function v.getDoneMapsByEntryMap(mn)
    if not mn then mn = getMapName() end
    local c = 0
    local i = 1
    while true do
        local data = v.getMapData(i)
        if not data then
            break
        end
        i = i + 1
        if data.entry == mn and v.hasBeatenMap(data.name) and not data.warpzone then
            c = c + 1
        end
    end
    return c
end

-- rewarded only used for hub/special maps
function v.setRewarded(m, yes)
    local val
    if yes then
        val = 1
    else
        val = 0
    end
    return setSavedEntry(m, "-rewarded", val)
end

function v.wasRewarded(m)
    local x = getSavedEntry(m, "-rewarded") or 0
    return tonumber(x) ~= 0
end

function v.getSavedBandaid(m)
    local x = getSavedEntry(m, "-bandaid") or 0
    return tonumber(x) or 0
end

function v.setSavedBandaid(m, t)
    return setSavedEntry(m, "-bandaid", t)
end

function v.getTotalBandaidsCollected()
    local i = 1
    local count = 0
    local data
    while true do
        data = v.getMapData(i)
        if not data then
            return count
        end
        i = i + 1
        count = count + v.getSavedBandaid(data.name)
    end
end

function v.getTotalDeaths()
    local i = 1
    local count = 0
    while true do
        count = count + v.getSavedDeaths(i)
        if not v.getMapData(i) then
            return count
        end
        i = i + 1
    end
end


v.__mapsave_loaded = true
