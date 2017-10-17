
-- AI support functions.

-- supported callbacks:

-- combatStart(me, who)
-- combatStop(me, who)
-- attack(me, who)
-- moveStart(me)
-- moveStop(me)


local meta, methods

local function loadAI(file)
    return modlib_include("ai/" .. file .. ".lua")
end

--local trait_poi_follower = loadAI("poi_follower")
--local trait_passive = loadAI("poi_passive") -- really necessary ?

--local trait_passive = loadAI("passive")
--local trait_protect = loadAI("protect")
--local trait_support = loadAI("support")

AI_NONE = 0 -- placeholder
AI_FOLLOWER = 1 -- follows friend
AI_TYPE_POI_FOLLOWER = 2 -- wanders around

AI_PASSIVE = 3 -- 
AI_PROTECT = 4 -- protect friend(s) if near
AI_SUPPORT = 5 -- attack target of friend, if freind attacks
AI_AGGRESSIVE = 6 -- attack everything that is in range


-- AI helpers
loadAI("_movement")
loadAI("_combat")

-- AI traits
local trait_ctors = {}
trait_ctors[AI_FOLLOWER]      = loadAI("follower")
trait_ctors[AI_AGGRESSIVE]    = loadAI("aggressive")


local function ai_create(me, ...)
    local ai = {
        e = me,               -- back-reference to owning entity
        traits = {},          -- active AI traits (tables!)
        traits_off = {},      -- inactive AI traits (swapped here if disabled, and back if enabled again)
        _cb = {},             -- callback functions
        friends = {},         -- follow or protect one of these entities (nearest one where applicable)
        
        -- user-confgurable part (what is used depends on active AIs)
        friend_mindist = 250, -- when following friends, go that close, but not closer
        aggro_range = 700,    -- entities nearer than this can be engaged (further away is ignored)
        attack_range = 550,   -- if nearer than this, attack
        damageType = DT_AVATAR_ENERGYBLAST,
        
        -- used by internal things, but listed here for completeness
        nearestFriend = 0,    -- is automatically set to nearest one of friends
        combatEntity = 0,     -- entity currently in combat with
        lastFoeHp = 0,
        lastFoeHpT = 0,
        ignoreFoeName = "",
    }
    setmetatable(ai, meta)
    for _, trait in pairs({...}) do
        ai:enable(trait)
    end
    esetv(me, EV_ENTITYDIED, 1) -- so that we know when something dies, this is important to prevent crashing
    return ai
end

local function ai_enable(ai, what)
    local parked = ai.traits_off[what]
    if parked then
        ai.traits_off[what] = nil
        ai.traits[what] = parked
    else
        debugLog("AI: creating trait " .. what .. " for " .. entity_getName(ai.e))
        ai.traits[what] = trait_ctors[what]()
    end
end

local function ai_disable(ai, what)
    local active = ai.traits[what]
    if active then
        ai.traits[what] = nil
        ai.traits_off[what] = active
    end
end

local function ai_setAttackRange(ai, r)
   ai.attack_range = r
end


--- HMM
local function ai_setCallback(ai, name, f)
    ai._cb[name] = f
end

local function ai_addFriend(ai, e)
    ai.friends[e] = true -- TODO: friend specific data?
    entity_setDeathScene(e, true) -- use this as an indicator that the entity needs to be removed
end

local function _ai_updateFriends(ai)

    -- HACK: extra checking required because an entity may have been deleted in the editor
    if not MOD_RELEASE_VERSION then
        local oldfriends = ai.friends
        ai.friends = {}
        local o
        for _, f in pairs(getAllEntities()) do
            o = oldfriends[f]
            if o then
                ai.friends[f] = o
            end
        end
    end
    
    local nearest = 999999
    for f, _ in pairs(ai.friends) do
        if entity_isState(f, STATE_DEATHSCENE) then
            ai.friends[f] = nil
        else
            local d = entity_getDistanceToEntity(ai.e, f)
            if d < nearest then
                ai.nearestFriend = f
                nearest = d
            end
        end
    end
end

local function ai_update(ai, dt)
    _ai_updateFriends(ai)
    for i, trait in pairs(ai.traits) do
        trait:update(dt, ai)
    end
end

local function ai_msg(ai, s, x)
    for _, trait in pairs(ai.traits) do
        if trait.msg then
            trait:msg(ai, s, x)
        end
    end
end

local function ai_damage(ai, ...) -- same params as in damage(), but "me" is "ai"
    for _, trait in pairs(ai.traits) do
        if trait.damage then
            trait:damage(ai, ...)
        end
    end
end

local function ai_entityDied(ai, e) -- same params as in damage(), but "me" is "ai"

    ai.friends[e] = nil
    if e == ai.nearestFriend then
        _, ai.nearestFriend = next(ai.friends)
    end
    
    if e == ai.combatEntity then
        _ai_doCombatWithEntity(ai, 0) -- hackish but ok
    end
    
    for _, trait in pairs(ai.traits) do
        if trait.entityDied then
            trait:entityDied(ai, e)
        end
    end
end

local function ai_cb(ai, name, ...)
    local f = ai._cb[name]
    if f then
        return f(ai.e, ...)
    else
        debugLog("AI: " .. entity_getName(ai.e) .. " no cb " .. name)
    end
end

local function ai_isInCombat(ai)
    if ai.combatEntity == 0 then
        return false
    end
    
    if not entity_exists(ai.combatEntity) or entity_isState(ai.combatEntity, STATE_DEATHSCENE) then
        _ai_doCombatWithEntity(ai, 0) -- hackish but ok
        return false
    end
    return true
end


methods = {
    setCallback = ai_setCallback,
    addFriend = ai_addFriend,
    disable = ai_disable,
    enable = ai_enable,
    update = ai_update,
    msg = ai_msg,
    entityDied = ai_entityDied,
    cb = ai_cb,
    damage = ai_damage,
    isInCombat = ai_isInCombat,
}

meta = {
    __index = methods
}


return {
    ai_create = ai_create,
}