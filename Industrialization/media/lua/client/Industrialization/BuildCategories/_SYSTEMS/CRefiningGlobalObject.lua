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

CRefiningGlobalObject = CIndustrializationGlobalObject:derive("CRefiningGlobalObject")

function CRefiningGlobalObject:new(luaSystem, isoObject)
	local o = CIndustrializationGlobalObject.new(self, luaSystem, isoObject)
	return o
end

--[[function CRefiningGlobalObject:updateFromIsoObject()
    CIndustrializationGlobalObject.updateFromIsoObject(self)
end--]]


