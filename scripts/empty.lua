
function init(me)
    setupEntity(me)
    entity_makePassive(me)
    entity_alpha(me, 0)
end

function update(me, dt)
    entity_updateMovement(me, dt)
end

function postInit() end
function damage() return false end
function enterState() end
function exitState() end
function msg() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function hitSurface() end
