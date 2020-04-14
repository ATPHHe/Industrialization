--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"

ISTakeMachine = ISBaseTimedAction:derive("ISTakeMachine");

function ISTakeMachine:isValid()
	return self.object:getObjectIndex() ~= -1 and
		not self.object:isConnected()
end

function ISTakeMachine:update()
	self.character:faceThisObject(self.object)
end

function ISTakeMachine:start()
end

function ISTakeMachine:stop()
    ISBaseTimedAction.stop(self);
end

function ISTakeMachine:perform()
    forceDropHeavyItems(self.character)
    local item = self.character:getInventory():AddItem("Base.Generator");
    item:setCondition(self.object:getCondition());
    self.character:setPrimaryHandItem(item);
    self.character:setSecondaryHandItem(item);
    if self.object:getFuel() > 0 then
        item:getModData()["fuel"] = self.object:getFuel();
    end
    self.character:getInventory():setDrawDirty(true);
    self.object:remove();

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISTakeMachine:new(character, object, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(character);
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	return o;
end
