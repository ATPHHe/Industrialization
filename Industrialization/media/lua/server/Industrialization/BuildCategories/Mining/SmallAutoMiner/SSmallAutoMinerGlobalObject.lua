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

SSmallAutoMinerGlobalObject = SGlobalObject:derive("SSmallAutoMinerGlobalObject")

function SSmallAutoMinerGlobalObject:new(luaSystem, globalObject)
	local o = SGlobalObject.new(self, luaSystem, globalObject)
	return o
end

SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS = 
    {
        ["exterior"] = false,
        ["isRunning"] = false,
        ["isOn"] = false,
        ["hasPower"] = false,
        ["isWired"] = false,
        ["isPowerSource"] = false,
        ["powerRadius"] = 1,
        ["powerUsage"] = 1,
        ["minPowerUsage"] = 1,
        ["maxPowerUsage"] = 4,
    }
SSmallAutoMinerGlobalObject.TEMP_FIELDS = 
    {
        ["container"] = nil,
    }

function SSmallAutoMinerGlobalObject:initNew()
    --
    for stat, value in pairs( SPowerSourceGlobalObject.DEFAULT_GO_FIELDS ) do
        if value ~= nil then self[stat] = value end
    end
    for stat, value in pairs( SPowerSourceGlobalObject.TEMP_FIELDS ) do
        if value ~= nil then self[stat] = value end
    end
    --]]
	--[[
    self.exterior = false
    self.isRunning = false
    self.isOn = false
    self.hasPower = false
    self.isWired = false
    self.powerUsage = 2
    self.minPowerUsage = 1
    self.maxPowerUsage = 4
    
    self.container = nil
    --]]
    
    --self.emitter = nil
    
	--[[self.taintedWater = false
	self.waterAmount = 0
	self.waterMax = IsoSmallAutoMiner.largeWaterMax]]
end

-- When some new GlobalObject variables are added to SSmallAutoMinerGlobalObject.DEFAULT_STATS, 
--      call this function for already existing Objects in the world to make sure they get the newly added variable stats.
function SSmallAutoMinerGlobalObject:initNewOnlyNilValues()
    --
    for stat, value in pairs( SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS ) do 
        if value ~= nil and self[stat] == nil then 
            self[stat] = value 
        end
    end
    for stat, value in pairs( SSmallAutoMinerGlobalObject.TEMP_FIELDS ) do 
        if value ~= nil and self[stat] == nil then 
            self[stat] = value 
        end
    end
	--]]
    --[[
    if self.exterior == nil then                self.exterior = false                   end
    if self.isRunning == nil then               self.isRunning = false                  end
    if self.isOn == nil then                    self.isOn = false                       end
    if self.hasPower == nil then                self.hasPower = false                   end
    if self.isWired == nil then                 self.isWired = false                    end
    if self.powerUsage == nil then              self.powerUsage = 2                     end
    if self.minPowerUsage == nil then           self.minPowerUsage = 1                  end
    if self.maxPowerUsage == nil then           self.maxPowerUsage = 4                  end
    
    --if self.container == nil then               self.container = nil                    end
    --]]
    
	--[[self.taintedWater = false
	self.waterAmount = 0
	self.waterMax = IsoSmallAutoMiner.largeWaterMax]]
end

--[[
    This is called for IsoObjects that did not have a Lua object when loaded.
    This can happen when the gos_NAME.bin file was deleted.
    This is where you would init the fields of this Lua object from
        isoObject:getModData().
]]
function SSmallAutoMinerGlobalObject:stateFromIsoObject(isoObject)
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
	
    for k, _ in pairs( SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS ) do
        self[k] = isoObject:getModData()[k]
    end
    --[[
    self.isRunning = isoObject:getModData().isRunning
    self.isOn = isoObject:getModData().isOn
    self.hasPower = isoObject:getModData().hasPower
    self.isWired = isoObject:getModData().isWired
    self.powerUsage = isoObject:getModData().powerUsage
    self.minPowerUsage = isoObject:getModData().minPowerUsage
    self.maxPowerUsage = isoObject:getModData().maxPowerUsage
    --]]
    self.exterior = square:isOutside()
    self.container = isoObject:getContainer()
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
    -- Update old values
    if self.powerUsage ~= SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS.powerUsage then 
        self.powerUsage = SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS.powerUsage end
    
	--[[self.taintedWater = isoObject:isTaintedWater()
	self.waterAmount = isoObject:getWaterAmount()
	self.waterMax = isoObject:getModData().waterMax

	-- Sanity check
	if not self.waterMax then
		local spriteName = isoObject:getSprite() and isoObject:getSprite():getName()
		if spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" then
			self.waterMax = IsoSmallAutoMiner.smallWaterMax
		elseif spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" then
			self.waterMax = IsoSmallAutoMiner.largeWaterMax
		else
			self.waterMax = IsoSmallAutoMiner.smallWaterMax
		end
	end

	-- ISTakeWaterAction was fixed to consider storage capacity of water containers.
	-- Update old rainbarrels with 40/100 capacity to 160/400 capacity.
	if self.waterMax == 40 then self.waterMax = IsoSmallAutoMiner.smallWaterMax end
	if self.waterMax == 100 then self.waterMax = IsoSmallAutoMiner.largeWaterMax end

	isoObject:getModData().waterMax = self.waterMax]]
    
    -- Update GlobalObject and IsoObject stuff.
	self:changeSprite()
	isoObject:transmitModData()
    
    -- Find a power source
    self:findPower()
    
    -- Run Audio for this Object.
    self:DoAudioRunning()
