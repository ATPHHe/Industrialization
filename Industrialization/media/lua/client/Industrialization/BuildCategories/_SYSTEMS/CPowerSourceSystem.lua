--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

--require "Map/CGlobalObjectSystem"
require "Industrialization/CIndustrializationGlobalObjectSystem"

CPowerSourceSystem = CIndustrializationGlobalObjectSystem:derive("CPowerSourceSystem")

function CPowerSourceSystem:new()
	local o = CIndustrializationGlobalObjectSystem.new(self, "Industrialization_PowerSourceSystem")
	return o
end

function CPowerSourceSystem:isValidIsoObject(isoObject)
	return instanceof(isoObject, "IsoGenerator") --instanceof(isoObject, "IsoThumpable") and isoObject:getName() == IsoPowerSource.FULL_NAME
end

function CPowerSourceSystem:newLuaObject(isoObject)
	return CPowerSourceGlobalObject:new(self, isoObject)
end

----- ----- -----

CIndustrializationGlobalObjectSystem.RegisterSystemClass(CPowerSourceSystem)

----- ----- -----

function CPowerSourceSystem.DoSpecialTooltip(tooltipUI, square)
    CPowerSourceSystem.DoSpecialTooltip2(tooltipUI, square, CPowerSourceSystem.instance)
end

Events.DoSpecialTooltip.Add(CPowerSourceSystem.DoSpecialTooltip)


-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
    CPowerSourceSystem.instance:sendCommand(getPlayer(), "ping", {})
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)


