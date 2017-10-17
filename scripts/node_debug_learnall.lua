if not v then v = {} enddofile("scripts/inc_flags.lua")v.needinit = truev.txt = ""v.q = 0v.on = truefunction init(me)    v.txt = node_getName(me)    node_setCursorActivation(me, v.on)endfunction update(me, dt)    if v.on then        if v.needinit then            v.needinit = false            v.q = createQuad("fish")            quad_scale(v.q, 2.5, 2.5)            quad_scale(v.q, 5, 5, 0.8, -1, 1)            quad_rotate(v.q, 360, 3, -1)        end                local x, y = node_getPosition(me)        quad_setPosition(v.q, x, y)    endendfunction activate(me)    learnSong(SONG_ENERGYFORM)    learnSong(SONG_BEASTFORM)    learnSong(SONG_NATUREFORM)    learnSong(SONG_SUNFORM)    learnSong(SONG_SPIRITFORM)    learnSong(SONG_PORTALFORM)    learnSong(SONG_SHIELD)        setStringFlag("HAS_BOOSTER", "1")    setStringFlag("HAS_BOOSTER2", "1")    setStringFlag("HAS_DOUBLEJUMP", "1")    setStringFlag("HAS_AIRCONTROL", "1")        playSfx("energy")    setControlHint("DEBUG: You have learned everything. You can activate additional powerups in a stage's internal Esc-menu.", false, false, false, 15)endfunction songNote(me, note)endfunction songNoteDone(me, note, done)end