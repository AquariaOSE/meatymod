-- Portal form logic script
-- BEWARE: this script heavily abuses the fact that nodes are updated *AFTER* entities!


-- config part
local CHANGE_COLOR_WITH_FLIP = false
local CHANGE_PORTAL_COLOR_WITH_RIGHTCLICK = true
local CHANGE_COLOR_WITH_SHOT = true

local PORTAL_BEAM_RANGE = 15000



-- some globals (DO NOT TOUCH THESE)
FORM_PORTAL = FORM_MAX + 1
SONG_PORTALFORM = 10

local M = {}

M.on = false
M.e = 0
M.riding = false
M.wasLMB = false
M.wasRMB = false
M.blue = false
M.flippedOnce = false
M.glow = 0
M.gunglow = 0
M.gunbone = 0
M.handbone = 0
M.armStartRot = 0 -- this is used when hanging on a wall, where entity_fh() doesn't work


local function flipPortalColor(silent)
    if M.blue then
        M.blue = false
        quad_color(M.glow, 1, 0.6, 0.3, 0.05)
        bone_color(M.gunbone, 0.8, 0.4, 0.2, 0.05)
        quad_color(M.gunglow, 1, 0.6, 0.3, 0.05)
    else
        M.blue = true
        quad_color(M.glow, 0.5, 0.5, 1, 0.05)
        bone_color(M.gunbone, 0.2, 0.2, 1, 0.05)
        quad_color(M.gunglow, 0.5, 0.5, 1, 0.05)
    end
    if not silent then
        --playSfx("switchcolor", 1.4, 0.85)
        playSfx("tick1", 1.3, 0.85)
    end
end


M.init = function()

    loadSound("portalgun_shoot_blue1")
    loadSound("portalgun_shoot_red1")
    loadSound("portal_enter1")
    loadSound("portal_enter2")
    loadSound("portal_exit1")
    loadSound("portal_exit2")
    loadSound("portal_open1")
    loadSound("portal_open2")
    loadSound("portal_open3")
    loadSound("portal_close1")
    loadSound("portal_close2")
    loadSound("portal_fizzle2")
    loadSound("portal_invalid_surface3")
    loadSound("portal_ambient_loop1")
    
    M.on = true
    M.e = createEntity("logichelp_portal")
    loadSound("switchcolor")
    loadSound("tick1")
    
    
    local q = createQuad("softglow-add")
    quad_setBlendType(q, BLEND_ADD)
    quad_scale(q, 2, 2)
    quad_alpha(q, 0.5)
    M.glow = q
    
    q = createQuad("softglow-add")
    quad_setBlendType(q, BLEND_ADD)
    quad_scale(q, 0.6, 0.6)
    quad_alpha(q, 0.5)
    M.gunglow = q
    
end


M.postInit = function()
    M.gunbone = entity_getBoneByIdx(v.n, 22)
    M.handbone = entity_getBoneByIdx(v.n, 11)
    flipPortalColor(true)
    
    -- if disabled by another node
    if getStringFlag("HAS_PORTALFORM") ~= "" then
        learnSong(SONG_PORTALFORM)
    end
end


local updateRMB -- defined below

local function _endExtraRot()
    entity_rotateOffset(v.n, 0)
end

local function _doExtraRot()
    if entity_isfh(v.n) then
        entity_rotateOffset(v.n, 360, 0.7)
    else
        entity_rotateOffset(v.n, -360, 0.7)
    end
    v.pushTQ(0.9, _endExtraRot)
end

M.update = function(dt)

    if not (M.on and isForm(FORM_PORTAL)) then
        quad_alpha(M.glow, 0, 0.1)
        quad_alpha(M.gunglow, 0, 0.1)
        return
    end
    
    M.gunbone = entity_getBoneByIdx(v.n, 22)
    M.handbone = entity_getBoneByIdx(v.n, 11)
    
    quad_alpha(M.glow, 0.65, 0.1)
    quad_alpha(M.gunglow, 0.35, 0.1)
    
    quad_setPosition(M.glow, entity_getPosition(v.n))
    
    if entity_getAnimationName(v.n, 3) == "-flourish" then -- because the game returns "" as internal form name when it tries to set flourish anim
        entity_animate(v.n, "portal-flourish", 0, 3, 0.1) -- flourish animation layer, with short transtion
        --debugLog("flourish hack")
        --_endExtraRot()
        v.pushTQ(0.2, _doExtraRot)
    end
    
    local rmb = isRightMouse()
    local riding = entity_getRiding(v.n)
    
    if rmb then
        
        if riding ~= 0 and riding ~= M.e then
            debugLog("logic_portal.lua: Riding something else, aborting...")
            return
        end
        
        if riding == 0 then
            entity_clearVel(M.e)
            entity_addVel(M.e, entity_getVel(v.n))
            entity_setRiding(v.n, M.e)
            --debugLog("riding start")
        end
    else
        M.flippedOnce = false
        if riding == M.e then
        entity_setRiding(v.n, 0)
            entity_clearVel(v.n)
            entity_addVel(v.n, entity_getVel(M.e))
            entity_clearVel(M.e)
            --debugLog("riding end")
            riding = 0
        end
        quad_setPosition(M.gunglow, bone_getWorldPosition(M.handbone))
    end
    
    if rmb or riding == M.e then
        updateRMB()
    end
    
    if rmb and not M.wasRMB then
        if CHANGE_PORTAL_COLOR_WITH_RIGHTCLICK then
            flipPortalColor()
        end
        setGameSpeed(0.2, 0.6, 0, 0, 1)
    elseif not rmb and M.wasRMB then
        setGameSpeed(1, 0.6, 0, 0, 1)
    end
    
    M.wasRMB = rmb
    
