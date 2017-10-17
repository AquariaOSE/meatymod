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


-- FG: dummied out and hopelessly crippled for use in the intro scene

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.seat = 0
v.seat2 = 0
v.tame = 0
v.n = 0
v.li = 0
v.leave = 0
v.avatarAttached = false
v.liAttached = false
v.myFlag = 0

v.light1 = 0
v.light2 = 0

v.seen = false

v.sbank = 0

function init(me)
	v.n = getNaija()
	
	setupEntity(me, "")
	
	entity_initSkeletal(me, "TransTurtle")
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	v.seat = entity_getBoneByName(me, "Seat")
	v.seat2 = entity_getBoneByName(me, "Seat2")
	v.tame = entity_getBoneByName(me, "Tame")
	entity_setCullRadius(me, 1024)
	bone_alpha(v.tame, 0)

	v.light1 = entity_getBoneByName(me, "Light1")
	v.light2 = entity_getBoneByName(me, "Light2")
	
	bone_setBlendType(v.light1, BLEND_ADD)
	bone_setBlendType(v.light2, BLEND_ADD)
	
	loadSound("TransTurtle-Light")
	loadSound("transturtle-takeoff")
	
    --entity_generateCollisionMask(me)
    entity_setInvincible(me, true)
	
end


local function lights(me, on, t)
	local a = 1
	if not on then
		a = 0
		debugLog("Lights off!")
	else
		debugLog("Lights on!")
	end
	
	bone_alpha(v.light1, a, t)
	bone_alpha(v.light2, a, t)
end

function postInit(me)
	v.leave = entity_getNearestNode(me, "TRANSTURTLELEAVE")
	
	-- if naija starts on a turtle, ignore the seen/hint
	if entity_isEntityInRange(me, v.n, 350) then
		v.seen = true
	end
end

local function isOtherFlag(flag)
	return (v.myFlag ~= flag and isFlag(flag, 1))
end
function update(me, dt)

	
	if v.avatarAttached then
		--entity_flipToSame(v.n, me)
		local x, y = bone_getWorldPosition(v.seat)
		
		entity_setRidingData(me, x, y, 0, entity_isfh(me))
	end
	
	if v.liAttached then
		local x, y = bone_getWorldPosition(v.seat2)
		entity_setPosition(v.li, x, y)
		entity_rotate(v.li, entity_getRotation(me))
		if entity_isfh(me) and not entity_isfh(v.li) then
			entity_fh(v.li)
		elseif not entity_isfh(me) and entity_isfh(v.li) then
			entity_fh(v.li)
		end
	end
	
end

function activate(me)

	if entity_isFlag(me, 0) then return end
	
	if entity_getRiding(getNaija())~=0 then
		return
	end
	
    entity_setActivation(me, AT_NONE)
    
    if isFlag(FLAG_FIRSTTRANSTURTLE, 0) then
        local x, y = bone_getWorldPosition(v.tame)
        entity_swimToPosition(v.n, x, y)
        entity_watchForPath(v.n)
        entity_flipToEntity(v.n, me)
        entity_animate(v.n, "tameTurtle", 0, LAYER_UPPERBODY)
        entity_animate(me, "tame")
        while entity_isAnimating(me) do
            watch(FRAME_TIME)
        end
        entity_idle(v.n)
        entity_animate(me, "idle")
        watch(0.5)
        -- don't forget this later: 
        setFlag(FLAG_FIRSTTRANSTURTLE, 1)
    end
    v.li = 0
    if hasLi() then
        v.li = getLi()
        if entity_isEntityInRange(v.n, v.li, 512) then
        else
            fade2(1, 0.2, 1, 1, 1)
            watch(0.2)
            entity_setPosition(v.li, entity_x(v.n), entity_y(v.n))
            fade2(0, 0.5)
            watch(0.5)
        end
    end
    local x, y = bone_getWorldPosition(v.seat)

    entity_swimToPosition(v.n, x, y)
    entity_watchForPath(v.n)
    entity_animate(v.n, "rideTurtle", -1)
    v.avatarAttached = true
    if entity_isfh(me) and not entity_isfh(v.n) then
        entity_fh(v.n)
    elseif not entity_isfh(me) and entity_isfh(v.n) then
        entity_fh(v.n)
    end
    
    if v.li ~= 0 then
        debugLog("here!")
        entity_setState(v.li, STATE_PUPPET, -1, 1)
        local x2, y2 = bone_getWorldPosition(v.seat2)
        entity_swimToPosition(v.li, x2, y2)
        entity_watchForPath(v.li)
        entity_animate(v.li, "rideTurtle", -1)
        v.liAttached = true
        entity_setRiding(v.li, me)
    end
    
    
    entity_setRiding(v.n, me)
    overrideZoom(0.75, 1.5)
    if isMapName("VEIL01") then
        entity_rotate(me, -80, 2, 0, 0, 1)
    end
    entity_animate(me, "swimPrep")
    while entity_isAnimating(me) do
        watch(FRAME_TIME)
    end
    

    entity_moveToNode(me, v.leave, SPEED_FAST)
    entity_animate(me, "swim", -1)
    
    playSfx("transturtle-takeoff")
    watch(1)
    fade(1, 1)
    watch(1)
    
    -- HACK: Keep the mouse cursor from reappearing for an instant
    -- when under keyboard or joystick control.
    disableInput()
    
    -- FG: WARP CODE WAS HERE
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1, 0, -1)
	end
end

function exitState(me)
end
