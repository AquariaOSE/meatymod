
if rawget(v, "__mapmgr_loaded") then return end

-- name: as passed in loadMap("*.xml")
-- partime: A+ if <= this time
-- entry: "overworld" map that links to this map. When "Exit to map" is chosen in the main menu, return to this map.
--        If entry is false, the map is treated as a special map (without death protection and all the "meaty" things)
-- desc: text that is shown when the map is first entered.
-- reward: Either a SONG_* constant, or a function.
-- bandaid: If given, this map has a bandaid node. Can be a number or boolean. Be sure this is kept in sync with the actual maps!
--          The actual bandaid rewards table is in logic_hubmaps.lua.
-- warpzone: If given, this map is counted as a warpzone map, and not reachable in the normal map order. wmap nodes leading to this map will not be active unless this map was seen once.
-- noscene: The reward (as a function) will be executed without the short scene if this is set.
-- !! Each zone should end with a zone indicator/terminator, that also has the map name and desc.
local MAPLIST =
{
    -- REEF MAPS START
    { name = "helloworld",      partime = 3, entry = "main_reef", desc = "Hello World!" },               -- easy as crap                      [SMB remastered]
    { name = "upward",          partime = 10, entry = "main_reef", desc = "Upward" },                    -- remind about proper walljumping   [SMB remastered]
    { name = "bladecatcher",    partime = 10, entry = "main_reef", desc = "Bladecatcher" },              -- intro to saws                     [SMB remastered]
    { name = "diverge",         partime = 16, entry = "main_reef", desc = "Diverge", bandaid = true },   -- walljump + saws                   [SMB remastered]
    { name = "thebit",          partime = 6, entry = "main_reef", desc = "The Bit" },                    -- harder walljump (fall = death)    [SMB remastered]
    { name = "safetythird",     partime = 15, entry = "main_reef", desc = "Safety Third" },              -- intro to dissolving blocks        [SMB remastered]
    { name = "tommyscabin",     partime = 10, entry = "main_reef", desc = "Tommy's Cabin", bandaid = true }, -- intro to moving saws          [SMB remastered] **warpzone -> cavestory**
    { name = "bloodmountain",   partime = 10, entry = "main_reef", desc = "Blood Mountain" },            -- moving saws + walljump            [SMB remastered]
    { name = "cactusjumper",    partime = 20, entry = "main_reef", desc = "Cactus Jumper" },             -- intro to saw shooters             [SMB remastered]
    { name = "sidewinder",      partime = 24, entry = "main_reef", desc = "Sidewinder" },                -- intro to vertical saw shooters    [SMB remastered]
    { name = "sardines",        partime = 18, entry = "main_reef", desc = "Sardines in a Tin" },         -- moving saws + steady walljump     [SMP remastered, out of order]
    { name = "thecliff",        partime = 20, entry = "main_reef", desc = "The Cliff", bandaid = true }, -- more jump practice (wall normal influence)
    
    -- REEF warp zones
    { name = "cavestory",       partime = 50, entry = "main_reef", desc = "Cave Story", warpzone = true, bandaid = true}, -- from tommyscabin
    --{ name = "dbg",             partime = 5, entry = "main_reef", desc = "DEBUG MAP", warpzone = true },
   
    { name = "main_reef",       partime = -1, entry = false,      desc = "The Reef", reward = SONG_SUNFORM },

    
    -- ABYSS MAPS START
    { name = "downward",        partime = 20, entry = "main_abyss", desc = "Downward", bandaid = true },   -- intro to darkness, currents + saws
    { name = "ldarkness",       partime = 25, entry = "main_abyss", desc = "Lightness and Darkness" },     -- intro to key + door 
    { name = "alonedark",       partime = 27, entry = "main_abyss", desc = "Alone in the Dark" },          -- saw shooters, key + door
    { name = "dgforward",       partime = 24, entry = "main_abyss", desc = "Dragging Forward" },           -- currents, saws, saw shooters
    { name = "soflight",        partime = 13, entry = "main_abyss", desc = "Source of Light" },            -- MANY saw shooters
    { name = "tmahead",         partime = 36, entry = "main_abyss", desc = "Up, up, the Mountain ahead", bandaid = true }, -- all of it
        
    { name = "main_abyss",      partime = -1, entry = false,       desc = "The Abyss" , reward = SONG_NATUREFORM },

    
    -- DESERT MAPS START
    { name = "dusted",          partime = 24, entry = "main_desert", desc = "Dusted!" },                        -- intro to sand + gears
    { name = "desminds",        partime = 60, entry = "main_desert", desc = "Deserted Minds", bandaid = true },  -- gears, saws
    { name = "angrybirds",      partime = 27, entry = "main_desert", desc = "Angry Birds" },                     -- intro to exploding parrots **warpzone -> iwbtg**
    { name = "thepump",         partime = 45, entry = "main_desert", desc = "The Pump", bandaid = true },        -- gears, saws, pipe travelling (*has shortcut*)
    { name = "sandmachine",     partime = 33, entry = "main_desert", desc = "Sand in the Machinery", bandaid = true }, -- sand, gears, saws
    { name = "nowhere",         partime = 80, entry = "main_desert", desc = "On the way to nowhere" },           -- first advancing wall of doom (*has shortcut*)
    
    { name = "iwbtg",           partime = 42, entry = "main_desert", desc = "I wanna be the ... what?", warpzone = true },
    
    { name = "main_desert",     partime = -1, entry = false,        desc = "The Desert", reward = SONG_SPIRITFORM },
    
    
    -- VOLCANO MAPS START
    { name = "envdmg",          partime = 85, entry = "main_volcano", desc = "Environmental Damage" },              -- intro to lava -- long map
    { name = "workingrobot",    partime = 28, entry = "main_volcano", desc = "Heavy working Robot" },               -- lots of gear jumping **warpzone -> cavestory2**
    { name = "barrelroll",      partime = 35, entry = "main_volcano", desc = "Do a Barrel Roll!", bandaid = true }, -- inside of a rolling thing (*has shortcut*)
    { name = "throwup",         partime = 33, entry = "main_volcano", desc = "Throwing Up", bandaid = true },       -- raising lava
    { name = "shelter",         partime = 40, entry = "main_volcano", desc = "Shelter" },                           -- first missile launcher. Blocks that need to be crumbled using missiles
    { name = "burninghate",     partime = 25, entry = "main_volcano", desc = "Burning Hate" },                      -- narrow shaft, complicated jump angles
    
    { name = "cavestory2",      partime = 100, entry = "main_volcano", desc = "Bloody Sanctum", warpzone = true },  -- hard version of the first cavestory warpzone
    
    { name = "main_volcano",    partime = -1, entry = false,         desc = "The Volcano", reward = SONG_BEASTFORM },

    
    -- NIGHTMARE MAPS START
    { name = "nightmare",       partime = 28, entry = "main_nightmare", desc = "Nightmare" },               -- first actual entities [remastered nightmare area from beginning]
    { name = "home",            partime = 34, entry = "main_nightmare", desc = "Home?", bandaid = true },   -- precise jumping [vedhacave remastered] **warpzone -> homehard**
    { name = "haunted",         partime = 50, entry = "main_nightmare", desc = "Haunted", bandaid = true },-- bullet hell [mainarea remastered]
    { name = "noescape",        partime = 50, entry = "main_nightmare", desc = "No Escape!" },              -- chased by saw, sawshooters, entitites, bullet hell [trainingcave remastered]
    { name = "energized",       partime = 65, entry = "main_nightmare", desc = "Energized" },        -- energy temple based, missiles, angrybirds, gears [energytemple03 remastered] **warpzone -> challenge**
    { name = "mithalas",        partime = 50, entry = "main_nightmare", desc = "Nothing remains", bandaid = true }, -- lava, lavaballs, jump trickery required [mithalas remastered]
    
    { name = "homehard",        partime = 120, entry = "main_nightmare", desc = "Deja vu!", warpzone = true},
    { name = "challenge",        partime = 19, entry = "main_nightmare", desc = "Challenge accepted!", bandaid = true, warpzone = true},
    
    
    { name = "main_nightmare",  partime = -1, entry = false,            desc = "The Nightmare", reward = SONG_ENERGYFORM },
    
    
    -- SPECIAL LAST LEVELS
    { name = "gravity",     partime = 32, entry = "main_retribution", desc = "Flippin' Gravity!" },     -- kinda easy map but upside down for lots of brain screw
    { name = "upisdown",     partime = 130, entry = "main_retribution", desc = "Up is down" },          -- normal in water, upside down on land. Little trick required at end.
    { name = "13lair",     partime = 70, entry = "main_retribution", desc = "Retribution" },            -- missile macross massacre / racetrack [thirteenlair remastered]
    
    { name = "final",     partime = -1, entry = "main_retribution", desc = "Paying back", warpzone = true },  -- Final boss. WZ so that the map warp appears when this map was seen once
    
    { name = "main_retribution",    partime = -1, entry = false, desc = "", noscene = true },
    
    
    -- feel free to add any other maps here
    
    --{ name = "main_bonus",      partime = -1,   entry = false,            desc = "", reward = function() centerText("FIXME: BONUS!") end },
    
}


