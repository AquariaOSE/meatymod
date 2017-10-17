
v.n = 0
v.bb = 0
v.a = 0
v.t = 0
v.tips = 0
v.c = 0
v.dripT = 0

function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)
    entity_setEntityLayer(me, -2)
    entity_initSkeletal(me, "spikes")
    entity_generateCollisionMask(me)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    entity_setState(me, STATE_IDLE)
    entity_setInvincible(me, true)
    v.bb = entity_getBoneByIdx(me, 1)
    
    bone_alpha(v.bb, 0)
    
    entity_setUpdateCull(me, 1000)
    
    local data = entity_getNearestNode(me, "spikedata")
    if data ~= 0 then
        local a = node_getName(data):explode(" ", true)
        for i = 2, #a do
            local x = a[i]
            if x == "red" and CFG_GORE_LEVEL > 0 then
                bone_alpha(v.bb, 1)
                v.a = 1
                v.c = 1000
                v.dripT = math.random(500, 2000) / 1000
            end
        end
    end
    
end

function postInit(me)
    v.n = getNaija()
    
    -- opt out spikes pointing up
    local r = entity_getRotation(me) % 360
    if not (r > 90 and r < 270) then
        v.c = -9999
    end
    
    entity_updateSkeletal(me, 1)
    
    v.tips = {}
    for i = 2, 6 do
        local b = entity_getBoneByIdx(me, i)
        if not isObstructed(bone_getWorldPosition(b)) then
            table.insert(v.tips, b)
        end
    end
end

function update(me, dt)
    if v.t > 0 then
        v.t = v.t - dt
    elseif entity_getAlpha(v.n) > 0.99 then
        local bone = entity_collideSkeletalVsCircle(me, v.n)
        if bone ~= 0 then
            v.a = v.a + 0.33
            v.c = v.c + 1
            if v.a > 1 then
                v.a = 1
            end
            entity_hugeDamage(v.n)
            
            if CFG_GORE_LEVEL > 0 then
                playSfx("spike", nil, 1.3)
                bone_alpha(v.bb, v.a, 0.33)
            end
            
            v.t = 0.6
            
            --debugLog("c = " .. v.c)
        end
    end
    
    if CFG_GORE_LEVEL > 0 and v.c > 2 and v.dripT >= 0 then
        v.dripT = v.dripT - dt
        if v.dripT <= 0 then
            v.dripT = math.random(1500, 4000) / 1000
            local tip = v.tips[math.random(1, #v.tips)]
            createEntity("drop-blood", "", bone_getWorldPosition(tip))
        end
    end
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
    end
end

function msg() end

function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
