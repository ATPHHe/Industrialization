--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

if isClient() then return end

--require "ISBaseObject"
require "Map/SGlobalObject"

SIndustrializationGlobalObject = SGlobalObject:derive("SIndustrializationGlobalObject")

-- These fields will be saved to the GlobalObject.
SIndustrializationGlobalObject.DEFAULT_GO_FIELDS = 
    {
        ["UID"] = nil,
        ["name"] = nil,
        ["health"] = -1,
        ["maxHealth"] = -1,
        ["exterior"] = false,
        ["canPoisonInterior"] = false,
        ["isRunning"] = false,
        ["isOn"] = false,
        ["hasPower"] = false,
        ["isWired"] = false,
        ["isPowerSource"] = false,
        ["powerSearchRadius"] = 1,
        ["fuel"] = 0,
        ["fuelUsage"] = 1,
        ["fuelUsageGenerator"] = 1,
        ["minFuelUsage"] = 1,
        ["maxFuelUsage"] = 1,
    }

-- These fields will never be saved and are only temporary.
SIndustrializationGlobalObject.TEMP_FIELDS = 
    {
        ["container"] = nil,
        ["objectIndex"] = nil,
    }

-- InitNew
function SIndustrializationGlobalObject:initNew()
    --
    for stat, value in pairs( self.DEFAULT_GO_FIELDS ) do
        if value ~= nil then self[stat] = value end
    end
    for stat, value in pairs( self.TEMP_FIELDS ) do
        if value ~= nil then self[stat] = value end
    end
    --]]
end

-- When some new GlobalObject variables are added to SIndustrializationGlobalObject.DEFAULT_STATS, 
--      call this function for already existing Objects in the world to make sure they get the newly added variable stats.
function SIndustrializationGlobalObject:initNewOnlyNilValues()
    --
    for stat, value in pairs( self.DEFAULT_GO_FIELDS ) do 
        if value ~= nil and self[stat] == nil then 
            self[stat] = value 
        end
    end
    for stat, value in pairs( self.TEMP_FIELDS ) do 
        if value ~= nil and self[stat] == nil then 
            self[stat] = value 
        end
    end
	--]]
end

