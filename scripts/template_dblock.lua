
dofile("scripts/inc_timerqueue.lua")

-- does intentionally not handle shot collisions, as this would totally overload the CPU,
-- because the cull radius would have to be set very high... which is infeasible

local CULL = 180

v.n = 0
v.on = true
v.t = 0

local function reset(me)
    entity_alpha(me, 1, 0.5)
    v.on = true
    v.t = 0
    entity_setUpdateCull(me, CULL) -- VERY important, otherwise it lags to death
end

function v.commonInit(me, skel, sx, sy)
    setupEntity(me)
    entity_setEntityLayer(me, -2)
    entity_initSkeletal(me, skel)
    entity_generateCollisionMask(me)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_scale(me, sx, sy)
    entity_setInvincible(me, true)
    reset(me)
end

function postInit(me)
    v.n = getNaija()
end

local function crumble(me)
    v.on = false
    entity_alpha(me, 0, 0.3)
    if entity_getBoneLockEntity(v.n) == me then
        avatar_fallOffWall()
    end
    entity_playSfx(me, "rockhit")
    
    spawnParticleEffect("crumble", entity_getPosition(me))
end

function update(me, dt)
    v.updateTQ(dt)
    
    if v.t > 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            crumble(me)
            v.pushTQ(0.15, function() entity_playSfx(me, "bigrockhit") end)
            v.pushTQ(3, function() entity_setUpdateCull(me, CULL) end)
        end
    elseif v.on then
        local bone = entity_collideSkeletalVsCircle(me, v.n)
        if bone ~= 0 then
            if avatar_isLockable() and entity_setBoneLock(v.n, me, bone) then
                entity_setUpdateCull(me, -1)
                v.t = 0.5
                v.pushTQ(0.3, function() spawnParticleEffect("crumble", entity_getPosition(me)) end)
            else
                local vx, vy = entity_getVectorToEntity(me, v.n)
                vx, vy = vector_setLength(vx, vy, 500)
                entity_addVel(v.n, vx, vy)
            end
        end
    end
end

function msg(me, s)
    if s == "reinit" then
        reset(me)
        entity_setUpdateCull(me, -1)
        entity_update(me, 2)
        reset(me) -- grrr
    end
end

function damage(me, attacker)
    --[[if attacker ~= 0 then
        local name = entity_getName(attacker)
        if name == "sawshot" or name == "missile" then
            crumble(me)
        end
    end]]
    return false
end

function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
