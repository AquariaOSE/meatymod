-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

dofile("scripts/inc_util.lua")

-- Duoeye


-- L O C A L  V A R I A B L E S 

local MAX_BREEDERS = 10


v.orient = ORIENT_LEFT
v.orientTimer = 0

v.swimTime = 0.75
v.swimTimer = v.swimTime - v.swimTime/4

v.node_mist = 0
v.eMate = 0
v.matingTimer = 0
v.mateCheckDelay = 5
 
-- F U N C T I O N S

function init(me)
	setupBasicEntity(me, 
	"gloweye/head2",					-- texture
	7,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)	
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initPart(me, 
	"FlipperLeft", 
	"gloweye/flipper2",
	-24,
	16,
	0,
	0, 
	0)
	
	entity_initPart(me, 
	"FlipperRight", 
	"gloweye/flipper2",
	24,
	16,
	0,
	1,
	0)
    
    loadSound("MoneyeThrust")
	
	entity_partRotate(me, "FlipperLeft", -20, v.swimTime/2, -1, 1, 1)
	entity_partRotate(me, "FlipperRight", 20, v.swimTime/2, -1, 1, 1)

	entity_scale(me)
	entity_scale(me, 0.6, 0.6, 0.5)
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_setEatType(me, EAT_FILE, "Moneye")-- FIXME
	
	esetv(me, EV_ENTITYDIED, 1)
    
    v.glow = createQuad("softglow-add", 13)
    quad_scale(v.glow, 3, 3)
    quad_color(v.glow, 0.84, 0.6, 1)
    quad_alpha(v.glow, 0)
    quad_alpha(v.glow, 1, 1)
    quad_setBlendType(v.glow, BLEND_ADD)
	
	--entity_setMaxSpeed(me, 1000)
    
    v.mateCheckDelay = math.random(450, 600) / 100 -- add a bit of variance to distribute peak times
end

function postInit(me)
	v.node_mist = entity_getNearestNode(me, "MIST")
end

local function destroy(me, light)
    if v.glow ~= 0 then
        quad_delete(v.glow, 1.5)
        v.glow = 0
    
        if light then
            local l = createQuad("Naija/LightFormGlow", 13)
            quad_setPosition(l, entity_getPosition(me))
            quad_color(l, 0.7, 0.5, 1)
            quad_scale(l)
            quad_scale(l, 7, 7, 0.5, 0, 0, 1)
            quad_delete(l, 8)
        end
    end
end

function dieNormal(me)
    if chance(20) then
        if chance(40) then
            spawnIngredient("SmallEye", entity_x(me), entity_y(me))
        else
            spawnIngredient("GlowingEgg", entity_x(me), entity_y(me))
        end
    end
end

-- warning: only called if EV_ENTITYDIED set to 1!
function entityDied(me, ent)
	if v.eMate == ent then
		v.eMate = 0
		entity_setState(me, STATE_IDLE)
	end
end

function msg(me, msg, val)
	if msg == "mate" then
		--debugLog("mate msg")
		v.eMate = val
		entity_setState(me, STATE_MATING)
	elseif msg == "matedone" then
        destroy(me)
    end
end

local function countBreeders(e, t)
    if entity_isName(e, "gloweyebreeder") then
        t.v = t.v + 1
    end
end

function update(me, dt)
	local amt = 400
    
    quad_setPosition(v.glow, entity_getPosition(me))
	
	if entity_isState(me, STATE_MATING) then
		if v.eMate == 0 then
            entity_setState(me, STATE_IDLE)
        elseif entity_isEntityInRange(me, v.eMate, 64) then
			v.matingTimer = v.matingTimer + dt
			if v.matingTimer > 2 then
				--debugLog("MATED!")
                destroy(me)
                entity_msg(v.eMate, "matedone")

				local ent = createEntity("gloweyebreeder", "", entity_getPosition(me))
				entity_setState(ent, STATE_GROW)
                
               	entity_delete(me)
				entity_delete(v.eMate) 

				v.eMate = 0
			end
		end
        
        if v.eMate ~= 0 then
            entity_moveTowards(me, entity_x(v.eMate), entity_y(v.eMate), dt, 800)
        end
		
	else
		if v.node_mist ~= 0 then
			if node_isEntityIn(v.node_mist, me) then
				v.mateCheckDelay = v.mateCheckDelay - dt
				if v.mateCheckDelay < 0 then
                    local tmp = { v = 0 }
                    v.forAllEntities(countBreeders, tmp)
                    if tmp.v < MAX_BREEDERS then
                        v.eMate = entity_getNearestEntity(me, "gloweye2", 210)
                        if v.eMate ~= 0 and entity_isState(v.eMate, STATE_IDLE) then
                            entity_msg(v.eMate, "mate", me)
                            entity_setState(me, STATE_MATING, 4)
                        end
                    end
					v.mateCheckDelay = 2
				end
			end
		end
		if not entity_hasTarget(me) then
			entity_findTarget(me, 500)
			v.swimTimer = v.swimTimer + dt
			if v.swimTimer > v.swimTime then
                entity_sound(me, "MoneyeThrust")
				v.swimTimer = v.swimTimer - v.swimTime
				if v.orient == ORIENT_LEFT then
					entity_addVel(me, -amt, 0)
					v.orient = ORIENT_UP
				elseif v.orient == ORIENT_UP then
					entity_addVel(me, 0, -amt)
					v.orient = ORIENT_RIGHT
				elseif v.orient == ORIENT_RIGHT then
					entity_addVel(me, amt, 0)
					v.orient = ORIENT_DOWN
				elseif v.orient == ORIENT_DOWN then
					entity_addVel(me, 0, amt)
					v.orient = ORIENT_LEFT
				end			
				entity_rotateToVel(me, 0.2)
				v.orientTimer = v.orientTimer + dt
				entity_doEntityAvoidance(me, 1, 256, 0.2)
			end
			entity_doCollisionAvoidance(me, dt, 6, 0.5)
		else
			
			v.swimTimer = v.swimTimer + dt
			if v.swimTimer > v.swimTime then
                entity_sound(me, "MoneyeThrust")
				entity_moveTowardsTarget(me, 1, amt)
				if not entity_isNearObstruction(getNaija(), 8) then
					entity_doCollisionAvoidance(me, 1, 6, 0.5)
				end
				entity_doEntityAvoidance(me, 1, 256, 0.2)
				entity_rotateToVel(me, 0.2)
				v.swimTimer = v.swimTimer - v.swimTime
			else
				entity_moveTowardsTarget(me, dt, 100)
				entity_doEntityAvoidance(me, dt, 64, 0.1)
				--if not entity_isNearObstruction(getNaija(), 8) then
				entity_doCollisionAvoidance(me, dt, 6, 0.5)
				--end
			end
			entity_findTarget(me, 800)
		end
	end
	entity_doFriction(me, dt, 600)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 16, 1, 1200)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.mateCheckDelay = 3
		v.matingTimer = 0
		entity_setMaxSpeed(me, 600)
	elseif entity_isState(me, STATE_MATING) then
		entity_offset(me)
		entity_offset(me, 0, 10, 0.05, -1, 1)
	elseif entity_isState(me, STATE_DEAD) then
        destroy(me, true)
	end
end

function exitState(me)
end

function hitSurface(me)
	v.orient = v.orient + 1
end
