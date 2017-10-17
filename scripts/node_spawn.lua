
-- Note: Entities spawned by this node must take care of "reinit" msg themselves!

v.ename = 0
v.a = 0

local function spawn(me)
    for i = 1, v.a do
        createEntity(v.ename, "", node_getPosition(me))
    end
end

function init(me)
    v.ename = node_getContent(me)
    v.a = node_getAmount(me)
    if v.a <= 0 then
        v.a = 1
    end
    spawn(me)
end
   
function update(me, dt)
end

function song()
end

function songNote()
end

function songNoteDone()
end

function activate(me)
    spawn(me)
end