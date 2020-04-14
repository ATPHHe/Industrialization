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
    local powerLuaObject = SPowerSourceSystem.instance:getLuaObjectOnSquare(self.generator:getSquare())
    if powerLuaObject then 
        powerLuaObject.fuel = self.generator:getFuel()
    end
    
    -- needed to remove from queue / start next.
	--ISBaseTimedAction.perform(self);
end


