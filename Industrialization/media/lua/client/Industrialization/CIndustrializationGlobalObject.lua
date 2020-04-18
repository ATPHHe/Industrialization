--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

--require "ISBaseObject"
require "Map/CGlobalObject"

CIndustrializationGlobalObject = CGlobalObject:derive("CIndustrializationGlobalObject")

function CIndustrializationGlobalObject:new(luaSystem, isoObject)
	local o = CGlobalObject.new(self, luaSystem, isoObject)
    
    -- Get Object's name
    o.name = isoObject:getName()
    isoObject:getModData().name = o.name
    if not o.name then
        o.name = isoObject:getObjectName()
        isoObject:getModData().name = o.name
    end
    
    -- Store audio names from "IndustrializationGlobalObjectAudio.lua" into this CGlobalObject.
    local objName = o.name
    objName = string.gsub(objName, "%s+", "") -- Remove all spaces from the objName
    
    if objName and objName ~= "" then
        for key, value in pairs( IndustrializationGlobalObjectAudio[ objName ] ) do
            o[key] = value
        end
    end
    
	return o
end

function CIndustrializationGlobalObject.createAudioTable()
    local audioTable = 
        {
            audio = {},
            audio2 = {},
            audioToggle = {},
        }
    return audioTable
end
CIndustrializationGlobalObject.AudioTable = CIndustrializationGlobalObject.createAudioTable()

local AudioTable = CIndustrializationGlobalObject.AudioTable

-- Should be called when this object is being toggled on or off.
-- The server will automatically attempt to call this via OnServerCommands when the client requests to turn off or on the machine.
function CIndustrializationGlobalObject:DoAudioToggleOnOff(UID)
    --self:noise('attempt to manage audio: DoAudioToggleOnOff at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if AudioTable.audioToggle[UID] and AudioTable.audioToggle[UID]:isPlaying() then AudioTable.audioToggle[UID]:stop() end
    
    -- TODO: replace switch sound with another sound
    AudioTable.audioToggle[UID] = getSoundManager():PlayWorldSound( self.audioToggle, false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object is spawned in to attempt to play it's running audio.
-- The server will automatically attempt to call this via OnServerCommand when the client requests that the machine should be running.
function CIndustrializationGlobalObject:DoAudioRunning(UID)
    --self:noise('attempt to manage audio: DoAudioRunning at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if self.isOn and self.hasPower then
        --self:noise('success: DoAudioRunning')
        if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
        AudioTable.audio[UID] = getSoundManager():PlayWorldSound( self.audioRunning, true, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is trying to be started.
-- The server will automatically attempt to call this via OnServerCommand when the client requests that the machine is starting or turned on.
function CIndustrializationGlobalObject:DoAudioStart(UID)
    --self:noise('attempt to manage audio: DoAudioStart at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if self.isOn and self.hasPower then
        if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
        if AudioTable.audio2[UID] and AudioTable.audio2[UID]:isPlaying() then AudioTable.audio2[UID]:stop() end
        
        -- TODO: replace generator sound with another sound
        --AudioTable.audio[UID] = getSoundManager():PlayWorldSound('SmallAutoMinerTryStart0', false, self:getSquare(), 0, 8, 1, false);
        AudioTable.audio2[UID] = getSoundManager():PlayWorldSound( self.audioStart, false, self:getSquare(), 0, 8, 1, false);
    end
end

-- Should be called when this object is being turned off.
-- The server will automatically attempt to call this via OnServerCommand when the client requests that the machine is stopping or turned off.
function CIndustrializationGlobalObject:DoAudioStop(UID)
    --self:noise('attempt to manage audio: DoAudioStop at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
    if AudioTable.audio2[UID] and AudioTable.audio2[UID]:isPlaying() then AudioTable.audio2[UID]:stop() end
    
    -- TODO: replace generator sound with another sound
    --AudioTable.audio[UID] = getSoundManager():PlayWorldSound('SmallAutoMinerTryStop0', false, self:getSquare(), 0, 8, 1, false);
    AudioTable.audio[UID] = getSoundManager():PlayWorldSound( self.audioStop, false, self:getSquare(), 0, 8, 1, false);
end

-- Should be called when this object destroyed or non-existent.
-- The server will automatically attempt to call this via OnServerCommand when it sees that the machine does not exist anymore.
function CIndustrializationGlobalObject:DoAudioForceStop(UID)
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
    if AudioTable.audio2[UID] and AudioTable.audio2[UID]:isPlaying() then AudioTable.audio2[UID]:stop() end
    if AudioTable.audioToggle[UID] and AudioTable.audioToggle[UID]:isPlaying() then AudioTable.audioToggle[UID]:stop() end
    
    AudioTable.audio[UID] = nil
    AudioTable.audio2[UID] = nil
    AudioTable.audioToggle[UID] = nil
end




