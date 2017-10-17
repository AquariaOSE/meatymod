
v.initT = 0
v.t = 0
v.rechargeT = 2
v.pipe = 0
v.n = 0
v.seen = false

local INIT_SPEED = 400
local MAXRANGE = 1800

local STATE_SHOOT = 1000


local function shoot(me)
    local vx, vy = entity_getVectorToEntity(me, v.n)
    vx, vy = vector_setLength(vx, vy, INIT_SPEED)
    local m = createEntity("missile", "", entity_getPosition(me))
    --entity_rotate(m, bone_getWorldRotation(v.pipe))
    entity_rotate(m, entity_getRotation(me))
    entity_addVel(m, vx, vy)
    entity_playSfx(me, "airship-boost", nil, 1.45, nil, 1.8, 3000)
    return m
end

function init(me)
    setupEntity(me)
    entity_setEntityLayer(me, -1)
    --entity_initSkeletal(me, "missileshooter")
    entity_setTexture(me, "missile/tube")
    
    entity_generateCollisionMask(me)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 1)
    
    v.pipe = entity_getBoneByIdx(me, 1)
    
    entity_scale(me, 0.5, 0.5)
    
    local data = entity_getNearestNode(me, "mshooter") -- "mshooter <freq> <initDelay>"
    if data ~= 0 and node_isEntityIn(data, me) then
        local t = node_getName(data):explode(" ", true)
        v.rechargeT = tonumber(t[2] or 2)
        v.initT = tonumber(t[3] or 0)
        if t[4] then
            v.spd = tonumber(t[4])
        end
    end
    
    entity_setState(me, STATE_IDLE)
    loadSound("missile-detect")
    loadSound("airship-boost")
    
    -- for the missiles
    loadSound("pistolshrimp-fire")
    loadSound("mantis-bomb")
    
end

local function reset(me)
    v.t = v.initT
    v.seen = false
    entity_setState(me, STATE_IDLE)
end

function postInit(me)
    reset(me)
    v.n = getNaija()
end

function update(me, dt)
    if v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            if entity_isEntityInRange(me, v.n, MAXRANGE) and entity_isInLineOfSight(me, v.n) then
                if not v.seen then
                    v.seen = true
                    entity_playSfx(me, "missile-detect", nil, nil, nil, nil, 4000) -- me, name, freq, vol, loops, fadeout, range
                end
                entity_setState(me, STATE_SHOOT)
            else
                v.t = 0.2
            end
        end
    end
    
    entity_rotateToEntity(me, v.n)
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
        v.t = v.t + v.rechargeT
    elseif entity_isState(me, STATE_SHOOT) then
        --local a = entity_animate(me, "shoot")
        local a = 0.5
        entity_setStateTime(me, a)
        shoot(me)
    end
end

function exitState(me)
    if entity_isState(me, STATE_SHOOT) then
        entity_setState(me, STATE_IDLE)
    end
end

function animationKey(me, k)
    if entity_isState(me, STATE_SHOOT) then
        if k == 2 then
            shoot(me)
        end
    end
end


function msg(me, s)
    if s == "reinit" then
        reset(me)
    end
end

function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
