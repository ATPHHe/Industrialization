--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

--require "Map/SGlobalObjectSystem"
require "Industrialization/SIndustrializationGlobalObjectSystem"

SPowerSourceSystem = SIndustrializationGlobalObjectSystem:derive("SPowerSourceSystem")

function SPowerSourceSystem:new()
	local o = SIndustrializationGlobalObjectSystem.new(self, "Industrialization_PowerSourceSystem")
	return o
end

function SPowerSourceSystem:newLuaObject(globalObject)
	return SPowerSourceGlobalObject:new(self, globalObject)
end

function SPowerSourceSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoGenerator") --instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoPowerSource.FULL_NAME
end

----- ----- ----- 

SIndustrializationGlobalObjectSystem.RegisterSystemClass(SPowerSourceSystem)

----- ----- ----- 

local noise = function(msg)
	SPowerSourceSystem.instance:noise(msg)
end

-----

local ticks = 0
local function OnTick()
    ticks = ticks + 1
    if ticks >= 512 then
        ticks = 0
        SPowerSourceSystem.instance:sync()
    end
end
Events.OnTick.Add(OnTick)

-- Every in-game hour, call this function using Events.EveryHours.
local function EveryHours()
	SPowerSourceSystem.instance:useFuel()
    return
end
Events.EveryHours.Add(EveryHours)

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
	--SPowerSourceSystem.instance:tryToLoot()
    --SPowerSourceSystem.instance:syncFuel()
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)

-----

--[[local function OnWaterAmountChange(object, prevAmount)
	if not object then return end
	local luaObject = SPowerSourceSystem.instance:getLuaObjectAt(object:getX(), object:getY(), object:getZ())
	if luaObject then
		noise('waterAmount changed to '..object:getWaterAmount()..' tainted='..tostring(object:isTaintedWater())..' at '..luaObject.x..','..luaObject.y..','..luaObject.z)
		luaObject.waterAmount = object:getWaterAmount()
		luaObject.taintedWater = object:isTaintedWater()
		luaObject:changeSprite(object)
	end
end]]
--Events.OnWaterAmountChange.Add(OnWaterAmountChange)