--[[
    This is called for IsoObjects that did not have a Lua object when loaded.
    This can happen when the gos_NAME.bin file was deleted.
    This is where you would init the fields of this Lua object from
        isoObject:getModData().
]]
function SIndustrializationGlobalObject:stateFromIsoObject(isoObject)
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
	
    for k, _ in pairs( self.DEFAULT_GO_FIELDS ) do
        self[k] = isoObject:getModData()[k]
    end
    
    -- Get Object's name
    self.name = isoObject:getName()
    isoObject:getModData().name = self.name
    if not self.name then
        self.name = isoObject:getObjectName()
        isoObject:getModData().name = self.name
    end
    
    -- Override fields if the object's name is listed in (IndustrializationGlobalObjectFields.lua)
    local objName = self.name
    --objName = string.gsub(objName, "Industrialization ", "") -- Remove "Industrialization" from the objName
    objName = string.gsub(objName, "%s+", "") -- Remove all spaces from the objName
    
    for k, v in pairs( IndustrializationGlobalObjectFields[ objName ] ) do
        self[k] = v
    end
    
    -- Override other fields.
    if not instanceof(isoObject, "IsoGenerator") then
        self.health = isoObject:getHealth()
        self.maxHealth = isoObject:getMaxHealth()
    else 
        -- Sync Generator data from isoObject
        self.fuel = isoObject:getFuel()
        self.isOn = isoObject:isActivated()
    end
    
    self.exterior = square:isOutside()
    self.container = isoObject:getContainer()
    
    -- Get Gas-Powered Generator's fuel consumption.
    local sandbox = getSandboxOptions();
    if sandbox then
        local classField
        for i=0, getNumClassFields(sandbox)-1 do
            local field = getClassField(sandbox, i)
            --print(tostring(field))
            if tostring(field) == "public zombie.SandboxOptions$DoubleSandboxOption zombie.SandboxOptions.GeneratorFuelConsumption" then
                classField = field; 
                break;
            end
        end
        local classFieldVal = getClassFieldVal(sandbox, classField);
        local GeneratorFuelConsumption = classFieldVal
        
        -- get value here
        if GeneratorFuelConsumption then
            self.fuelUsageGenerator = GeneratorFuelConsumption:getValue()
            if isoObject then
                isoObject:getModData().fuelUsageGenerator = self.fuelUsageGenerator
            end
        end
    end
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
    -- Update old values
    if self.fuelUsage ~= self.DEFAULT_GO_FIELDS.fuelUsage then 
        self.fuelUsage = self.DEFAULT_GO_FIELDS.fuelUsage end
    
    -- Define a UID for LuaObject and ModData.
    self.objectIndex = isoObject:getObjectIndex()
    self.UID = string.format("%.2f%.2f%.2f%s%d", self.x, self.y, self.z, self.name, self.objectIndex) 
    isoObject:getModData().UID = self.UID
    
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
function SIndustrializationGlobalObject:stateToIsoObject(isoObject)
    
    -- Update old values
    if self.fuelUsage ~= self.DEFAULT_GO_FIELDS.fuelUsage then 
        self.fuelUsage = self.DEFAULT_GO_FIELDS.fuelUsage end
    
    -------------------------------
    -- Sync data.
    local square = isoObject:getSquare()
    
    for k, _ in pairs( self.DEFAULT_GO_FIELDS ) do
        isoObject:getModData()[k] = self[k]
    end
    
    -- Get Object's name
    self.name = isoObject:getName()
    isoObject:getModData().name = self.name
    if not self.name then
        self.name = isoObject:getObjectName()
        isoObject:getModData().name = self.name
    end
    
    -- Override fields if the object's name is listed in (IndustrializationGlobalObjectFields.lua)
    local objName = self.name
    --objName = string.gsub(objName, "Industrialization ", "") -- Remove "Industrialization" from the objName
    objName = string.gsub(objName, "%s+", "") -- Remove all spaces from the objName
    
    for k, v in pairs( IndustrializationGlobalObjectFields[ objName ] ) do
        self[k] = v
    end
    
    -- Override other fields.
    if not instanceof(isoObject, "IsoGenerator") then
        self.health = isoObject:getHealth()
        self.maxHealth = isoObject:getMaxHealth()
    else 
        -- Sync Generator data from isoObject
        self.fuel = isoObject:getFuel()
        self.isOn = isoObject:isActivated()
    end
    
    self.exterior = square:isOutside()
    
    if not self.container then 
        self.container = isoObject:getContainer()
    else
        isoObject:setContainer(self.container)
    end
    
    -- Get Gas-Powered Generator's fuel consumption.
    local sandbox = getSandboxOptions();
    if sandbox then
        local classField
        for i=0, getNumClassFields(sandbox)-1 do
            local field = getClassField(sandbox, i)
            --print(tostring(field))
            if tostring(field) == "public zombie.SandboxOptions$DoubleSandboxOption zombie.SandboxOptions.GeneratorFuelConsumption" then
                classField = field; 
                break;
            end
        end
        local classFieldVal = getClassFieldVal(sandbox, classField);
        local GeneratorFuelConsumption = classFieldVal
        
        -- get value here
        if GeneratorFuelConsumption then
            self.fuelUsageGenerator = GeneratorFuelConsumption:getValue()
            if isoObject then
                isoObject:getModData().fuelUsageGenerator = self.fuelUsageGenerator
            end
        end
    end
    
    -------------------------------
    
    -- Init nil values stored in this GlobalObject.
    self:initNewOnlyNilValues()
    
    -- Define a UID for LuaObject and ModData.
    self.objectIndex = isoObject:getObjectIndex()
    self.UID = string.format("%.2f%.2f%.2f%s%d", self.x, self.y, self.z, self.name, self.objectIndex) 
    isoObject:getModData().UID = self.UID
    
    -- Update GlobalObject and IsoObject stuff.
	self:changeSprite()
	isoObject:transmitModData()
    
    -- Find a power source
    self:findPower()
    
    -- Run Audio for this Object.
    self:DoAudioRunning()
end

function SIndustrializationGlobalObject:changeSprite()
    error "override this method"
end

