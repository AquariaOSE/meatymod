
-- death preventer, time tracker

-- TODO: add joystick support!

UI = {}

UI.timertext = 0
UI.inMenu = false
UI.menu = {}
UI.noinput = false
UI.isEscInner = false
UI.isEscOuter = false
UI.curSel = nil
UI.exitMenu = false -- force flag
UI.wasLMB = false

local DEFAULT_ENTRY_MAP = "main_hub" -- in case something goes wrong

local TEXTSCALE = 1.6
local TEXTSCALE_SEL = 1.7

local function wasMapBeaten()
    --return v.getSavedTime() > 0
    return v.hasBeatenMap()
end

local function formatTimeStr()
    --return string.format("%000.2f | %d", PLAYTIME, DEATHCOUNTER)
    return string.format("%000.2f", PLAYTIME)
end

local function hideMenu()
    for _, elem in pairs(UI.menu) do
        obj_alpha(elem, 0)
    end
end

local function showMenu()
    for _, elem in pairs(UI.menu) do
        obj_alpha(elem, 1)
    end
    --obj_alpha(UI.menu.underlay, 0.2, 0.1)
end


-- HACK, but otherwise we get drawn into the top-left corner...
local function doMenuSave()
    hideMenu()
    local node = v.me -- the logic node itself
    local x, y = node_getPosition(node)
    node_setPosition(node, entity_getPosition(v.n))
    savePoint(node)
    node_setPosition(node, x, y)
    showMenu()
    UNSAVED_PROGRESS = false
end

local function getMouseItemName()
    local x, y = getMousePos()
    
    if x >= 445 and x <= 700 then
        if y >= 192 and y < 228 then
            return "resume"
        elseif y >= 228 and y < 266 then
            return "save"
        elseif y >= 266 and y < 307 then
            return "exitmap"
        elseif y >= 307 and y < 346 then
            return "replays"
        elseif y >= 346 and y < 385 then
            return "exittitle"
        end
    end
    
    if x >= 120 and x <= 330 then
        if y >= 192 and y < 228 then
            return "booster"
        elseif y >= 228 and y < 266 then
            return "booster2"
        elseif y >= 266 and y < 307 then
            return "doublejump"
        elseif y >= 307 and y < 346 then
            return ""
        elseif y >= 346 and y < 385 then
            return "nogore"
        end
    end

    return ""
end

local function getMouseItem()
    return UI.menu[getMouseItemName()]
end

local function updateActivePowerup(activename, force, silent)
    if not force and activename == getStringFlag("ACTIVE_POWERUP") then
        activename = ""
        force = true
        setStringFlag("ACTIVE_POWERUP", "")
        if not silent then
            playSfx("pet-off")
        end
    end
    
    if force or activename ~= getStringFlag("ACTIVE_POWERUP") then
        for name, elem in pairs(UI.menu) do
            obj_color(elem, 1, 1, 1)
            if name == activename then
                setStringFlag("ACTIVE_POWERUP", name)
                obj_color(elem, 1, 0, 0, 0.5, -1, 1, 0)
                if not silent then
                    playSfx("pet-on")
                end
            end
        end
    end
end

local function handleMenuSelect()
    -- TODO: joystick support
    local c = getMouseItem()
    if not c then
        return
    end   
    
    if c ~= UI.curSel then
        if UI.curSel then
            obj_scale(UI.curSel, TEXTSCALE, TEXTSCALE)
        end
        obj_scale(c, TEXTSCALE_SEL, TEXTSCALE_SEL)
    end
    UI.curSel = c
    
    local sel = UI.menu.sel
    local x, y = obj_getPosition(c)
    obj_setPosition(sel, obj_x(c) - 140, obj_y(c) + 10)
    
    local lmb = isLeftMouse()
    if lmb and not UI.wasLMB then
        playSfx("click")
        if c == UI.menu.resume then
            UI.exitMenu = true
        elseif c == UI.menu.exitmap then
            UI.exitMenu = true
            LAST_MAP_BEFORE_RETURN = getMapName()
            local entrymap = v.getEntryMap() or DEFAULT_ENTRY_MAP
            NEXT_MAP = false -- HACK: prevent logic_replay.lua from changing the map when it registers left-click
            debugLog("exiting from map " .. LAST_MAP_BEFORE_RETURN .. " to map " .. entrymap)
            loadMap(entrymap)
        elseif c == UI.menu.replays then
            if not wasMapBeaten() then
                playNoEffect()
                
                return
            end
            UI.exitMenu = true
            NEXT_MAP = getMapName() -- HACK: logic_replay.lua checks for this

        elseif c == UI.menu.save then
            UI.exitMenu = true
            doMenuSave()
        elseif c == UI.menu.exittitle then
            if UNSAVED_PROGRESS then
                pause()
                local really = confirm("", "exit")
                unpause()
                if really then
                    UI.exitMenu = true
                    goToTitle()
                end
            else
                UI.exitMenu = true
                goToTitle()
            end
        elseif c == UI.menu.nogore then
            if CFG_GORE_LEVEL == 0 then
                CFG_GORE_LEVEL = 2
                setStringFlag("CFG_GORE_LEVEL", "2")
                playSfx("naijaugh2")
            elseif CFG_GORE_LEVEL == 1 then
                CFG_GORE_LEVEL = 0
                setStringFlag("CFG_GORE_LEVEL", "0")
                playSfx("naijasigh3")
            else -- 2
                CFG_GORE_LEVEL = 1
                setStringFlag("CFG_GORE_LEVEL", "1")
                playSfx("naijaew1")
            end
        elseif c == UI.menu.booster then
            updateActivePowerup("booster")
        elseif c == UI.menu.booster2 then
            updateActivePowerup("booster2")
        elseif c == UI.menu.doublejump then
            updateActivePowerup("doublejump")
        end
    end
    
    UI.wasLMB = lmb
