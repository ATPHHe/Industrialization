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

require "Industrialization/BuildCategories/Mining/SmallAutoMiner/BuildingObjects/IsoSmallAutoMiner"

local function noise(message) SSmallAutoMinerSystem.instance:noise(message) end


local function CreateAutoMiner(sq, spriteName, health)
    local obj = {}
	obj.modData = {}
    
    --[[obj.firstItem = "BlowTorch";
    obj.secondItem = "WeldingMask";
    obj.craftingBank = "BlowTorch";
    obj.canBeAlwaysPlaced = true;
    obj.noNeedHammer = true;
    obj.noNeedScrewdriver = false;]]
    
    --------------------------------------------------------
    obj.modData["need:Base.MetalPipe"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.metalPipe;
    obj.modData["need:Base.SmallSheetMetal"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.smallMetalSheet;
    obj.modData["need:Base.SheetMetal"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.metalSheet;
    obj.modData["need:Base.Hinge"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.hinge;
    --obj.modData["need:Base.ScrapMetal"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.scrapMetal;
    obj.modData["need:Base.ElectronicsScrap"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.electronicsScrap;
    obj.modData["need:Radio.ElectricWire"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.electricWire;
    obj.modData["need:Base.Nails"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.nails;
    obj.modData["need:Base.Screws"] = IsoSmallAutoMiner.REQUIRED_MATERIALS.screws;
    --------------------------------------------------------
    local torchUse = IsoSmallAutoMiner.REQUIRED_MATERIALS.torchUse;
    --obj.modData["need:Base.Hammer"] = "0";
    --obj.modData["need:Base.Screwdriver"] = "0";
    obj.modData["use:Base.BlowTorch"] = torchUse;
    obj.modData["use:Base.WeldingRods"] = torchUse / 2;
    --------------------------------------------------------
    obj.modData["xp:MetalWelding"] = 5 * IsoSmallAutoMiner.REQUIRED_MATERIALS.skill ;
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
	javaObject:setName(IsoSmallAutoMiner.FULL_NAME)
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

local function NewIsoSmallAutoMiner(isoObject)
	local health = IsoSmallAutoMiner.HEALTH_FLAT 
                    + ZombRand(0, IsoSmallAutoMiner.HEALTH_PER_LEVEL*10) 
                    + (ZombRand(2) == 0 and IsoSmallAutoMiner.HEALTH_HANDY_TRAIT or 0)
	ReplaceExistingObject(isoObject, health)
end


local PRIORITY = 5

MapObjects.OnNewWithSprite("industrialization_auto_miners_01_0", NewIsoSmallAutoMiner, PRIORITY)

----- ----- -----

local function LoadObject(isoObject, health)
    --noise("loadobject=================")
	local sq = isoObject:getSquare()
	if instanceof(isoObject, "IsoThumpable") then
	else
		isoObject = ReplaceExistingObject(isoObject, health)
	end
	SSmallAutoMinerSystem.instance:loadIsoObject(isoObject)
end

local function LoadIsoSmallAutoMiner(isoObject)
	local health = IsoSmallAutoMiner.HEALTH_FLAT 
                    + ZombRand(0, IsoSmallAutoMiner.HEALTH_PER_LEVEL*10) 
                    + (ZombRand(2) == 0 and IsoSmallAutoMiner.HEALTH_HANDY_TRAIT or 0)
	LoadObject(isoObject, health)
end

MapObjects.OnLoadWithSprite("industrialization_auto_miners_01_0", LoadIsoSmallAutoMiner, PRIORITY)


----- ----- -----


--=======================================================================================
--[[ -----------------------------------------------------------------------------------------------------------------------------
    DEPRECATED FUNCTIONS/CODE
    
    DEV NOTE: Load sprites by using a texturepack and a tileset definition instead.
    
    DEV NOTE: The .pack and .tile files must correctly use the same sprites and names for each unique sprite.
    DEV NOTE: Add more sprites to the .pack and .tile file to allow for North, South, East, and West sprites.
    DEV NOTE: Add East Sprite: industrialization_auto_miners_01_0
    DEV NOTE: Add South Sprite: industrialization_auto_miners_01_1
    DEV NOTE: Add West Sprite: industrialization_auto_miners_01_2
    DEV NOTE: Add North Sprite: industrialization_auto_miners_01_3
    
    DEV NOTE: To add .pack and .tile files, "mod.info" must correctly list them in order to add them to the game.
        - Example "mod.info" file:
            name=Industrialization
            poster=poster.png
            id=Industrialization
            description=Allows you to build machines to automate some work.
            pack=IndustrializationAutoMiners1x
            pack=IndustrializationAutoMiners2x
            tiledef=industrialization_tiledefinitions1 801
            
    DEV NOTE: pack=NAME
    DEV NOTE: tiledef=NAME NUMBER (NUMBER must be a unique id from 100 to 1000)
    
    DEV NOTE - HELPFUL LINK(S): 
        - https://theindiestone.com/forums/index.php?/topic/8790-custom-texture-packs-and-tile-definitions/
    
--------------------------------------------------------------------------------------------------------------------------------]]
--[[
MOSmallAutoMiner = {}

MOSmallAutoMiner.isAutoMiner = function(object)
	if not object then return nil end
	return object:getName() == "Industrialization Small Auto Miner";
end

MOSmallAutoMiner.findAutoMiner = function(square)
	if not square then return nil end
	local items = square:getObjects();
	for x=0, items:size()-1 do
		local item = items:get(x);
		if MOSmallAutoMiner.isAutoMiner(item) then
			return item;
		end
	end
	return nil;
end

MOSmallAutoMiner.OnLoadGridSquare = function(square)
	local object = MOSmallAutoMiner.findAutoMiner(square);
	if object ~= nil then
        local sprite1 = "industrialization_auto_miners_01_0"
        noise(string.format("found autominer - %s (%.0f, %.0f, %.0f)", object:getName(), object:getX(), object:getY(), object:getZ()))
		object:setSprite(sprite1);
	end
end

Events.LoadGridsquare.Add(MOSmallAutoMiner.OnLoadGridSquare);
--]]
--=======================================================================================