function v.getMapIdx(m)
    if type(m) == "number" then
        return m
    end
    
    if not m then
        for i, mp in pairs(MAPLIST) do
            if isMapName(mp.name) then
                return i
            end
        end
    else
        for i, mp in pairs(MAPLIST) do
            if mp.name == m then
                return i
            end
        end
    end
    
    debugLog("inc_mapmgr: map " .. getMapName() .. " has no index")
end

local function gettab(m)
    if type(m) ~= "number" then
        m = v.getMapIdx(m)
    end
    
    return MAPLIST[m]
end

function v.getMapData(m)
    return gettab(m)
end

-- starts with 1.
function v.getMapNameForEntryByIndex(idx, entry)
    local c = 0
    for _, m in ipairs(MAPLIST) do
        if m.entry == entry then
            c = c + 1
            if c == idx then
                return m.name
            end
        end
    end
end

-- starts with 1.
function v.getMapIndexForEntryByName(name, entry)
    local c = 0
    for _, m in ipairs(MAPLIST) do
        if m.entry == entry then
            c = c + 1
            if name == m.name then
                return c
            end
        end
    end
    return -1
end

function v.getMapName(m)
    if not m then return getMapName() end
    if type(m) == "string" then return m end
    
    m = gettab(m)
    if m then
        return m.name
    end
