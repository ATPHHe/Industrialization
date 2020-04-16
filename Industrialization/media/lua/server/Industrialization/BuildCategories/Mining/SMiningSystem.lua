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

--require "Map/SGlobalObjectSystem"
require "Industrialization/SIndustrializationGlobalObjectSystem"

SMiningSystem = SIndustrializationGlobalObjectSystem:derive("SMiningSystem")

function SMiningSystem:new()
	local o = SIndustrializationGlobalObjectSystem.new(self, "IndustrailizationMiningSystem")
	return o
end

function SMiningSystem:newLuaObject(globalObject)
	return SMiningGlobalObject:new(self, globalObject)
end

function SMiningSystem:isValidIsoObject(isoObject)
    self:resetSprite(isoObject)
    local isValid = instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallAutoMiner.FULL_NAME
	return isValid
end

function SMiningSystem:resetSprite(isoObject)
    if instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallAutoMiner.FULL_NAME then 
        isoObject:setSprite( IsoSmallAutoMiner.DEFAULT_SPRITE_NAME ) 
        isoObject:transmitUpdatedSpriteToClients() end
    return
end
----- ----- ----- 

-- Register SMiningSystem
SIndustrializationGlobalObjectSystem.RegisterSystemClass(SMiningSystem)

----- ----- ----- 

local noise = function(msg)
	SMiningSystem.instance:noise(msg)
end

local ticks = 0
local function OnTick()
    ticks = ticks + 1
    if ticks >= 48 then
        ticks = 0
        SMiningSystem.instance:sync()
    end
end
Events.OnTick.Add(OnTick)

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
	SMiningSystem.instance:tryToLoot()
    return
end
Events.EveryTenMinutes.Add(EveryTenMinutes)