end

-- quite hackish, because we don't have dt here
local function updateMenuItems()
    local c = getMouseItem()
    local sel = UI.menu.sel
    if not c then
        obj_alphaMod(sel, 0)
        return
    end
    
    obj_alphaMod(sel, 1)
    quad_scale(sel, 0.5, 0.5)
    
    if c == UI.menu.resume then
        local newrot = obj_getRotation(UI.menu.sel) + 6
        newrot = newrot % 360
        obj_rotate(sel, newrot)
        obj_setTexture(sel, "energysong-rune-0003")
    elseif c == UI.menu.exitmap then
        obj_rotate(sel, 0)
        obj_setTexture(sel, "energysong-rune-0002")
    elseif c == UI.menu.replays then
        obj_rotate(sel, 0)
        obj_setTexture(sel, "energysong-rune-0001")
    elseif c == UI.menu.save then
        local newrot = obj_getRotation(UI.menu.sel) + 3
        newrot = newrot % 360
        obj_rotate(sel, newrot)
        obj_setTexture(sel, "saveglowsmall")
    elseif c == UI.menu.exittitle then
        obj_rotate(sel, 0)
        obj_setTexture(sel, "menu-note4")
    elseif c == UI.menu.nogore then
        obj_rotate(sel, 0)
        obj_scale(sel, 0.4, 0.4)
        if CFG_GORE_LEVEL == 0 then
            obj_setTexture(sel, "spikes/normal")
            text_setText(UI.menu.nogore, "No blood")
        elseif CFG_GORE_LEVEL == 1 then
            obj_setTexture(sel, "spikes/bloody")
            text_setText(UI.menu.nogore, "Blood on")
        else
            obj_setTexture(sel, "spikes/bloody2")
            text_setText(UI.menu.nogore, "Full gore")
        end
    elseif c == UI.menu.booster then    
        local newrot = obj_getRotation(UI.menu.sel) + 4
        newrot = newrot % 360
        obj_rotate(sel, newrot)
        obj_setTexture(sel, "naija/booster")
    elseif c == UI.menu.booster2 then    
        local newrot = obj_getRotation(UI.menu.sel) + 4
        newrot = newrot % 360
        obj_rotate(sel, newrot)
        obj_setTexture(sel, "naija/booster2")
    elseif c == UI.menu.doublejump then    
        local newrot = obj_getRotation(UI.menu.sel) + 4
        newrot = newrot % 360
        obj_rotate(sel, newrot)
        obj_setTexture(sel, "iwbtg/doublejump") -- FIXME
    end
    
end

local function makeMenuText(s, x, y)
    local t = createBitmapText(s, nil, x, y)
    obj_setLayer(t, LR_HUD3)
    obj_followCamera(t, 1)
    obj_scale(t, TEXTSCALE, TEXTSCALE)
    return t
end

