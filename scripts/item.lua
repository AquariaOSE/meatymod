
dofile("scripts/inc_timerqueue.lua")

local ITEM_DEF =
{
    aircontrol =
    {
        name = "Air control",
        tex = "parrot/wing",
        flag = "HAS_AIRCONTROL",
        text = "You have found strange wings!\nRolling in the air has a much stronger effect now.",
    },
    
    booster = 
    {
        name = "Booster v0.8",
        skel = "item_booster",
        flag = "HAS_BOOSTER",
        scale = 0.5,
        text = "You have found the Booster v0.8!\nThis rocket tied to your back can be activated by left-clicking while in air, but it lasts only for a short time. Hold still to refill it.",
    },
    
    booster2 =
    {
        name = "Booster v2.0",
        skel = "item_booster2",
        flag = "HAS_BOOSTER2",
        scale = 0.5,
        text = "You have found the Booster v2.0!\nThis one has a lot more power than v0.8 and allows precisely controlling the flight direction.",
    },
    
    doublejump =
    {
        name = "Double jump",
        tex = "iwbtg/doublejump",
        flag = "HAS_DOUBLEJUMP",
        text = "You have found the double jump! Click while in air to leap into that direction.",
    },
}



v.myFlag = false
v.text = "NO DEF?!"
v.name = v.text
v.useDef = ""


function init(me)
    setupEntity(me)
    entity_initEmitter(me, 0, "glow")
end

function postInit(me)
    entity_startEmitter(me, 0)
    v.initx, v.inity = entity_getPosition(me)
end

function update(me, dt)
    v.updateTQ(dt)
end

function msg(me, s, x)
    if s == "setitem" then
        local def = ITEM_DEF[x]
        if not def then
            errorLog("item.lua: setitem: Unknown def " .. tostring(x))
        else
            v.useDef = x
            v.myFlag = def.flag
            v.text = def.text
            v.name = def.name
            if def.tex then
                entity_setTexture(me, def.tex)
            end
            if def.skel then
                entity_initSkeletal(me, def.skel)
                entity_animate(me, "idle", -1)
            end
            if def.scale then
                entity_scale(me, def.scale, def.scale)
            end
        end
    elseif s == "collect" then
        if v.myFlag then
            entity_setState(me, STATE_COLLECT)
        else
            errorLog("item.lua: collect msg but type undefined!")
        end
    elseif s == "reinit" then
        entity_setPosition(me, v.initx, v.inity)
    end
end

function enterState(me)
    if entity_isState(me, STATE_COLLECT) then
        setStringFlag(v.myFlag, "1")
        v.incut = true
        entity_idle(getNaija())
        entity_flipToEntity(getNaija(), me)
        cam_toEntity(me)
        overrideZoom(1.2, 7)
        musicVolume(0.1, 3)
        setSceneColor(1, 0.9, 0.5, 3)
        spawnParticleEffect("treasure-glow", entity_x(me), entity_y(me))
        setControlHint(v.text, 0, 0, 0, 12)
        playSfx("low-note1", 0, 0.4)
        playSfx("low-note5", 0, 0.4)
        entity_stopEmitter(me, 0)
        
        entity_setStateTime(me, 6)
        
        v.pushTQ(3, function()
            entity_setPosition(me, entity_x(me), entity_y(me)-100, 3, 0, 0, 1)
            playSfx("Collectible")
            
            v.pushTQ(3, function()
                playSfx("secret", 0, 0.5)
                cam_toEntity(getNaija())
                musicVolume(1, 2)
                setSceneColor(1, 1, 1, 1)
                overrideZoom(0)
                debugLog("item: set active powerup: " .. v.useDef)
                setStringFlag("ACTIVE_POWERUP", v.useDef)
            end)
        end)
        
    elseif entity_isState(me, STATE_COLLECTED) then
        debugLog("COLLECTED, fading OUT alpha")
        entity_alpha(me, 0, 1)
    end
end

function exitState(me)
    if entity_isState(me, STATE_COLLECT) then
        entity_alpha(me, 0, 1)
        spawnParticleEffect("Collect", entity_x(me), entity_y(me))
        entity_setState(me, STATE_COLLECTED)
    end
end
