-- This node ensures all the updated Lua functions do what is expected.
-- It will work for any version, but requires 1.1.3+ to pass.
-- (Possibly the latest icculus.org repo revision, or maybe even my own: https://bitbucket.org/fgenesis/aquaria)
-- Specifically, it checks for the most critical things that would break the mod if they were wrong.

-- DO NOT SKIP THESE CHECKS! THE MOD WILL BREAK OTHERWISE, AND THEN EXPLODE!

-- okay, i admit the checks might be a bit too detailed regarding the individual changesets,
-- but better safe than sorry.
-- And we never know what may break in future versions.


local REQ_VERSION = 10103
local TEST_FILE = "scripts/songs.lua"

if v and type(v) == "table" then
    v.vfail = false
else
    v = { vfail = true }
end

v.errs = false
v.needinit = true
v.t = 0
v.bad = false

local function proceed()
    overrideZoom(0)
    if getStringFlag("seen_intro") == "" then
        loadMap("introscene")
    else
        loadMap("main_hub")
    end
end

local function addError(err)
    if not v.errs then
        v.errs = {}
    end
    
    table.insert(v.errs, err)
end

local function makeVerString(ver)
    -- eh.. no rounding erros doing it this way?
    local maj = math.floor(math.floor(ver / 10000) * 10000)
    local med = math.floor(math.floor((ver - maj) / 100) * 100)
    local min = ver - maj - med
    return string.format("%d.%d.%d", maj / 10000, med / 100, min)
end

local function doChecks1(me)

    if not AQUARIA_VERSION then
        addError("Unknown version (pre-opensource)")
    elseif AQUARIA_VERSION < REQ_VERSION then
        addError("Outdated version: " .. makeVerString(AQUARIA_VERSION))
    end
    
    -- some scripts expect this exists (was too lazy to add "if not v then v = {}" everywhere to fix this)
    -- but why fix it if the script would break somewhere else anyways.
    if v.vfail then
        addError("Old script interface present")
    end

    -- does dofile support relative paths?
    local ok, err = pcall(dofile, TEST_FILE)
    if not ok then
        addError("No relative script path support")
        debugLog("VERSIONCHECK DOFILE ERROR: " .. err)
    end
    
    -- node functions work?
    if rawget(_G, "node_getLabel") then -- if this does not exist no reason to check for others
    
        -- both must ignore params in search-by-name
        local node = getNode("check")
        local node2 = node_getNearestNode(me, "check")
        
        if node == 0 then
            addError("Node functions fail (#1)")
        else
            if node_getLabel(node) ~= "check"
            or node ~= node2
            or node_getContent(node) ~= "test"
            or  node_getAmount(node) ~= 12345
            then
                addError("Node functions fail (#2)")
            end
        end
    else
        addError("Required node functions missing")
    end
    
    -- representing my commits. There are more this mod needs, but they were all added in related changesets.
    if not (
            rawget(_G, "obj_scale")
        and rawget(_G, "obj_getRotationOffset")
        and rawget(_G, "entity_stopAnimation")
    ) then
        addError("Missing extension functions")
    end
end

local function doChecks2(me)
    local n = getNaija()
    local node = getNode("check")
    local node2 = entity_getNearestNode(n, "check")
    local e = node_getNearestEntity(me, "naija", n)
    
    if node ~= node2 
    or e ~= 0 then
        addError("Entity/Node enum failed")
    end
end

-- BEWARE: this function can be run only if all checks were passed!
local function trollAppleUsers()
    --setControlHint("A mouse isn't required, but neither is bathing.\nThink about it.", false, false, false, 4, "mouse", nil, 0.37)
    
    local LR_HUD = 56 -- aqmodlib not yet loaded
    
    local underlay = createQuad("black")
    quad_setLayer(underlay, LR_HUD)
    quad_followCamera(underlay, 1)
    quad_alphaMod(underlay, 0.61)
    quad_scale(underlay, 60, 4.2)
    quad_setPosition(underlay, 400, 480)
    
    local bx, by = node_getPosition(getNode("bubblepos"))
    
    local b = createQuad("thinkbubble")
    quad_setPosition(b, bx, by)
    quad_setLayer(b, LR_HUD)
    quad_alpha(b, 0.5)
    quad_scale(b, 1.2, 1.2)
    
    local m = createQuad("mouse")
    quad_setLayer(m, LR_HUD)
    quad_setPosition(m, bx, by - 30)
    quad_alpha(b, 0.6)
    quad_scale(m, 0.8, 0.8)
    
    local t = createBitmapText("A mouse isn't required, but neither is bathing.\nThink about it.", 15, 400, 444)
    obj_followCamera(t, 1)
    obj_moveToFront(t)
    obj_scale(t, 1.6, 1.6)
    
    
    if isPlat(PLAT_MAC) then
        t = createBitmapText("(And in case your mouse has only one button, good luck.)", 15, 400, 520)
        obj_followCamera(t, 1)
        obj_moveToFront(t)
        obj_scale(t, 1, 1)
        
        v.t = v.t + 2
    end
end


function init(me)

    local n = getNaija()
    bone_alpha(entity_getBoneByIdx(n, 17), 0)
    bone_alpha(entity_getBoneByIdx(n, 20), 0)
    bone_alpha(entity_getBoneByIdx(n, 21), 0)
    bone_alpha(entity_getBoneByIdx(n, 18), 0)
    bone_alpha(entity_getBoneByIdx(n, 22), 0)
    bone_alpha(entity_getBoneByIdx(n, 15), 0)
    bone_alpha(entity_getBoneByIdx(n, 19), 0)
    
    entity_setState(n, 12345)
    entity_animate(n, "sitthrone", -1)
    avatar_toggleCape(false)
    
    doChecks1(me)
end


function update(me, dt)
    if v.needinit then
        v.needinit = false
        
        entity_updateSkeletal(getNaija(), 1)
        cam_snap()
        
        doChecks2(me)
        
        if v.errs and #v.errs ~= 0 then
            v.bad = true
            playMusicStraight("flyaway") -- yup, that fits
            disableInput()
            centerText("You have an old/incompatible Aquaria version!")
            voice("naija_endingpart1c")
            v.t = 7
            setSceneColor(0, 0.3, 0.4, 7)
            overrideZoom(0.5)
            overrideZoom(1.5, 17)
            setCutscene(true, true)
        else
            debugLog("checks passed, starting for real")
            overrideZoom(1)
            cam_snap()
            v.t = 3 -- need a timer, otherwise the map won't be loaded (still in init phase here)
            trollAppleUsers()
        end
    end
    
    if v.bad then
        disableInput()
    end
        
    
    if v.t > 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            if v.bad then
                local n = getNaija()
                setNaijaHeadTexture("blink", 20)
                local msg = "Sanity checks failed:\n \n-- " .. table.concat(v.errs, "\n-- ")
                    .. "\n \nYou need at least " .. makeVerString(REQ_VERSION) .. "+"
                v.errs = false
                debugLog(msg)
                centerText(msg)
                setSceneColor(1, 0, 0, 12)
                wait(7) -- 7
                
                centerText("Time to upgrade!" .. string.rep(" \n", 7) .. "Check the bit-blot.com forums!")
                wait(3) -- 10
                
                setNaijaHeadTexture("smile", 7)
                wait(2) -- 12
                
                voice("naija_quitjabba")
                fadeOut(3)
                wait(3) -- 15
                
                setCutscene(false)
                v.bad = false
                goToTitle()
            else
                proceed()
            end
        end
    end
end

function activate(me)
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function song(id)
end
