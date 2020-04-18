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
require "Map/SGlobalObjectSystem"

SIndustrializationGlobalObjectSystem = SGlobalObjectSystem:derive("SIndustrializationGlobalObjectSystem")



function SIndustrializationGlobalObjectSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, "IsoGenerator") then
        return true
    end
    
    local objectName = isoObject:getName()
    if not objectName or objectName == "" then return false end
    
    for name, _ in pairs(IndustrializationGlobalObjectFields) do
        objectName = string.gsub(objectName, "%s+", "")
        
        if instanceof(isoObject, "IsoThumpable") and objectName == name then
            
            objectName = string.gsub(objectName, "Industrialization", "")
            local spriteName = nil
            local f = loadstring("return Iso"..objectName..".DEFAULT_SPRITE_NAME")
            spriteName = f()
            
            --self:noise(tostring(spriteName))
            -- Reset/update to default sprite
            if spriteName then
                isoObject:setSprite( spriteName ) 
                isoObject:transmitUpdatedSpriteToClients()
            end
            
            return true
        end
    end
    
	return false
end

-- initSystem
function SIndustrializationGlobalObjectSystem:initSystem()
	SGlobalObjectSystem.initSystem(self)
    
    ----- -----
    
	-- Specify GlobalObjectSystem fields that should be saved.
	self.system:setModDataKeys({})
    
    ----- -----
    
	-- Specify GlobalObject fields that should be saved.
    local globalObjectFields = {}
    for k, _ in pairs( SIndustrializationGlobalObject.DEFAULT_GO_FIELDS ) do
        table.insert( globalObjectFields, k )
    end
    
    self.system:setObjectModDataKeys( globalObjectFields )
	--self.system:setObjectModDataKeys({'exterior', 'isRunning', 'isOn', 'isWired', 'powerUsage', 'minPowerUsage', 'maxPowerUsage'})
    
    ----- -----
    
	self:convertOldModData()
end

function SIndustrializationGlobalObjectSystem:convertOldModData()
	-- If the gos_xxx.bin file existed, don't touch GameTime modData in case mods are using it.
	if self.system:loadedWorldVersion() ~= -1 then return end
	
	-- Global object data was never saved anywhere.
	-- The objects in this system wouldn't update unless they had been loaded in a session.
    --local modData = GameTime:getInstance():getModData()
end

-- This is called when an LuaObject is being removed due to it's IsoObject not being valid or not existing.
function SIndustrializationGlobalObjectSystem:removeLuaObject(luaObject)
    -- Force some Audio to stop playing if and only if they are playing.
    luaObject:DoAudioForceStop()
    
    -- Finish using generic super class to remove luaObject.
    SGlobalObjectSystem.removeLuaObject(self, luaObject)
end

--[[
function SIndustrializationGlobalObjectSystem:sendCommand(command, args)
	self.system:sendCommand(command, args)
end--]]

function SIndustrializationGlobalObjectSystem:OnClientCommand(command, playerObj, args)
	-- CGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
    local userAndID = tostring(playerObj:getUsername()).." "..tostring(playerObj:getOnlineID())
    if command == "ping" then
        self:sendCommand("message", { message="SERVER: \"ping\" was recieved from "..userAndID })
    elseif command == "set" then
        --self:sendCommand("message", { message="SERVER: \"set\" command recieved from "..userAndID.." key="..tostring(args.key).." value="..tostring(args.value) })
        local sLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        local sIsoObject = self:getIsoObjectAt(args.x, args.y, args.z)
        if sLuaObject then 
            sLuaObject[args.key] = args.value; 
        end
        if sIsoObject then 
            sIsoObject:getModData()[args.key] = args.value; 
            sIsoObject:transmitModData(); 
        end
    elseif command == "findPower" then
        --self:sendCommand("message", { message="SERVER: \"findPower\" command recieved from "..userAndID })
        local sLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        --local sIsoObject = self:getIsoObjectAt(args.x, args.y, args.z)
        if sLuaObject then 
            sLuaObject:findPower(args.param1)
        end
        --if sIsoObject then sIsoObject:getModData()[args.key] = args.value; sIsoObject:transmitModData(); end
    end
end

function SIndustrializationGlobalObjectSystem:sync()
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local isoObject = luaObject:getIsoObject()
        
        -- Check for power source.
        luaObject:findPower(false)
        
        --
        if isoObject then
            luaObject.health = isoObject.getHealth and isoObject:getHealth() or -1
            luaObject.maxHealth = isoObject.getMaxHealth and isoObject:getMaxHealth() or -1
            isoObject:getModData().health = luaObject.health
            isoObject:getModData().maxHealth = luaObject.maxHealth
            isoObject:transmitModData()
            --isoObject:sendObjectChange('health')
        end
        --]]
        
        if isoObject and instanceof(isoObject, "IsoGenerator") then
            if luaObject.fuel ~= isoObject:getFuel() then
                isoObject:setFuel( luaObject.fuel )
            end
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
            
            -- set generator fuel consumption values here
            if GeneratorFuelConsumption then
                luaObject.powerUsageGenerator = GeneratorFuelConsumption:getValue()
                if isoObject then
                    isoObject:getModData().powerUsageGenerator = luaObject.powerUsageGenerator
                    isoObject:transmitModData()
                end
            end
        end
        
    end
