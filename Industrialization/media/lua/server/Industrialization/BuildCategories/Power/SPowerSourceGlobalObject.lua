--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

--require "Map/SGlobalObject"
require "Industrialization/SIndustrializationGlobalObject"

SPowerSourceGlobalObject = SIndustrializationGlobalObject:derive("SPowerSourceGlobalObject")

function SPowerSourceGlobalObject:new(luaSystem, globalObject)
	local o = SIndustrializationGlobalObject.new(self, luaSystem, globalObject)
	return o
end

-- TODO: finish this once more sprites are added for power sources.
function SPowerSourceGlobalObject:changeSprite()
	local isoObject = self:getIsoObject()
	if not isoObject then return end
	local spriteName = nil
    
	if spriteName and (not isoObject:getSprite() or spriteName ~= isoObject:getSprite():getName()) then
		self:noise('sprite changed to '..spriteName..' at '..self.x..','..self.y..','..self.z)
		isoObject:setSprite(spriteName)
		isoObject:transmitUpdatedSpriteToClients()
	end
end



