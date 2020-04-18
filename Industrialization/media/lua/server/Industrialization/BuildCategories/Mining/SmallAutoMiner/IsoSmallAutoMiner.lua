--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\server\RainBarrel\BuildingObjects\RainCollectorBarrel.lua" as reference.
--*****************************
--

--require "BuildingObjects/ISBuildingObject"
require "Industrialization/BuildCategories/IsoIndustrializationObject"

-- This class extends IsoIndustrializationObject. IsoIndustrializationObject.lua contains most of the defaults needed for this object.
IsoSmallAutoMiner = IsoIndustrializationObject:derive("IsoSmallAutoMiner");

-- Names/Other
IsoSmallAutoMiner.NAME = "Small Auto Miner"
IsoSmallAutoMiner.GROUP_NAME = "Industrialization"
IsoSmallAutoMiner.FULL_NAME = IsoSmallAutoMiner.GROUP_NAME .. " " .. IsoSmallAutoMiner.NAME
IsoSmallAutoMiner.DEFAULT_SPRITE_NAME = "industrialization_mining_01_0"

IsoSmallAutoMiner.TRANSLATE_NAME = "ContextMenu_Industrialization_SmallAutoMiner"
IsoSmallAutoMiner.TRANSLATE_DESC = "Tooltip_Industrialization_craft_SmallAutoMinerDesc"

-- Health
IsoSmallAutoMiner.HEALTH_FLAT = 10000
IsoSmallAutoMiner.HEALTH_PER_PERK_LEVEL = { 500 , 100 , }
IsoSmallAutoMiner.HEALTH_PERKS = { Perks.MetalWelding , Perks.Electricity , }
IsoSmallAutoMiner.HEALTH_HANDY_TRAIT = 2000

-- XP Gain
IsoSmallAutoMiner.BUILD_XP_GAINS = { 12 , 6 , } -- XP Gained for building the object.
IsoSmallAutoMiner.BUILD_XP_PERKS = { Perks.MetalWelding , Perks.Electricity , } -- perk for XP gain.

-- Settings
IsoSmallAutoMiner.SETTINGS = 
    {
        firstItem = "BlowTorch", -- The item you will equip in your primary slot when building the object.
        secondItem = "WeldingMask", -- The item you will equip in your secondary slot when building the object.
        craftingBank = "BlowTorch", -- TODO: fill in note
        thumpDmg = 1, -- INTEGER value: Damage done per zombie attack on the object.
        dismantable = true, -- the object will be dismantable (come from IsoThumpable stuff, check buildUtil.setInfo to see wich options are available)
        canBarricade = false, -- can be barricaded if true
        canBeAlwaysPlaced = true,
        blockAllTheSquare = true, -- the item will block all the squares where it placed (not like a wall for example)
    }

-- Required Materials/Items needed to build this object goes here.
--  
-- noNeedHammer        = BOOLEAN,
-- noNeedScrewdriver   = BOOLEAN,
-- noNeedBlowTorch     = BOOLEAN,
-- torchUse            = INTEGER,
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- ...
--[[
    itemID - the string name of the item.
    itemText - The translation to display for itemID. (Spaces are ignored when translating.)
    value - the amount of items for itemID, required to build this object.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoSmallAutoMiner.REQUIRED_MATERIALS = 
    {
        noNeedHammer        = true,
        noNeedScrewdriver   = false,
        noNeedBlowTorch     = false,
        torchUse            = 12,
        { itemID="Base.MetalBar", itemText="Metal Bar",                      value=0 },
        { itemID="Base.MetalPipe", itemText="Metal Pipe",                    value=4 },
        { itemID="Base.SmallSheetMetal", itemText="Small Metal Sheet",       value=8 },
        { itemID="Base.SheetMetal", itemText="Metal Sheet",                  value=4 },
        { itemID="Base.Hinge", itemText="Hinge",                             value=0 },
        { itemID="Base.ScrapMetal", itemText="Scrap Metal",                  value=0 },
        { itemID="Base.ElectronicsScrap", itemText="Electronics Scrap",      value=4 },
        { itemID="Radio.ElectricWire", itemText="Electric Wire",             value=1 },
        { itemID="Base.Nails", itemText="Nails",                             value=0 },
        { itemID="Base.Screws", itemText="Screws",                           value=(4*2 + 8*4 + 4*4) }, --(metalPipe*screws + smallMetalSheet*screws + metalSheet*screws)
    }

-- Required Perks/Skills needed to build this object goes here.
-- { perk=Perks.PERKNAME, skillLevel=INTEGER, perkTranslation="IGUI_perks_PERKNAME" or nil },
--[[
    perk - The skill/perk required to build this object.
    skillLevel - The skill level needed to be reached in order to build this object.
    perkTranslation - The perk's translation name. Can be set to nil and "IGUI_perks_"..tostring(perk) will be used in buildmenu tooltips instead.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoSmallAutoMiner.REQUIRED_SKILLS = 
    {
        { perk=Perks.MetalWelding, skillLevel=4, perkTranslation=nil },
        { perk=Perks.Electricity, skillLevel=2, perkTranslation=nil },
    }

--[[
    Can this object can be placed on this square?
    This function is called everytime you move the mouse over a grid square.
    
    Return true to allow the player to build this object.
    Return false to disallow the player from building this object.
]]
function IsoSmallAutoMiner:isValid(square)
    if not IsoIndustrializationObject.isValid(self, square) then return false end
    
    -- Build Cheat
    if ISBuildMenu.cheat then return true end
    
    -- height check (prevents building this miner on high elevations)
    if math.floor(square:getZ()) > 0 then return false end
    
	return true
end

-- Called to render the ghost objects
-- The ISBuildingObject only renders 1 sprite (north, south...), for example for stairs I can render the 2 others tile for stairs here
-- If isValid(square) returns false, the ghost render will be in red and the player cannot build the item.
function IsoSmallAutoMiner:render(x, y, z, square)
	IsoIndustrializationObject.render(self, x, y, z, square)
end


