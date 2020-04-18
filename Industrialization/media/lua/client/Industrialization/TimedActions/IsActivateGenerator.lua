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
    local cLuaObject = CPowerSourceSystem.instance:getLuaObjectAt(x, y, z)
    
    if cLuaObject then 
        cLuaObject:updateFromIsoObject()
        cLuaObject.luaSystem:sendCommand(self.character, "set", { key="isOn", value=isActivated, x=x, y=y, z=z })
    end
    
    --[[
    for x1 = x-1, x+1 do
        for y1 = y-1, y+1 do
            local sq = getWorld():getCell():getOrCreateGridSquare(x1, y1, z)
            local cLuaObjects = 
                {
                    SPowerSourceSystem.instance:getLuaObjectOnSquare(sq),
                }
            
            for k, cLuaObject in pairs(cLuaObjects) do
                local cIsoObject
                
                --local objects = sq:getObjects()
                if not cLuaObject then
                    local specialObjects = sq:getSpecialObjects()
                    for i=0, specialObjects:size()-1 do
                        local v = specialObjects:get(i)
                        if v:getName() == IsoSmallAutoMiner.FULL_NAME then
                            cIsoObject = v;
                        end
                    end
                end
                
                if cLuaObject then
                    cLuaObject:updateFromIsoObject()
                    
                    cIsoObject = cLuaObject:getIsoObject()
                    
                    cLuaObject.luaSystem:sendCommand(self.character, "set", { key = "hasPower", value=isActivated, x=x1, y=y1, z=z})
                    cLuaObject.luaSystem:sendCommand(self.character, "findPower", { param1=true, x=x1, y=y1, z=z })
                end
                
                if cIsoObject then
                    cIsoObject:getModData().hasPower = self.activate
                    cIsoObject:transmitModData()
                end
                
            end
        end
    end
    --]]
    
    -- needed to remove from queue / start next.
	--ISBaseTimedAction.perform(self);
end


