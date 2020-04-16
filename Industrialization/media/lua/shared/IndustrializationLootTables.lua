--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

---------------------------------------------------------------------------
--   Change the loot that comes out of certain machines.
---------------------------------------------------------------------------
IndustrializationLootTables = {}

-- 
-- Every ten in-game minutes, each running machine should try to loot items from their loot table.
-- All looted items will be stored into the machine's container until it is full.
--
-- NOTE: All loot calculations are currently handled by the server.
-- The loot functions are handled in "SIndustrializationGlobalObjectSystem.lua".
--      - Example file: "..\Industrialization\media\lua\server\Industrialization\BuildCategories\SIndustrializationGlobalObjectSystem.lua"
--
--[[ 

Format:

IndustrializationLootTables.ObjectLootTable = 
    {  
        ["Module.ItemID"] =       { Percent % Chance To Get Item, MAX_LOOT, MIN_LOOT },
        ["Module.ItemID2"] =      { Percent % Chance To Get Item, MAX_LOOT, MIN_LOOT },
        ["Module2.ItemID3"] =     { Percent % Chance To Get Item, MAX_LOOT, MIN_LOOT },
    }

--]]
--


-----------------
----- Power -----
-----------------
-- Generic PowerSource
IndustrializationLootTables.IsoGenerator = 
    {
        ["Base.UnusableMetal"] = { 0.0, 3, 0 }, 
        ["Base.UnusableWood"] = { 0.0, 3, 0 }, 
    }

------------------
----- Mining -----
------------------
-- Small Auto Miner
IndustrializationLootTables.IndustrializationSmallAutoMiner = 
    {
        ["Base.ScrapMetal"] = { 10.0, 3, 0 }, 
        ["Base.MetalPipe"] = { 1.0, 3, 0 }, 
        ["Base.Pipe"] = { 0.0, 3, 0 }, 
        ["Base.SheetMetal"] = { 1.0, 3, 0 }, 
        ["Base.SmallSheetMetal"] = { 2.0, 3, 0 }, 
        ["Base.MetalBar"] = { 1.0, 3, 0 }, 
        ["Base.ElectronicsScrap"] = { 1.0, 3, 0 }, 
        ["Base.Aluminum"] = { 1.0, 3, 0 }, 
        ["Base.Nails"] = { 0.1, 25, 0 }, 
        ["Base.Screws"] = { 0.1, 25, 0 }, 
        ["Base.UnusableMetal"] = { 0.0, 3, 0 }, 
        ["Base.UnusableWood"] = { 0.0, 3, 0 }, 
    }

-- Large Auto Miner
IndustrializationLootTables.IndustrializationLargeAutoMiner = 
    {
        ["Base.ScrapMetal"] = { 10.0, 3, 0 }, 
        ["Base.MetalPipe"] = { 1.0, 3, 0 }, 
        ["Base.Pipe"] = { 0.0, 3, 0 }, 
        ["Base.SheetMetal"] = { 1.0, 3, 0 }, 
        ["Base.SmallSheetMetal"] = { 2.0, 3, 0 }, 
        ["Base.MetalBar"] = { 1.0, 3, 0 }, 
        ["Base.ElectronicsScrap"] = { 1.0, 3, 0 }, 
        ["Base.Aluminum"] = { 1.0, 3, 0 }, 
        ["Base.Nails"] = { 0.1, 25, 0 }, 
        ["Base.Screws"] = { 0.1, 25, 0 }, 
        ["Base.UnusableMetal"] = { 0.0, 3, 0 }, 
        ["Base.UnusableWood"] = { 0.0, 3, 0 }, 
    }









