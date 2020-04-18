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
IsoSmallFurnace = IsoIndustrializationObject:derive("IsoSmallFurnace");

-- Names/Other
IsoSmallFurnace.NAME = "Small Furnace"
IsoSmallFurnace.GROUP_NAME = "Industrialization"
IsoSmallFurnace.FULL_NAME = IsoSmallFurnace.GROUP_NAME .. " " .. IsoSmallFurnace.NAME
IsoSmallFurnace.DEFAULT_SPRITE_NAME = "industrialization_refining_01_0"

IsoSmallFurnace.TRANSLATE_NAME = "ContextMenu_Industrialization_SmallFurnace"
IsoSmallFurnace.TRANSLATE_DESC = "Tooltip_Industrialization_craft_SmallFurnaceDesc"

-- Health
IsoSmallFurnace.HEALTH_FLAT = 20000
IsoSmallFurnace.HEALTH_PER_PERK_LEVEL = { 500 , }
IsoSmallFurnace.HEALTH_PERKS = { Perks.MetalWelding , }
IsoSmallFurnace.HEALTH_HANDY_TRAIT = 2000

-- XP Gain
IsoSmallFurnace.BUILD_XP_GAINS = { 12 , } -- XP Gained for building the object.
IsoSmallFurnace.BUILD_XP_PERKS = { Perks.MetalWelding , } -- perk for XP gain.

-- Settings
IsoSmallFurnace.SETTINGS = 
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
    itemText - The translation to display for itemID. getItemText(itemText) is used. (Spaces are ignored when translating.)
    value - the amount of items for itemID, required to build this object.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoSmallFurnace.REQUIRED_MATERIALS = 
    {
        noNeedHammer        = true,
        noNeedScrewdriver   = false,
        noNeedBlowTorch     = false,
        torchUse            = 12,
        { itemID="Base.MetalBar", itemText="Metal Bar",                      value=0 },
        { itemID="Base.MetalPipe", itemText="Metal Pipe",                    value=4 },
        { itemID="Base.SmallSheetMetal", itemText="Small Metal Sheet",       value=8 },
        { itemID="Base.SheetMetal", itemText="Metal Sheet",                  value=8 },
        { itemID="Base.Hinge", itemText="Hinge",                             value=0 },
        { itemID="Base.ScrapMetal", itemText="Scrap Metal",                  value=16 },
        { itemID="Base.ElectronicsScrap", itemText="Electronics Scrap",      value=0 },
        { itemID="Radio.ElectricWire", itemText="Electric Wire",             value=0 },
        { itemID="Base.Nails", itemText="Nails",                             value=0 },
        { itemID="Base.Screws", itemText="Screws",                           value=(4*2 + 8*4 + 8*4) }, --(metalPipe*screws + smallMetalSheet*screws + metalSheet*screws)
    }

-- Other mod additions
--[[table.insert(IsoSmallFurnace.REQUIRED_MATERIALS, { itemID="Base.MetalBar", itemText="Metal Bar", value=0 })
table.insert(IsoSmallFurnace.REQUIRED_MATERIALS, { itemID="Base.MetalBar", itemText="Metal Bar", value=0 })
table.insert(IsoSmallFurnace.REQUIRED_MATERIALS, { itemID="Base.MetalBar", itemText="Metal Bar", value=0 })
table.insert(IsoSmallFurnace.REQUIRED_MATERIALS, { itemID="Base.MetalBar", itemText="Metal Bar", value=0 })
table.insert(IsoSmallFurnace.REQUIRED_MATERIALS, { itemID="Base.MetalBar", itemText="Metal Bar", value=0 })]]

-- Required Perks/Skills needed to build this object goes here.
-- { perk=Perks.PERKNAME, skillLevel=INTEGER, perkTranslation="IGUI_perks_PERKNAME" or nil },
--[[
    perk - The skill/perk required to build this object.
    skillLevel - The skill level needed to be reached in order to build this object.
    perkTranslation - The perk's translation name. Can be set to nil and getText("IGUI_perks_"..tostring(perk)) will be used in buildmenu tooltips instead.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoSmallFurnace.REQUIRED_SKILLS = 
    {
        { perk=Perks.MetalWelding, skillLevel=4, perkTranslation=nil },
    }

--[[
    Can this object can be placed on this square?
    This function is called everytime you move the mouse over a grid square.
    
    Return true to allow the player to build this object.
    Return false to disallow the player from building this object.
]]
function IsoSmallFurnace:isValid(square)
    if not IsoIndustrializationObject.isValid(self, square) then return false end
    
    -- Build Cheat
    if ISBuildMenu.cheat then return true end
    
    -- height check (prevents building this miner on high elevations)
    --if math.floor(square:getZ()) > 0 then return false end
    
	return true
end

-- Called to render the ghost objects
-- The ISBuildingObject only renders 1 sprite (north, south...), for example for stairs I can render the 2 others tile for stairs here
-- If isValid(square) returns false, the ghost render will be in red and the player cannot build the item.
function IsoSmallFurnace:render(x, y, z, square)
	IsoIndustrializationObject.render(self, x, y, z, square)
end


