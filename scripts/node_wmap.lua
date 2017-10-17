
dofile("scripts/inc_flags.lua")
dofile("scripts/inc_mapsave.lua")

v.n = 0
v.on = false
v.mapid = 0
v.targetmap = false
v.iswz = false
v.noinput = false
v.wzT = -1
v.text = 0
v.mapname = false

function init(me)
    v.n = getNaija()
    v.mapid = tonumber(node_getContent(me))
    
    if v.mapid and v.mapid > 0 then
        
        local m = v.getMapNameForEntryByIndex(v.mapid, getMapName())
        if m then
            v.mapname = m
            local x, y = node_getPosition(me)
            
            v.targetmap = m
            v.on = true
            
            if v.isWarpzoneMap(m) then
                v.iswz = true
                if v.hasSeenMap(m) then
                    spawnParticleEffect("warpspiral-blue", x, y)
                else
                    v.on = false
                    return
                end
            elseif v.hasBeatenMap(m) then
                spawnParticleEffect("warpspiral-green", x, y)
            else
                spawnParticleEffect("warpspiral-red", x, y)
            end
            
            if v.hasParTime(m) then
                spawnParticleEffect("warp-aplus", x, y)
            end
            
            local q = createQuad("softglow-add", 13)
            quad_setBlendType(q, BLEND_ADD)
            quad_setPosition(q, x, y)
            quad_scale(q, 2, 2)
            
            if not v.iswz then
            
                v.text = createBitmapText(tostring(v.mapid), 15, x, y - 35)
                obj_scale(v.text, 3.5, 3.5)
                obj_color(v.text, 0, 0, 0)
                
                -- HACK: HAAAACK
                local izoom = node_getNearestNode(me, "izoom")
                if izoom ~= 0 and node_isPositionIn(izoom, node_getPosition(me)) then
                    obj_rotate(v.text, 180)
                    obj_setPosition(v.text, obj_x(v.text), obj_y(v.text) + 70)
                end
            end
            
            node_setCursorActivation(me, true)
        end
    end
end

local function doWarpZone(me)
    v.on = false
    v.noinput = true
    
    entity_clearVel(v.n)
    disableInput()
    
    local q = createQuad("particles/warpzone")
    quad_alpha(q, 0)
    quad_alpha(q, 1, 0.5)
    quad_followCamera(q, 1)
    quad_setPosition(q, 400, 300)
    quad_scale(q, 2.5, 2.5)
    quad_rotate(q, 360)
    quad_rotate(q, 0, 1.8, -1)
    quad_setLayer(q, LR_HUD)
    spawnParticleEffect("warpzone", entity_getPosition(v.n))
    
    entity_setState(v.n, 12345)
    entity_animate(v.n, "frozen", -1)
    entity_rotate(v.n, entity_getRotation(v.n) - 360, 0.6, -1)
    entity_setPosition(v.n, node_x(me), node_y(me), 1)
    
    playSfx("warpzone_noise", nil, 0.25)
    playSfx("warpzone_sq", nil, 0.6)
    
    v.wzT = 2
    -- WTF: watch() does not work here for some reason
    
end

function update(me, dt)
    if v.on and node_isEntityIn(me, v.n) then
        v.on = false
        debugLog("wmap " .. v.mapid .. " -- " .. v.targetmap)
        if v.iswz then
            doWarpZone(me)
        else
            loadMapTrans(v.targetmap)
        end
    end
    
    if v.noinput and isInputEnabled() then
        disableInput()
    end
    
    if v.wzT >= 0 then
        v.wzT = v.wzT - dt
        if v.wzT <= 0 then
            local x, y = entity_getPosition(v.n)
            spawnParticleEffect("spirit-big", x, y + 20)
            playSfx("spirit-beacon")
            watch(0.5)
            loadMap(v.targetmap)
        end
    end
end

function activate(me)
    local m = v.mapname
    local desc = v.getMapDesc(m)
    local par = v.getParTime(m)
    local tm = v.getSavedTime(m)
    local d = v.getSavedDeaths(m)
    
    local s = "[" .. v.mapid .. "] \"" .. desc .. "\""
    if par and par > 0 then
        s = s .. "\nPar time: " .. par
    end
    
    s = s .. "\nBest time: "
    
    if tm > 0 then
        s = s .. string.format("%.3f", tm)
    else
        s = s .. "---"
    end
    
    s = s .. "\nDeaths: " .. d

    setControlHint(s, false, false, false, 6)
end

function song()
end

function songNote()
end

function songNoteDone()
end
