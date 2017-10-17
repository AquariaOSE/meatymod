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

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

--dofile("scripts/inc_flags.lua")

local ADJUST_TIME = 0.2
local LOCK_TIME = 0.7  -- must be > ADJUST_TIME
local SPIN_MASS_LIMIT = 35
local PULL_WEIGHT_WATER = 200
local PULL_WEIGHT_AIR = 800

local SPEED_CORRECTION_MULT = 1.043 -- probably due to precision loss, gears lose speed over a longer distance. this somewhat compensates it.

v.ga = 0 -- "ga" (gear activate") node nearby

v.rotSpd = 0.0
v.minSpd = 300 -- speed required to activate nearest "ga" node
v.n = 0
v.gear = 0 -- bone
v.gearBack = 0 -- bone
v.soundTimer = 0
v.mass = 0
v.deathtimer = 0
v.deadposx = 0
v.deadposy = 0
v.isBg = false
v.ignoreroll = false

v.wasPulled = false

v.useSetRotSpd = 0

-- the gear should check neighbors speeds in regular intervals
v.adjtimer = 0 -- adjust own speed if timer passed

-- when adjusted by another gear, ignore naija rotating
v.locktimer = 0

-- stores nearby gears
v.neargears = nil -- { gear => doAdjust [true or false] }
v.adjBy = 0 -- gear which last adjusted us

-- some things worth to know:
-- esetvf(EV_WALLTRANS) stores our current rotation speed, so other gears from outside can see it.
--   the engine does not use this one, so this is safe.
-- esetv(EV_SWITCHCLAMP) stores adjust chain order, to be able to distinguish between which gear is adjusted by which other gear
--   it is used only by entity_switchSurfaceDirection(), which is not used here.



local gear_debug = function() end --v.edbg
--[[function(e, ...)
    v.edbg(e, ...)
    debugLog(...)
end]]

local function setRotSpeedExt(e, spd)
    esetvf(e, EV_WALLTRANS, spd * 1000)
end

local function getRotSpeedExt(e)
    return egetvf(e, EV_WALLTRANS) / 1000
end

local function setChainIdExt(e, id)
    esetv(e, EV_SWITCHCLAMP, id)
end

local function getChainIdExt(e)
    return egetv(e, EV_SWITCHCLAMP)
end

local function isPullable(me)
    return entity_isProperty(me, EP_MOVABLE)
end

local function isFixed(gear)
    return not isPullable(gear) or entity_getVelLen(gear) == 0
end

local function calcGearRatio(me, other)
    local myr = entity_getCollideRadius(me)
    local otherr = entity_getCollideRadius(other)
    return otherr / myr
end

-- returns a speed value independent from size
local function calcUniformSpeed(gear, speed)
    if not speed then
        speed = getRotSpeedExt(gear)
    end
    
    return math.abs(speed / entity_getCollideRadius(gear))
end

-- NOT USED right now
local function getMyFastestNeighbor(me)
    local fastest
    local maxspd = 0
    for e, _ in pairs(v.neargears) do
        local spd = calcUniformSpeed(e)
        if spd > maxspd then
            maxspd = spd
            fastest = e
        end
    end
    if maxspd < 0.001 then
        return nil
    end
    return fastest
end

local function calcMySpeedRelativeTo(me, other)
    return -getRotSpeedExt(other) * calcGearRatio(me, other) * SPEED_CORRECTION_MULT
end

local function updateCollideRadius(me, scale)
    local r = 106.666 * scale -- rough guess
    local m = 20 * scale
    --debugLog("gear " .. entity_getID(me) .. " coll rad: " .. r .. " - mass: " .. m)
    entity_setCollideRadius(me, r)
    v.mass = m
end

local function updateWeight(me)
    if entity_isUnderWater(me) then
        entity_setMaxSpeedLerp(me, 1, 0.1)
        entity_setWeight(me, PULL_WEIGHT_WATER)
    else
        if not entity_isBeingPulled(me) then
            entity_setWeight(me, PULL_WEIGHT_AIR)
            entity_setMaxSpeedLerp(me, 5, 0.1)
        end
    end
end

function v.makeOthersAdjustToMe(me)
    for e, doit in pairs(v.neargears) do
        if doit and e ~= v.adjBy and isFixed(e) then
            entity_msg(e, "adjust", me)
        end
    end
end


function v.adjustMySpeed(me, to)
    local who = to
    if not to or to == 0 then
        to = getMyFastestNeighbor(me)
    end
    if to and to ~= 0 then
        v.rotSpd = calcMySpeedRelativeTo(me, to)
        if math.abs(v.rotSpd) > 0.001 then
            local chainId = getChainIdExt(who)
            chainId = chainId + 1
            setChainIdExt(me, chainId)
            gear_debug(me, "[" .. chainId .. "] adjspeed: " .. v.rotSpd, 0)
            return
        end
    end
    
    setChainIdExt(me, 0)
    if next(v.neargears) == nil then
        gear_debug(me, "no nearby gears", 0)
    else
        gear_debug(me, "no gear to adjust to!", 0)
    end
end

function init(me)
    v.neargears = {}
	entity_setEntityType(me, ET_NEUTRAL)
    entity_setState(me, STATE_IDLE)
	entity_initSkeletal(me, "Gear")
	entity_setUpdateCull(me, -1)
    entity_setCull(me, false)
    
    entity_scale(me, 1.5, 1.5)
    updateCollideRadius(me, 1.5)
	
	v.gear = entity_getBoneByName(me, "Gear")
	v.gearBack = entity_getBoneByName(me, "GearBack")
	
	loadSound("GearTurn")
	loadSound("choprock")
	
	esetv(me, EV_BEASTBURST, 0)
	esetv(me, EV_LOOKAT, 0)
    setChainIdExt(me, 0)
    setRotSpeedExt(me, 0)
    
    entity_setCanLeaveWater(me, true)
end

function v.foundNearGear(g, me)
    if g ~= me and not v.neargears[g] then
        v.neargears[g] = true
        --debugLog("gear " .. entity_getID(me) .. " found other: " .. entity_getID(g))
        entity_msg(g, "link", me)
    end
end

local function hasContact(e, me)
    if e ~= me and not entity_isBeingPulled(e) and entity_isName(e, "geargeneric") then
        local c1 = entity_getCollideRadius(me)
        local c2 = entity_getCollideRadius(e)
        local d = entity_getDistanceToEntity(me, e)
        return c1 + c2 > d
    end
    return false
end

function v.findNearGears(me)
    v.neargears = {}
    forAllEntities(v.foundNearGear, me, hasContact, me)
end

function postInit(me)
    v.n = getNaija()
    v.findNearGears(me)
    
    local node = entity_getNearestNode(me, "ga")
    if node ~= 0 and node_isEntityIn(node, me) then
        v.ga = node
    end
end

function msg(me, s, x)
    if s == "setdata" then
        v.useSetRotSpd = x
        updateCollideRadius(me, entity_getScale(me))
        v.findNearGears(me)
    elseif s == "scan" then
        v.findNearGears(me)
    elseif s == "link" then
        if hasContact(x, me) then
            v.foundNearGear(x, me)
        end
    elseif s == "unlink" then
        v.neargears[x] = nil
        v.adjgear = 0
    elseif s == "bg" then
        v.isBg = true
    elseif s == "ignoreroll" then
        v.ignoreroll = true
    elseif s == "minspeed" then
        v.minSpd = x
    elseif s == "pullable" then
        entity_setProperty(me, EP_MOVABLE, true)
        entity_setMaxSpeed(me, 300)
        entity_setBounce(me, 0.2)
        updateWeight(me)
    elseif s == "stop" then
        v.rotSpd = 0
    elseif s == "adjust" then
        v.adjBy = x
        v.adjustMySpeed(me, x)
    end
end
        

function enterState(me)
end

function exitState(me)
end

function activate(me)
end

function songNote(me, note)
end

function song(me, s)
end

function songNoteDone(me, note, t)
end

function damage(me)
	return false
end

local function doFunction(me)
    if v.ga ~= 0 then
        node_activate(v.ga, me)
    end
end

function v.getSpinMulti(me)
    local m = 77 - v.mass -- seems like a good value in relation to size and friction
    if m < 0 then
        m = 0
    end
    return m
end

local function myIsLockable()
    return avatar_isLockable() or (entity_isUnderWater(v.n) and entity_updateCurrents(v.n, 0))
end

function update(me, dt)

	local spinning = false
	
	if v.useSetRotSpd == 0 then
        if v.locktimer < dt then
            v.locktimer = 0
        else
            v.locktimer = v.locktimer - dt
        end
        
        if not v.ignoreroll then
            v.locktimer = 0
            setChainIdExt(me, 0)
            if entity_isEntityInRange(me, v.n, 600) then  -- FIXME: finetune this range
                if entity_isUnderWater(v.n) and avatar_isRolling() then
                    local sm = v.getSpinMulti(me)
                    v.rotSpd = v.rotSpd + sm * dt * avatar_getRollDirection()
                    
                    local limit = 360
                    
                    if v.mass > SPIN_MASS_LIMIT then
                        limit = 270 -- should be < minSpd below
                    end
                    
                    if v.rotSpd > limit then
                        v.rotSpd = limit
                    elseif v.rotSpd < -limit then
                        v.rotSpd = -limit
                    end

                    spinning = sm > 0
                end
            end
        end

	else
		spinning = true
		v.rotSpd = v.useSetRotSpd
        gear_debug(me, "my speed: " ..v.rotSpd, 0)
	end
    
    -- adjust nearby gears
    if v.adjtimer < dt then
        if v.rotSpd ~= 0 then
            v.makeOthersAdjustToMe(me)
        end
        
        v.adjtimer = ADJUST_TIME
    else
        v.adjtimer = v.adjtimer - dt
    end
        
        
	--debugLog(string.format("rotspd:%d", v.rotSpd))
	if v.rotSpd ~= 0 then
		
		entity_rotate(me, entity_getRotation(me)+v.rotSpd*dt)
		--bone_rotate(gear, bone_getRotation(gear)+v.rotSpd*dt)
		bone_rotate(v.gearBack, bone_getRotation(v.gearBack)-v.rotSpd*2*dt)
		
		if bone_getRotation(v.gear) > 360 then
			bone_rotate(v.gear, bone_getRotation(v.gear)-360)
		elseif bone_getRotation(v.gear) < -360 then
			bone_rotate(v.gear, bone_getRotation(v.gear)+360)	
		end
        
        -- do not spam sounds
        if v.rotSpd < 100  then
            v.soundTimer = v.soundTimer + v.rotSpd*dt
            --debugLog(string.format("soundTimer: %f", v.soundTimer))
            local intv = 210
            if v.soundTimer > intv then
                v.soundTimer = 0
                entity_sound(me, "GearTurn")
            end
            if v.soundTimer < -intv then
                v.soundTimer = 0
                entity_sound(me, "GearTurn")
            end
        end

		if v.mass > SPIN_MASS_LIMIT or not spinning then -- if naija is not spinning or the gear is too heavy, apply friction
			local dir = 1
            local frictSpeed = v.rotSpd
			if v.rotSpd > 0 then
                frictSpeed = frictSpeed + 40
				dir = -1
			else
                frictSpeed = frictSpeed - 40
            end
			v.rotSpd = v.rotSpd + (-frictSpeed * 0.2 * dt)
			if dir == 1 and v.rotSpd > 0 then
				v.rotSpd = 0
			elseif dir == -1 and v.rotSpd < 0 then
				v.rotSpd = 0
			end
		end
	end
    
    setRotSpeedExt(me, v.rotSpd)
    
    -- BELOW HERE DO NOT CHANGE ROT SPEED --  

	if v.rotSpd > v.minSpd or v.rotSpd < -v.minSpd then
		doFunction(me)
	end
    
    local pulled = false
    if isPullable(me) then
        --entity_updateCurrents(me, dt * 5) -- no! this allows passing through horizontal strong currents - attaching to a gear and falling through
        entity_updateMovement(me, dt)
        pulled = entity_isBeingPulled(me)
        if pulled and (next(v.neargears) ~= nil or not v.wasPulled) then
            debugLog("gear pull start")
            for g, _ in pairs(v.neargears) do
                entity_msg(g, "scan", me) -- others will ignore us now since we are pulled
            end
            v.neargears = {}
        end
        if pulled or entity_checkSplash(me) then
            updateWeight(me)
        end
    end
    
    if not pulled and v.wasPulled then
        debugLog("gear pull stop")
        v.findNearGears(me)
    end
    
    v.wasPulled = pulled
    
    if not v.isBg then
    
        local offset = 0
        if isForm(FORM_FISH) then -- HACK: crappy hack
            offset = 36
        end
    
        if not pulled and entity_touchAvatarDamage(me, entity_getCollideRadius(me) + offset, 0) then
            
            if v.deathtimer <= 0 then -- timed to prevent death spam
                local e = entity_getBoneLockEntity(v.n)
                if e ~= 0 and e ~= me and entity_isName(e, "geargeneric") then
                    local es = getRotSpeedExt(e)
                    if (es > 0 and v.rotSpd < 0) or (es < 0 and v.rotSpd > 0) then -- riding along is ok, getting between 2 is not
                        v.crushed(me, e)
                    else
                        avatar_fallOffWall()
                    end
                end
            end
            
            if myIsLockable() and entity_setBoneLock(v.n, me) then
            else
                local x, y = entity_getVectorToEntity(me, v.n)
                if isForm(FORM_FISH) then
                    x, y = vector_setLength(x, y, 20000*dt) -- HACK: crappy hack
                end
                entity_addVel(v.n, x, y)
            end
            
        end
        
        entity_handleShotCollisions(me)
        
        if v.deathtimer >= 0 then
            v.deathtimer = v.deathtimer - dt
        end
    end
end


function v.crushed(me, e)
    v.deathtimer = DEATH_IDLE_TIME
    --if entity_getHealth(v.n) > 0 then
    --    entity_playSfx(v.n, "naijalow1")
    --end
    
    entity_hugeDamage(v.n) 

    if CFG_GORE_LEVEL > 0 then
        playSfx("choprock")
        playSfx("squishy-die")
    end
end

function hitSurface(me)
end
