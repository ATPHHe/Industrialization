--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

require "Map/SGlobalObject"

SPowerSourceGlobalObject = SGlobalObject:derive("SPowerSourceGlobalObject")

function SPowerSourceGlobalObject:new(luaSystem, globalObject)
	local o = SGlobalObject.new(self, luaSystem, globalObject)
	return o
end

SPowerSourceGlobalObject.DEFAULT_GO_FIELDS = 
    {
        ["exterior"] = false,
        ["canPoisonInterior"] = false,
        ["isRunning"] = false,
        ["isOn"] = false,
        ["hasPower"] = false,
        ["isWired"] = false,
        ["isPowerSource"] = true,
        ["fuel"] = 0,
        ["powerRadius"] = 1,
        ["powerUsage"] = 1,
        ["powerUsageGenerator"] = 1,
        ["minPowerUsage"] = 1,
        ["maxPowerUsage"] = 4,
    }
SPowerSourceGlobalObject.TEMP_FIELDS = 
    {
        ["container"] = nil,
    }

function SPowerSourceGlobalObject:initNew()
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
	self.waterMax = IsoPowerSource.largeWaterMax]]
end

-- When some new GlobalObject variables are added to SPowerSourceGlobalObject.DEFAULT_STATS, 
--      call this function for already existing Objects in the world to make sure they get the newly added variable stats.
function SPowerSourceGlobalObject:initNewOnlyNilValues()
    --
    for stat, value in pairs( SPowerSourceGlobalObject.DEFAULT_GO_FIELDS ) do 
        if value ~= nil and self[stat] == nil then 
            self[stat] = value 
        end
    end
    for stat, value in pairs( SPowerSourceGlobalObject.TEMP_FIELDS ) do
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
	self.waterMax = IsoPowerSource.largeWaterMax]]
end

--[[
    This is called for IsoObjects that did not have a Lua object when loaded.
    This can happen when the gos_NAME.bin file was deleted.
    This is where you would init the fields of this Lua object from
        isoObject:getModData().
]]
function SPowerSourceGlobalObject:stateFromIsoObject(isoObject)
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
    
    for k, _ in pairs( SPowerSourceGlobalObject.DEFAULT_GO_FIELDS ) do
        self[k] = isoObject:getModData()[k]
    end
    --[[
    self.canPoisonInterior = isoObject:getModData().canPoisonInterior
    self.isRunning = isoObject:getModData().isRunning
    self.isOn = isoObject:getModData().isOn
    self.hasPower = isoObject:getModData().hasPower
    self.isWired = isoObject:getModData().isWired
    
    self.fuel = isoObject:getModData().fuel
    if not self.fuel then
        if instanceof(isoObject, "IsoGenerator") then
            self.fuel = isoObject:getFuel()
        end
    end
    
    self.powerRadius = isoObject:getModData().powerRadius
    self.powerUsage = isoObject:getModData().powerUsage
    self.minPowerUsage = isoObject:getModData().minPowerUsage
    self.maxPowerUsage = isoObject:getModData().maxPowerUsage
    --]]
    
    -- Sync Generator
    if instanceof(isoObject, "IsoGenerator") then
        self.fuel = isoObject:getFuel()
        self.isOn = isoObject:isActivated()
    end
    
    self.exterior = square:isOutside()
    self.container = isoObject:getContainer()
    
    -- get generator power usage
    local sandbox = getSandboxOptions();
    if sandbox then
        local classField
        for i=0, getNumClassFields(sandbox)-1 do
            local field = getClassField(sandbox, i)
            --print(tostring(field))
            if tostring(field) == "public zombie.SandboxOptions$DoubleSandboxOption zombie.SandboxOptions.GeneratorFuelConsumption" then
                classField = field; 
            end
        end
        local classFieldVal = getClassFieldVal(sandbox, classField);
        local GeneratorFuelConsumption = classFieldVal
        
        -- get value here
        if GeneratorFuelConsumption then
            self.powerUsageGenerator = GeneratorFuelConsumption:getValue()
            isoObject:getModData().powerUsageGenerator = self.powerUsageGenerator
        end
    end
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
    -- Update old values
    if self.powerUsage ~= SPowerSourceGlobalObject.DEFAULT_GO_FIELDS.powerUsage then 
        self.powerUsage = SPowerSourceGlobalObject.DEFAULT_GO_FIELDS.powerUsage end
    
    -- Update GlobalObject and IsoObject stuff.
	self:changeSprite()
	isoObject:transmitModData()
    
    -- Find a power source
    --self:findPower()
    
    -- Run Audio for this Object.
    --self:DoAudioRunning()
end

