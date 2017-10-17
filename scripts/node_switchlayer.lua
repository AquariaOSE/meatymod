
v.ent = ""
v.layer = 0
v.needinit = true
v.me = 0
v.moved = 0
v.n = 0

function init(me)
    local a = tonumber(node_getContent(me))
    if a == nil then
        v.ent = node_getContent(me)
        v.layer = node_getAmount(me)
    else
        v.layer = a
    end
    v.me = me
end

local function filterNoName(e)
    return node_isEntityIn(v.me, e) and e ~= v.n
end

local function filterName(e, name)
    return node_isEntityIn(v.me, e) and entity_isName(e, name)
end

local function coundAndSwitch(me, e)
    v.moved = v.moved + 1
    entity_switchLayer(me, e)
end

function update(me, dt)
    if v.needinit then
        v.n = getNaija()
        v.needinit = false
        if v.ent == "" then
            forAllEntities(coundAndSwitch, v.layer, filterNoName)
        else
            forAllEntities(coundAndSwitch, v.layer, filterName, v.ent)
        end
        
        if v.moved == 0 then
            centerText("WARNING: switchlayer " .. v.ent .. " ." .. v.layer .. " - no entity")
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
