--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\client\RainBarrel\CRainBarrelGlobalObject.lua" as reference.
--*****************************
--

--require "Map/CGlobalObject"
require "Industrialization/CIndustrializationGlobalObject"

CMiningGlobalObject = CIndustrializationGlobalObject:derive("CMiningGlobalObject")

function CMiningGlobalObject:new(luaSystem, isoObject)
	local o = CIndustrializationGlobalObject.new(self, luaSystem, isoObject)
	return o
end

--[[function CMiningGlobalObject:updateFromIsoObject()
    CIndustrializationGlobalObject.updateFromIsoObject(self)
end--]]


