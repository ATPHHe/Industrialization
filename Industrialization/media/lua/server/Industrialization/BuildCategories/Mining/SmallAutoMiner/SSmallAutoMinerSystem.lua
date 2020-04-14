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

SSmallAutoMinerSystem = SGlobalObjectSystem:derive("SSmallAutoMinerSystem")

function SSmallAutoMinerSystem:new()
	local o = SGlobalObjectSystem.new(self, "SmallAutoMinerSystem")
	return o
end

function SSmallAutoMinerSystem:initSystem()
	SGlobalObjectSystem.initSystem(self)

	-- Specify GlobalObjectSystem fields that should be saved.
	self.system:setModDataKeys({})
    
	-- Specify GlobalObject fields that should be saved.
    local globalObjectFields = {}
    for k, _ in pairs( SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS ) do
        table.insert(globalObjectFields, k)
    end
    self.system:setObjectModDataKeys(globalObjectFields)
	--self.system:setObjectModDataKeys({'exterior', 'isRunning', 'isOn', 'isWired', 'powerUsage', 'minPowerUsage', 'maxPowerUsage'})

	self:convertOldModData()
end

function SSmallAutoMinerSystem:newLuaObject(globalObject)
	return SSmallAutoMinerGlobalObject:new(self, globalObject)
end

function SSmallAutoMinerSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallAutoMiner.FULL_NAME
end

function SSmallAutoMinerSystem:convertOldModData()
	-- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it.
	if self.system:loadedWorldVersion() ~= -1 then return end
	
	-- Global object data was never saved anywhere.
	-- The objects in this system wouldn't update unless they had been loaded in a session.
    --local modData = GameTime:getInstance():getModData()
end

function SSmallAutoMinerSystem:removeLuaObject(luaObject)
    -- Force some Audio to stop playing if and only if they are playing.
    luaObject:DoAudioForceStop()
    
    -- Finish using generic super class to remove luaObject.
    SGlobalObjectSystem.removeLuaObject(self, luaObject)
end

--[[function SSmallAutoMinerSystem:checkRain()
	if not RainManager.isRaining() then return end
	for i=1,self:getLuaObjectCount() do
		local luaObject = self:getLuaObjectByIndex(i)
		if luaObject.waterAmount < luaObject.waterMax then
			local square = luaObject:getSquare()
			if square then
				luaObject.exterior = square:isOutside()
			end
			if luaObject.exterior then
				luaObject.waterAmount = math.min(luaObject.waterMax, luaObject.waterAmount + 1 * IsoSmallAutoMiner.waterScale)
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

function SSmallAutoMinerSystem:sync()
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        
        -- Check for power source.
        luaObject:findPower()
        
    end
end

-- Call this to try and loot all luaObjects for each SmallAutoMiner. Only works if they each have a container.
function SSmallAutoMinerSystem:tryToLoot()
    --self:noise('tryToLoot()')
    
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        
        -- Check for power source.
        luaObject:findPower()
        
        if luaObject.isOn and luaObject.hasPower then 
            local square = luaObject:getSquare()
            if square then
                luaObject.exterior = square:isOutside()
            end
            
            ----- -----
            -- Attempt to loot and store items into the luaObject's container.
            if luaObject.container then
                
                local lootTable = self:getLootTable()
                
                if lootTable then
                    for itemName, itemTable in pairs(lootTable) do
                        
                        local percentChance = itemTable[1]
                        local MAX_LOOT = itemTable[2]
                        local MIN_LOOT = itemTable[3]
                        
                        if itemName ~= "minLoot" and itemName ~= "maxLoot" then
                            local roll = ZombRandFloat(0, 100)
                            if roll < percentChance then
                            
                                local randomAmount = ZombRand(MAX_LOOT + 1, MIN_LOOT)
                                for i=1, randomAmount do
                                    local item = InventoryItemFactory.CreateItem(itemName)
                                    if (item:getWeight() + luaObject.container:getCapacityWeight() <= luaObject.container:getCapacity()) then
                                        luaObject.container:addItem(item)
                                    end
                                end
                                
                                --self:noise(string.format('found loot at (%.1f, %.1f, %.1f) loot=(itemName: %s, amount: %d)', luaObject.x, luaObject.y, luaObject.z, itemName, randomAmount))
                                
                                break;
                            end
                        end
                        
                    end
                end
                
            end
            
            ----- -----
            
            local isoObject = luaObject:getIsoObject()
            if isoObject then -- object might have been destroyed
                --self:noise('added loot to container at '..luaObject.x..","..luaObject.y..","..luaObject.z..' ')
                --if luaObject.container then isoObject:setContainer(luaObject.container) end
                isoObject:transmitModData()
            end
        end
    end
end

function SSmallAutoMinerSystem:getLootTable()

    local lootTable = IndustrializationLootTables.SmallAutoMiner
    
    local lootTableCopy = {}
    for itemName, percentChance in pairs(lootTable) do
        lootTableCopy[itemName] = percentChance
    end
    return lootTableCopy
end

SGlobalObjectSystem.RegisterSystemClass(SSmallAutoMinerSystem)

----- ----- ----- 

local noise = function(msg)
	SSmallAutoMinerSystem.instance:noise(msg)
end

local ticks = 0
local function OnTick()
    ticks = ticks + 1
    if ticks >= 512 then
        ticks = 0
        SSmallAutoMinerSystem.instance:sync()
    end
end
Events.OnTick.Add(OnTick)

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
	SSmallAutoMinerSystem.instance:tryToLoot()
    return
end
Events.EveryTenMinutes.Add(EveryTenMinutes)

--[[local function OnWaterAmountChange(object, prevAmount)
	if not object then return end
	local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
	if luaObject then
		noise('waterAmount changed to '..object:getWaterAmount()..' tainted='..tostring(object:isTaintedWater())..' at '..luaObject.x..','..luaObject.y..','..luaObject.z)
		luaObject.waterAmount = object:getWaterAmount()
		luaObject.taintedWater = object:isTaintedWater()
		luaObject:changeSprite(object)
	end
end]]
--Events.OnWaterAmountChange.Add(OnWaterAmountChange)

