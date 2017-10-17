
v.t = 0

function init(me)
    v.t = math.random(500, 2000) / 1000
end

function update(me, dt)
    if v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            v.t = math.random(1200, 3000) / 1000
            if node_isEntityInRange(me, getNaija(), 3000) then
                createEntity("drop", "", node_getPosition(me))
            end
        end
    end
end

function song()
end

function songNote()
end

function songNoteDone()
end
