
v.on = false
v.initwl = 0


function init(me)
    loadSound("gearwaterlevel")
    v.initwl = getWaterLevel()
end

function update(me, dt)
   
    if not v.on and node_isEntityIn(me, getNaija()) then
        local wl = getWaterLevel()
        v.on = true
        debugLog("water level down")
        playSfx("gearwaterlevel", nil, 1.5)
        setWaterLevel(wl + dt * 300)
        return
    end
    
    if v.on then
        local wl = getWaterLevel()
        if wl < 20000 then
            if wl == v.initwl then
                debugLog("water level reset")
                v.on = false
                return
            end
            setWaterLevel(wl + dt * 300)
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