end

--
function SIndustrializationGlobalObjectSystem:refine(inputItems, outputItems)
    --self:noise('refine()')
    
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local isoObject = luaObject:getIsoObject()
        
        ----- ----- ----- -----
        if luaObject.isRefinery then 
            if not instanceof(isoObject, "IsoGenerator") then
                if luaObject.isOn then
                    if luaObject.container then
                        
                        if luaObject.container:getNumberOfItem(inputItems) > 0 then
                            -- REFINE ITEM
                            SIndustrializationGlobalObjectSystem.removeItemFromContainer(luaObject.container, inputItems, 1)
                            SIndustrializationGlobalObjectSystem.addItemToContainer(luaObject.container, outputItems, false)
                            self:noise(string.format('refining objects at %d, %d, %d', luaObject.x, luaObject.y, luaObject.z))
                        end
                        
                    end
                end
                
                if isoObject then -- object might have been destroyed
                    isoObject:transmitModData()
                end
                
            end
        end
        ----- ----- ----- -----
        
    end
end
--]]
-- Use up this object's fuel, only if it "isPowerSource".
function SIndustrializationGlobalObjectSystem:useFuel()
    --self:noise('useFuel()')
    
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local isoObject = luaObject:getIsoObject()
        
        ----- ----- ----- -----
        if luaObject.isPowerSource then 
            if not instanceof(isoObject, "IsoGenerator") then
                if luaObject.isOn and luaObject.fuel > 0 then
                    luaObject.fuel = luaObject.fuel - (1 * luaObject.fuelUsageGenerator)
                    
                    self:noise(string.format('removing fuel from object at %d, %d, %d | New Fuel=%.14f', luaObject.x, luaObject.y, luaObject.z, luaObject.fuel))
                    
                elseif luaObject.isOn and luaObject.fuel <= 0 then
                    luaObject.fuel = 0
                    luaObject.isOn = false
                end
                
                if isoObject then -- object might have been destroyed
                    isoObject:transmitModData()
                end
            else
                if luaObject.isOn and luaObject.fuel > 0 then
                    luaObject.fuel = luaObject.fuel - (luaObject.fuelUsageGenerator)
                    
                    self:noise(string.format('removing fuel from object at %d, %d, %d | New Fuel=%.14f', luaObject.x, luaObject.y, luaObject.z, luaObject.fuel))
                    
                elseif luaObject.isOn and luaObject.fuel <= 0 then
                    luaObject.fuel = 0
                    if luaObject.fuelUsageGenerator > 0 then luaObject.isOn = false end
                end
                
                if isoObject then -- object might have been destroyed
                    if not luaObject.isOn then isoObject:setActivated(false) end
                    isoObject:transmitModData()
                    --isoObject:transmitCompleteItemToClients()
                end
                
            end
        end
        ----- ----- ----- -----
        
    end
end

