
-- FG heavily shrinked down Li script
-- the hug works and following/combat should too
-- unnecessary stuff has been taken out (cutscene, dead code, eating icecream, etc)

local STATE_SWIM 			= 1001
local STATE_BURST 		= 1002 -- unused
local STATE_FOLLOWING 	= 1007
local STATE_CHASEFOOD	= 1009 -- unused
local STATE_EAT			= 1010 -- unused
local STATE_PATH		= 1011 -- unused
local STATE_IDLE2       = 1012 -- HACK

v.honeyPower = 0

v.gvel = false

v.forcedHug = false

v.incut = false


v.bone_helmet = 0
v.bone_head = 0
v.bone_fish1 = 0
v.bone_fish2 = 0
v.bone_hand = 0
v.bone_arm = 0
v.bone_weaponGlow = 0
v.bone_leftHand = 0

v.bone_llarm = 0
v.bone_ularm = 0

v.naijaOut = -25
v.hugOut = 0
v.curNote = -1

v.followDelay = 0

v.expressionTimer = 0


v.naijaLastHealth = 0
v.nearEnemyTimer = 0
v.nearNaijaTimer = 0
v.headDelay = 1

v.flipDelay = 0

v.n = 0

v.zapDelay = 0.1

local function setNaijaHugPosition(me)
	entity_setPosition(v.n, entity_x(me)+v.hugOut, entity_y(me))
	local fh = entity_isfh(me)
	if fh then
		fh = false
	else
		fh = true
	end
	entity_setRidingData(me, entity_x(me)+v.hugOut, entity_y(me), 0, fh)
end

local function distFlipTo(me, ent)
	if math.abs(entity_x(me)-entity_x(ent)) > 32 then
		entity_flipToEntity(me, ent)
	end
end

local function flipHug(me)
	debugLog("flipHug")
	if v.hugOut < 0 then
		v.hugOut = -v.naijaOut
	else
		v.hugOut = v.naijaOut
	end
	setNaijaHugPosition(me)
	entity_flipToEntity(me, v.n)
	entity_flipToEntity(v.n, me)
end

local function endHug(me)
	if entity_getRiding(v.n) == me then
		entity_setRiding(v.n, 0)
		entity_idle(v.n)
	end
	if entity_isState(me, STATE_HUG) then
		entity_setState(me, STATE_IDLE2)
	end
end

function activate(me)
	--debugLog("Li: activate")
	if entity_isState(me, STATE_HUG) then
		endHug(me)
	end
end