function SIndustrializationGlobalObject:findPower(playAudioToggle)
    
    --self:noise('attempt to find power near '..self.x..','..self.y..','..self.z)
    
    -- Find valid power sources
    local x, y, z = self.x, self.y, self.z
    
    local radius = (self.powerSearchRadius) and self.powerSearchRadius or 1
    
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
    if playAudioToggle then self:DoAudioToggleOnOff() end
    if self.isOn and not self.isRunning and hasPower then
        self.isRunning = true
        self:DoAudioStart()
        self:DoAudioRunning()
    end
    
    if self.isRunning and (not hasPower or not self.isOn) then
        self.isRunning = false
        self:DoAudioStop()
    end
    
end


-- Should be called when this object is being toggled on or off.
function SIndustrializationGlobalObject:DoAudioToggleOnOff()
    self.luaSystem:sendCommand("DoAudioToggleOnOff", {x=self.x, y=self.y, z=self.z, UID=self.UID})
end

-- Should be called when this object is spawned in to attempt to play it's running audio.
function SIndustrializationGlobalObject:DoAudioRunning()
    --self:noise('attempt to manage audio: DoAudioRunning at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        self.luaSystem:sendCommand("DoAudioRunning", {x=self.x, y=self.y, z=self.z, UID=self.UID})
    end
end

-- Should be called when this object is trying to be started.
function SIndustrializationGlobalObject:DoAudioStart()
    --self:noise('attempt to manage audio: DoAudioStart at '..self.x..','..self.y..','..self.z)
    if self.isOn and self.hasPower then
        self.luaSystem:sendCommand("DoAudioStart", {x=self.x, y=self.y, z=self.z, UID=self.UID})
    end
end

-- Should be called when this object is being turned off.
function SIndustrializationGlobalObject:DoAudioStop()
    --self:noise('attempt to manage audio: DoAudioStop at '..self.x..','..self.y..','..self.z)
    self.luaSystem:sendCommand("DoAudioStop", {x=self.x, y=self.y, z=self.z, UID=self.UID})
end

-- Should be called when this object is non-existent.
function SIndustrializationGlobalObject:DoAudioForceStop()
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z..' || '..self.UID)
    self.luaSystem:sendCommand("DoAudioForceStop", {x=self.x, y=self.y, z=self.z, UID=self.UID})
end



--[[
SIndustrializationGlobalObject = SGlobalObject:derive("SIndustrializationGlobalObject")

function SIndustrializationGlobalObject:noise(message)
	self.luaSystem:noise(message)
end

function SIndustrializationGlobalObject:initNew()
	error "override this method"
end

function SIndustrializationGlobalObject:stateFromIsoObject(isoObject)
	-- This is called for IsoObjects that did not have a Lua object when loaded.
	-- This can happen when the gos_NAME.bin file was deleted.
	-- This is where you would init the fields of this Lua object from
	-- isoObject:getModData().
	error "override this method"
end

function SIndustrializationGlobalObject:stateToIsoObject(isoObject)
	-- This is called for IsoObjects that already have a Lua object.
	-- This is where you would synchronize the state of the IsoObject
	-- with this Lua object's current state.
	error "override this method"
end

function SIndustrializationGlobalObject:getIsoObject()
	return self.luaSystem:getIsoObjectAt(self.x, self.y, self.z)
end

function SIndustrializationGlobalObject:getSquare()
	return getCell():getGridSquare(self.x, self.y, self.z)
end

function SIndustrializationGlobalObject:removeIsoObject()
	local square = self:getSquare()
	local isoObject = self:getIsoObject()
	if square and isoObject then
		square:transmitRemoveItemFromSquare(isoObject)
	end
end

function SIndustrializationGlobalObject:new(luaSystem, globalObject)
	-- NOTE: The table for this object is the *same* one the GlobalObject.class
	-- object created in Java.  Doing it this way means we don't have to worry
	-- about syncing this Lua object's fields with the GlobalObject in Java.
	-- Derived classes should not initialize any fields here that are saved,
	-- because they are already loaded from disk when this method is called.
	-- Override initNew() to initialize a brand-new SIndustrializationGlobalObject.
	local o = globalObject:getModData()
	setmetatable(o, self)
	self.__index = self
	o.luaSystem = luaSystem
	o.globalObject = globalObject
	o.x = globalObject:getX()
	o.y = globalObject:getY()
	o.z = globalObject:getZ()
	return o
end
--]]
