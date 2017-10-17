-- node_logic - pushing the game engine to its limits

-- This is basically a plugin manager; a single node that loads a set of plugins,
-- each doing its own stuff.
-- If a plugin fails to load, an error message will show.

-- Exactly one (!) logic node must be placed in each map.


--[[ bad backup code - will be overridden by the code below ]]--
-- hint: if it looks fishy to you, it was intentional.
local failtime = 3

function init(me)
    loadMap("_versioncheck") -- this hopefully does the right thing
    centerText("ERROR!")
    shakeCamera(20, 4)
    playSfx("healthupgrade-open")
end

function update(me, dt)
    setSceneColor(1, 0, 0, 0)
    failtime = failtime - dt
    if failtime < 0 then
        entity_animate(n, "agony", -1)
        goToTitle()
    end
end


--[[ real code start ]]--

-- quick check for correct version
if not (AQUARIA_VERSION and AQUARIA_VERSION >= 10103 and v and rawget(_G, "obj_getRotationOffset")) then
    return
end



dofile("scripts/_loader.lua") -- load aqmodlib
dofile("scripts/inc_flags.lua")
dofile("scripts/inc_timerqueue.lua")
dofile("scripts/inc_mapsave.lua") -- THIS IS IMPORTANT


v.__needinit = true
v.n = 0
v.me = 0
v.logic = false
v._err = 0
v._errtimer = 0


local function loadPlugin(p)
    local f = "scripts/logic_" .. p .. ".lua"
    local ok, err = pcall(dofile, f)
    if ok then
        return ""
    end
   
    debugLog("LOGIC: Error loading file: " .. f .. " -- ERROR follows:")
    debugLog(err)
    
    return err .. "\n\n"
end

local function loadPlugins()
    local err =
       loadPlugin("precache")   -- must be loaded first.
    .. loadPlugin("antideath")
    .. loadPlugin("replay")
    .. loadPlugin("ui")
    .. loadPlugin("sunform")
    .. loadPlugin("portal")
    .. loadPlugin("misc")
    .. loadPlugin("hubmaps")
    .. loadPlugin("aircontrol")
    .. loadPlugin("sanity")
    .. loadPlugin("glitches")
    --.. loadPlugin("mapchangedetector") -- must stay OFF ! otherwise bad things happen
    --.. loadPlugin("jumpvis") -- jump vector visualization - for wussies or screenshots

    
    
    if #err > 0 then
        v._err = "=== LOGIC PLUGIN ERRORS: ===\n\n" .. err
    end
end

function init(me)
    v.logic = {}
    v.me = me
    v.n = getNaija()
    fade3(0, 4)
    
    debugLog("logic init in map " .. getMapName())
    
    loadPlugins()

    for k, f in pairs(v.logic) do
        if f.init then
            f.init()
        end
    end
end

function update(me, dt)
    if v.__needinit then
        v.__needinit = false
        v.n = getNaija()
        for k, f in pairs(v.logic) do
            if f.postInit then
                f.postInit()
            end
        end
    end
    
    v.updateTQ(dt)
    
    for k, f in pairs(v.logic) do
        f.update(dt)
    end
    
    if v._err ~= 0 then
        if v._errtimer < dt then
            entity_debugText(getNaija(), v._err)
            v._errtimer = 0.5
        else
            v._errtimer = v._errtimer - dt
        end
    end
    
end

function activate(me, ...)
    for k, f in pairs(v.logic) do
        if f.activate then
            f.activate(...)
        end
    end
end


function songNote(me, note)
end

function songNoteDone(me, note, done)
end
