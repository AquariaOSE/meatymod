Okay, the fact that you found this file tells me you are interested in
what is going on under the hood.


The scripts are organized like this:


globalfuncs.lua - Some global functions that are specific for this mod, and can be used by all other scripts.


aqmodlib/* - My own auxiliary mod library. Does not rely on any files except _loader.lua, and can be dropped into other mods,
             but requires the single lua state implementation (1.1.3+) to work.
             Provides global functions. If you see an unknown non-local function, look here first.

_loader.lua - Includes the mod library and sets up some things, needs to be included at least once per map, anywhere.
              (I think node_logic.lua is the only script including it)

inc_* - Include scripts, used by other entites and nodes.
    Some just contain bits and snippets of code to avoid code duplication,
    and to allow easier maintenance.

logic_* - Plugins for node_logic.lua
    These define the backbone logic of the mod.
    One logic node exists per map that manages all all of them.

logichelp_* - ENTITY scripts that serve as helpers for the logic plugins.
    Sometimes things need to be managed by an entity for various reasons.
    These helper entities are invisible and mostly very close to the avatar.

template_* - Common code for entity specialization.
    Note: The original game calls them *common.lua.


The scripts are mostly a horrible mess because the mod was done in a hurry.

Almost all scripts work in a generic way and do not contain map specific code.

All of the map-specific stuff is done via nodes (for example rising lava, advancing saw-wall of doom, etc).
Only a few nodes are really specific - those that open doors in the last hub maps after having played all the other levels.

To make a valid map, first add it to the large table in inc_mapmgr.lua.
Then, make *ONE* "logic" node anywhere on the map, and one "finish" node at the end of the level.
Then the scripts do everything by themselves - instant respawn on death, replay recording, etc etc.

Saws/gears are also added via nodes.

But be careful with entities. Those used in the mod needed a small modification to despawn once they
receive a "reinit" message - which is sent whenever the map is reset (on death + respawn).

Some really die - these need to be spawned with a "spawn <entityName>" node.
Others just turn invisible once killed, and appear again on reset. These can be placed directly on the map.

Best is to see how existing maps are made, which entities are placed how, and use the same way in other maps.


Last thing:
The editor mode is blocked by default. To get into the editor, either use a developer build,
or edit the mod's XML file and set blockEditor="0".

Have fun with it.
I'd be happy to see additional maps for this mod one day that I didn't do myself.
Write me an email if you made one. Or if there are any questions. Or just because writing emails is awesome.

-- fg
(false.genesis@googlemail.com)