end

function v.getParTime(m)
    --[[if not m or type(m) == "string" then
        m = v.getMapIdx(m)
    end
    if not m then
        return -1
    end
    return MAPLIST[m].partime]]
    
    m = gettab(m)
    if m then
        return m.partime
    end
    return -1
end

function v.getNextMapName(m)
    local idx = v.getMapIdx(m)
    if not idx then
        return
    end
    while true do
        idx = idx + 1
        local map = MAPLIST[idx]
        if not map then
            errorLog("MAP LIST EMPTY")
            return "main_hub"
        end
        
        if not map.warpzone then 
            return map.name
        end
    end
end

function v.getEntryMap(m)
    m = gettab(m)
    if m then
        return m.entry
    end
end


function v.getMapDesc(m)
    m = gettab(m)
    if m then
        return m.desc
    end
    return ""
end

function v.isSpecialMap(m)
    m = gettab(m)
    if m then
        return not m.entry
    end
    return true -- if in doubt, always assume special
end

function v.getTotalMapsByEntryMap(mn)
    if not mn then mn = getMapName() end
    local c = 0
    for _, m in pairs(MAPLIST) do
        if m.entry == mn and not m.warpzone then
            c = c + 1
        end
    end
    return c
end

function v.isWarpzoneMap(m)
    m = gettab(m)
    if m then
        return m.warpzone
    end
    return false
end

function v.getTotalBandaidsInGame()
    local i = 1
    local count = 0
    local data
    while true do
        data = v.getMapData(i)
        if not data then
            return count
        end
        if data.bandaid then
            if type(data.bandaid) == "number" then
                count = count + data.bandaid
            else
                count = count + 1
            end
        end
        i = i + 1
    end
end

function v.getBandaidCount(m)
    m = gettab(m)
    if m then
        if m.bandaid then
            if type(m.bandaid) == "boolean" then
                return 1
            else
                return tonumber(m.bandaid) -- just to be sure
            end
        end
    end
    return 0
end

v.__mapmgr_loaded = true
