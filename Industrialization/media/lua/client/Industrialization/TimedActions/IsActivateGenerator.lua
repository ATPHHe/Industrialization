--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"


-- Modified "ISActivateGenerator" function to allow for machines to be updated when the generator is turned off or on.
local original_ISActivateGenerator_perform = ISActivateGenerator.perform
function ISActivateGenerator:perform()
	original_ISActivateGenerator_perform(self)
    
    -- Power on other machines nearby.
    local isActivated = self.generator:isActivated()
    
    local x, y, z = self.generator:getX(), self.generator:getY(), self.generator:getZ()
    local sq = getWorld():getCell():getOrCreateGridSquare(x, y, z)
    local powerLuaObject = SPowerSourceSystem.instance:getLuaObjectAt(x, y, z)
    if powerLuaObject then 
        powerLuaObject.isOn = isActivated 
    end
    self.generator:getModData().isOn = isActivated
    
    for x1 = x-1, x+1 do
        for y1 = y-1, y+1 do
            local sq = getWorld():getCell():getOrCreateGridSquare(x1, y1, z)
            local luaObjects = 
                {
                    [1] = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(sq),
                }
            
            for k, luaObject in pairs(luaObjects) do
                local isoObject
                
                --local objects = sq:getObjects()
                if not luaObject then
                    local specialObjects = sq:getSpecialObjects()
                    for i=0, specialObjects:size()-1 do
                        local v = specialObjects:get(i)
                        if v:getName() == IsoSmallAutoMiner.FULL_NAME then
                            isoObject = v;
                        end
                    end
                end
                
                if luaObject then
                    isoObject = luaObject:getIsoObject()
                    
                    luaObject.hasPower = isActivated
                    
                    -- Do Audio if possible
                    if luaObject.isOn and not luaObject.isRunning and luaObject.hasPower then
                        luaObject.isRunning = true
                        luaObject:DoAudioStart()
                        luaObject:DoAudioRunning()
                    end
                    
                    if luaObject.isRunning and not luaObject.hasPower then
                        luaObject.isRunning = false
                        luaObject:DoAudioStop()
                    end
                end
                
                if isoObject then
                    isoObject:getModData().hasPower = self.activate
                    isoObject:transmitModData()
                end
                
            end
        end
    end
    
    -- needed to remove from queue / start next.
	--ISBaseTimedAction.perform(self);
end


