
v.needinit = true
v.me = 0
v.msgd = 0
v.m = ""
v.x = 0

function init(me)
    v.m = node_getContent(me)
    v.x = node_getAmount(me)
    v.me = me
end

local function filterInside(e)
    return node_isEntityIn(v.me, e)
end

local function countAndMsg(e)
    v.msgd = v.msgd + 1
    entity_msg(e, v.m, v.x)
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        forAllEntities(countAndMsg, nil, filterInside)
        
        if v.msgd == 0 then
            centerText("WARNING: node_msg " .. v.m .. ", " .. v.x .. " - no entity")
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
