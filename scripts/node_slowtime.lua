
if not v then v = {} end

v.hasn = false
v.amount = 1
v.transtime = 0

local function dosetspeed(s, t)
    debugLog("NODE: Set game speed = " .. v.amount .. " in " .. t .. " s")
    setGameSpeed(s, t)
end

function init(me)
    local c = node_getContent(me)
    if c ~= "" then
        v.amount = tonumber(c)
    end
    v.transtime = node_getAmount(me)
end

function update(me, dt)
    local n = getNaija()
    if node_isEntityIn(me, n) then
        if not v.hasn then
            dosetspeed(v.amount, v.transtime)
        end
        v.hasn = true
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