UI.init = function()

    -- deactivate & unhook on "overworld" maps and the like
    local special = v.isSpecialMap()
    if special then
        v.logic.ui = nil
    end

    -- do not display desc if this is set,
    -- and clear the setting in next update loop
    if LAST_MAP_BEFORE_RETURN then
        v.pushTQ(0.01, function() LAST_MAP_BEFORE_RETURN = false end)
        v.logic.ui = nil
        return
    end

    local desc = v.getMapDesc()
    if desc and desc ~= "" then
        centerText(desc)
    end

    if special then
        return
    end
    
    local vx, vy = getScreenVirtualOff()
    
    -- time tracker text
    v.timertext = createBitmapText("", 10, 40 - vx, 5 - vy)
    obj_followCamera(v.timertext, 1)
    obj_color(v.timertext, 1, 0, 0)
    
    -- time tracker bg box
    local box = createQuad("hintbox")
    quad_scale(box, 0.3, 0.2)
    quad_alpha(box, 0.8)
    quad_setLayer(box, LR_HUD)
    quad_followCamera(box, 1)
    quad_setPosition(box, 40 - vx, 15 - vy)
    quad_moveToBack(box)
    
    -- pause menu
    local underlay = createQuad("black")
    quad_setLayer(underlay, LR_HUD2)
    quad_followCamera(underlay, 1)
    quad_alphaMod(underlay, 0.61)
    quad_scale(underlay, 60, 8.5) -- 7.2
    quad_setPosition(underlay, 400, 320) -- 290
    
    -- right column
    local x = 540
    local resume    = makeMenuText("    Resume Game", x, 190)
    local save      = makeMenuText(" Save Game", x, 230)
    local exitmap   = makeMenuText("  Exit to map", x, 270)
    local replays   = makeMenuText("   View replays", x, 310)
    local exittitle = makeMenuText("    Exit to title", x, 350)
    
    -- left column
    x = 200
    local booster, booster2, doublejump, nogore
    if getStringFlag("HAS_BOOSTER") ~= "" then
        booster = makeMenuText("    Booster v0.8", x, 190)
    end
    if getStringFlag("HAS_BOOSTER2") ~= "" then
        booster2   = makeMenuText("    Booster v2.0", x, 230)
    end
    if getStringFlag("HAS_DOUBLEJUMP") ~= "" then
        doublejump   = makeMenuText("    Double Jump", x, 270)
    end
    nogore = makeMenuText("     Blood?", x, 350)
    
    
    -- additional stuff
    local bandaids = v.getTotalBandaidsCollected()
    if bandaids > 0 then
        local bandaidText = makeMenuText(string.format("%d / %d", bandaids, v.getTotalBandaidsInGame()), 440, 415)
        local bandaidIcon = createQuad("ingredients/legendary-cake")
        quad_scale(bandaidIcon, 0.7, 0.7)
        quad_setPosition(bandaidIcon, 340, 435)
        quad_setLayer(bandaidIcon, LR_HUD3)
        quad_followCamera(bandaidIcon, 1)
        
        UI.menu.bandaidText = bandaidText
        UI.menu.bandaidIcon = bandaidIcon
    end
    
    
    local sel = createQuad("energysong-rune-0003")
    quad_setLayer(sel, LR_HUD3)
    quad_followCamera(sel, 1)
    quad_scale(sel, 0.5, 0.5)
    quad_setPosition(sel, 400, 200)
    
    UI.menu.sel = sel
    UI.menu.underlay = underlay
    UI.menu.resume = resume
    UI.menu.save = save
    UI.menu.exitmap = exitmap
    UI.menu.replays = replays
    UI.menu.exittitle = exittitle
    
    UI.menu.booster = booster
    UI.menu.booster2 = booster2
    UI.menu.doublejump = doublejump
    UI.menu.nogore = nogore
    
    if not wasMapBeaten() then
        --obj_alphaMod(replays, 0)
        obj_color(replays, 0.3, 0.3, 0.3)
    end
    
    updateActivePowerup(getStringFlag("ACTIVE_POWERUP"), true, true)
    
    hideMenu()
end


UI.postInit = function()
end

local function enterMenu()
    if UI.inMenu then
        return false
    end
    MENU_OPEN = true
    UI.noinp = not isInputEnabled()
    UI.wasLMB = isLeftMouse()
    enableInput()
    UI.inMenu = true
    pause()
    return true
end

local function leaveMenu()
    unpause()
    if UI.noinp then
        disableInput()
    end
    local vx, vy = entity_getVel(v.n)
    watch(FRAME_TIME) -- if this is not here, the game registers left-click and naija jumps around
    entity_clearVel(v.n) -- just in case
    entity_addVel(v.n, vx, vy) -- because watch() sets it to 0.
    UI.inMenu = false
    MENU_OPEN = false
    MENU_OPEN_DELAY = 0.3
end

local function runMenu()

    if not enterMenu() then
        return
    end
    
    debugLog("open menu")
    showMenu()
    
    local isEsc
    UI.isEscInner = true
    
    local returnOnRelease = false
    
    while true do
        isEsc = isEscapeKey()
        if (returnOnRelease and not isEsc) or UI.exitMenu then
            UI.exitMenu = false
            break
        end
        
        if (isEsc and not UI.isEscInner) or UI.exitMenu then
            returnOnRelease = true
        end
        
        pause()
        wait(FRAME_TIME)
        unpause()
        UI.isEscInner = isEsc
        
        --local x, y = getMousePos()
        --debugLog("x: " .. x .. "; y: " .. y)
        
        updateMenuItems()
        handleMenuSelect()
    end
    
    debugLog("close menu")
    hideMenu()
    leaveMenu()
end

UI.update = function(dt)
    
    --if UI.timertext ~= 0 then
        text_setText(v.timertext, formatTimeStr())
    --end
    
    -- custom menu on ESC
    if isEscapeKey() then
        if not UI.isEscOuter then
            runMenu()
        end
        UI.isEscOuter = true
    else
        UI.isEscOuter = false
    end
    
    if not MENU_OPEN then
        MENU_OPEN_DELAY = MENU_OPEN_DELAY - dt
        if MENU_OPEN_DELAY < 0 then
            MENU_OPEN_DELAY = 0
        end
    end
end

v.logic.ui = UI
