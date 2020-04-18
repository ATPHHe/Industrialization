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

CRefiningSystem = CIndustrializationGlobalObjectSystem:derive("CRefiningSystem")

function CRefiningSystem:new()
	local o = CIndustrializationGlobalObjectSystem.new(self, "Industrialization_RefiningSystem")
	return o
end

function CRefiningSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoSmallFurnace.FULL_NAME
end

function CRefiningSystem:newLuaObject(isoObject)
	return CRefiningGlobalObject:new(self, isoObject)
end

----- -----

-- Register CRefiningSystem
CIndustrializationGlobalObjectSystem.RegisterSystemClass(CRefiningSystem)

----- -----

function CRefiningSystem.DoSpecialTooltip(tooltipUI, square)
    CRefiningSystem.DoSpecialTooltip2(tooltipUI, square, CRefiningSystem.instance)
end

Events.DoSpecialTooltip.Add(CRefiningSystem.DoSpecialTooltip)


-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
    CRefiningSystem.instance:sendCommand(getPlayer(), "ping", {})
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)


