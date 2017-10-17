
v.n = 0
v.lastForm = false

local function setGunAlpha(a)
    local b = entity_getBoneByIdx(v.n, 22)
    if b == 0 then
        errorLog("logichelp_portal.lua: bone 22 not found")
        return
    end
    bone_alpha(b, a)
end

function init(me)
    setupEntity(me)
    entity_makePassive(me)
    entity_setCollideRadius(me, 0)
    entity_alpha(me, 0.001)
    loadSound("portal_open2")
    entity_setMaxSpeed(me, 9999)
end

function postInit(me)
    v.n = getNaija()
    v.lastForm = getForm()
    if v.lastForm == FORM_PORTAL then
        setGunAlpha(1)
    else
        setGunAlpha(0)
    end
end

function update(me, dt)

    local uw = entity_isUnderWater(me)
    
    if uw or avatar_isOnWall() then
        entity_setWeight(me, 0)
    else
        entity_setWeight(me, 980 * 1.5) -- from Avatar.cpp: vel += Vector(0,980)*dt*fallMod;
    end

    entity_setMaxSpeed(me, entity_getMaxSpeed(v.n))
    
    if entity_getRiding(v.n) == me then
    
        if entity_isfh(v.n) ~= entity_isfh(me) then
            entity_fh(me)
        end
    
        -- taken from Avatar::doFriction()
        local wasIn = entity_getVelLen(me) < 10
        entity_doFriction(me, dt, 160) -- as set in variables.txt
        if not wasIn and entity_getVelLen(me) < 10 then
            entity_clearVel(me)
        end
        
        entity_updateMovement(me, dt)
        entity_rotateToVel(me, 0.1)
        
        local x, y = entity_getPosition(me)
        entity_setRidingData(me, x, y, entity_getRotation(me), entity_isfh(me))
        
    else
        entity_setPosition(me, entity_getPosition(v.n))
        entity_rotate(me, entity_getRotation(v.n))
    end
    
    
    local f = getForm()

    
    if f ~= v.lastForm then
        if f ~= FORM_PORTAL then
        
            setGunAlpha(0)
            setGameSpeed(1, 0.6, 0, 0, 1)
            if entity_getRiding(v.n) == me then
                entity_setRiding(v.n, 0)
            end
            
            if f == FORM_NORMAL then
                local c = getCostume()
                local oldc = getStringFlag("BEFORE_PORTAL_COSTUME")
                if c == "portal" then
                    debugLog("restoring saved costume: " .. oldc)
                    setCostume(oldc)
                end
            end
        end
    end
        
    
    v.lastForm = f
end

function msg(me, s)
end

function hitSurface() end
function enterState() end
function exitState() end
function animationKey() end
function song(me, s)
    if s == SONG_PORTALFORM and not isForm(FORM_PORTAL) then
        debugLog("portal form hackfix")
        changeForm(FORM_NORMAL)
        local c = getCostume()
        if c ~= "portal" then
            debugLog("saving costume: " .. c)
            setStringFlag("BEFORE_PORTAL_COSTUME", c)
            setCostume("portal")
        end
        changeForm(FORM_PORTAL)
        playSfx("portal_open2")
        setGunAlpha(1)
    end
end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
