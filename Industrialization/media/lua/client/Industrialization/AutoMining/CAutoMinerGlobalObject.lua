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

CAutoMinerGlobalObject = CGlobalObject:derive("CAutoMinerGlobalObject")

function CAutoMinerGlobalObject:new(luaSystem, isoObject)
	local o = CGlobalObject.new(self, luaSystem, isoObject)
	return o
end

function CAutoMinerGlobalObject:getObject()
	return self:getIsoObject()
end

--[[function CAutoMinerGlobalObject:updateFromIsoObject()
    CGlobalObject.updateFromIsoObject(self)
end--]]