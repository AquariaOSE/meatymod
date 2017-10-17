
-- node placed in maps that shouldn't have portal form.

function init()
    unlearnSong(SONG_PORTALFORM)
end

function update(me, dt)
    if isForm(FORM_PORTAL) then
        changeForm(FORM_NORMAL)
    end
    unlearnSong(SONG_PORTALFORM)
end

function song() end
function songNote() end
function songNoteDone() end
