
local FORMNAMES =
{
    [FORM_NORMAL] = "Normal Form",
    [FORM_ENERGY] = "Energy Form",
    [FORM_BEAST] = "Beast Form",
    [FORM_NATURE] = "Nature Form",
    [FORM_SUN] = "Sun Form",
    [FORM_FISH] = "Fish Form",
    [FORM_SPIRIT] = "Spirit Form",
    [FORM_DUAL] = "Dual Form",
}

local SONG_FOR_FORM =
{
    [FORM_ENERGY] = SONG_ENERGYFORM,
    [FORM_BEAST] = SONG_BEASTFORM,
    [FORM_NATURE] = SONG_NATUREFORM,
    [FORM_SUN] = SONG_SUNFORM,
    [FORM_FISH] = SONG_FISHFORM,
    [FORM_SPIRIT] = SONG_SPIRITFORM,
    [FORM_DUAL] = SONG_DUALFORM,
}

local FORM_FOR_SONG = {}
for a, b in pairs(SONG_FOR_FORM) do
    FORM_FOR_SONG[b] = a
end

local SONGNAMES =
{
    [SONG_ENERGYFORM] = "Energy Form Song",
    [SONG_BEASTFORM] = "Beast Form Song",
    [SONG_NATUREFORM] = "Nature Form Song",
    [SONG_SUNFORM] = "Sun Form Song",
    [SONG_FISHFORM] = "Fish Form Song",
    [SONG_SPIRITFORM] = "Spirit Form Song",
    [SONG_DUALFORM] = "Dual Form Song",
    [SONG_SHIELD] = "Shield Song",
    [SONG_BIND] = "Bind Song",
}

local SONGSYMBOLS =
{
    [SONG_ENERGYFORM] = "song/songslot-2",
    [SONG_BEASTFORM] = "song/songslot-3",
    [SONG_NATUREFORM] = "song/songslot-4",
    [SONG_SUNFORM] = "song/songslot-5",
    [SONG_FISHFORM] = "song/songslot-6",
    [SONG_SPIRITFORM] = "song/songslot-7",
    [SONG_DUALFORM] = "song/songslot-8",
    [SONG_SHIELD] = "song/songslot-0",
    [SONG_BIND] = "song/songslot-1",
    [SONG_LI] = "song/songslot-9",
    [SONG_ANIMA] = "song/songslot-10",
}

local function getFormName(form)
    return FORMNAMES[form] or "Unknown Form"
end

local function getSongForForm(form)
    return SONG_FOR_FORM[form]
end

local function getSongName(s)
    return SONGNAMES[s] or "Unknown Song"
end

local function getFormForSong(s)
    return FORM_FOR_SONG[s]
end

local function getSongSymbol(s)
    return SONGSYMBOLS[s]
end

return {
    getFormName = getFormName,
    getSongForForm = getSongForForm,
    getSongName = getSongName,
    getFormForSong = getFormForSong,
    getSongSymbol = getSongSymbol,
}
