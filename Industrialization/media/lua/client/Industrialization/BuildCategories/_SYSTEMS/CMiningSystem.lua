--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\client\RainBarrel\CRainBarrelSystem.lua" as reference.
--*****************************
--

--require "Map/CGlobalObjectSystem"
require "Industrialization/CIndustrializationGlobalObjectSystem"

CMiningSystem = CIndustrializationGlobalObjectSystem:derive("CMiningSystem")

function CMiningSystem:new()
	local o = CIndustrializationGlobalObjectSystem.new(self, "Industrialization_MiningSystem")
	return o
end

function CMiningSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallAutoMiner.FULL_NAME
end

function CMiningSystem:newLuaObject(isoObject)
	return CMiningGlobalObject:new(self, isoObject)
end

----- -----

-- Register CMiningSystem
CIndustrializationGlobalObjectSystem.RegisterSystemClass(CMiningSystem)

----- -----

function CMiningSystem.DoSpecialTooltip(tooltipUI, square)
    CMiningSystem.DoSpecialTooltip2(tooltipUI, square, CMiningSystem.instance)
end

Events.DoSpecialTooltip.Add(CMiningSystem.DoSpecialTooltip)


-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
    CMiningSystem.instance:sendCommand(getPlayer(), "ping", {})
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)


