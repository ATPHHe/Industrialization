--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\server\RainBarrel\SRainBarrelGlobalObject.lua" as reference.
--*****************************
--

if isClient() then return end

--require "Map/SGlobalObject"
require "Industrialization/SIndustrializationGlobalObject"

SMiningGlobalObject = SIndustrializationGlobalObject:derive("SMiningGlobalObject")

function SMiningGlobalObject:new(luaSystem, globalObject)
	local o = SIndustrializationGlobalObject.new(self, luaSystem, globalObject)
	return o
end

-- TODO: finish this once more sprites are added to the miners.
function SMiningGlobalObject:changeSprite()
	local isoObject = self:getIsoObject()
	if not isoObject then return end
	local spriteName = nil
	--[[if self.waterMax == IsoSmallAutoMiner.smallWaterMax then
		if self.waterAmount >= self.waterMax * 0.75 then
			spriteName = "industrialization_auto_miners_01_0"
		else
			spriteName = "industrialization_auto_miners_01_0"
		end
	elseif self.waterMax == IsoSmallAutoMiner.largeWaterMax then
		if self.waterAmount >= self.waterMax * 0.75 then
			spriteName = "industrialization_auto_miners_01_0"
		else
			spriteName = "industrialization_auto_miners_01_0"
		end
	end]]
	if spriteName and (not isoObject:getSprite() or spriteName ~= isoObject:getSprite():getName()) then
		self:noise('sprite changed to '..spriteName..' at '..self.x..','..self.y..','..self.z)
		isoObject:setSprite(spriteName)
		isoObject:transmitUpdatedSpriteToClients()
	end
end