--[[
    This is called for IsoObjects that already have a Lua object.
    This is where you would synchronize the state of the IsoObject
        with this Lua object's current state.
]]
function SPowerSourceGlobalObject:stateToIsoObject(isoObject)
    
    -- Update old values
    if self.powerUsage ~= SPowerSourceGlobalObject.DEFAULT_GO_FIELDS.powerUsage then 
        self.powerUsage = SPowerSourceGlobalObject.DEFAULT_GO_FIELDS.powerUsage end
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
    
    for k, _ in pairs( SPowerSourceGlobalObject.DEFAULT_GO_FIELDS ) do
        isoObject:getModData()[k] = self[k]
    end
	--[[
    isoObject:getModData().canPoisonInterior = self.canPoisonInterior
    isoObject:getModData().isRunning = self.isRunning
    isoObject:getModData().isOn = self.isOn
    isoObject:getModData().hasPower = self.hasPower
    isoObject:getModData().isWired = self.isWired
    isoObject:getModData().fuel = self.fuel
    
    if instanceof(isoObject, "IsoGenerator") then
        isoObject:setFuel( self.fuel )
    end
    
    isoObject:getModData().powerRadius = self.powerRadius
    isoObject:getModData().powerUsage = self.powerUsage
    isoObject:getModData().minPowerUsage = self.minPowerUsage
    isoObject:getModData().maxPowerUsage = self.maxPowerUsage
    --]]
    
    self.exterior = square:isOutside()
    
    -- Sync Generator
    if instanceof(isoObject, "IsoGenerator") then
        --isoObject:setFuel( self.fuel )
        self.isOn = isoObject:isActivated()
    end
    
    if not self.container then 
        self.container = isoObject:getContainer()
    else
        isoObject:setContainer(self.container)
    end
    
    -- get and sync generator power usage
    local sandbox = getSandboxOptions();
    if sandbox then
        local classField
        for i=0, getNumClassFields(sandbox)-1 do
            local field = getClassField(sandbox, i)
            --print(tostring(field))
            if tostring(field) == "public zombie.SandboxOptions$DoubleSandboxOption zombie.SandboxOptions.GeneratorFuelConsumption" then
                classField = field; 
            end
        end
        local classFieldVal = getClassFieldVal(sandbox, classField);
        local GeneratorFuelConsumption = classFieldVal
        
        -- get value here
        if GeneratorFuelConsumption then
            self.powerUsageGenerator = GeneratorFuelConsumption:getValue()
            isoObject:getModData().powerUsageGenerator = self.powerUsageGenerator
        end
    end
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
    -- Update GlobalObject and IsoObject stuff.
	self:changeSprite()
	isoObject:transmitModData()
    
    -- Find a power source
    --self:findPower()
    
    -- Run Audio for this Object.
    --self:DoAudioRunning()
end

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

function SPowerSourceGlobalObject:findPower()
    
    self:noise('attempt to find power near '..self.x..','..self.y..','..self.z)
    
    -- Find valid power sources
    local x, y, z = self.x, self.y, self.z
    
    local radius = (self.powerRadius) and self.powerRadius or 1
    
    local hasPower = false
    for x1 = x - radius, x + radius do
        for y1 = y - radius, y + radius do
            local sq = getWorld():getCell():getOrCreateGridSquare(x1, y1, z)
            
            if sq then 
                --local objects = sq:getObjects()
                --local specialObjects = sq:getSpecialObjects()
                local generator = sq:getGenerator()
                if generator then self:noise("FUEL: " .. generator:getFuel()) end
                local powerSource = nil
                
                if not hasPower and generator and generator:isConnected() and generator:isActivated() then 
                    self:noise('found power source '.. generator:getObjectName() .. " " ..self.x..','..self.y..','..self.z)
                    hasPower = true
                end
                
                if not hasPower and powerSource then
                    --self:noise('found power source '.. powerSource:getObjectName() .. " " ..self.x..','..self.y..','..self.z)
                    hasPower = true
                end
            else
                
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
function SPowerSourceGlobalObject:DoAudioToggleOnOff()
    --self:noise('attempt to manage audio: DoAudioToggleOnOff at '..self.x..','..self.y..','..self.z)
    if self.audioToggle and self.audioToggle:isPlaying() then self.audioToggle:stop() end
    
    -- TODO: replace switch sound with another sound
    self.audioToggle = getSoundManager():PlayWorldSound('LightSwitch', false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object is spawned in to attempt to play it's running audio.
function SPowerSourceGlobalObject:DoAudioRunning()
    --self:noise('attempt to manage audio: DoAudioRunning at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        self:noise('success: DoAudioRunning')
        if self.audio and self.audio:isPlaying() then self.audio:stop() end
        
        -- TODO: replace generator sound with another sound
        --self.audio = getSoundManager():PlayWorldSound('PowerSourceRunning0', true, self:getSquare(), 0, 8, 1, false);
        self.audio = getSoundManager():PlayWorldSound('GeneratorLoop', true, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is trying to be started.
function SPowerSourceGlobalObject:DoAudioStart()
    --self:noise('attempt to manage audio: DoAudioStart at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        if self.audio and self.audio:isPlaying() then self.audio:stop() end
        if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
        
        -- TODO: replace generator sound with another sound
        --self.audio = getSoundManager():PlayWorldSound('PowerSourceTryStart0', false, self:getSquare(), 0, 8, 1, false);
        self.audio2 = getSoundManager():PlayWorldSound('GeneratorStarting', false, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is being turned off.
function SPowerSourceGlobalObject:DoAudioStop()
    --self:noise('attempt to manage audio: DoAudioStop at '..self.x..','..self.y..','..self.z)
    if self.audio and self.audio:isPlaying() then self.audio:stop() end
    if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
    
    -- TODO: replace generator sound with another sound
    --self.audio = getSoundManager():PlayWorldSound('PowerSourceTryStop0', false, self:getSquare(), 0, 8, 1, false);
    self.audio = getSoundManager():PlayWorldSound('GeneratorStopping', false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object destroyed or non-existent.
function SPowerSourceGlobalObject:DoAudioForceStop()
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z)
    if self.audio and self.audio:isPlaying() then self.audio:stop() end
    if self.audio2 and self.audio2:isPlaying() then self.audio2:stop() end
    if self.audioToggle and self.audioToggle:isPlaying() then self.audioToggle:stop() end
end


