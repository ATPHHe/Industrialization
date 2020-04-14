--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "Map/CGlobalObject"

CPowerSourceGlobalObject = CGlobalObject:derive("CPowerSourceGlobalObject")

function CPowerSourceGlobalObject:new(luaSystem, isoObject)
	local o = CGlobalObject.new(self, luaSystem, isoObject)
	return o
end

function CPowerSourceGlobalObject:getObject()
	return self:getIsoObject()
end

--[[function CPowerSourceGlobalObject:updateFromIsoObject()
    CGlobalObject.updateFromIsoObject(self)
end--]]