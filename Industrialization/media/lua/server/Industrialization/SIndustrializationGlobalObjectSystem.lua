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

function SIndustrializationGlobalObjectSystem:useFuel()
    --self:noise('useFuel()')
    
    self:sync()
    
    -- Find all LuaObjects.
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local isoObject = luaObject:getIsoObject()
        
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
                                
                                    local randomAmount = ZombRand(MAX_LOOT + 1, MIN_LOOT)
                                    for i=1, randomAmount do
                                        --ItemPicker.tryAddItemToContainer(luaObject.container, itemName)
                                        local item = InventoryItemFactory.CreateItem(itemName)
                                        --local sq = luaObject:getSquare()
                                        --item = sq:AddWorldInventoryItem(item, sq:getX(), sq:getY(), sq:getZ(), false)
                                        if (item:getWeight() + luaObject.container:getCapacityWeight() <= luaObject.container:getCapacity()) then
                                            luaObject.container:addItem(item)
                                            --if isServer() then luaObject.container:addItemOnServer(item) end
                                            --luaObject.container:addItemsToProcessItems()
                                        end
                                    end
                                    
                                    --self:noise(string.format('found loot at (%.1f, %.1f, %.1f) loot=(itemName: %s, amount: %d)', luaObject.x, luaObject.y, luaObject.z, itemName, randomAmount))
                                    --local isClientServer = "isClient: "..tostring(isClient()) .. " || isServer: " .. tostring(isServer())
                                    --self:sendCommand("message", { message="SERVER: ".. string.format('found loot at (%.1f, %.1f, %.1f) loot=(itemName: %s, amount: %d) %s', luaObject.x, luaObject.y, luaObject.z, itemName, randomAmount, isClientServer) })
                                    
                                    -- Send container's items to Clients.
                                    if isServer() then 
                                        local isoObject = luaObject:getIsoObject()
                                        if isoObject then
                                            isoObject:sendObjectChange('containers')
                                        end
                                    end
                                    
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
    ----- ----- ----- ----- ----- ----- ----- ----- 
    
end