function init(me)
	
	setupBasicEntity(me, 
	"",								-- texture
	32,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	28,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE2,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Li")
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_scale(me, 0.5, 0.5)

	v.bone_helmet = entity_getBoneByName(me, "Helmet")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_fish1 = entity_getBoneByName(me, "Fish1")
	v.bone_fish2 = entity_getBoneByName(me, "Fish2")
	v.bone_hand = entity_getBoneByName(me, "RightArm")
	v.bone_arm = entity_getBoneByName(me, "RightArm2")
	v.bone_weaponGlow = entity_getBoneByName(me, "WeaponGlow")
	bone_setBlendType(v.bone_weaponGlow, BLEND_ADD)
	bone_alpha(v.bone_fish1)
	bone_alpha(v.bone_fish2)
    bone_alpha(v.bone_helmet, 0)
	
	v.bone_llarm = entity_getBoneByName(me, "LLArm")
	v.bone_ularm = entity_getBoneByName(me, "ULArm")
	v.bone_leftHand = entity_getBoneByName(me, "LeftArm")
    
    entity_setAllDamageTargets(me, false)

	
	entity_setEntityType(me, ET_NEUTRAL)

	--entity_setSpiritFreeze(me, false)
	
	entity_setBeautyFlip(me, false)
    entity_setCanLeaveWater(me, true)
	
    entity_setInvincible(me, true)
end

local function expression(me, ep, t)

    if ep == "happy" then
        ep = EXPRESSION_HAPPY
    elseif ep == "hurt" then
        ep = EXPRESSION_HURT
    elseif ep == "surprise" then
        ep = EXPRESSION_SURPRISE
    elseif ep == "laugh" then
        ep = EXPRESSION_LAUGH
    elseif ep == "angry" then
        ep = EXPRESSION_ANGRY
    elseif ep == "hurtred" then
        ep = EXPRESSION_SURPRISE + 1 -- HACK
    elseif ep == "normal" then
        ep = EXPRESSION_NORMAL
    end
    
    if t then
        v.expressionTimer = t
    else
        v.expressionTimer = -1
    end
    
    if type(ep) ~= "number" then
        return
    end

    bone_showFrame(v.bone_head, ep)
end

local function refreshWeaponGlow(me)
	local t = 0.5
	local f = 3
	if isFlag(FLAG_LICOMBAT, 1) then
		bone_alpha(v.bone_weaponGlow, 1, 0.5)
		bone_setColor(v.bone_weaponGlow, 1, 0.5, 0.5, t)
	else
		bone_alpha(v.bone_weaponGlow, 0.5, 0.5)
		bone_setColor(v.bone_weaponGlow, 0.5, 0.5, 1, t)
	end
	--[[
	bone_scale(v.bone_weaponGlow, v.bwgsz, v.bwgsz)
	bone_scale(v.bone_weaponGlow, v.bwgsz*f, v.bwgsz*f, t*0.75, 1, 1)		
	]]--
end

function postInit(me)
    entity_idle(me)
    --entity_checkSplash(me)
    v.n = getNaija()
	v.naijaLastHealth = entity_getHealth(v.n)
	v.bwgsz = bone_getScale(v.bone_weaponGlow)
	refreshWeaponGlow(me)
end

function shiftWorlds(me, old, new)
end

function update(me, dt)
    if entity_isState(me, STATE_PUPPET) then return end
    if entity_isState(me, STATE_IDLE) then return end -- FG: HACK: because this is forced by the engine, although it's not supposed to do so ~.~ (using STATE_IDLE2 instead)
    if isForm(FORM_DUAL) then return end
	if v.incut then return end
	if entity_isState(me, STATE_WAIT) then return end
	
	if v.bone_head ~= 0 then
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_head))
	end
	entity_updateCurrents(me, dt)
	
	v.flipDelay = v.flipDelay - dt
	if v.flipDelay < 0 then
		v.flipDelay = 0
	end

    if v.headDelay > 0 then
        v.headDelay = v.headDelay - dt
    else
        v.ent = entity_getNearestEntity(me)
        if eisv(v.ent, EV_TYPEID, EVT_PET) then
            v.ent = v.n
        end
        if v.ent ~= 0 and entity_isEntityInRange(me, v.ent, 256) then
            if not entity_isState(me, STATE_HUG) then
                if entity_getEntityType(v.ent) == ET_ENEMY and entity_isEntityInRange(me, v.ent, 128) then
                    if eisv(v.ent, EV_TYPEID, EVT_PET) then
                        v.ent = 0
                    else
                        v.nearEnemyTimer = v.nearEnemyTimer + dt*2
                        v.nearNaijaTimer = v.nearNaijaTimer - dt
                        if v.nearEnemyTimer > 10 then
                            expression(me, EXPRESSION_ANGRY, 2)
                            v.nearEnemyTimer = 10
                        else
                            expression(me, EXPRESSION_SURPRISE, 1)
                        end
                        entity_setNaijaReaction(me, "")
                    end
                elseif v.ent == v.n and entity_isEntityInRange(me, v.ent, 128) then
                    distFlipTo(me, v.ent)
                    if entity_getHealth(v.ent) > 2 and isForm(FORM_NORMAL) and not avatar_isSinging() then
                        v.nearNaijaTimer = v.nearNaijaTimer + dt*2
                        if v.nearNaijaTimer > 4 then
                            expression(me, EXPRESSION_HAPPY, 1)
                        end
                        if v.nearNaijaTimer > 5 then
                            entity_setNaijaReaction(me, "smile")
                        end
                        if v.nearNaijaTimer > 14 then
                            v.nearNaijaTimer = 0+math.random(2)
                            entity_setNaijaReaction(me, "")
                        end
                        
                        if avatar_getStillTimer() > 4 and not avatar_isOnWall() and v.nearNaijaTimer > 8 then
                            if not isInputEnabled() or avatar_isSinging() then 
                                v.nearNaijaTimer = 0
                            else
                                if entity_getRiding(getNaija()) == 0 then
                                    local nohug = entity_getNearestNode(me, "nohug")
                                    if nohug ~= 0 and node_isEntityIn(nohug, me) then
                                        v.nearNaijaTimer = 0
                                        entity_setState(me, STATE_IDLE2)
                                    else
                                        entity_setState(me, STATE_HUG)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            v.ent = 0
        end
        if v.ent ~= 0 then
            bone_setAnimated(v.bone_head, ANIM_POS)
            bone_lookAtEntity(v.bone_head, v.ent, 0.3, -10, 30, -90)
        else
            bone_setAnimated(v.bone_head, ANIM_ALL)
            entity_setNaijaReaction(me, "")
        end
    end
    v.nearEnemyTimer = v.nearEnemyTimer - dt
    if v.nearEnemyTimer < 0 then v.nearEnemyTimer = 0 end
    v.nearNaijaTimer = v.nearNaijaTimer - dt
    if v.nearNaijaTimer < 0 then v.nearNaijaTimer = 0 end
    
    if entity_getHealth(v.n) > v.naijaLastHealth then
        expression(me, EXPRESSION_HAPPY, 2)
    end
    v.naijaLastHealth = entity_getHealth(v.n)
    if entity_getHealth(v.n) < 1 then
        expression(me, EXPRESSION_HURT, 2)
    end
    if isFlag(FLAG_LICOMBAT, 1) then
        if v.zapDelay > 0 then
            v.zapDelay = v.zapDelay - dt
            if v.zapDelay < 0 then
                zap(me)
                v.zapDelay = 1.2
                --v.zapDelay = 0.001
            end
        end
    end
	
	
	if v.expressionTimer > 0 then
		v.expressionTimer	= v.expressionTimer - dt
		if v.expressionTimer < 0 then
			v.expressionTimer = 0
			expression(me, EXPRESSION_NORMAL, 0)
		end
	end	
	if entity_isState(me, STATE_IDLE2) then
		entity_setTarget(me, v.n)
		v.followDelay = v.followDelay - dt
		if v.followDelay < 0 then
			v.followDelay = 0
		end
		if entity_isEntityInRange(me, v.n, 1024) and not entity_isEntityInRange(me, v.n, 256) and not avatar_isOnWall() and entity_isUnderWater(v.n) then
			if v.followDelay <= 0 then
				entity_setState(me, STATE_FOLLOWING)
			end
		end 
		entity_doSpellAvoidance(me, dt, 128, 0.1)
		--entity_doEntityAvoidance(me, dt, 64, 0.5)
		if entity_isEntityInRange(me, v.n, 20) then
			entity_moveTowardsTarget(me, dt, -150)
		end
	elseif entity_isState(me, STATE_FOLLOWING) then		
		--debugLog("updating following")
		local amt = 800
		--not avatar_isOnWall() and 
		
		entity_doCollisionAvoidance(me, dt, 4, 1, 100, 1, true)
	
		entity_setTarget(me, v.n)
		if entity_isUnderWater(v.n) then
			if entity_isEntityInRange(me, v.n, 180) then
				entity_setMaxSpeedLerp(me, 0.2, 1)
			else
				entity_setMaxSpeedLerp(me, 1, 0.2)
			end
			
			if entity_isEntityInRange(me, v.n, 180) then
				entity_doFriction(me, dt, 200)
				if ((math.abs(entity_velx(v.n)) < 10 and math.abs(entity_vely(v.n)) < 10) or avatar_isOnWall()) then
					entity_setState(me, STATE_IDLE2)
				end
			elseif entity_isEntityInRange(me, v.n, 250) then
				--entity_moveAroundTarget(me, dt, amt*0.8)
				entity_moveTowardsTarget(me, dt, amt)
			elseif entity_isEntityInRange(me, v.n, 512) then
				entity_moveTowardsTarget(me, dt, amt*2)
			elseif not entity_isEntityInRange(me, v.n, 1024) then
				if entity_isUnderWater(v.n) and not avatar_isOnWall() then
					entity_moveTowardsTarget(me, dt, amt)
				else
					entity_moveTowardsTarget(me, dt, amt)
				end
			else
				entity_moveTowardsTarget(me, dt, amt)
			end
		else
			entity_setState(me, STATE_IDLE2)
		end
		
		if math.abs(entity_velx(me)) < 1 and math.abs(entity_vely(me)) < 1 then
			entity_setMaxSpeedLerp(me, 1)
			entity_moveTowardsTarget(me, 1, 500)
		end

	elseif entity_isState(me, STATE_HUG) then
		--debugLog("state hug")
		entity_setMaxSpeedLerp(me, 2)
		expression(me, EXPRESSION_HAPPY, 0.5)
		if entity_getRiding(v.n) == me then
			entity_animate(v.n, "hugLi", 0, 3)
			if v.curNote ~= -1 then
				local vx, vy = getNoteVector(v.curNote, 400*dt)
				entity_addVel(me, vx, vy)
			end
			entity_doCollisionAvoidance(me, dt, 5, 0.1)
			entity_doCollisionAvoidance(me, dt, 1, 1)
			entity_doFriction(me, dt, 100)
			entity_updateMovement(me, dt)
			
			setNaijaHugPosition(me)
			
			entity_updateLocalWarpAreas(me, true)
			
			bone_setRenderPass(v.bone_llarm, 3)
			bone_setRenderPass(v.bone_ularm, 3)
			bone_setRenderPass(v.bone_leftHand, 3)
			
			if not v.forcedHug then
				if not isForm(FORM_NORMAL) or not isInputEnabled() or entity_isFollowingPath(v.n) or avatar_getStillTimer() < 1 or v.honeyPower ~= entity_getHealthPerc(v.n) then
					endHug(me)
				end
			end
			
			
			
			--[[
			ent = entity_getNearestEntity(me, "", 400, ET_ENEMY)
			if ent ~= 0 then
				expression(me, EXPRESSION_ANGRY, 1)
				entity_setState(me, STATE_IDLE2)
				entity_flipToEntity(me, ent)
				entity_flipToEntity(v.n, ent)
			end
			]]--
		else
			--debugLog("naija is not riding")
			entity_setRiding(v.n, me)
		end
	end
	
	if not entity_isState(me, STATE_HUG) and not entity_isState(me, STATE_PATH) then
		if (math.abs(entity_velx(me))) > 10 then
			entity_flipToVel(me)
		end
		if not entity_isState(me, STATE_IDLE2) then
			entity_rotateToVel(me, 0.1)
		end
		if math.abs(entity_velx(me)) > 20 or math.abs(entity_vely(me)) > 20 then
			entity_doFriction(me, dt, 150)
			v.gvel = true
		else
			if v.gvel then
				entity_clearVel(me)
				v.gvel = false
			else
				entity_doFriction(me, dt, 40)
			end
		end
		entity_updateMovement(me, dt)
	end
	
	if not entity_isUnderWater(me) then
		local w = getWaterLevel()
		if math.abs(w - entity_y(me)) <= 40 then
			entity_setPosition(me, entity_x(me), w+40)
			entity_clearVel(me)
		else
			if entity_isUnderWater(v.n) then
				entity_setPosition(me, entity_x(v.n), entity_y(v.n))
			end
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me)
	if entity_isState(me, STATE_IDLE2) then
		debugLog("idle")
		entity_rotate(me,0,0.5)
		entity_setMaxSpeed(me, 200)
		entity_animate(me, "idle", LOOP_INF)
		if v.n ~= 0 then
			entity_flipToEntity(me, v.n)
		end
		--[[if not(isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102)) and getFlag(FLAG_LI) >= 100 then
			if v.bone_helmet ~= 0 then
				--debugLog("setting helmet alpha to 0")
				bone_alpha(v.bone_helmet, 0)
			end
		end]]
	elseif entity_isState(me, STATE_FOLLOWING) then
		--debugLog("following")
		v.followDelay = 0.2
		entity_animate(me, "swim", LOOP_INF)
		entity_setMaxSpeed(me, 600)
		
		entity_setMaxSpeedLerp(me, 1, 0.1)
        elseif entity_getState(me)==STATE_SWIM then
		--debugLog("swim")
		entity_animate(me, "swim", LOOP_INF)
	elseif entity_isState(me, STATE_WAIT) then
		debugLog("wait")
	elseif entity_isState(me, STATE_HUG) then
		v.incut = true
		debugLog("HUG!")
		
		entity_flipToEntity(me, v.n)
		entity_flipToEntity(v.n, me)
		
		v.nearNaijaTimer = 0
		v.hugOut = v.naijaOut
		if entity_isfh(me) then
			v.hugOut = -v.hugOut
		end
		
		entity_setNaijaReaction(me, "")
		
		entity_clearVel(me)
		entity_clearVel(v.n)
		
		entity_idle(v.n)
		entity_setPosition(v.n, entity_x(me)+v.hugOut, entity_y(me), 1, 0, 0, 1)
		watch(1)
		
		v.honeyPower = entity_getHealthPerc(v.n)
	
		entity_setRiding(v.n, me)
		
		entity_flipToEntity(me, v.n)
		entity_flipToEntity(v.n, me)
		
		entity_setNaijaReaction(me, "smile")
		
		entity_animate(me, "hugNaija")
		
		entity_offset(me, 0, 0, 0)
		entity_offset(v.n, 0, 0, 0)
		
		entity_offset(me, 0, 10, 1, -1, 1, 1)
		entity_offset(v.n, 0, 10, 1, -1, 1, 1)
		
		entity_setActivationType(me, AT_CLICK)
		
		if not v.forcedHug then
			if chance(75) then
				if chance(50) then
					emote(EMOTE_NAIJAGIGGLE)
				else
					emote(EMOTE_NAIJASIGH)
				end
			end
		end
		v.incut = false
	elseif entity_isState(me, STATE_PUPPET) or entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
    if entity_isState(me, STATE_HUG) then
		entity_setMaxSpeedLerp(me, 1, 0.5)
		debugLog("hug off")
		entity_offset(me, 0, 0, 0)
		entity_offset(v.n, 0, 0, 0)
		
		bone_setRenderPass(v.bone_llarm, 1)
		bone_setRenderPass(v.bone_ularm, 1)
		bone_setRenderPass(v.bone_leftHand, 1)
		
		endHug(me)
		
		entity_setActivationType(me, AT_NONE)
    end
