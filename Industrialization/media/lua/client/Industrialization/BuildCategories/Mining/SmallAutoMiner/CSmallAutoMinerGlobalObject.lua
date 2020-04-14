--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\client\RainBarrel\CRainBarrelGlobalObject.lua" as reference.
--*****************************
--

require "Map/CGlobalObject"

CSmallAutoMinerGlobalObject = CGlobalObject:derive("CSmallAutoMinerGlobalObject")

function CSmallAutoMinerGlobalObject:new(luaSystem, isoObject)
	local o = CGlobalObject.new(self, luaSystem, isoObject)
	return o
end

function CSmallAutoMinerGlobalObject:getObject()
	return self:getIsoObject()
end

--[[function CSmallAutoMinerGlobalObject:updateFromIsoObject()
    CGlobalObject.updateFromIsoObject(self)
end--]]