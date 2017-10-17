
v.head = 0

v.damage = false
v.canmove = false


function init(me)
	setupEntity(me)
    entity_setHealth(me, 999)
	entity_setEntityType(me, ET_AVATAR) -- this is important for evilsphere boss
	entity_initSkeletal(me, "mia")
	
	entity_scale(me, 0.6, 0.6)
	
	entity_setState(me, STATE_IDLE)
	
	v.head = entity_getBoneByName(me, "Head")
    
    entity_setCollideRadius(me, 20)
    
    entity_setAllDamageTargets(me, false)
    entity_setCanLeaveWater(me, true)
    
    --bone_alpha(entity_getBoneByIdx(me, 15), 0)
    --bone_alpha(entity_getBoneByIdx(me, 16), 0)
    
    --entity_setDeathScene(me, true)
    entity_setInvincible(me, true)
    
    entity_setBounceType(me, BOUNCE_NONE)
end

function postInit(me)
end

local function expression(me, ep)
    -- frame order in animation file
    if ep == "" then
        ep = 0
    elseif ep == "shock" then
        ep = 1
    elseif ep == "pain" then
        ep = 2
    else
        errorLog("mia.lua: Unknown expression " .. tostring(ep))
    end
    
    bone_showFrame(v.head, ep)
end

function update(me, dt)
    entity_handleShotCollisions(me)
    entity_setLookAtPoint(me, bone_getWorldPosition(v.head))
    
    if v.canmove then
        entity_updateMovement(me, dt)
    end
end

function enterState(me)
    -- HACK: animation done by node_finish.lua (otherwise this breaks due to unknown reason)
	--if entity_isState(me, STATE_IDLE) then
	--	entity_animate(me, "idle", -1)
	--end
    
    if entity_isState(me, STATE_PUSH) then
        entity_animate(me, "pushed", 0, 0, 0.08)
    elseif entity_isState(me, STATE_PUSHDELAY) then
        entity_clearVel(me)
        entity_applySurfaceNormalForce(me, 150)
        entity_animate(me, "pushimpact", 0, 0, -1)
    end
end

function exitState(me)
end
    

function damage(me, attacker, bone, damageType, dmg)
    entity_heal(me, 999)
    return v.damage
end

function msg(me, s, x)
    if s == "expr" then
        expression(me, x)
    elseif s == "reinit" then
        expression(me, "")
    elseif s == "norportal" then
        return true
    elseif s == "damage" then -- sent by node_finalfinish.lua
        v.damage = x
    elseif s == "move" then -- sent by node_outtro3.lua
        v.canmove = true
    end
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

