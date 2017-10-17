
v.t = 0
v.n = 0

function init(me)
    v.n = getNaija()
    loadSound("energyboss-attack")
end

function update(me, dt)
    if v.t > 0 then
        v.t = v.t - dt
    end
    if v.t <= 0 and not entity_isInvincible(v.n) and node_isEntityIn(me, v.n) then
        DEATH_EFFECT = "death-lava"
        playSfx("energyboss-attack")
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