-- Call this to try and loot all luaObjects for this system's GlobalObjects. Only works if they each have a container.
function SIndustrializationGlobalObjectSystem:tryToLoot()
    --self:noise('tryToLoot()')
    --self:sendCommand("message", { message="SERVER: ".. string.format('tryToLoot') })
    
    ----- ----- ----- ----- ----- ----- ----- ----- 
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local isoObject = luaObject:getIsoObject()
        
        ----- ----- ----- ----- 
        if luaObject.isMiner then
            
            -- Check for power source.
            luaObject:findPower(false)
            
            if luaObject.isOn and luaObject.hasPower then 
                local square = luaObject:getSquare()
                if square then
                    luaObject.exterior = square:isOutside()
                end
                
                ----- ----- ----- -----
                -- Attempt to loot and store items into the luaObject's container if the object's container exists.
                if luaObject.container then
                    
                    -- Get the object's name, then get it's loot table using the name.
                    local objName
                    if isoObject then
                        objName = isoObject:getName()
                        if not objName then
                            objName = isoObject:getModData().name
                        end
                    end
                    if not objName then
                        objName = luaObject.name
                    end
                    
                    -- Check if objName is a valid String. 
                    -- Continue to the next LuaObject if and only if this object does not have a valid objName.
                    if objName and objName ~= "" then 
                        
                        --objName = string.gsub(objName, "Industrialization ", "") -- Remove "Industrialization" from the objName
                        objName = string.gsub(objName, "%s+", "") -- Remove all spaces from the objName
                        
                        -- Get the loot table using the valid objName
                        local lootTable = IndustrializationLootTables[ objName ]
                        
                        -- Try to loot some items using the loot table.
                        if lootTable then
                            for itemName, itemTable in pairs(lootTable) do
                                
                                local percentChance = itemTable[1]
                                local MAX_LOOT = itemTable[2]
                                local MIN_LOOT = itemTable[3]
                                
                                if itemName ~= "minLoot" and itemName ~= "maxLoot" then
                                    local roll = ZombRandFloat(0, 100)
                                    if roll < percentChance then
                                        
                                        -------------------------------------
                                        -- TRY TO ADD ITEM TO CONTAINER
                                        local randomAmount = ZombRand(MAX_LOOT + 1, MIN_LOOT)
                                        for i=1, randomAmount do
                                            SIndustrializationGlobalObjectSystem.addItemToContainer(luaObject.container, itemName, true)
                                        end
                                        -------------------------------------
                                        
                                        self:noise(string.format('found loot at (%.1f, %.1f, %.1f) loot=(itemName: %s, amount: %d)', luaObject.x, luaObject.y, luaObject.z, itemName, randomAmount))
                                        --self:sendCommand("message", { message="SERVER: ".. string.format('found loot at (%.1f, %.1f, %.1f) loot=(itemName: %s, amount: %d)', luaObject.x, luaObject.y, luaObject.z, itemName, randomAmount) })
                                        
                                        -- Send container's items to Clients.
                                        --[[if isServer() then 
                                            local isoObject = luaObject:getIsoObject()
                                            if isoObject then
                                                isoObject:sendObjectChange('containers')
                                                --isoObject:sendObjectChange('addItem', { item = kit } )
                                            end
                                        end--]]
                                        
                                        break;
                                    end
                                end
                                
                            end
                        end
                    end
                    
                end
                ----- ----- ----- -----
                
                if isoObject then -- object might have been destroyed
                    --self:noise('added loot to container at '..luaObject.x..","..luaObject.y..","..luaObject.z..' ')
                    --if luaObject.container then isoObject:setContainer(luaObject.container) end
                    isoObject:transmitModData()
                end
            end
        
        end
        ----- ----- ----- ----- 
        
    end
    ----- ----- ----- ----- ----- ----- ----- ----- 
    
end

function SIndustrializationGlobalObjectSystem.removeItemFromContainer(container, itemName, amount)
    local isoObject = container:getParent()
    local item = container:FindAndReturn(itemName)
    
    if not item or not isoObject then return end
    --local sq = isoObject:getSquare()
    --item = sq:AddWorldInventoryItem(item, sq:getX(), sq:getY(), sq:getZ(), false)
    if container:getNumberOfItem(itemName) > 0 then
        print("remove")
        container:Remove(item)
        --if isServer() then container:addItemOnServer(item) end
        --container:addItemsToProcessItems()
        if isServer() then 
            if isoObject then
                --isoObject:sendObjectChange('Remove', { item = item } )
                isoObject:sendObjectChange('Remove', { item = item } )
            end
        end
    end
end

function SIndustrializationGlobalObjectSystem.addItemToContainer(container, itemName, checkCapacity)
    local isoObject = container:getParent()
    local item = InventoryItemFactory.CreateItem(itemName)
    
    if not item or not isoObject then return end
    --local sq = isoObject:getSquare()
    --item = sq:AddWorldInventoryItem(item, sq:getX(), sq:getY(), sq:getZ(), false)
    if not checkCapacity or (item:getWeight() + container:getCapacityWeight() <= container:getCapacity()) then
        container:addItem(item)
        --if isServer() then container:addItemOnServer(item) end
        --container:addItemsToProcessItems()
        if isServer() then 
            if isoObject then
                isoObject:sendObjectChange('addItem', { item = item } )
            end
        end
    end
end

----- ----- ----- 

-- Register SIndustrializationGlobalObjectSystem
--SGlobalObjectSystem.RegisterSystemClass(SIndustrializationGlobalObjectSystem)

----- ----- ----- 

local noise = function(msg)
	SIndustrializationGlobalObjectSystem.instance:noise(msg)
end

--[[

-- Ticks.
local ticks = 0
local function OnTick()
    ticks = ticks + 1
    if ticks >= 48 then
        ticks = 0
        SIndustrializationGlobalObjectSystem.instance:sync()
    end
end
--Events.OnTick.Add(OnTick)

-- Every in-game hour, call this function using Events.EveryHours.
local function EveryHours()
    SIndustrializationGlobalObjectSystem.instance:sync()
	SIndustrializationGlobalObjectSystem.instance:useFuel()
    return
end
--Events.EveryHours.Add(EveryHours)

-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
    SIndustrializationGlobalObjectSystem.instance:sync()
	SIndustrializationGlobalObjectSystem.instance:tryToLoot()
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)

--]]

