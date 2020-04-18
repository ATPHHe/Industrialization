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

SRefiningSystem = SIndustrializationGlobalObjectSystem:derive("SRefiningSystem")

function SRefiningSystem:new()
	local o = SIndustrializationGlobalObjectSystem.new(self, "Industrialization_RefiningSystem")
	return o
end

function SRefiningSystem:newLuaObject(globalObject)
	return SRefiningGlobalObject:new(self, globalObject)
end

function SRefiningSystem:isValidIsoObject(isoObject)
    self:resetSprite(isoObject)
    local isValid = instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallFurnace.FULL_NAME
	return isValid
end

function SRefiningSystem:resetSprite(isoObject)
    if instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallFurnace.FULL_NAME then 
        isoObject:setSprite( IsoSmallFurnace.DEFAULT_SPRITE_NAME ) end
    
    isoObject:transmitUpdatedSpriteToClients()
    return
end
----- ----- ----- 

-- Register SRefiningSystem
SIndustrializationGlobalObjectSystem.RegisterSystemClass(SRefiningSystem)

----- ----- ----- 

local noise = function(msg)
	SRefiningSystem.instance:noise(msg)
end

local ticks = 0
local function OnTick()
    ticks = ticks + 1
    if ticks >= 48 then
        ticks = 0
        SRefiningSystem.instance:sync()
    end
end
Events.OnTick.Add(OnTick)

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
	SRefiningSystem.instance:refine("Base.ScrapMetal", "Base.SheetMetal")
    return
end
Events.EveryTenMinutes.Add(EveryTenMinutes)


