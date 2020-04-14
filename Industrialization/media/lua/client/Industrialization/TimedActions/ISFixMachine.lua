--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"

ISFixMachine = ISBaseTimedAction:derive("ISFixMachine");

function ISFixMachine:isValid()
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
    local healthPercent = (self.object:getHealth() / self.object:getMaxHealth()) * 100
    
    local isOn = (luaObject and luaObject.isOn ~= nil)         and luaObject.isOn      or self.object:getModData().isOn
    --local hasPower = (luaObject and luaObject.hasPower ~= nil) and luaObject.hasPower  or self.object:getModData().hasPower
    --local isWired = (luaObject and luaObject.isWired ~= nil)   and luaObject.isWired   or self.object:getModData().isWired
    
	return self.object:getObjectIndex() ~= -1 and
		not isOn and
		healthPercent < 100 and
		self.character:getInventory():contains("ElectronicsScrap")
end

function ISFixMachine:update()
	self.character:faceThisObject(self.object)
end

function ISFixMachine:start()
end

function ISFixMachine:stop()
    ISBaseTimedAction.stop(self);
end

function ISFixMachine:perform()
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
    
    local healthPercent = (self.object:getHealth() / self.object:getMaxHealth()) * 100
    local restoredHealthPercent = healthPercent + 4 + ( 1*(self.character:getPerkLevel(Perks.Electronics))/1 ) + ( 1*(self.character:getPerkLevel(Perks.MetalWelding))/1 )
    
    local restoredHealth = (restoredHealthPercent / 100) * self.object:getMaxHealth()
    self.object:setHealth( restoredHealth )
    if self.object:getHealth() > self.object:getMaxHealth() then
        self.object:setHealth( self.object:getMaxHealth() )
    end
    
    self.character:getInventory():RemoveOneOf("ElectronicsScrap");
    
    -- Transmit Mod Data
    if self.object then
        self.object:transmitModData()
    end
    
    if restoredHealth < 100 and self.character:getInventory():contains("ElectronicsScrap") then
        ISTimedActionQueue.add(ISFixMachine:new(self.character, self.object, 150));
    end
    
end

function ISFixMachine:new(character, object, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time - (o.character:getPerkLevel(Perks.Electronics) * 3);
    o.caloriesModifier = 4;
	return o;
end