end


-- I know the math in here is very convoluted...
-- Have figured this out by careful experimentation, not actual trigonometry thinking
local function updateArmAim(vx, vy, noRecurse)
    local arm = entity_getBoneByIdx(v.n, 2)
    local arm2 = entity_getBoneByIdx(v.n, 3)
    local body = entity_getBoneByIdx(v.n, 0)
    
    bone_rotate(M.handbone, -10)
    bone_rotate(arm2, -22)
    
    local ao = vector_getAngleDeg(vx, vy) -- 0: pointing up, 90: pointing right, etc. (clockwise rotation)
    if ao < 0 then
        ao = ao + 360
    end
    
    
    local a = vector_getAngleDeg(-vx, -vy)
    local ba = bone_getWorldRotation(body)
    
    a = (a - ba)
    
    if entity_isfh(v.n) then
        a = (360 - a) --% 360
    end
    
    a = a % 360

    local fh = false -- must flip?
    
    -- just clicked?
    if not M.wasRMB then
        M.armStartRot = ao
    end
    
    if not avatar_isOnWall() then

        M.armStartRot = ao
        fh = (a > 200 and a < 350)
    else
        local t = ((ao - M.armStartRot) + 360) % 360
        --debugLog(string.format("--: a: %.1f  ba: %.1f  ao: %.1f  armstart: %.1f diff: %.1f", a, ba, ao, M.armStartRot, t))
        fh = t < (360 - 150) and t > 150
        if fh then
            --debugLog("lock flip")
            M.armStartRot = ao
        end
    end
    

    
    if fh then
    
        if not avatar_isOnWall() then
            entity_fh(v.n) 
            entity_fh(M.e)
            local x, y = entity_getPosition(M.e)
            entity_setRidingData(M.e, x, y, entity_getRotation(M.e), entity_isfh(M.e))
        end
        
        if not noRecurse then
            if M.flippedOnce and CHANGE_COLOR_WITH_FLIP then
                flipPortalColor()
            end
            M.flippedOnce = not M.flippedOnce
            return updateArmAim(vx, vy, true)
        end
    end
    
    bone_rotate(arm, a + 15)
    
    quad_setPosition(M.gunglow, bone_getWorldPosition(M.handbone))
end

local function firePortal(vx, vy)
    local nx, ny = bone_getWorldPosition(M.gunbone)
    local ox, oy = vector_setLength(vx, vy, 35)
    
    vx, vy = vector_setLength(vx, vy, PORTAL_BEAM_RANGE) -- max. portal distance
    
    local prt = "portalspark-orange"
    local prt2 = "portalgun-orange"
    local ent = "portalorange"
    local sfx = "portalgun_shoot_red1"
    if M.blue then
        sfx = "portalgun_shoot_blue1"
        prt2 = "portalgun-blue"
        prt = "portalspark-blue"
        ent = "portalblue"
    end
    
    local startx = nx+ox
    local starty = ny+oy
    
    spawnParticleEffect(prt2, startx, starty)
    
    if isObstructed(startx, starty) then
        -- shot is in wall, refuse to create portal
        playSfx("portal_invalid_surface3")
        return
    end
    
    local obs, cx, cy = isLineObstructed(startx, starty, nx+vx, ny+vy, prt)
    
    -- FIXME: not if OT_HURT ?
    if obs then
        createEntity(ent, "", cx, cy)
    end
    
    playSfx(sfx, nil, 0.7)
    
    avatar_fallOffWall()
    
    if CHANGE_COLOR_WITH_SHOT then
        flipPortalColor()
    end
end

updateRMB = function()

    local mx, my = getMouseWorldPos()
    local nx, ny = entity_getPosition(v.n)
    local vx, vy = makeVector(nx, ny, mx, my)
    
    -- prevent shooting portal when reverting forms via 2-ouse button click
    if vector_getLength(vx, vy) < 60 then -- const int minMouse, see Avatar.cpp
        quad_setPosition(M.gunglow, bone_getWorldPosition(M.handbone))
        return
    end
    
    updateArmAim(vx, vy)
    
    local lmb = isLeftMouse()
    
    if lmb and not M.wasLMB then
        firePortal(vx, vy)
    end
    
    M.wasLMB = lmb
end


v.logic.portal = M