--[[
SIndustrializationGlobalObjectSystem = SGlobalObjectSystem:derive("SIndustrializationGlobalObjectSystem")

function SIndustrializationGlobalObjectSystem:noise(message)
	if self.wantNoise then print(self.systemName..': '..message) end
end

function SIndustrializationGlobalObjectSystem:new(name)
	-- Create the GlobalObjectSystem called NAME and load gos_NAME.bin if it exists.
	local system = SGlobalObjects.registerSystem(name)
	-- NOTE: The table for this Lua object is the same one the SIndustrializationGlobalObjectSystem
	-- Java object created.  The Java class calls some of this Lua object's methods.
	-- At this point, system:getModData() has already been read from disk if the
	-- gos_name.bin file existed.
	local o = system:getModData()
	setmetatable(o, self)
	self.__index = self
	o.system = system
	o.systemName = name
	o.wantNoise = getDebug()
	o:initSystem()
	o:initLuaObjects()
	o:noise('#objects='..system:getObjectCount())
	return o
end

function SIndustrializationGlobalObjectSystem:initSystem()
end

function SIndustrializationGlobalObjectSystem:getInitialStateForClient()
	-- Return a Lua table that is used to initialize the client-side system.
	-- This is called when a client connects in multiplayer, and after
	-- server-side systems are created in singleplayer.
	return nil
end

function SIndustrializationGlobalObjectSystem:getLuaObjectCount()
	return self.system:getObjectCount()
end

function SIndustrializationGlobalObjectSystem:getLuaObjectByIndex(index)
	return self.system:getObjectByIndex(index-1):getModData()
end

function SIndustrializationGlobalObjectSystem:initLuaObjects()
	for i=1,self.system:getObjectCount() do
		local globalObject = self.system:getObjectByIndex(i-1)
		local luaObject = self:newLuaObject(globalObject)
		self:noise('added luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
	end
end

function SIndustrializationGlobalObjectSystem:isValidIsoObject(isoObject)
	error "override this method"
end

function SIndustrializationGlobalObjectSystem:getIsoObjectOnSquare(square)
	if not square then return nil end
	for i=1,square:getObjects():size() do
		local isoObject = square:getObjects():get(i-1)
		if self:isValidIsoObject(isoObject) then
			return isoObject
		end
	end
	return nil
end

function SIndustrializationGlobalObjectSystem:getIsoObjectAt(x, y, z)
	local square = getCell():getGridSquare(x, y, z)
	return self:getIsoObjectOnSquare(square)
end

function SIndustrializationGlobalObjectSystem:newLuaObject(globalObject)
	-- Return an object derived from SGlobalObject
	error "override this method"
end

function SIndustrializationGlobalObjectSystem:newLuaObjectAt(x, y, z)
	local globalObject = self.system:newObject(x, y, z)
	return self:newLuaObject(globalObject)
end

function SIndustrializationGlobalObjectSystem:newLuaObjectOnSquare(square)
	return self:newLuaObjectAt(square:getX(), square:getY(), square:getZ())
end

function SIndustrializationGlobalObjectSystem:removeLuaObject(luaObject)
	if not luaObject or (luaObject.luaSystem ~= self) then return end
	self:noise('removing luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
	self.system:removeObject(luaObject.globalObject)
	self:noise('#objects='..self.system:getObjectCount())
end

function SIndustrializationGlobalObjectSystem:removeLuaObjectAt(x, y, z)
	local luaObject = self:getLuaObjectAt(x, y, z)
	self:removeLuaObject(luaObject)
end

function SIndustrializationGlobalObjectSystem:removeLuaObjectOnSquare(square)
	local luaObject = self:getLuaObjectOnSquare(square)
	self:removeLuaObject(luaObject)
end

function SIndustrializationGlobalObjectSystem:getLuaObjectAt(x, y, z)
	local globalObject = self.system:getObjectAt(x, y, z)
	return globalObject and globalObject:getModData() or nil
end

function SIndustrializationGlobalObjectSystem:getLuaObjectOnSquare(square)
	if not square then return nil end
	return self:getLuaObjectAt(square:getX(), square:getY(), square:getZ())
end

function SIndustrializationGlobalObjectSystem:loadIsoObject(isoObject)
	if not isoObject or not isoObject:getSquare() then return end
	if not self:isValidIsoObject(isoObject) then return end
	local square = isoObject:getSquare()
	local luaObject = self:getLuaObjectOnSquare(square)
	if luaObject then
		self:noise('found isoObject with a luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
		luaObject:stateToIsoObject(isoObject)
	else
		self:noise('found isoObject without a luaObject '..square:getX()..','..square:getY()..','..square:getZ())
		local globalObject = self.system:newObject(square:getX(), square:getY(), square:getZ())
		local luaObject = self:newLuaObject(globalObject)
		luaObject:stateFromIsoObject(isoObject)
		self:noise('#objects='..self.system:getObjectCount())
	end
end

function SIndustrializationGlobalObjectSystem:sendCommand(command, args)
	self.system:sendCommand(command, args)
end

function SIndustrializationGlobalObjectSystem:OnClientCommand(command, playerObj, args)
	-- CGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
end

function SIndustrializationGlobalObjectSystem:OnDestroyIsoThumpable(isoObject, playerObj)
	self:OnObjectAboutToBeRemoved(isoObject)
end

function SIndustrializationGlobalObjectSystem:OnObjectAdded(isoObject)
	if not self:isValidIsoObject(isoObject) then return end
	self:loadIsoObject(isoObject)
end

function SIndustrializationGlobalObjectSystem:OnObjectAboutToBeRemoved(isoObject)
	if not self:isValidIsoObject(isoObject) then return end
	local luaObject = self:getLuaObjectOnSquare(isoObject:getSquare())
	if not luaObject then return end
	self:removeLuaObject(luaObject)
end

-- Java calls this method when a chunk with GlobalObjects managed by this system is loaded.
-- This is how GlobalObjects with a missing IsoObject are removed.
-- Instead of using the LoadGridSquare event and checking every location,
-- this event is triggered only for chunks that have GlobalObjects belonging
-- to this particular system.
function SIndustrializationGlobalObjectSystem:OnChunkLoaded(wx, wy)
	local globalObjects = self.system:getObjectsInChunk(wx, wy)
	for i=1,globalObjects:size() do
		local globalObject = globalObjects:get(i-1)
		local square = getCell():getGridSquare(globalObject:getX(), globalObject:getY(), globalObject:getZ())
		local isoObject = self:getIsoObjectOnSquare(square)
		if not isoObject then
			self:noise('found luaObject without an isoObject')
			self:removeLuaObject(globalObject:getModData())
		end
	end
	-- This returns the ArrayList to a pool for reuse.  There's no harm if
	-- you forget to call it.
	self.system:finishedWithList(globalObjects)
end



local function OnDestroyIsoThumpable(luaClass, isoObject, playerObj)
	luaClass.instance:OnDestroyIsoThumpable(isoObject, playerObj)
end

local function OnObjectAdded(luaClass, isoObject)
	luaClass.instance:OnObjectAdded(isoObject)
end

local function OnObjectAboutToBeRemoved(luaClass, isoObject)
	luaClass.instance:OnObjectAboutToBeRemoved(isoObject)
end

local function OnGameBoot(luaClass)
	if not isServerSoftReset() then return end
	luaClass.instance = luaClass:new()
end

local function OnSIndustrializationGlobalObjectSystemInit(luaClass)
	luaClass.instance = luaClass:new()
end

local function OnClientCommand(module, command, player, args)
	if module ~= 'SFarmingSystem' then return end
	if Commands[command] then
		local argStr = ''
		for k,v in pairs(args) do argStr = argStr..' '..k..'='..v end
		noise('OnClientCommand '..module..' '..command..argStr)
		SFarmingSystem.instance:receiveCommand(player, command, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)

function SIndustrializationGlobalObjectSystem.RegisterSystemClass(luaClass)
	if luaClass == SIndustrializationGlobalObjectSystem then error "replace : with . before RegisterSystemClass" end

	-- This is to support reloading a derived class file in the Lua debugger.
	for i=1,SGlobalObjects.getSystemCount() do
		local system = SGlobalObjects.getSystemByIndex(i-1)
		if system:getModData().Type == luaClass.Type then
			luaClass.instance = system:getModData()
			return
		end
	end
	
	Events.OnDestroyIsoThumpable.Add(function(isoObject, playerObj) OnDestroyIsoThumpable(luaClass, isoObject, playerObj) end)
	Events.OnObjectAdded.Add(function(isoObject) OnObjectAdded(luaClass, isoObject) end)
	Events.OnObjectAboutToBeRemoved.Add(function(isoObject) OnObjectAboutToBeRemoved(luaClass, isoObject) end)
	Events.OnGameBoot.Add(function() OnGameBoot(luaClass) end)
	Events.OnSGlobalObjectSystemInit.Add(function() OnSIndustrializationGlobalObjectSystemInit(luaClass) end)
end
--]]
