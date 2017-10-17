

v.n = 0
v.t = 0
v.initx = 0
v.inity = 0

function init(me)
    setupEntity(me, "lava-tile6-rot", -2)
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    --entity_setCull(me, false)
    entity_setMaxSpeed(me, 6000)
    entity_setDeathSound(me, "")
    entity_setCollideRadius(me, 95)
    --entity_scale(me, 2, 2)
    entity_setSegs(me, 2, 8, 0.6, 0.6, -0.03, 0, 4, 0)
    entity_setInvincible(me, true)
end

function postInit(me)
    v.n = getNaija()
    v.initx, v.inity = entity_getPosition(me)
end

function update(me, dt)

    if v.t >= 0 then
        v.t = v.t - dt
    elseif entity_touchAvatarDamage(me, entity_getCollideRadius(me)) and entity_getHealth(v.n) > 0.1 then
        DEATH_EFFECT = "death-lava"
        playSfx("energyboss-attack")
        entity_hugeDamage(v.n)
        v.t = 1
    end
    
    
end

function damage(me)
    return false
end


function enterState(me)
end

function exitState()
end

function msg(me, s)
    if s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
    end
end

function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
