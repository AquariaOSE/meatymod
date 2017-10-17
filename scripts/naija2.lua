
-- replay naija entity

-- uses animations/naija-essentials.xml instead of the normal naija.xml.
-- the essentials one is a really stripped down version to optimize loading speed.
-- a few animations may be missed, but i think it includes all that can be returned
-- by entity_getAnimationName() in this mod.

-- Found out these are never detected although displayed quite often:
-- jumpout, backflip, backflip2
-- all swimextra-*
-- all *-flourish


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
	
	entity_initSkeletal(me, "naija-essentials")
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_scale(me, 0.5, 0.5)

	--v.bone_fish2 = entity_getBoneByName(me, "Fish2")
	--v.bone_glow = entity_getBoneByName(me, "DualFormGlow")
	--bone_alpha(v.bone_fish2, 0)
	--bone_alpha(v.bone_glow, 0)
    
    entity_setAllDamageTargets(me, false)

	
	entity_setEntityType(me, ET_NEUTRAL)

	--entity_setSpiritFreeze(me, false)
	
	entity_setBeautyFlip(me, false)
	
	--entity_setRenderPass(me, 1)
    
    esetv(me, EV_LOOKAT, 0)
    entity_setCanLeaveWater(me, true)
    
    v.q = createQuad("softglow-add", 13)
    quad_scale(v.q, 3, 3)
    quad_setBlendType(v.q, BLEND_ADD)
    
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
    quad_setPosition(v.q, entity_getPosition(me))
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

function msg(me, msg, val)
end

function songNote(me, note)
end

function songNoteDone(me, note, len)
end

function animationKey()
end
