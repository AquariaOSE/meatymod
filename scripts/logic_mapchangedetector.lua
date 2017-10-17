
local MCD = {}

MCD.init = function()
    MCD.triggered = false
    MCD.showDebug = true -- DEBUG
end

MCD.update = function()
    --[[
    Okay, so there is no API to detect when the map is changed.
    So hereby i present THE MEGA HACK - see Avatar.cpp:
        void Avatar::onWarp()
        {
            avatar->setv(EV_NOINPUTNOVEL, 0);
            closeSingingInterface();
        }
        
    -- EV_NOINPUTNOVEL is not really used anywhere else (in this mod!),
    -- so relying on this check here should be somewhat safe.
    -- Note: The original node_sit and node_sleep use it,
    -- BUT ARE NOT USED IN THIS MOD!
    -- Cool is that it also works when reloading a map in the editor.
    -- If this ever goes off unexpectedly, check if EV_NOINPUTNOVEL is used anywhere !!
    ]]
    if not MCD.triggered and egetv(v.n, EV_NOINPUTNOVEL) == 0 then
        MCD.triggered = true
        debugLog("logic_mapchangedetector: detected map change!")
        for k, f in pairs(v.logic) do
            if f.onMapChange then
                f.onMapChange()
            end
        end
    end
    
    -- DEBUG
    if MCD.triggered and MCD.showDebug then
        MCD.showDebug = false
        --entity_clearVel(v.n)
        --entity_clearVel2(v.n) -- prevent smear
        centerText("\n\n\n\n\n\n\n\nlogic_mapchangedetector:\ndetected map change!") -- spam
        playSfx("defense", nil, 2)
        fade3(0.5, 0, 0, 0, 1)
        fade3(0, 0.5, 0, 0, 1)
    end
end


v.logic.mcd = MCD
