
-- uses "ACTIVE_POWERUP" string flag

local M = {}

local ROLLMULT_DEFAULT = 300
local ROLLMULT_EXTRA = 1200

local DOUBLEJUMP_VEL = 800
local DOUBLEJUMP_KEEPVEL = 300

local BOOSTER_POWER = 1000
local BOOSTER_TIME = 1
local BOOSTER_FIXTIME = 0.95 -- required to stay still this long until it recharges (synced with animation)
local BOOSTER2_POWER = 3600
local BOOSTER2_KICK = 0
local BOOSTER2_FRICTION = 1600

local ANIMLAYER_ARMOVERRIDE = ANIMLAYER_ARMOVERRIDE

-- selectable by player, via "ACTIVE_POWERUP" string flag (see logic_ui.lua)
M.useBooster = false
M.useBooster2 = false
M.useDoubleJump = false

-- internal state
M.rollmult = ROLLMULT_DEFAULT
M.hasRollmultExtra = false
M.hasBooster = false
M.hasBooster2 = false
M.fixingBooster = false -- for animation
M.boosterOn = false
M.e = 0 -- entity for booster PE
M.wasInAir = false
M.wasLMB = false
M.boosterT = BOOSTER_TIME
M.hasDoubleJump = false
M.canDoubleJump = false -- set to true everytime when landed
M.boosterSfx = 0
M.boosterBone = 0
M.boosterBone2 = 0

M.init = function()
    -- HACK: otherwise this makes the cape visible
    if isMapName("introscene") or isMapName("introtunnel") or isMapName("outtroscene") then
        v.logic.aircontrol = nil
        return
    end
    
    loadSound("froogflap")
    loadSound("airship-boost")
    
    M.hasBooster = getStringFlag("HAS_BOOSTER") ~= ""
    M.hasBooster2 = getStringFlag("HAS_BOOSTER2") ~= ""
    M.hasDoubleJump = getStringFlag("HAS_DOUBLEJUMP") ~= ""
    M.hasRollmultExtra = getStringFlag("HAS_AIRCONTROL") ~= ""
end

M.postInit = function()
    M.e = createEntity("empty")
    entity_alpha(M.e, 0.001)
    entity_initEmitter(M.e, 0, "exhaust")
    entity_makePassive(M.e)
    
    if M.hasRollmultExtra then
        M.rollmult = ROLLMULT_EXTRA
    end
end

-- on map reset
M.activate = function()
    M.boosterT = BOOSTER_TIME
    M.fixingBooster = false
end

local function getVecToMouse(len)
    local x, y = entity_getPosition(v.n)
    local mx, my = getMouseWorldPos()
    local vx, vy = makeVector(x, y, mx, my)
    if len then
        vx, vy = vector_setLength(vx, vy, len)
    end
    return vx, vy
end

local function getBurstAnimName()
    if isForm(FORM_ENERGY) then
        return "energyburst"
    end
    return "burst"
end

