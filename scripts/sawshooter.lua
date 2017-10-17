
v.initT = 0
v.t = 0
v.rechargeT = 1
v.arrow = 0
v.arrowhead = 0
v.saw = 0
v.spd = 720
v.special = false
v.mustReset = true -- initial reset

local STATE_SHOOT = 1000

local function createSaw(me)
    local s = createEntity("sawshot")
    entity_alpha(s, 0)
    entity_alpha(s, 1, 0.3)
    entity_msg(s, "rot", 720)
    entity_msg(s, "sz", 70)
    entity_msg(s, "layer", "over")
    if v.special then
        entity_msg(s, "special", v.special)
    end
    v.saw = s
    return s
end

local function releaseSaw(me)
    if v.saw == 0 then return end
    local ax, ay = entity_getAimVector(me, 0, v.spd)
    entity_msg(v.saw, "move")
    entity_clearVel(v.saw)
    entity_addVel(v.saw, ax, ay)
    entity_playSfx(me, "sawshot")
    v.saw = 0
end

function init(me)
    setupEntity(me)
    entity_setEntityLayer(me, -1)
    entity_initSkeletal(me, "sawshooter")
    entity_generateCollisionMask(me)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_setInvincible(me, true)
    
    v.arrow = entity_getBoneByIdx(me, 1)
    v.arrowhead = entity_getBoneByIdx(me, 2)
    
    --entity_setUpdateCull(me, -1)
    entity_scale(me, 0.5, 0.5)
    
    local data = entity_getNearestNode(me, "sawshooter") -- "sawshooter <freq> <initDelay> <sawSpeed> [<special>]"
    if data ~= 0 and node_isEntityIn(data, me) then
        local t = node_getName(data):explode(" ", true)
        v.rechargeT = tonumber(t[2] or 1)
        v.initT = tonumber(t[3] or 0)
        if t[4] then
            v.spd = tonumber(t[4])
        end
        if t[5] then
            v.special = t[5]
        end
    end
    
    loadSound("sawshot")
    
    entity_setState(me, STATE_IDLE)
    
end

local function reset(me)
    v.saw = 0
    createSaw(me)
    v.t = v.initT
    entity_setState(me, STATE_IDLE)
end

function postInit(me)
    v.mustReset = true
    -- can't call reset() here, because it creates an entity
end

function update(me, dt)
    if v.mustReset then
        v.mustReset = false
        reset(me)
    end
    
    if v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            entity_setState(me, STATE_SHOOT)
        end
    end
    
    if v.saw ~= 0 then
        entity_setPosition(v.saw, bone_getWorldPosition(v.arrowhead))
    end
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
        if v.t < 0 then
            v.t = 0
        end
        if v.saw == 0 then
            createSaw(me)
            v.t = v.t + v.rechargeT
        end
    elseif entity_isState(me, STATE_SHOOT) then
        local a = entity_animate(me, "shoot")
        entity_setStateTime(me, a)
    end
end

function exitState(me)
    if entity_isState(me, STATE_SHOOT) then
        entity_setState(me, STATE_IDLE)
    end
end

function animationKey(me, k)
    if entity_isState(me, STATE_SHOOT) then
        if k >= 2 then
            releaseSaw(me)
        end
    end
end


function msg(me, s)
    if s == "reinit" then
        reset(me)
        -- DO NOT CHANGE ENTITIES WHILE ITERATING OVER THEM (and this is the case when "reinit" is sent!!)
        -- wait... changed resetMap() instead, probably safer for the long term. see globalfuncs.lua.
        --v.mustReset = true
    end
end

function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
