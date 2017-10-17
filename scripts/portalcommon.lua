
v.n = 0
v.ignore = false
v.blue = false
v.needinit = true
v.enterSoundT = 0
v.exitSoundT = 0

local function getSamePortal()
    if v.blue then
        return "portalblue"
    end
    
    return "portalorange"
end

local function getOtherPortal()
    if v.blue then
        return "portalorange"
    end
    
    return "portalblue"
end

local function calcPitchForVel(who)
    if not who then return 1 end
    local t = entity_getVelLen(who)
    
    -- scale [600, 1500] into [0.7, 1.2]
    local lower = 600
    local upper = 1500
    local lowerperc = 0.7
    local upperperc = 1.2
    
    
    if t < lower then
        return lowerperc
    end
    if t > upper then
        return upperperc
    end

    t = t - lower
    t = t / (upper - lower)
    t = t * (upperperc - lowerperc)
    t = t + lowerperc
    --debugLog("vel: " .. entity_getVelLen(who) .. " - pitch: " .. t)
    return t
end

local function enterSound(me, who)
    if v.enterSoundT <= 0 then
        v.enterSoundT = 0.2
        entity_playSfx(me, "portal_enter" .. math.random(1, 2), calcPitchForVel(who) )
    end
end

local function exitSound(me, who)
    if v.exitSoundT <= 0 then
        v.exitSoundT = 0.2
        entity_playSfx(me, "portal_exit" .. math.random(1, 2), calcPitchForVel(who) )
    end
end

local function openSound(me)
    entity_playSfx(me, "portal_open" .. math.random(1, 3))
end

local function closeSound(me)
    entity_playSfx(me, "portal_close" .. math.random(1, 2))
end

local function ensureOnce(me)
    local pn = getSamePortal()
    local function filt(e)
        return e ~= me and entity_isName(e, pn)
    end
    forAllEntities(entity_setState, STATE_DEATHSCENE, filt)
end

local function dbgVisVector(px, py, vx, vy)

    local q = createQuad("vector")
    local r = vector_getAngleDeg(vx, vy)
    quad_setPosition(q, px, py)
    quad_rotate(q, r)
    quad_delete(q, 2)

end


function v.commonInit(me, blue)

    v.ignore = {}
    v.blue = blue
    
    local same = getSamePortal() -- also tex name
    setupEntity(me, same)
    
    esetvf(me, EV_CLAMPTRANSF, 0)
    --esetv(me, EV_WALLOUT, 18)
    entity_clampToSurface(me)
    entity_rotateToSurfaceNormal(me, 0)
    entity_adjustPositionBySurfaceNormal(me, 18)
    --entity_setSegs(me, 2, 16, 0.6, 0.6, -0.028, 0, 6, 1)
    
    entity_setCollideRadius(me, 90)
    entity_setDeathScene(me, true)
    entity_scale(me, 0, 1)
    entity_scale(me, 1, 1, 0.05)
    entity_alpha(me, 0)
    entity_alpha(me, 1, 0.05)
    
    entity_setDeathSound(me, "")
    entity_setInvincible(me, true)
    
    --entity_setBlendType(me, BLEND_ADD)
    
    entity_initEmitter(me, 0, same .. "-bits")

end

function postInit(me)
    v.n = getNaija()
    
    -- shots are very speedy and get often stuck in the wall
    -- so move the entity out, then rotate to wall
    --[[local x, y = entity_getPosition(me)
    local nx, ny = getWallNormal(x, y, 6)
    nx, ny = vector_setLength(nx, ny, 80)
    entity_setPosition(me, entity_x(me)+nx, entity_y(me)+ny)
    entity_clampToSurface(me, 120)]]
    -- NO LONGER SPAWNED VIA SHOT
    
    entity_rotateToSurfaceNormal(me, 0)
    
    local o = getOtherPortal()
    
    local otherp = entity_getNearestEntity(me, o)
    if otherp ~= 0 and entity_isEntityInRange(me, otherp, 130) then
        entity_setState(me, STATE_DEATHSCENE)
        entity_playSfx(me, "portal_fizzle2")
        return
    end
    
    local np = entity_getNearestNode(me, "noportal")
    if np ~= 0 and node_isEntityIn(np, me) then
        entity_setState(me, STATE_DEATHSCENE)
        entity_playSfx(me, "portal_invalid_surface3")
        return
    end
    
    ensureOnce(me)
    
    local other = entity_getNearestEntity(me, o)
    if other ~= 0 then
        entity_setTexture(other, o .. "-open")
        entity_setTexture(me, getSamePortal() .. "-open")
        entity_startEmitter(me, 0)
        entity_startEmitter(other, 0)
    end
        
