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
    local cLuaObject = self.luaSystem:getLuaObjectOnSquare(self.object:getSquare())
    cLuaObject:updateFromIsoObject()
    
    local healthPercent = (self.object:getHealth() / self.object:getMaxHealth()) * 100
    
    local isOn = (cLuaObject and cLuaObject.isOn ~= nil)           and cLuaObject.isOn      or self.object:getModData().isOn
    --local hasPower = (cLuaObject and cLuaObject.hasPower ~= nil) and cLuaObject.hasPower  or self.object:getModData().hasPower
    --local isWired = (cLuaObject and cLuaObject.isWired ~= nil)   and cLuaObject.isWired   or self.object:getModData().isWired
    
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

function ISFixMachine:new(character, luaSystem, object, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
    o.luaSystem = luaSystem;
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time - (o.character:getPerkLevel(Perks.Electronics) * 3);
    o.caloriesModifier = 4;
	return o;
end
