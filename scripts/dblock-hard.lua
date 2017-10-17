
local CULL = 180

v.n = 0
v.on = true
v.t = 0
v.hard = false

local function reset(me)
    entity_alpha(me, 1, 0.5)
    v.on = true
    v.t = 0
    entity_setFillGrid(me, true)
    entity_setCollideRadius(me, 110)
end

function init(me)
    setupEntity(me, "dissolving-block-hard")
    entity_setEntityLayer(me, -2)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_scale(me, 1.1, 1.1)
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
    
    local x, y = entity_getPosition(me)
    spawnParticleEffect("crumble", x, y)
    spawnParticleEffect("crumble", x - 30, y - 30)
    spawnParticleEffect("crumble", x + 30, y - 30)
    spawnParticleEffect("crumble", x - 30, y + 30)
    spawnParticleEffect("crumble", x + 30, y + 30)
    
    entity_setFillGrid(me, false)
    reconstructEntityGrid()
end

function update(me, dt)
    if v.on then
        entity_handleShotCollisions(me)
    end
end

function msg(me, s)
    if s == "reinit" then
        reset(me)
    end
end

function damage(me, attacker)
    if attacker ~= 0 then
        local name = entity_getName(attacker)
        if name == "sawshot" or name == "missile" then
            crumble(me)
        end
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
