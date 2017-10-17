
-- node placed in maps that allow having Li after the outtro

v.n = 0
v.needinit = false

function init()
    if getStringFlag("DONE_OUTTRO2") ~= "" then
        local n = getNaija()
        local li = getEntity("li")
        if li == 0 then
            local x, y = entity_getPosition(n)
            li = createEntity("li", "", x + 20, y + 20)
            entity_updateSkeletal(li, 1)
        end
        entity_msg(li, "idle")
    end
end

function update(me, dt)
end

function song() end
function songNote() end
function songNoteDone() end
