--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\server\RainBarrel\SRainBarrelSystem.lua" as reference.
--*****************************
--

if isClient() then return end

require "Map/SGlobalObjectSystem"

SAutoMinerSystem = SGlobalObjectSystem:derive("SAutoMinerSystem")

function SAutoMinerSystem:new()
	local o = SGlobalObjectSystem.new(self, "autominer")
	return o
end

function SAutoMinerSystem:initSystem()
	SGlobalObjectSystem.initSystem(self)

	-- Specify GlobalObjectSystem fields that should be saved.
	self.system:setModDataKeys({})
    
	-- Specify GlobalObject fields that should be saved.
	self.system:setObjectModDataKeys({'exterior', 'isOn', 'isWired', 'powerUsage', 'minPowerUsage', 'maxPowerUsage'})

	self:convertOldModData()
end

function SAutoMinerSystem:newLuaObject(globalObject)
	return SAutoMinerGlobalObject:new(self, globalObject)
end

function SAutoMinerSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "Industrialization Small Auto Miner"
end

function SAutoMinerSystem:convertOldModData()
	-- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it.
	if self.system:loadedWorldVersion() ~= -1 then return end
	
	-- Global object data was never saved anywhere.
	-- The objects in this system wouldn't update unless they had been loaded in a session.
    --local modData = GameTime:getInstance():getModData()
end

--[[function SAutoMinerSystem:checkRain()
	if not RainManager.isRaining() then return end
	for i=1,self:getLuaObjectCount() do
		local luaObject = self:getLuaObjectByIndex(i)
		if luaObject.waterAmount < luaObject.waterMax then
			local square = luaObject:getSquare()
			if square then
				luaObject.exterior = square:isOutside()
			end
			if luaObject.exterior then
				luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + 1 * IsoAutoMiner.waterScale)
				luaObject.taintedWater = true
				local isoObject = luaObject:getIsoObject()
				if isoObject then -- object might have been destroyed
					self:noise('added rain to barrel at '..luaObject.x..","..luaObject.y..","..luaObject.z..' waterAmount='..luaObject.waterAmount)
					isoObject:setTaintedWater(true)
					isoObject:setWaterAmount(luaObject.waterAmount)
					isoObject:transmitModData()
				end
			end
		end
	end
end]]

function SAutoMinerSystem:checkForMinedObjects()
    --self:noise('checkForMinedObjects()')

    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        if not luaObject.isOn then return end
        
        local square = luaObject:getSquare()
        if square then
            luaObject.exterior = square:isOutside()
        end
        
        if luaObject.container then
            local item =  InventoryItemFactory.CreateItem("Base.ScrapMetal")
            if (item:getWeight() + luaObject.container:getCapacityWeight() <= luaObject.container:getCapacity()) then
                luaObject.container:addItem(item)
            end
        end
        self:noise('added loot to container at '..luaObject.x..","..luaObject.y..","..luaObject.z..' ')
        
        local isoObject = luaObject:getIsoObject()
        if isoObject then -- object might have been destroyed
            --self:noise('added loot to container at '..luaObject.x..","..luaObject.y..","..luaObject.z..' ')
            --if luaObject.container then isoObject:setContainer(luaObject.container) end
            isoObject:transmitModData()
        end
    end
end

SGlobalObjectSystem.RegisterSystemClass(SAutoMinerSystem)

----- ----- ----- 

local noise = function(msg)
	SAutoMinerSystem.instance:noise(msg)
end

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
	SAutoMinerSystem.instance:checkForMinedObjects()
    return
end
Events.EveryTenMinutes.Add(EveryTenMinutes)

--[[local function OnWaterAmountChange(object, prevAmount)
	if not object then return end
	local luaObject = SAutoMinerSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
	if luaObject then
		noise('waterAmount changed to '..object:getWaterAmount()..' tainted='..tostring(object:isTaintedWater())..' at '..luaObject.x..','..luaObject.y..','..luaObject.z)
		luaObject.waterAmount = object:getWaterAmount()
		luaObject.taintedWater = object:isTaintedWater()
		luaObject:changeSprite(object)
	end
end]]
--Events.OnWaterAmountChange.Add(OnWaterAmountChange)

