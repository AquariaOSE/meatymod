
v.t = 0

function init(me)
    v.n = getNaija()
end

function update(me, dt)
    if v.t > 0 then
        v.t = v.t - dt
    end
    if v.t <= 0 and node_isEntityIn(me, v.n) then
        entity_hugeDamage(v.n)
        v.t = 1
    end
end

function song()
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
