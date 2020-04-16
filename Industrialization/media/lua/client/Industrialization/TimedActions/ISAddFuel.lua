--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"

-- Modified
local original_ISAddFuel_perform = ISAddFuel.perform
function ISAddFuel:perform()
    original_ISAddFuel_perform(self)
    
    -- Sync generator fuel with powerLuaObject
    local generatorFuel = self.generator:getFuel()
    --self.generator:getModData().fuel = generatorFuel
    --self.generator:transmitModData()
    
    local sq = self.generator:getSquare()
    local x, y ,z = sq:getX(), sq:getY(), sq:getZ()
    CPowerSourceSystem.instance:sendCommand(self.character, "set", { key="fuel", value=generatorFuel, x=x, y=y, z=z })
    
    -- needed to remove from queue / start next.
	--ISBaseTimedAction.perform(self);
end


