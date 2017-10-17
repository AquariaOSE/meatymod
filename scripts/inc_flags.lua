
-- although this file's name suggests so, there are no integer flags to find.
-- the mod doesn't use setFlag() at all -- everything uses string flags.

DEATH_TIME = 0.7
DEATH_IDLE_TIME = 0.8

---- globally used states ( >= 800, < 1000 )----
STATE_SLEEP = 800 -- probably unused, leftover from my other mod


-- some other (volatile) globals, mainly used for communication
-- between logic_replay.lua, logic_antideath.lua, node_finish.lua
if not rawget(_G, "__FLAGS_LOADED") then
    PLAYTIME = 0 -- per map
    PLAYTIME_STOP = false -- true once finish is reached
    DEATHCOUNTER = 0 -- per map
    NEXT_MAP = false -- false or holds map name
    UNSAVED_PROGRESS = true
    LAST_MAP_BEFORE_RETURN = false -- temporary. set to last map name when the current map was left with "Exit to Map" in the custom menu (see logic_ui.lua)
    DEATH_EFFECT = "" -- temp. used in logic_antideath.lua and node_lava.lua - maybe more after his comment was added...
    MENU_OPEN = false -- true if the menu is visible
    MENU_OPEN_DELAY = 0 -- if ~= 0, menu was opened recently (set by logic_ui.lua)
    
    -- initial config (overriden by saved values if these exist)
    CFG_GORE_LEVEL = 1 -- set this to 0 for the kids (loaded by logic_antideath.lua, changed by logic_ui.lua) - checked in many places
    -- 0 = nothing, 1 = blood, 2 = gibs + more blood (not pretty)
    
    -- there is also get/setStringFlag("ACTIVE_POWERUP"), which is set by logic_ui.lua and used by logic_aircontrol.lua
    -- and "DONE_OUTTRO" - set to "1" once the final boss was defeated and the outtro seen
    -- and "DONE_OUTTRO2"
    -- and "HAS_*" where * can be AIRCONTROL, BOOSTER, BOOSTER2, PORTALFORM, DOUBLEJUMP
end




__FLAGS_LOADED = true