end

local function addIgnore(e, t)
    if not t then t = 0.22 end
    v.ignore[e] = t
end

local function isIgnored(e)
    return v.ignore[e] ~= nil
end

local function updateIgnores(dt)
    for e, t in pairs(v.ignore) do
        if t >= 0 then
            t = t - dt
            if t <= 0 then
                v.ignore[e] = nil
                --debugLog("expired ignore " .. entity_getName(e))
            else
                v.ignore[e] = t
            end
        end
    end
end

local function warp(me, e)
    if isIgnored(e) then
        return
    end
    
    if e ==  v.n then
        avatar_fallOffWall()
    end
    
    local other = entity_getNearestEntity(me, getOtherPortal())
    if other ~= 0 then
    
        if entity_msg(other, "warp", e, me) then
            addIgnore(e)
        end
        
        
        --entity_msg(other, "warpprep", me)
        --entity_msg(other, "warp", e)
        --addIgnore(e)
    end
end

local function warpNearby(e, me)
    if  not isMapObject(e)
        and entity_isEntityInRange(me, e, entity_getCollideRadius(me))
        and entity_msg(e, "noportal") ~= true -- HACK: dunno how to do it better
    then
        warp(me, e)
    end
end


function update(me, dt)
    if v.needinit and entity_isState(me, STATE_IDLE) then
        openSound(me)
        v.needinit = false
        --entity_playSfx(me, "portal_ambient_loop1", nil, 1, -1) -- not really audible
    end
    
    v.enterSoundT = v.enterSoundT - dt
    v.exitSoundT = v.exitSoundT - dt
    
    updateIgnores(dt)
    
    forAllEntities(warpNearby, me)
    
end

local function warpRecv(me, e, origin)

    if isIgnored(e) then
        return false
    end

    addIgnore(e)
    
    --debugLog("warp recv: " .. entity_getName(e))
    
    setCameraLerpDelay(0)
    
    local orot = entity_getRotation(origin)
    local myrot = entity_getRotation(me)
    local rotdiff = orot - myrot
    
    local vx, vy = entity_velx(e), entity_vely(e)
    
    
    vx, vy = vector_rotateDeg(vx, vy, 180 - rotdiff) -- FIXME - not always correct

    
    local tx, ty = entity_getPosition(me)
    
    --local nx, ny = entity_getNormal(me)
    local nx, ny = getWallNormal(tx, ty)
    
    nx, ny = vector_setLength(nx, ny, entity_getCollideRadius(me))
    
    
    entity_setMaxSpeedLerp(e, 3)
    entity_setMaxSpeedLerp(e, 1, 2)
    
    entity_setPosition(e, tx+nx, ty+ny)
    entity_clearVel(e)
    entity_addVel(e, vx * 1.047 + nx * 10, vy * 1.047 + ny * 10) -- compensation for air friction and minimal normal influence
    
    if entity_getVelLen(e) < 200 then
        entity_setVelLen(e, 200)
    end
    
    exitSound(me, e)
    enterSound(origin, e)
    
    if e == v.n then
        --[[dbgVisVector(tx, ty, vx, vy)
        local ox, oy = entity_getPosition(origin)
        dbgVisVector(ox, oy, vx, vy)]]
        avatar_fallOffWall()
        cam_snap()
    end
    
    return true
    
end


function msg(me, s, x, origin)
    if s == "warp" then
        return warpRecv(me, x, origin)
    elseif s == "reinit" then
        entity_setState(me, STATE_DEATHSCENE)
    elseif s == "noportal" then
        return true -- prevent teleporting self
    end
end

function song(me, s)
end

function songNote(me, note)
end

function songNoteDone(me, note, t)
end

function dieNormal(me)
end

function dieNormal(me)
end

function enterState(me)
    if entity_isState(me, STATE_DEATHSCENE) then
        entity_scale(me, 0, 0, 0.15)
        entity_alpha(me, 0.3, 0.1)
        closeSound(me)
        entity_delete(me, 0.15)
    end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
end

function hitSurface(me)
end
