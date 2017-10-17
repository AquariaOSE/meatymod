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


-- FG: slightly modified, ehanced athmosphere
-- + and now fixed for meatymod

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end


v.on = true
v.lights = 0
v.ntimer = 0
v.initx = 0
v.inity = 0
v.falling = false

local function createLight(me, s1, s2, amod, layer)
    local light = createQuad("glow-add", layer)
    quad_setBlendType(light, BLEND_ADD)
    quad_scale(light, s1, s1)
    quad_scale(light, s2, s2, 2, -1, 1)
    quad_color(light, 0.95, 0.45, 0.08)
    quad_setPosition(light, entity_x(me), entity_y(me))
    quad_alphaMod(light, amod)
    table.insert(v.lights, light)
    return light
end

local function addLights(me, layer)
    createLight(me, 2.8, 3.3, 0.1, layer)
    createLight(me, 5, 6, 0.1, layer)
    createLight(me, 7, 9, 0.1, layer)
end

local function shatter(me)
    if not v.on then return end
    
    local bx, by = vector_fromDeg(entity_getRotation(me), 30)
    spawnParticleEffect("starexplode2", entity_x(me)+bx, entity_y(me)+by) -- FG: custom effect
    for i=1,6 do
        local e = createEntity("BrokenPiece", "", entity_x(me), entity_y(me))
        local str = string.format("%s-0001", "breakable/energylamp", i)
        --debugLog(str)
        entity_setTexture(e, str)
    end
    entity_setStateTime(me, 0.1)
    
    for _, light in pairs(v.lights) do
         quad_alpha(light, 0, 1)
    end
    
    entity_alpha(me, 0, 0.5)
    v.on = false
    
    entity_playSfx(me, "energylamp-explode")
    entity_setWeight(me, 0)
end

function init(me)
	setupBasicEntity(
	me,
	"breakable/energylamp",		-- texture
	1,							-- health
	1,							-- manaballamount
	1,							-- exp
	1,							-- money
	70,							-- collideRadius
	STATE_IDLE,					-- initState
	128,						-- sprite width	
	256,						-- sprite height
	1,							-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	2000						-- updateCull -1: disabled, default: 4000
	)

	loadSound("energylamp-explode")
	entity_setDeathScene(me, true)
	entity_setDeathSound(me, "energylamp-explode")

	entity_setEatType(me, EAT_NONE)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setUpdateCull(me, 3000)
	esetv(me, EV_LOOKAT, 0)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
    
    v.lights = {}
    addLights(me)
    addLights(me, 13)
    
    entity_setMaxSpeed(me, 1200)
    entity_setCanLeaveWater(me, true)
    
end

function postInit(me)
    v.initx, v.inity = entity_getPosition(me)
end

function update(me, dt)
    if v.on then
        entity_handleShotCollisions(me)
        
        local x, y = entity_getPosition(me)
        
        if v.falling then
            entity_updateMovement(me, dt)
        else
            if x ~= v.initx or y ~= v.inity then
                entity_setWeight(me, 1200)
                v.falling = true
            end
        end
        
        for _, light in pairs(v.lights) do
             quad_setPosition(light, x, y)
        end
    end
end

function enterState(me)
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    shatter(me)
	return false
end

function msg(me, s, x)
    if s == "noportal" then -- sent if about to be warped by a portal
        if not v.falling then
            entity_setWeight(me, 1200)
            v.falling = true
        end
        return true
    elseif s == "bg" then
        entity_switchLayer(me, -4)
        entity_setAllDamageTargets(me, false)
    elseif s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
        entity_alpha(me, 1, 0.1)
        v.on = true
        entity_setWeight(me, 0)
        v.falling = false
        
        for _, light in pairs(v.lights) do
             quad_alpha(light, 1, 0.1)
        end
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

