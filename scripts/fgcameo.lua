
-- hey! outta here! this is my private super-secret script!

v.q = 0

function init(me)
	
	setupBasicEntity(me, 
	"",								-- texture
	32,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	28,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "naija", "fg")
	
	entity_scale(me, 0.6, 0.6)

	bone_alpha(entity_getBoneByIdx(me, 21), 0)
	bone_alpha(entity_getBoneByIdx(me, 20), 0)
	bone_alpha(entity_getBoneByIdx(me, 15), 0)
	bone_alpha(entity_getBoneByIdx(me, 22), 0)
    
    entity_setAllDamageTargets(me, false)

	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_setBeautyFlip(me, false)
    
    esetv(me, EV_LOOKAT, 1)
    entity_setCanLeaveWater(me, true)
    
    entity_setInvincible(me, true)
end


function postInit(me)
    entity_idle(me)
end

function shiftWorlds(me, old, new)
end

function song(me, song)
end

function update(me, dt)
    entity_updateMovement(me, dt)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me, state)
end

function exitState(me)
end

function hitSurface(me)
end

function msg(me, s)
    if s == "enabletalk" then
        entity_setActivation(me, AT_CLICK, 64, 512)
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, len)
end

function animationKey()
end

function activate(me)
    setControlHint("I'm tired after all of this. Just let me sleep for a while...", false, false, false, 6)
end