end

function hitSurface(me)
end

function msg(me, s, x, t)
    if s == "expr" then
        expression(me, x, t)
    elseif s == "noportal" then
        return true
    elseif s == "forcehug" then
        debugLog("li - forcehug")
		v.forcedHug = true
		entity_setState(me, STATE_HUG, -1, true)
	elseif s == "endhug" then
		v.forcedHug = false
		endHug(me)
    elseif s == "idle" then
        entity_setState(me, STATE_IDLE2)
    elseif msg == "c" then
		refreshWeaponGlow(me)
		entity_animate(me, "switchCombat", 0, LAYER_UPPERBODY)
    end
end

function song(me, song)
	--debugLog("Li: Sung song!")
	if entity_isState(me, STATE_HUG) then
		if song == SONG_SHIELD then
			flipHug(me)
		end
		if song == SONG_LI then
			entity_setState(me, STATE_IDLE2)
		end
	end
	
    if song == SONG_ENERGYFORM then
        v.nearNaijaTimer = 0
        expression(me, EXPRESSION_SURPRISE, 1.5)
        entity_flipToEntity(me, v.n)
        --entity_moveTowardsTarget(me, 1, -1000)
    elseif song == SONG_BEASTFORM then
        v.nearNaijaTimer = 0
        expression(me, EXPRESSION_ANGRY, 4)
        entity_flipToEntity(me, v.n)
    elseif song == SONG_NATUREFORM then
        v.nearNaijaTimer = 2
        expression(me, EXPRESSION_HAPPY, 3)
        entity_flipToEntity(me, v.n)		
    end
end

function songNote(me, note)
	v.curNote = note
end

function songNoteDone(me, note, len)
	v.curNote = -1
end
