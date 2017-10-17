

rawset(_G, "entity_hugeDamage", function(e, attacker)
    if e == getNaija() then
        entity_damage(e, attacker or e, entity_getHealth(e) - 0.01)
        entity_changeHealth(e, -(entity_getHealth(e) - 0.01)) -- in case invulnerability timer after taking slight damage is on
        return true
    else
        return entity_damage(e, attacker or e, 999)
    end
end)

-- nodes that need to be activated on resetMap() to perform a special function
local NEED_ACTIVATE_NODE = {
    logic = true,
    finish = true,
    move = true,
    shootlava = true,
    spawn = true,
    lavaball = true,
    iwbtg = true,
}

local function isNeedActivateNode(node)
    return NEED_ACTIVATE_NODE[node_getLabel(node)]
end

-- entities that are assured to be *never* deleted
local MAP_OBJECTS = {
    geargeneric = true,
    saw = true,
    sawshooter = true,
    missileshooter = true,
    lavatile = true,
    key = true,
    spikes = true,
    barrel = true,
    bandaid = true,
    healthplant = true,
    dblock = true,
    item = true,
    ["dblock-hard"] = true,
    darkjellyfg = true,
}

rawset(_G, "isMapObject", function(e)
    return MAP_OBJECTS[entity_getName(e)]
end)

rawset(_G, "resetMap", function(firstInit)
    DEATH_EFFECT = ""
    debugLog("resetMap: Resetting entities...")
    --forAllEntities(entity_msg, "reinit") -- WARNING: may create entities while iterating - this causes problems & possible crashes with saw shooters
    -- so instead, get a list of them, then it won't matter
    for _, e in pairs(getAllEntities()) do
        entity_msg(e, "reinit")
    end
    debugLog("resetMap: Resetting nodes...")
    forAllNodes(node_activate, nil, isNeedActivateNode)
    debugLog("resetMap: Misc cleanups...")
    clearShots()    
    reconstructEntityGrid()
    entity_clearVel(getNaija())
    cureAllStatus()
    entity_idle(getNaija())
end)


-- no idea why i am actually putting this here
rawset(_G, "fadeOutAnim", function(t)
    if not t then t = 0.7 end
    local q = createQuad("rune-black")
    quad_followCamera(q, 1)
    quad_alpha(q, 0)
    quad_alpha(q, 1, 0.1)
    quad_scale(q, 15, 15)
    quad_rotate(q, 270, t)
    
    local r = math.random()
    
    if r <= 0.33 then
        quad_setPosition(q, 400, -800)
        quad_setPosition(q, 400, 600, t)
    elseif r > 0.33 and r < 0.66 then
        quad_setPosition(q, -900, 300)
        quad_setPosition(q, 800, 300, t)
    else
        quad_setPosition(q, 400, 300)
        quad_scale(q, 0.1, 0.1)
        quad_scale(q, 15, 15, t)
        quad_rotate(q, 120, t)
    end
    debugLog(debug.traceback())
end)

rawset(_G, "loadMapTrans", function(m, t)
    fadeOutAnim(t)
    esetv(getNaija(), EV_NOINPUTNOVEL, 0)
    watch(0.2)
    return loadMap(m)
end)


local function spawnMoreBlood(src, x, y)

    local vx, vy = entity_getVel(src)
    vx = vx * 0.3
    vy = vy * 0.3
    for i = 1, 15 do
        local e = createEntity("drop-blood2", "", x, y)
        local s = 0.4 + math.random(0, 600) / 1000
        entity_scale(e, s, s)
        entity_addVel(e, math.random(-2500, 2500) / 10, math.random(-5700, 0) / 10)
        entity_addVel(e, vx, vy)
    end
    for i = 1, 5 do
        local e = createEntity("drop-blood2", "", x, y)
        local s = 0.4 + math.random(0, 600) / 1000
        entity_scale(e, s, s)
        entity_addVel(e, math.random(-3200, 3200) / 10, math.random(-7700, -4500) / 10)
        entity_addVel(e, vx, vy)
    end
    
end

-- HACK
if not rawget(_G, "FORM_PORTAL") then
    FORM_PORTAL = FORM_MAX + 1 -- see logic_portal.lua
