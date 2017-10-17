
dofile("scripts/inc_timerqueue.lua")

v.n = 0
v.on = true
v.initx = 0
v.inity = 0


local function shatter(me)
    if not v.on then return end
    
    local x, y = entity_getPosition(me)
    spawnParticleEffect("palmdie", x, y)
    spawnParticleEffect("palmdie", x + 45, y + 45)
    spawnParticleEffect("palmdie", x + 45, y - 45)
    spawnParticleEffect("palmdie", x - 45, y + 45)
    spawnParticleEffect("palmdie", x - 45, y - 45)

    entity_alpha(me, 0, 0.5)
    v.on = false
    
    entity_playSfx(me, "licage-crack1")
end

function init(me)

    setupEntity(me, "palm-frond-0001", 1)

    entity_setCollideRadius(me, 70)
    entity_scale(me, 1.3, 1.3)
    
    entity_setEntityType(me, ET_NEUTRAL)

	entity_setEatType(me, EAT_NONE)
	entity_setState(me, STATE_IDLE)
	
	esetv(me, EV_LOOKAT, 0)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
    
    entity_setCanLeaveWater(me, true)
    
    loadSound("licage-crack1")
end

function postInit(me)
    v.initx, v.inity = entity_getPosition(me)
    v.n = getNaija()
end

function update(me, dt)
    if v.on then
        entity_handleShotCollisions(me)
    end
end

function enterState(me)
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    if attacker ~= v.n then
        shatter(me)
    end
	return false
end

function msg(me, s, x)
    if s == "noportal" then -- sent if about to be warped by a portal
        return true
    elseif s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
        entity_alpha(me, 1, 0.1)
        v.on = true
    end
end
        

function animationKey(me, key)
end

function hitSurface(me)
    shatter(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

