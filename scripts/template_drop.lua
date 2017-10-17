
v.n = 0
v.prt = true
v.pe = ""
v.touch = true
v.onDestroy = false
v.lifetime = 0

function v.commonInit(me, tex, pe)
    v.pe = pe
    setupEntity(me, tex, -1)
    entity_setWidth(me, 32)
    entity_setHeight(me, 32)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_alpha(me, 0)
    entity_setCollideRadius(me, 8)
    entity_setWeight(me, 1000)
    entity_setCanLeaveWater(me, true)
    entity_color(me, 0.7, 0.7, 1)
    entity_setMaxSpeed(me, 1200)
    local s = math.random(500, 750) / 1000
    entity_scale(me, s, s + 0.1)
    entity_setInvincible(me, true)
end

function postInit(me)
    v.n = getNaija()
    entity_alpha(me, 1, 0.3)
end

local function destroy(me, uw)
    --spawnParticleEffect(v.pe, entity_getPosition(me))
    if v.onDestroy then
        v.onDestroy(me, uw)
    end
    entity_delete(me, 0.2)
end

function update(me, dt)
    if (v.touch and entity_touchAvatarDamage(me, 8)) or entity_isUnderWater(me) then
        if v.lifetime > 0.2 then
            spawnParticleEffect(v.pe, entity_getPosition(me))
        end
        destroy(me, true)
    end
    
    if v.prt and v.lifetime > 0.2 and entity_vely(me) > 10 and entity_isNearObstruction(me, 5, OBSCHECK_DOWN) then
        v.prt = false
        local x, y = entity_getPosition(me)
        spawnParticleEffect(v.pe, x, y + 4*20)
    end
    
    entity_updateMovement(me, dt)
    v.lifetime = v.lifetime + dt
end

function hitSurface(me)
    return destroy(me, false)
end

function msg(me, s)
    if s == "noportal" then
        return true
    end
end

function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
