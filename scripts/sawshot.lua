
-- just need another name for this entity.

dofile("scripts/saw.lua")

v.shotT = 0.2
v.move = false

-- i am lazy.
local oldinit = init
local oldupdate = update
local oldmsg = msg

function init(me)
    oldinit(me)
    entity_setCollideRadius(me, 32) -- for wall collision. does not affect naija range check
end

local function destroy(me)
    if v.move then
        if v.lava then
            spawnParticleEffect("lavaballexplode", entity_getPosition(me))
        else
            spawnParticleEffect("sawsplinter", entity_getPosition(me))
        end
        entity_playSfx(me, "metalexplode")
        entity_rotate(me, 0) -- HACK: hmm?
    end
    local q
    while true do
        q = table.remove(v.qs)
        if not q then break end
        quad_delete(q, 0.1)
    end
    entity_delete(me, 0.1)
end

function update(me, dt)

    oldupdate(me, dt)
    
    
    if v.shotT >= 0 then
        v.shotT = v.shotT - dt
        if v.shotT <= 0 then
            v.shotT = v.shotT + 0.05
            createShot("trigger", me)
        end
    end
    
    if v.move then
        entity_updateMovement(me, dt)
        entity_checkSplash(me)
    end
end

function shotHitEntity(me, who)
    entity_hugeDamage(who)
end

function hitSurface(me)
    destroy(me)
end

function msg(me, s, ...)
    if s == "noportal" then
        return false -- sawshots can portal
    elseif s == "reinit" then
        destroy(me)
    elseif s == "move" then
        v.move = true
    else
        return oldmsg(me, s, ...)
    end
end