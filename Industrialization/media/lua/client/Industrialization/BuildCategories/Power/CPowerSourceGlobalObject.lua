--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

--require "Map/CGlobalObject"
require "Industrialization/CIndustrializationGlobalObject"

CPowerSourceGlobalObject = CIndustrializationGlobalObject:derive("CPowerSourceGlobalObject")

function CPowerSourceGlobalObject:new(luaSystem, isoObject)
	local o = CIndustrializationGlobalObject.new(self, luaSystem, isoObject)
	return o
end

--[[function CPowerSourceGlobalObject:updateFromIsoObject()
    CIndustrializationGlobalObject.updateFromIsoObject(self)
end--]]


