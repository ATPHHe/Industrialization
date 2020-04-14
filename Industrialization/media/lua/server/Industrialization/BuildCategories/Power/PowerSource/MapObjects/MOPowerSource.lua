--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\server\Map\MapObjects\MORainCollectorBarrel.lua" as reference.
--*****************************
--

if isClient() then return end

require "Industrialization/BuildCategories/Power/PowerSource/BuildingObjects/IsoPowerSource"

local function noise(message) SPowerSourceSystem.instance:noise(message) end

----- ----- -----
--[[
local function CreateAutoMiner(sq, spriteName, health)
    local obj = {}
	obj.modData = {}
    
    --------------------------------------------------------
    obj.modData["need:Base.MetalPipe"] = IsoPowerSource.REQUIRED_MATERIALS.metalPipe;
    obj.modData["need:Base.SmallSheetMetal"] = IsoPowerSource.REQUIRED_MATERIALS.smallMetalSheet;
    obj.modData["need:Base.SheetMetal"] = IsoPowerSource.REQUIRED_MATERIALS.metalSheet;
    obj.modData["need:Base.Hinge"] = IsoPowerSource.REQUIRED_MATERIALS.hinge;
    --obj.modData["need:Base.ScrapMetal"] = IsoPowerSource.REQUIRED_MATERIALS.scrapMetal;
    obj.modData["need:Base.ElectronicsScrap"] = IsoPowerSource.REQUIRED_MATERIALS.electronicsScrap;
    obj.modData["need:Radio.ElectricWire"] = IsoPowerSource.REQUIRED_MATERIALS.electricWire;
    obj.modData["need:Base.Nails"] = IsoPowerSource.REQUIRED_MATERIALS.nails;
    obj.modData["need:Base.Screws"] = IsoPowerSource.REQUIRED_MATERIALS.screws;
    --------------------------------------------------------
    local torchUse = IsoPowerSource.REQUIRED_MATERIALS.torchUse;
    --obj.modData["need:Base.Hammer"] = "0";
    --obj.modData["need:Base.Screwdriver"] = "0";
    obj.modData["use:Base.BlowTorch"] = torchUse;
    obj.modData["use:Base.WeldingRods"] = torchUse / 2;
    --------------------------------------------------------
    obj.modData["xp:MetalWelding"] = 5 * IsoPowerSource.REQUIRED_MATERIALS.skill ;
    --------------------------------------------------------
    
	local cell = getWorld():getCell()
	local north = false
	local javaObject = IsoThumpable.new(cell, sq, spriteName, north, obj.modData)
    
    --javaObject:setSprite(spriteName);
	javaObject:setCanPassThrough(false)
	javaObject:setCanBarricade(false)
	javaObject:setThumpDmg(8)
	javaObject:setIsContainer(true)
	javaObject:setIsDoor(false)
	javaObject:setIsDoorFrame(false)
	javaObject:setCrossSpeed(1.0)
	javaObject:setBlockAllTheSquare(true)
	javaObject:setName(IsoPowerSource.FULL_NAME)
	javaObject:setIsDismantable(true)
	javaObject:setCanBePlastered(false)
	javaObject:setIsHoppable(false)
	javaObject:setIsThumpable(true)
	javaObject:setModData(copyTable(obj.modData))
	javaObject:setMaxHealth(health)
	javaObject:setHealth(health)
	javaObject:setBreakSound("BreakObject")
	javaObject:setSpecialTooltip(true)
	--javaObject:setWaterAmount(waterAmount)
	--javaObject:setTaintedWater(waterAmount > 0 and sq:isOutside())
    
	return javaObject
end

local function ReplaceExistingObject(isoObject, health)
	local sq = isoObject:getSquare()
	noise('replacing isoObject at '..sq:getX()..','..sq:getY()..','..sq:getZ())
	local javaObject = CreateAutoMiner(sq, isoObject:getSprite():getName(), health)
	local index = isoObject:getObjectIndex()
	sq:transmitRemoveItemFromSquare(isoObject)
	sq:AddSpecialObject(javaObject, index)
	javaObject:transmitCompleteItemToClients()
	return javaObject
end

local function NewIsoPowerSource(isoObject)
	local health = IsoPowerSource.HEALTH_FLAT 
                    + ZombRand(0, IsoPowerSource.HEALTH_PER_LEVEL*10) 
                    + (ZombRand(2) == 0 and IsoPowerSource.HEALTH_HANDY_TRAIT or 0)
	ReplaceExistingObject(isoObject, health)
end


local PRIORITY = 5

--MapObjects.OnNewWithSprite("industrialization_auto_miners_01_0", NewIsoPowerSource, PRIORITY)

----- ----- -----

local function LoadObject(isoObject, health)
    --noise("loadobject=================")
	local sq = isoObject:getSquare()
	if instanceof(isoObject, "IsoThumpable") then
	else
		isoObject = ReplaceExistingObject(isoObject, health)
	end
	SPowerSourceSystem.instance:loadIsoObject(isoObject)
end

local function LoadIsoPowerSource(isoObject)
	local health = IsoPowerSource.HEALTH_FLAT 
                    + ZombRand(0, IsoPowerSource.HEALTH_PER_LEVEL*10) 
                    + (ZombRand(2) == 0 and IsoPowerSource.HEALTH_HANDY_TRAIT or 0)
	LoadObject(isoObject, health)
end

--MapObjects.OnLoadWithSprite("industrialization_auto_miners_01_0", LoadIsoPowerSource, PRIORITY)

--]]
----- ----- -----

local PRIORITY = 6

local function ReplaceExistingGeneratorObject(object, fuel, condition)
	local cell = getWorld():getCell()
	local square = object:getSquare()

	local item = InventoryItemFactory.CreateItem("Base.Generator")
	if item == nil then
		noise('Failed to create Base.Generator item')
		return
	end
	item:setCondition(condition)
	item:getModData().fuel = fuel

--	local index = object:getObjectIndex()
	square:transmitRemoveItemFromSquare(object)

	local javaObject = IsoGenerator.new(item, cell, square)
	-- IsoGenerator constructor calls AddSpecialObject, probably it shouldn't.
--	square:AddSpecialObject(javaObject, index)
	javaObject:transmitCompleteItemToClients()
end

local function NewGenerator(isoObject)
	local fuel = 0
	local condition = 100
	ReplaceExistingGeneratorObject(isoObject, fuel, condition)
    SPowerSourceSystem.instance:loadIsoObject(isoObject)
end

MapObjects.OnNewWithSprite("appliances_misc_01_0", NewGenerator, PRIORITY)

----- ----- -----

local function LoadGeneratorObject(isoObject, fuel, condition)
    --noise("loadobject=================")
	local sq = isoObject:getSquare()
	if instanceof(isoObject, "IsoGenerator") then
	else
		isoObject = ReplaceExistingObject(isoObject, fuel, condition)
	end
	SPowerSourceSystem.instance:loadIsoObject(isoObject)
end

local function LoadGenerator(isoObject)
    local fuel = 0
	local condition = 100
	LoadGeneratorObject(isoObject, fuel, condition)
end

MapObjects.OnLoadWithSprite("appliances_misc_01_0", LoadGenerator, PRIORITY)
