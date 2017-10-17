
dofile("scripts/inc_timerqueue.lua")
dofile("scripts/inc_flags.lua")

v.offs = 0
v.multi = 0
v.wl = 0
v.tm = 0

function init(me)
    v.n = getNaija()
    v.offs = tonumber(node_getContent(me)) or 0
    v.multi = node_getAmount(me)
    v.wl = getWaterLevel()
end

local sin = math.sin

function update(me, dt)
    v.updateTQ(dt)
    
    v.tm = v.tm + (dt * v.multi)
    setWaterLevel(v.wl + (v.offs * sin(v.tm)))
end

function song()
end

function songNote()
end

function songNoteDone()
end
