
-- death preventer, time tracker

AD = {}

AD.waterlevel = 0
AD.startnode = 0
AD.reverting = false
AD.initwait = 0.5


local function updateMapDeaths()
    v.setSavedDeaths(nil, DEATHCOUNTER)
end

local function initDeathCounter()
    DEATHCOUNTER = v.getSavedDeaths()
end


AD.init = function()

    CFG_GORE_LEVEL = tonumber(getStringFlag("CFG_GORE_LEVEL")) or 1 -- the default

    -- deactivate & unhook on "overworld" maps and the like
    if v.isSpecialMap() then
        PLAYTIME_STOP = true
        --v.logic.antideath = nil
        v.logic.antideath.update = AD._updateSpecial
        return
    end
    
    AD.waterlevel = getWaterLevel()
    AD.startnode = getNode("naijastart")
    PLAYTIME = 0
    PLAYTIME_STOP = false
    initDeathCounter()
end

local function handleDeath()
    DEATHCOUNTER = DEATHCOUNTER + 1
    updateMapDeaths()
    
    entity_alpha(v.n, 0, 0.3)
    if entity_isUnderWater(v.n) then
        entity_clearVel(v.n)
    end
    setGameSpeed(1)
    doDeathEffect(v.n, DEATH_EFFECT)
    
    -- notify other logic plugins
    for _, plugin in pairs(v.logic) do
        if plugin.onDeath then
            plugin.onDeath()
        end
    end
end

-- see node_finish.lua for the initial appear after loading map
local function appear()
    resetMap(false)
    local x, y = entity_getPosition(v.n)
    spawnParticleEffect("spirit-big", x, y + 20)
    playSfx("spirit-beacon")
    entity_heal(v.n, 100)
    entity_alpha(v.n, 1, 0.2)
    PLAYTIME = 0
    cam_toEntity(v.n)
    
    fade2(0.6, 0, 1, 1, 1)
    fade2(0, 0.7, 1, 1, 1)
end

local function revert()

    entity_clearVel(v.n)
    
    -- HACK: death prevention. This will cause the engine to abort the death sequence and continue running the game
    entity_heal(v.n, 0.01)
    entity_revive(v.n)
    entity_heal(v.n, 0.01)
    entity_heal(v.n)
    wait(DEATH_TIME)
    
    local x, y = node_getPosition(AD.startnode)
    entity_setPosition(v.n, x, y)
    setWaterLevel(AD.waterlevel)
    
    -- HACK: doing this a second time works around a bug that Naija would be respawned at the water surface
    -- if died in the water and respawned on land
    wait(FRAME_TIME)
    entity_setPosition(v.n, x, y)
    
    avatar_fallOffWall()
    entity_setInvincible(v.n, false)
    
    appear()
    
    AD.reverting = false
    PLAYTIME = 0
end


AD.postInit = function()
    entity_setInvincible(v.n, false) -- just in case
end

AD.update = function(dt)
    if AD.initwait >= 0 then
        AD.initwait = AD.initwait - dt
        return
    end
    
    if not AD.reverting and entity_getHealth(v.n) <= 0.1 then
        AD.reverting = true
        handleDeath()
        revert()
    end
    
    -- FIXME: left mouse if not really the right to test if payer started
    -- HACK: okay, added check for swim anim -- still not the right way but it seems to work now
    if not PLAYTIME_STOP and ((PLAYTIME == 0 and isLeftMouse() and isInputEnabled()) or PLAYTIME > 0 or entity_getAnimationName(v.n) == "swim") then
        PLAYTIME = PLAYTIME + dt
    end
end

-- special function for special maps. there, we don't want instant death-and-respawn,
-- but warp back to hub map
AD._updateSpecial = function(dt)
    if AD.initwait >= 0 then
        AD.initwait = AD.initwait - dt
        return
    end
    
    if not AD.reverting and entity_getHealth(v.n) <= 0.1 then
        AD.reverting = true
        
        local q = createQuad("particles/tripper")
        quad_alpha(q, 0)
        quad_alpha(q, 1, 0.2)
        quad_scale(q, 2.5, 2.5)
        quad_scale(q, 3.5, 3.5, 3, -1, 1, 1)
        quad_rotate(q, 360, 3, -1)
        quad_color(q, 1, 0, 0, 0.33)
        quad_followCamera(q, 1)
        quad_setPosition(q, 400, 300)
        
        entity_heal(v.n, 1)
        entity_revive(v.n)
        entity_heal(v.n, 1)
        wait(0.2)
        entity_heal(v.n, 1)
        entity_revive(v.n)
        entity_heal(v.n, 1)
        wait(0.6)
        
        loadMapTrans("main_hub")
        AD.reverting = false
    end
end


v.logic.antideath = AD
