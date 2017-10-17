
local NOTES_FOR_MAP =
{
    main_reef          = { 1, 3, 4, 5, 1, 3, 4, 2, 1, 3, 4, 0 },
    main_abyss         = { 4, 0, 1, 5, 0, 3 },
    main_desert        = { 4, 0, 1, 4, 3, 2 },
    main_volcano       = { 4, 0, 1, 4, 5, 6 },
    main_nightmare     = { 1, 3, 4, 7, 6, 5 },
}


local M = {}

M.incut = false
M.sphere = 0

M.init = function()

    -- this activates warpzones if seen first time, etc.
    v.setSeenMap()

    if not v.isSpecialMap() then
        v.logic.hubmaps = nil
        return
    end

    -- when exiting via menu (see logic_ui.lua), return to a spot near the warp that leads to the map just returned from
    if LAST_MAP_BEFORE_RETURN then
        debugLog("previously exited from map " .. LAST_MAP_BEFORE_RETURN)
        local idx = v.getMapIndexForEntryByName(LAST_MAP_BEFORE_RETURN, getMapName())
        local find = "wmap " .. idx
        debugLog("trying to find node: " .. find)
        for _, node in pairs(getAllNodes()) do
            if node_getName(node) == find then
                local retn = node_getNearestNode(node, "return")
                if retn ~= 0 then
                    debugLog("wmap found return")
                    entity_setPosition(v.n, node_getPosition(retn))
                    break
                end
            end
        end
    end
end



local function wmapSort(a, b)
    return tonumber(node_getContent(a)) < tonumber(node_getContent(b))
end

local function isWmap(node)
    return node_getLabel(node) == "wmap"
end

local function wmapPrt(node, notetab)
    cam_toNode(node)
    spawnParticleEffect("greenstream", node_getPosition(node))
    local sfx
    if notetab then
        local note = notetab[tonumber(node_getContent(node))]
        if note then
            sfx = playSfx("low-note" .. note, nil, 2)
        end
    end
    watch(1)
    
    if sfx then
        fadeSfx(sfx, 1)
    end
end


local function clearedZone(param)

    debugLog("clearedZone() start")

    local wmapnodes = {}
    forAllNodes(function(node)
        local num = tonumber(node_getContent(node)) or 0
        if num == 0 then return end
        local m = v.getMapNameForEntryByIndex(num, getMapName())
        if v.isWarpzoneMap(m) then return end
        table.insert(wmapnodes, node) end,
    nil, isWmap)
    
    table.sort(wmapnodes, wmapSort)
    
    local notetab = NOTES_FOR_MAP[getMapName()]
    
    setCutscene(true, true)
    
    --for i, node in ipairs(wmapnodes) do
    --    wmapPrt(node, notetab)
    --end
    
    watch(1)
    
    cam_toEntity(v.n)
    playSfx("collectible")
    centerText("\n\nZone cleared!")
    overrideZoom(1.2, 3)
    watch(1)
    
    local function isFxFire(e)
        return entity_isName(e, "fx_fire")
    end
    
    forAllEntities(entity_stopEmitter, 0, isFxFire)
    v.pushTQ(2, function()
        forAllEntities(entity_delete, nil, isFxFire)
        entity_delete(M.sphere)
        M.sphere = 0
    end)
    
    
    
    local res
    
    if type(param) == "function" then
        res = param()
    elseif type(param) == "number" then
    
        entity_animate(v.n, "energystruggle2", -1)
        watch(2)
        learnSong(param)

        local sname = getSongName(param)
        setControlHint("You have learned the " .. sname, false, false, false, 6, nil, param)
        
        local form = getFormForSong(param)
        if form then
            changeForm(form)
        end
        res = form
        local t = entity_animate(v.n, "checkoutenergy")
        watch(t / 3)
        --playSfx("naijaew1")
        --watch(t / 3)
        emote(EMOTE_NAIJALAUGH)
        --watch(t / 3)
    end
    
    v.setRewarded(nil, true)
    
    overrideZoom(0)
    
    M.incut = false
    setCutscene(false)
    entity_setState(v.n, STATE_IDLE)
    setNaijaHeadTexture("")
    musicVolume(1, 2)
    enableInput()
    debugLog("clearedZone() done")
    
    return res
end

local function createSphere()
    local sphere = createEntity("3dmodel", "", entity_getPosition(v.n))
    -- ent, cmd, model, pointEntity, camDist, initScale
    entity_msg(sphere, "load", "sphere128", "fx_fire", 400, 500)
    
    local totaltime = 0
    -- called in 3dmodel's update() function
    local function calcSphereCoords(sphere, dt)
        totaltime = totaltime + dt
        local s = entity_getScale(sphere)
        return 0, totaltime * 2, 0, s, s, s
    end
    
    entity_msg(sphere, "setfunc", calcSphereCoords)
    
    entity_scale(sphere, 0.2, 0.2, 4)
    M.sphere = sphere
    
    local q = createQuad("softglow-add", 13)
    quad_setBlendType(q, BLEND_ADD)
    quad_scale(q, 15, 15)
    quad_scale(q, 6, 6, 5)
    quad_setPosition(q, entity_getPosition(v.n))
    v.pushTQ(11, function() quad_delete(q, 6) end)
    
    return sphere
end

M.postInit = function()

    local data = v.getMapData()
    if not data then
        --errorLog("logic_hubmaps.lua: No data for map " .. getMapName())
        return
    end
    

    local done = v.getDoneMapsByEntryMap()
    local total = v.getTotalMapsByEntryMap()
    --centerText(string.format("\n\n\n\n\nDone maps: %d / %d", done, total))
    
    if data.reward and done >= total and not v.wasRewarded() then
        
        -- just call and exec reward if given
        if data.noscene then
            if type(data.reward) == "function" then
                data.reward()
            end
            v.setRewarded(nil, true)
            return
        end
        createSphere()
        M.incut = true
        overrideZoom(0.55)
        disableInput()
        entity_setState(v.n, 12345) -- prevent idle animation taking over
        entity_animate(v.n, "energystruggle", -1)
        setNaijaHeadTexture("pain", 999)
        spawnParticleEffect("energygodspirithit", entity_getPosition(v.n))
        musicVolume(0, 3)
        v.pushTQ(3.5, clearedZone, data.reward)
    end
end

M.update = function(dt)


    if M.incut and isInputEnabled() then
        disableInput()
    end
    
end


v.logic.hubmaps = M
