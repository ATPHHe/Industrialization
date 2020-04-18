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

--require "Industrialization/BuildCategories/Power/IsoGenerator/IsoGenerator"
--require "Industrialization/SIndustrializationGlobalObjectSystem"


local function getSystem()
    return SPowerSourceSystem
end


local function noise(message) getSystem().instance:noise(message) end



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
    
    getSystem().instance:loadIsoObject(javaObject)
    
	-- IsoGenerator constructor calls AddSpecialObject, probably it shouldn't.
--	square:AddSpecialObject(javaObject, index)
	javaObject:transmitCompleteItemToClients()
end

local function NewGenerator(isoObject)
	local fuel = 0
	local condition = 100
	ReplaceExistingGeneratorObject(isoObject, fuel, condition)
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
    
	getSystem().instance:loadIsoObject(isoObject)
    
end

local function LoadGenerator(isoObject)
    local fuel = 0
	local condition = 100
	LoadGeneratorObject(isoObject, fuel, condition)
end

MapObjects.OnLoadWithSprite("appliances_misc_01_0", LoadGenerator, PRIORITY)

----- ----- -----