end

local form2name =
{
    [FORM_NORMAL] = "naija2",
    [FORM_ENERGY] = "energyform",
    [FORM_BEAST] = "beast",
    [FORM_NATURE] = "veggie",
    [FORM_SUN] = "sunform",
    [FORM_PORTAL] = "portal",
}

local formov =
{
    ["backleg1"] = "leg1",
    ["backleg2"] = "leg2",
    ["backleg3"] = "leg3",
    ["frontleg1"] = "leg1",
    ["frontleg2"] = "leg2",
    ["frontleg3"] = "leg3",
}


local function fixgibstex(tex)
    if isForm(FORM_BEAST) or isForm(FORM_NATURE) or isForm(FORM_SUN) then
        if tex == "head" then
            if isForm(FORM_NATURE) then return "head-hurt" end
            if isForm(FORM_BEAST) then return "head-pain" end
        end
        return formov[tex] or tex
    end

    return tex
end

local function formprefix(tex)
    if isForm(FORM_NORMAL) then
        local c = getCostume() -- screws up for many costumes, but these are not used
        if c ~= "" then
            if tex == "backarm3" or tex == "frontarm3" then
                return "naija2"
            end
            return c
        end
    end
    return form2name[getForm()] or "naija2"
end


local function gibs(src, tex, idx)
    tex = fixgibstex(tex)
    tex = "naija/" .. formprefix(tex) .. "-" .. tex
    --tex = "naija/naija2" .. tex
    local b = entity_getBoneByIdx(src, idx)
    local x, y = bone_getWorldPosition(b)
    local r = bone_getWorldRotation(b)
    local e = createEntity("tempdecal", "", x, y)
    entity_setTexture(e, tex)
    --entity_addVel(e, math.random(-2500, 2500) / 10, math.random(-5700, 0) / 10)
    entity_scale(e, 0.5, 0.5)
    entity_rotate(e, r)
    entity_clearVel(e)
    entity_addVel(e, entity_velx(src) * 0.5, entity_vely(src) * 0.5)
    entity_addVel(e, 0, -250)
    if chance(50) then
        entity_fh(e)
    end
    return e
end

local function spawnGibs(e)
    
    local g = gibs(e, "head", 1)
    entity_initEmitter(g, 0, "blood2")
    entity_startEmitter(g, 0)
    cam_toEntity(g)
    gibs(e, "backarm1", 4)
    gibs(e, "backarm2", 5)
    gibs(e, "backarm3", 10)
    --gibs(e, "backleg1", 6)
    --gibs(e, "backleg2", 7)
    gibs(e, "backleg3", 12)
    --gibs(e, "frontleg1", 8)
    --gibs(e, "frontleg2", 9)
    gibs(e, "frontleg3", 13)
    gibs(e, "frontarm1", 2)
    gibs(e, "frontarm2", 3)
    gibs(e, "frontarm3", 11)
    
    local x, y = entity_getPosition(e)
    
    for i = 1, 5 do
        local b = createEntity("tempdecal", "", x, y)
        entity_setTexture(b, "particles/bone")
        local s = math.random(900, 1200) / 1000
        entity_scale(b, s, s)
        entity_addVel(b, math.random(-2500, 2500) / 10, math.random(-5700, 0) / 10)
        entity_addVel(b, entity_velx(e) * 0.5, entity_vely(e) * 0.5)
    end
end

rawset(_G, "doDeathEffect", function(e, override)

    if chance(15) then
        playSfx("naijalow1")
    else
        emote(EMOTE_NAIJAUGH)
    end
    
    if CFG_GORE_LEVEL <= 0 then
        return
    end
    
    local x, y = entity_getPosition(e)
    
    if type(override) == "string" and override ~= "" then
        spawnParticleEffect(override, x, y)
        return
    end
    
    if entity_isUnderWater(e) then
        spawnParticleEffect("blood_uw", x, y)
    else
        spawnParticleEffect("blood", x, y)
        
        if CFG_GORE_LEVEL > 1 then
            spawnMoreBlood(e, x, y)
        end
    end
    
    if CFG_GORE_LEVEL > 1 then
        spawnGibs(e)
    end
    
end)
