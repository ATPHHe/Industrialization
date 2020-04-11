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

require "Map/SGlobalObject"

SAutoMinerGlobalObject = SGlobalObject:derive("SAutoMinerGlobalObject")

function SAutoMinerGlobalObject:new(luaSystem, globalObject)
	local o = SGlobalObject.new(self, luaSystem, globalObject)
	return o
end

function SAutoMinerGlobalObject:initNew()
	self.exterior = false
    self.isOn = false
    self.isWired = false
    self.powerUsage = 2
    self.minPowerUsage = 1
    self.maxPowerUsage = 4
    
    self.container = nil
    --self.emitter = nil
    
	--[[self.taintedWater = false
	self.waterAmount = 0
	self.waterMax = IsoAutoMiner.largeWaterMax]]
end

function SAutoMinerGlobalObject:initNewOnlyNilValues()
	if self.exterior == nil then                self.exterior = false                   end
    if self.isOn == nil then                    self.isOn = false                       end
    if self.isWired == nil then                 self.isWired = false                    end
    if self.powerUsage == nil then              self.powerUsage = 2                     end
    if self.minPowerUsage == nil then           self.minPowerUsage = 1                  end
    if self.maxPowerUsage == nil then           self.maxPowerUsage = 4                  end
    
    --if self.container == nil then               self.container = nil                    end
    
	--[[self.taintedWater = false
	self.waterAmount = 0
	self.waterMax = IsoAutoMiner.largeWaterMax]]
end

-- This is called whenever a chunk/cell/square is unloaded from the game along with the isoObject inside that chunk/cell/square.
function SAutoMinerGlobalObject:stateFromIsoObject(isoObject)
    
    -------------------------------
    -- Set loaded luaObject data.
    self:initNewOnlyNilValues()
    local square = isoObject:getSquare()
    
	self.exterior = square:isOutside()
    self.isOn = isoObject:getModData().isOn
    self.isWired = isoObject:getModData().isWired
    self.powerUsage = isoObject:getModData().powerUsage
    self.minPowerUsage = isoObject:getModData().minPowerUsage
    self.maxPowerUsage = isoObject:getModData().maxPowerUsage
    
    self.container = isoObject:getContainer()
    
	--[[self.taintedWater = isoObject:isTaintedWater()
	self.waterAmount = isoObject:getWaterAmount()
	self.waterMax = isoObject:getModData().waterMax

	-- Sanity check
	if not self.waterMax then
		local spriteName = isoObject:getSprite() and isoObject:getSprite():getName()
		if spriteName == "media/textures/Industrialization_AutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_AutoMiner_1.png" then
			self.waterMax = IsoAutoMiner.smallWaterMax
		elseif spriteName == "media/textures/Industrialization_AutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_AutoMiner_1.png" then
			self.waterMax = IsoAutoMiner.largeWaterMax
		else
			self.waterMax = IsoAutoMiner.smallWaterMax
		end
	end

	-- ISTakeWaterAction was fixed to consider storage capacity of water containers.
	-- Update old rainbarrels with 40/100 capacity to 160/400 capacity.
	if self.waterMax == 40 then self.waterMax = IsoAutoMiner.smallWaterMax end
	if self.waterMax == 100 then self.waterMax = IsoAutoMiner.largeWaterMax end

	isoObject:getModData().waterMax = self.waterMax]]
    
	self:changeSprite()
	isoObject:transmitModData()
    self:doAudio(square)
end

-- This is called whenever a chunk loads an isoObject into the game.
function SAutoMinerGlobalObject:stateToIsoObject(isoObject)
	-- Sanity check
	--[[if not self.waterAmount then
		self.waterAmount = 0
	end
	if not self.waterMax then
		local spriteName = isoObject:getSprite() and isoObject:getSprite():getName()
		if spriteName == "media/textures/Industrialization_AutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_AutoMiner_1.png" then
			self.waterMax = IsoAutoMiner.smallWaterMax
		elseif spriteName == "media/textures/Industrialization_AutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_AutoMiner_1.png" then
			self.waterMax = IsoAutoMiner.largeWaterMax
		else
			self.waterMax = IsoAutoMiner.smallWaterMax
		end
	end

	-- ISTakeWaterAction was fixed to consider storage capacity of water containers.
	-- Update old rainbarrels with 40/100 capacity to 160/400 capacity.
	if self.waterMax == 40 then self.waterMax = IsoAutoMiner.smallWaterMax end
	if self.waterMax == 100 then self.waterMax = IsoAutoMiner.largeWaterMax end]]
    
    -------------------------------
    -- Set loaded isoObject data.
    self:initNewOnlyNilValues()
    local square = isoObject:getSquare()
    
	self.exterior = square:isOutside()
    isoObject:getModData().isOn = self.isOn
    isoObject:getModData().isWired = self.isWired
    isoObject:getModData().powerUsage = self.powerUsage
    isoObject:getModData().minPowerUsage = self.minPowerUsage
    isoObject:getModData().maxPowerUsage = self.maxPowerUsage
    
    if not self.container then 
        self.container = isoObject:getContainer()
    else
        isoObject:setContainer(self.container)
    end
    
	--[[if not self.taintedWater then
		self.taintedWater = self.waterAmount > 0 and self.exterior
	end
	isoObject:setTaintedWater(self.taintedWater)

	isoObject:setWaterAmount(self.waterAmount) -- FIXME? OnWaterAmountChanged happens here
	isoObject:getModData().waterMax = self.waterMax]]
    
	self:changeSprite()
	isoObject:transmitModData()
    self:doAudio(square)
end

function SAutoMinerGlobalObject:changeSprite()
	local isoObject = self:getIsoObject()
	if not isoObject then return end
	local spriteName = nil
	--[[if self.waterMax == IsoAutoMiner.smallWaterMax then
		if self.waterAmount >= self.waterMax * 0.75 then
			spriteName = "industrialization_auto_miners_01_0"
		else
			spriteName = "industrialization_auto_miners_01_0"
		end
	elseif self.waterMax == IsoAutoMiner.largeWaterMax then
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

function SAutoMinerGlobalObject:doAudio(square)
    if self.isOn or true then
        self:noise('attempt to play audio')
        if self.audio and self.audio:isPlaying() then self.audio:stop() end
        self.audio = getSoundManager():PlayWorldSound('SmallAutoMinerRunning1', true, square, 0, 8, 1, false);
    end
end

