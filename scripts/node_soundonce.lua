if not v then v = {} end

v.play = true
v.snd = 0
v.Tcooldown = 0
v.t = 0

function init(me)
    v.snd = node_getContent(me)
    v.Tcooldown = node_getAmount(me)
    loadSound(v.snd)
end

function update(me, dt)
    if v.play then
        if node_isEntityIn(me, getNaija()) then
            playSfx(v.snd)
            v.play = false
            v.t = v.Tcooldown
        end
    else
        if v.t > 0 then
            v.t = v.t - dt
            if v.t <= 0 then
                v.play = true
                debugLog("soundonce: " .. v.snd .. " ready again")
            end
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
