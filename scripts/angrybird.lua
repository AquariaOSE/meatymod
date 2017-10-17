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

-- FG: hacked parrot script

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0

local STATE_FLYING = 1000
local STATE_FALLING = 1001
v.inity = 0
v.drownTimer = 0
v.drownTime = 6
v.initfh = false
v.needinit = true

local PUSHBACK_DIST = 1000
local BLAST_DIST = 100
local EXPLODE_SOUND = "pistolshrimp-fire"
local EXPLODE_SOUND2 = "mantis-bomb"
v.on = true
v.fadeT = -1
v.initX = 0
v.initY = 0
v.dmg = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "parrot", "parrot-angrybird")
	--entity_setAllDamageTargets(me, true)
	--entity_setEntityLayer(me, 0)

	entity_setCollideRadius(me, 48)
	
	entity_setHealth(me, 999)
	
	entity_setState(me, STATE_FLYING)
	
	entity_setCanLeaveWater(me, true)
	entity_setMaxSpeed(me, 800)
    local s = 1.25
	entity_scale(me, s, s)
    
    loadSound(EXPLODE_SOUND)
    loadSound(EXPLODE_SOUND2)
    
    esetv(me, EV_BEASTBURST, 0) -- not edible without BOOM
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
    v.initX, v.initY = entity_getPosition(me)
    
    local flip = entity_getNearestNode(me, "flip")
    if flip ~= 0 and node_isEntityIn(flip, me) then
        entity_fh(me)
    end
    
    v.initfh = entity_isfh(me)
end


local function pushback(me)
    if entity_touchAvatarDamage(me, PUSHBACK_DIST, 0, 1300, 0.2) then
        emote(EMOTE_NAIJAUGH)
    end
end

local function explode(me)

    if v.needinit then
        v.needinit = false
        v.initfh = entity_isfh(me) -- might have been changed by a "facing" node in the meantime
    end
    
    if not v.on then
        return
    end
    v.on = false
    
	entity_playSfx(me,  EXPLODE_SOUND, nil, 1.3, nil, nil, 3000)
	entity_playSfx(me, EXPLODE_SOUND2, nil, 1.3, nil, nil, 3000)
    
    if entity_touchAvatarDamage(me, BLAST_DIST) then
        entity_hugeDamage(v.n)
        shakeCamera(60, 1)
        fade2(1, 0.01, 1, 1, 1)
        v.fadeT = 0.05
    else
        shakeCamera(20, 1)
    end
    
    entity_alpha(me, 0, 0.1)
    
	--pushback(me)

    spawnParticleEffect("birdexplode", entity_getPosition(me))
end


function update(me, dt)

    if v.fadeT > 0 then
        v.fadeT = v.fadeT - dt
        if v.fadeT <= 0 then
            fade2(0, 0.4, 1, 1, 1)
        end
    end
        
    if not v.on then
        return
    end
    
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000, 0) then
        explode(me)
    end
	
	if entity_isState(me, STATE_FLYING) then
		if entity_isfh(me) then
			entity_addVel(me, 800*dt, 0)
		else
			entity_addVel(me, -800*dt, 0)
		end
		--entity_flipToVel(me)
	end
	if not entity_isState(me, STATE_IDLE) then	
		entity_updateMovement(me, dt)
	end
	if entity_isUnderWater(me) then
		if not entity_isState(me, STATE_FALLING) then
			entity_setState(me, STATE_FALLING)
		end
		v.drownTimer = v.drownTimer + dt
		if v.drownTimer > v.drownTime then
			explode(me)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FLYING) then
		entity_animate(me, "fly", -1)		
		entity_setWeight(me, 0)
	elseif entity_isState(me, STATE_FALLING) then
		entity_setWeight(me, 300)
		entity_addVel(me, -entity_velx(me)/2, 400)
		entity_setMaxSpeedLerp(me, 2, 0.1)
		entity_rotate(me, 160, 2, 0, 0, 1)
		entity_animate(me, "idle", -1)
		--spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    if not v.on then
        return false
    end
    
    if attacker == me then
        return false
    end
    
	--debugLog(string.format("parrot health: %d", entity_getHealth(me)))
	spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
	if damageType == DT_AVATAR_BITE then
		explode(me)
        return false
	elseif damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK or damageType == DT_CRUSH then
		entity_setState(me, STATE_FALLING)
		spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
	end
    
    v.dmg = v.dmg + dmg
    if v.dmg > 3 then
        explode(me)
    end
    
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
    entity_fh(me)
    if entity_isState(me, STATE_FLYING) then
        local vx = entity_velx(me)
        entity_clearVel(me)
        entity_addVel(me, -vx, 0)
    end
end

function msg(me, s)
    if s == "reinit" then
        entity_setState(me, STATE_FLYING)
        entity_alpha(me, 1, 0.2)
        entity_setPosition(me, v.initX, v.initY)
        entity_rotate(me, 0)
        if entity_isfh(me) ~= v.initfh then
            entity_fh(me)
        end
        v.on = true
        v.drownTimer = 0
        entity_clearVel(me)
        v.dmg = 0
    end
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

