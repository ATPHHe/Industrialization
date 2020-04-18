# Industrialization
WIP Mod for Project Zomboid

version 1.04
- Added furnace.

version 1.03.1
- Minor fixes to ISMachineInfoWindow.lua to prevent some errors.

version 1.03
- Created 4 new Frameworks for GlobalObject and GlobalObjectSystem to allow for less redundant coding and allow for more easier management of code.
    - SIndustrializationGlobalObject (sub-class derived from SGlobalObject)
    - SIndustrializationGlobalObjectSystem (sub-class derived from SGlobalObjectSystem)
    - CIndustrializationGlobalObject (sub-class derived from CGlobalObject)
    - CIndustrializationGlobalObjectSystem (sub-class derived from CGlobalObjectSystem)
- Restructuring of the Audio system to allow for easier management of code.
- Restructuring of the BuildMenu to allow for easier management of code.
- Code Restructured to work for Multiplayer.
    - Restructuring of code to allow for Server-to-Client and Client-to-Server communication between objects and object systems.

version 1.02
- added function to prevent small auto miner from being built high above the ground.

version 1.01
- fixes to loot calculations.

version 1.0
- created powersource system (currently only works with generator).
- created small auto miner system.
