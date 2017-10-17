
v.on = true
v.n = 0
v.prt = true
v.q = 0
v.door = 0

function init(me)
    setupEntity(me, "collectibles/sun-key")
    entity_setEntityType(me, ET_NEUTRAL)
    entity_setWidth(me, 200)
    entity_setHeight(me, 200)
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 1)
    --entity_initEmitter(me, 0, "glowbits")
    entity_initEmitter(me, 0, "glow")
    entity_setCollideRadius(me, 64)
    entity_setCanLeaveWater(me, true)
    entity_scale(me, 0.5, 0.5)
    entity_setInvincible(me, true)
end

function postInit(me)
    entity_startEmitter(me, 0)
    
    local q = createQuad("softglow-add")
    quad_scale(q, 2, 2)
    quad_setPosition(q, entity_getPosition(me))
    quad_setBlendType(q, BLEND_ADD)
    quad_alpha(q, 0.2)
    v.q = q

    local o = entity_getNearestNode(me, "open")
    local p = node_getContent(o)
    if p ~= "" then
        local which = getNode(p)
        v.door = node_getNearestEntity(which, "energydoor")
    end
    
end

local function pickup(me)
    playSfx("secret")
    quad_alpha(v.q, 0, 1)
    entity_alpha(me, 0, 0.2)
    v.on = false
    entity_setState(v.door, STATE_OPEN)
end

function update(me, dt)
    if v.on then
        if entity_touchAvatarDamage(me, 64) then
            pickup(me)
        end
        entity_updateMovement(me, dt)
    end
end

function msg(me, s)
    if s == "reinit" then
        v.on = true
        entity_alpha(me, 1, 0.3)
        quad_alpha(v.q, 0.2, 0.3)
    end
end

function hitSurface() end
function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
