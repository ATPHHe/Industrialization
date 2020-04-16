--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

--require "ISBaseObject"
require "Map/CGlobalObjectSystem"

CIndustrializationGlobalObjectSystem = CGlobalObjectSystem:derive("CIndustrializationGlobalObjectSystem")

--[[
function CIndustrializationGlobalObjectSystem:sendCommand(playerObj, command, args)
	self.system:sendCommand(command, playerObj, args)
end--]]

function CIndustrializationGlobalObjectSystem:OnServerCommand(command, args)
	-- SGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
    if command == "message" then
        self:noise(tostring(args.message))
        
    elseif command == "DoAudioToggleOnOff" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioToggleOnOff(args.UID) end
    elseif command == "DoAudioRunning" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioRunning(args.UID) end
    elseif command == "DoAudioStart" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioStart(args.UID) end
    elseif command == "DoAudioStop" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioStop(args.UID) end
    elseif command == "DoAudioForceStop" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then 
            cLuaObject:DoAudioForceStop(args.UID) 
        else 
            self:DoAudioForceStop(args.UID)
        end
    end
end


local AudioTable = CIndustrializationGlobalObject.AudioTable

-- Should be called when this object destroyed or non-existent.
-- The server will automatically attempt to call this via OnServerCommand when it sees that the machine does not exist anymore.
function CIndustrializationGlobalObjectSystem:DoAudioForceStop(UID)
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
    if AudioTable.audio2[UID] and AudioTable.audio2[UID]:isPlaying() then AudioTable.audio2[UID]:stop() end
    if AudioTable.audioToggle[UID] and AudioTable.audioToggle[UID]:isPlaying() then AudioTable.audioToggle[UID]:stop() end
    
    AudioTable.audio[UID] = nil
    AudioTable.audio2[UID] = nil
    AudioTable.audioToggle[UID] = nil
end


--[[
CIndustrializationGlobalObjectSystem = CGlobalObjectSystem:derive("CIndustrializationGlobalObjectSystem")

function CIndustrializationGlobalObjectSystem:noise(message)
	if self.wantNoise then print(self.systemName..': '..message) end
end

function CIndustrializationGlobalObjectSystem:new(name)
	local system = CGlobalObjects.registerSystem(name)
	-- NOTE: The table for this Lua object is the same one the CIndustrializationGlobalObjectSystem
	-- Java object created.  The Java class calls some of this Lua object's methods.
	local o = system:getModData()
	setmetatable(o, self)
	self.__index = self
	o.system = system
	o.systemName = name
	o.wantNoise = getDebug()
	o:initSystem()
	return o
end

function CIndustrializationGlobalObjectSystem:initSystem()
end

function CIndustrializationGlobalObjectSystem:isValidIsoObject(isoObject)
	error "override this method"
end

function CIndustrializationGlobalObjectSystem:getIsoObjectOnSquare(square)
	if not square then return nil end
	for i=1,square:getObjects():size() do
		local isoObject = square:getObjects():get(i-1)
		if self:isValidIsoObject(isoObject) then
			return isoObject
		end
	end
	return nil
end

function CIndustrializationGlobalObjectSystem:getIsoObjectAt(x, y, z)
	local square = getCell():getGridSquare(x, y, z)
	return self:getIsoObjectOnSquare(square)
end

function CIndustrializationGlobalObjectSystem:newLuaObject(isoObject)
	-- Return an object derived from CGlobalObject
	error "override this method"
end

function CIndustrializationGlobalObjectSystem:getLuaObjectAt(x, y, z)
	local isoObject = self:getIsoObjectAt(x, y, z)
	if not isoObject then return nil end
	-- The client doesn't have an SGlobalObjectSystem Java object, so create a
	-- new luaObject every time.
	return self:newLuaObject(isoObject)
end

function CIndustrializationGlobalObjectSystem:getLuaObjectOnSquare(square)
	if not square then return nil end
	return self:getLuaObjectAt(square:getX(), square:getY(), square:getZ())
end

function CIndustrializationGlobalObjectSystem:sendCommand(playerObj, command, args)
	self.system:sendCommand(command, playerObj, args)
end

function CIndustrializationGlobalObjectSystem:OnServerCommand(command, args)
	-- SGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
end

local function OnCIndustrializationGlobalObjectSystemInit(luaClass)
	luaClass.instance = luaClass:new()
end

function CIndustrializationGlobalObjectSystem.RegisterSystemClass(luaClass)
	if luaClass == CIndustrializationGlobalObjectSystem then error "replace : with . before RegisterSystemClass" end

	-- This is to support reloading a derived class file in the Lua debugger.
	for i=1,CGlobalObjects.getSystemCount() do
		local system = CGlobalObjects.getSystemByIndex(i-1)
		if system:getModData().Type == luaClass.Type then
			luaClass.instance = system:getModData()
			return
		end
	end

	Events.OnCGlobalObjectSystemInit.Add(function() OnCIndustrializationGlobalObjectSystemInit(luaClass) end)
end
--]]