end

--[[
    This is called for IsoObjects that already have a Lua object.
    This is where you would synchronize the state of the IsoObject
        with this Lua object's current state.
]]
function SSmallAutoMinerGlobalObject:stateToIsoObject(isoObject)
    
	-- Sanity check
	--[[if not self.waterAmount then
		self.waterAmount = 0
	end
	if not self.waterMax then
		local spriteName = isoObject:getSprite() and isoObject:getSprite():getName()
		if spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" then
			self.waterMax = IsoSmallAutoMiner.smallWaterMax
		elseif spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" 
                or spriteName == "media/textures/Industrialization_SmallAutoMiner_1.png" then
			self.waterMax = IsoSmallAutoMiner.largeWaterMax
		else
			self.waterMax = IsoSmallAutoMiner.smallWaterMax
		end
	end

	-- ISTakeWaterAction was fixed to consider storage capacity of water containers.
	-- Update old rainbarrels with 40/100 capacity to 160/400 capacity.
	if self.waterMax == 40 then self.waterMax = IsoSmallAutoMiner.smallWaterMax end
	if self.waterMax == 100 then self.waterMax = IsoSmallAutoMiner.largeWaterMax end]]
    
    -- Update old values
    if self.powerUsage ~= SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS.powerUsage then 
        self.powerUsage = SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS.powerUsage end
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
    
    for k, _ in pairs( SSmallAutoMinerGlobalObject.DEFAULT_GO_FIELDS ) do
        isoObject:getModData()[k] = self[k]
    end
    --[[
    isoObject:getModData().isRunning = self.isRunning
    isoObject:getModData().isOn = self.isOn
    isoObject:getModData().hasPower = self.hasPower
    isoObject:getModData().isWired = self.isWired
    isoObject:getModData().powerUsage = self.powerUsage
    isoObject:getModData().minPowerUsage = self.minPowerUsage
    isoObject:getModData().maxPowerUsage = self.maxPowerUsage
    --]]
    self.exterior = square:isOutside()
    
    if not self.container then 
        self.container = isoObject:getContainer()
    else
        isoObject:setContainer(self.container)
    end
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
	--[[if not self.taintedWater then
		self.taintedWater = self.waterAmount > 0 and self.exterior
	end
	isoObject:setTaintedWater(self.taintedWater)

	isoObject:setWaterAmount(self.waterAmount) -- FIXME? OnWaterAmountChanged happens here
	isoObject:getModData().waterMax = self.waterMax]]
    
    -- Update GlobalObject and IsoObject stuff.
	self:changeSprite()
	isoObject:transmitModData()
    
    -- Find a power source
    self:findPower()
    
    -- Run Audio for this Object.
    self:DoAudioRunning()
end

function SSmallAutoMinerGlobalObject:changeSprite()
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

