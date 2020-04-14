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
-- Every ten in-game minutes, each running machine should try to loot these items in their loot table.
--
-- NOTE: All loot calculations are currently handled by the server.
-- The small auto miner loot functions are handled in "SSmallAutoMinerSystem.lua".
--      - Example file: "..\Industrialization\media\lua\server\Industrialization\BuildCategories\Mining\SmallAutoMiner\SSmallAutoMinerSystem.lua"
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


--------------------------------
----- BuildCategory: Power -----

-- Generic PowerSource
IndustrializationLootTables.PowerSource = 
    {
        ["Base.UnusableMetal"] = { 0.0, 3, 0 }, 
        ["Base.UnusableWood"] = { 0.0, 3, 0 }, 
    }

---------------------------------
----- BuildCategory: Mining -----

-- Small Auto Miner
IndustrializationLootTables.SmallAutoMiner = 
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
IndustrializationLootTables.LargeAutoMiner = 
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









