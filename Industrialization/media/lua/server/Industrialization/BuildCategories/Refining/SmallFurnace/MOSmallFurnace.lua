--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

require "Industrialization/BuildCategories/Refining/SmallFurnace/IsoSmallFurnace"
--require "Industrialization/SIndustrializationGlobalObjectSystem"


local function getSystem()
    return SRefiningSystem
end


local function noise(message) getSystem().instance:noise(message) end



local function GetRandomHealth()
    local health = IsoSmallFurnace.HEALTH_FLAT + (ZombRand(2) == 0 and IsoSmallFurnace.HEALTH_HANDY_TRAIT or 0)
    for i, _ in ipairs(IsoSmallFurnace.HEALTH_PERKS) do
        health = health + (ZombRand(10, 0) * IsoSmallFurnace.HEALTH_PER_PERK_LEVEL[i]);
    end
    return health
end

local function CreateIsoSmallFurnace(sq, spriteName, health)
    local obj = {}
	obj.modData = IsoSmallFurnace.createAndGetModData()
    
	local cell = getWorld():getCell()
	local north = false
	local javaObject = IsoThumpable.new(cell, sq, spriteName, north, obj.modData)
    
    --javaObject:setSprite(spriteName);
	javaObject:setCanPassThrough(false)
	javaObject:setCanBarricade(false)
	javaObject:setThumpDmg(IsoSmallFurnace.SETTINGS.thumpDmg)
	javaObject:setIsContainer(true)
	javaObject:setIsDoor(false)
	javaObject:setIsDoorFrame(false)
	javaObject:setCrossSpeed(1.0)
	javaObject:setBlockAllTheSquare(true)
	javaObject:setName(IsoSmallFurnace.FULL_NAME)
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
	local javaObject = CreateIsoSmallFurnace(sq, isoObject:getSprite():getName(), health)
	local index = isoObject:getObjectIndex()
	sq:transmitRemoveItemFromSquare(isoObject)
	sq:AddSpecialObject(javaObject, index)
	javaObject:transmitCompleteItemToClients()
	return javaObject
end

local function NewIsoSmallFurnace(isoObject)
	local health = GetRandomHealth()
	ReplaceExistingObject(isoObject, health)
end


local PRIORITY = 5

MapObjects.OnNewWithSprite( IsoSmallFurnace.DEFAULT_SPRITE_NAME , NewIsoSmallFurnace, PRIORITY)

----- ----- -----

local function LoadObject(isoObject, health)
    --noise("loadobject=================")
	local sq = isoObject:getSquare()
	if instanceof(isoObject, "IsoThumpable") then
        
        --isoObject:setName( IsoSmallFurnace.FULL_NAME )
        
	else
		isoObject = ReplaceExistingObject(isoObject, health)
	end
    
	getSystem().instance:loadIsoObject(isoObject)
    
end

local function LoadIsoSmallFurnace(isoObject)
	local health = GetRandomHealth()
	LoadObject(isoObject, health)
end

MapObjects.OnLoadWithSprite( IsoSmallFurnace.DEFAULT_SPRITE_NAME , LoadIsoSmallFurnace, PRIORITY)


----- ----- -----