M.update = function(dt)

    if isForm(FORM_FISH) or isForm(FORM_SPIRIT) then
        M.boosterBone = 0
        M.boosterBone2 = 0
        return
    elseif M.boosterBone == 0 then
        M.boosterBone = entity_getBoneByName(v.n, "Booster")
        M.boosterBone2 = entity_getBoneByName(v.n, "Booster2")
    end
    
    -- HACK: portal form has aiming function on right mouse button, and shooting on left.
    if isRightMouse() and isForm(FORM_PORTAL) then
        return
    end
        
    local powerup = getStringFlag("ACTIVE_POWERUP")
    M.useBooster = (powerup == "booster") and M.hasBooster
    M.useBooster2 = (powerup == "booster2") and M.hasBooster2
    M.useDoubleJump = (powerup == "doublejump") and M.hasDoubleJump
    local anybooster = M.useBooster or M.useBooster2

    if anybooster then
        avatar_toggleCape(false)
        if M.useBooster then
            bone_alpha(M.boosterBone, 1)
            bone_alpha(M.boosterBone2, 0)
        elseif M.useBooster2 then
            bone_alpha(M.boosterBone, 0)
            bone_alpha(M.boosterBone2, 1)
        end
    else
        if isForm(FORM_NORMAL) or isForm(FORM_NATURE) then
            avatar_toggleCape(true)
        end
        bone_alpha(M.boosterBone, 0)
        bone_alpha(M.boosterBone2, 0)
    end

    local uw = entity_isUnderWater(v.n)
    local onwall = avatar_isOnWall()
    local inair = not (uw or onwall)
    local lmb = isLeftMouse() and isInputEnabled()
    
    if inair and avatar_isRolling() then
        local rd = avatar_getRollDirection()
        entity_addVel(v.n, rd * dt * M.rollmult, 0)
    end
    
    if anybooster then
        M.canDoubleJump = false -- prevent cheating
        if not M.boosterOn and lmb then
            if inair and M.wasInAir and not M.wasLMB then
                if M.boosterT > 0 then
                    M.boosterOn = true
                    --debugLog("booster on")
                    entity_startEmitter(M.e, 0)
                    if M.useBooster2 then
                        entity_addVel(v.n, getVecToMouse(BOOSTER2_KICK))
                    end
                    M.boosterSfx = playSfx("airship-boost")
                else
                    playSfx("click", 1.55)
                end
            end
        elseif M.boosterOn and not (lmb and inair and M.boosterT > 0) then
            M.boosterOn = false
            --debugLog("booster off")
            entity_stopEmitter(M.e, 0)
            fadeSfx(M.boosterSfx, 0.5)
            M.boosterSfx = 0
            if M.boosterT <= 0 then -- expired
                playSfx("energyblasthit")
            end
        end
        
        if avatar_getStillTimer() <= 0 then
            M.fixingBooster = false
        end
    else
        M.boosterOn = false
    end
    
    if anybooster and M.boosterOn then
        M.boosterT = M.boosterT - dt
        
        if not M.useBooster2 then
            local vx, vy = vector_fromDeg(entity_getRotation(v.n), BOOSTER_POWER * dt)
            entity_addVel(v.n, vx, vy)
        else
            entity_doFriction(v.n, dt, BOOSTER2_FRICTION)
            entity_addVel(v.n, getVecToMouse(BOOSTER2_POWER * dt))
        end
    end
    
    if anybooster and not M.boosterOn and not inair then
    
        if not M.fixingBooster and M.boosterT < BOOSTER_TIME and avatar_getStillTimer() > 0.3 then
            entity_animate(v.n, "fixbooster", 0, ANIMLAYER_ARMOVERRIDE) -- LeftArm animationlayer
            M.fixingBooster = true
        end
        if M.fixingBooster and avatar_getStillTimer() > BOOSTER_FIXTIME then
            M.boosterT = BOOSTER_TIME
            M.fixingBooster = false
            playSfx("click", 1.23, 1.2)
        end
    end
    
    
    if M.useDoubleJump then
        if inair and lmb and M.canDoubleJump and M.wasInAir and not M.wasLMB then
            entity_setVelLen(v.n, DOUBLEJUMP_KEEPVEL)
            local vx, vy = getVecToMouse(DOUBLEJUMP_VEL)
            local a = vector_getAngleDeg(vx, vy)
            entity_addVel(v.n, vx, vy)
            --entity_rotateToVel(v.n, 1)
            --entity_rotate(v.n, a)
            M.canDoubleJump = false
            playSfx("froogflap", 1.3)
            entity_animate(v.n, getBurstAnimName())
            local nx, ny = entity_getPosition(v.n)
            spawnParticleEffect("wallboost", nx, ny, 0, a)
            M.boosterT = 0 -- prevent cheating
            
            -- facing not in jump direction?
            if entity_isfh(v.n) == (vx < 0) then
                entity_animate(v.n, "normal-flourish", 0, 3) -- flourish animationlayer
            end
            
            if chance(8) then
                emote(EMOTE_NAIJAGIGGLE)
            end
        end
        
        if not inair then
            M.canDoubleJump = true
        end
    end
    
    
    
    M.wasLMB = lmb
    M.wasInAir = inair
    
    entity_setPosition(M.e, bone_getWorldPosition(M.boosterBone))
end


v.logic.aircontrol = M
