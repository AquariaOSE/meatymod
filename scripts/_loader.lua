
-- for maximum performance, this file should be loaded only once per map,
-- but it is not too bad if it is loaded multiple times.


-- if this ist true, debugging features are completely disabled,
-- no additional security checks for early entity deletion are done,
-- and the mod may be unstable and cause the game to crash if the editor is used.
-- If you plan to edit the mod, enable this. You have been warned.
MOD_RELEASE_VERSION = false

local RELOAD_SCRIPTS_ALWAYS = not MOD_RELEASE_VERSION -- force reloading scripts everytime a map is (re-)loaded


local t = rawget(_G, "_inc_once_")
if RELOAD_SCRIPTS_ALWAYS then
    t = nil
end
if not t then
    t = {}
    rawset(_G, "_inc_once_", t)
end

local function include_once(file)
    local ret
    if RELOAD_SCRIPTS_ALWAYS or not _inc_once_[file] then
        ret = dofile(file)
        _inc_once_[file] = true
    end
    return ret
end

rawset(_G, "include_once", include_once)


include_once("scripts/aqmodlib/main.lua")


-- when this file is loaded, we most likely just started a new map
-- (or an entity was created that includes this file)
-- allow semi-static parts of the lib to reset.
modlib_cleanup()


include_once("scripts/globalfuncs.lua")
