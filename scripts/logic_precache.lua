
-- precache textures and sound files and keep them used so the game does not free them
-- this should be done for custom forms/costumes, shots, particles, and any other non-static textures.
-- This prevents slight pauses in game flow while the engine is busy loading data off disk repeatedly.

local Precache = {} -- "class" def here!

local tex =
{
    "naija/portal-backarm1",
    "naija/portal-backarm2",
    "naija/portal-backleg1",
    "naija/portal-backleg2",
    "naija/portal-backleg3",
    "naija/portal-body",
    "naija/portal-frontarm1",
    "naija/portal-frontarm2",
    "naija/portal-frontleg1",
    "naija/portal-frontleg2",
    "naija/portal-frontleg3",
    "naija/portal-head-blink",
    "naija/portal-head-pain",
    "naija/portal-head-shock",
    "naija/portal-head-singing",
    "naija/portal-head-smile",
    "naija/portal-head",
    "naija/zgun",
    "naija/booster",
    "naija/booster2",
    
    "energysong-rune-0003",
    "energysong-rune-0002",
    "energysong-rune-0001",
    "menu-note4",
    "saveglowsmall",
    "sawbladeblood1",
    "sawbladeblood2",
    "particles/rockprt0001",
    "particles/rockprt0002",
    "particles/rockprt0006",
    "particles/saw-piece-0001",
    "particles/feather4",
    "particles/feather5",
    "particles/lavaball",
    "missile/miss",
    "spikes/normal",
    "spikes/bloody",
    "iwbtg/doublejump",

}


local snd =
{
    "spike",
    "warpzone_noise",
    "warpzone_sq",
    "sizzle"
}

local trig =
{
}



Precache.init = function()
    local q
    for _,t in pairs(tex) do
        q = createQuad(t)
        quad_alpha(q, 0) -- effectively turns off rendering
    end
    
    for _,s in pairs(snd) do
        loadSound(s)
    end
    
    for _,s in pairs(trig) do
        local e = createEntity(s)
        entity_msg(e, "_resident") -- see template_trigger.lua
    end
    
    debugLog("PRECACHE LOGIC: done " .. #tex .. " textures")
    debugLog("PRECACHE LOGIC: done " .. #snd .. " sounds")
    debugLog("PRECACHE LOGIC: done " .. #trig .. " triggers")
end

Precache.postInit = function()
    v.logic.Precache = nil
end
    

Precache.update = function(dt)
end


v.logic.Precache = Precache
