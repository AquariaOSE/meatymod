if not v then v = {} end

dofile("scripts/inc_flags.lua")

v.speed = 0
v.tm = 0
v.on = true
v.n = 0

function init(me)
    
    v.speed = tonumber(node_getContent(me)) or 0
    v.tm = node_getAmount(me)
    
    if v.speed <= 0 then
        v.on = false
    end
    
    v.n = getNaija()
end

function update(me, dt)
    if v.on and node_isEntityIn(me, v.n) then
        setGameSpeed(v.speed, v.tm)
    end
end

function song()
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
