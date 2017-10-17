if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.Ttimer = 1
v.activetimer = 2 -- TODO: make this configurable (parse content string)
v.timer = 1
v.magnitude = 3

function init(me)
	v.Ttimer = tonumber(node_getContent(me))
	v.magnitude = node_getAmount(me)
	v.timer = v.Ttimer
end

function update(me, dt)
	if v.timer < dt then
		v.timer = v.Ttimer -- TODO: add random variation (30%)
		shakeCamera(v.magnitude, v.activetimer)
	else
        v.timer = v.timer - dt
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