function SSmallAutoMinerGlobalObject:findPower()
    
    --self:noise('attempt to find power near '..self.x..','..self.y..','..self.z)
    
    -- Find valid power sources
    local x, y, z = self.x, self.y, self.z
    
    local radius = (self.powerRadius) and self.powerRadius or 1
    
    local hasPower = false
    for x1 = x - radius, x + radius do
        for y1 = y - radius, y + radius do
            local sq = getWorld():getCell():getOrCreateGridSquare(x1, y1, z)
            
            if sq then 
                -- HAS SQUARE
                
                --local objects = sq:getObjects()
                local specialObjects = sq:getSpecialObjects()
                local generator = sq:getGenerator()
                --if generator then self:noise("FUEL: " .. generator:getFuel()) end
                
                -- Find Gas-Powered Generator PowerSource
                if not hasPower and generator and generator:isConnected() and generator:isActivated() then 
                    --self:noise('HAS SQ: found working power source '.. generator:getObjectName() .. ' ' ..x1..','..y1..','..z)
                    hasPower = true
                end
                
                -- Find IsoObject PowerSource
                local powerLuaObject = SPowerSourceSystem.instance:getLuaObjectAt(x1, y1, z)
                if not hasPower and powerLuaObject and not specialObjects:isEmpty() then
                    for i=0, specialObjects:size()-1 do
                        local sO = specialObjects:get(i)
                        if sO and sO:getModData().isPowerSource and powerLuaObject.isOn then
                            --self:noise('HAS SQ: found working power source '.. sO:getObjectName() .. ' ' ..x1..','..y1..','..self.z)
                            hasPower = true
                        end
                    end
                end
            else
                -- NIL SQUARE
                
                -- Find WorldObject PowerSource LuaObject
                local powerLuaObject = SPowerSourceSystem.instance:getLuaObjectAt(x1, y1, z)
                
                if not hasPower and powerLuaObject then
                    if powerLuaObject.isOn then
                        --self:noise('NIL SQ: found working power source at '..x1..','..y1..','..z)
                        hasPower = true
                    end
                end
            end
            
            if hasPower then break end
        end
        
        if hasPower then break end
    end
    
    self.hasPower = hasPower
    
    local isoObject = self:getIsoObject()
    if isoObject then
        isoObject:getModData().hasPower = hasPower
        isoObject:transmitModData()
    end
    
    -- Do Audio if possible
    if self.isOn and not self.isRunning and hasPower then
        self.isRunning = true
        self:DoAudioStart()
        self:DoAudioRunning()
    end
    
    if self.isRunning and not hasPower then
        self.isRunning = false
        self:DoAudioStop()
    end
end

-- Should be called when this object is being toggled on or off.
function SSmallAutoMinerGlobalObject:DoAudioToggleOnOff()
    --self:noise('attempt to manage audio: DoAudioToggleOnOff at '..self.x..','..self.y..','..self.z)
    if self.audioToggle and self.audioToggle:isPlaying() then self.audioToggle:stop() end
    
    -- TODO: replace switch sound with another sound
    self.audioToggle = getSoundManager():PlayWorldSound('LightSwitch', false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object is spawned in to attempt to play it's running audio.
function SSmallAutoMinerGlobalObject:DoAudioRunning()
    --self:noise('attempt to manage audio: DoAudioRunning at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        --self:noise('success: DoAudioRunning')
        if self.audio and self.audio:isPlaying() then self.audio:stop() end
        self.audio = getSoundManager():PlayWorldSound('SmallAutoMinerRunning1', true, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is trying to be started.
function SSmallAutoMinerGlobalObject:DoAudioStart()
    --self:noise('attempt to manage audio: DoAudioStart at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        if self.audio and self.audio:isPlaying() then self.audio:stop() end
        if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
        
        -- TODO: replace generator sound with another sound
        --self.audio = getSoundManager():PlayWorldSound('SmallAutoMinerTryStart0', false, self:getSquare(), 0, 8, 1, false);
        self.audio2 = getSoundManager():PlayWorldSound('GeneratorStarting', false, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is being turned off.
function SSmallAutoMinerGlobalObject:DoAudioStop()
    --self:noise('attempt to manage audio: DoAudioStop at '..self.x..','..self.y..','..self.z)
    if self.audio and self.audio:isPlaying() then self.audio:stop() end
    if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
    
    -- TODO: replace generator sound with another sound
    --self.audio = getSoundManager():PlayWorldSound('SmallAutoMinerTryStop0', false, self:getSquare(), 0, 8, 1, false);
    self.audio = getSoundManager():PlayWorldSound('GeneratorStopping', false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object destroyed or non-existent.
function SSmallAutoMinerGlobalObject:DoAudioForceStop()
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z)
    if self.audio and self.audio:isPlaying() then self.audio:stop() end
    if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
    if self.audioToggle and self.audioToggle:isPlaying() then self.audioToggle:stop() end
end


