--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"

ISActivateMachine = ISBaseTimedAction:derive("ISActivateMachine");

function ISActivateMachine:isValid()
    local cLuaObject = self.luaSystem:getLuaObjectOnSquare(self.object:getSquare())
	if self.activate == cLuaObject.isOn then return false end
	--[[if self.activate and not self.object:isConnected() or
			self.object:getHealth() <= self.luaObject.criticalHealth then
        return false
	end]]
	return self.object:getObjectIndex() ~= -1
end

function ISActivateMachine:update()
	self.character:faceThisObject(self.object)
end

function ISActivateMachine:start()
    
end

function ISActivateMachine:stop()
    ISBaseTimedAction.stop(self);
end

function ISActivateMachine:perform()
    --local maxHealth = self.object:getMaxHealth()
    --local health = self.object:getHealth()
    
    local cLuaObject = self.luaSystem:getLuaObjectOnSquare(self.object:getSquare())
    
    local oX = self.object:getX()
    local oY = self.object:getY()
    local oZ = self.object:getZ()
    --local tempLuaObject = SSmallAutoMinerSystem.instance:getLuaObjectAt(oX, oY, oZ)
    --local tempObject = SSmallAutoMinerSystem.instance:getIsoObjectAt(oX, oY, oZ)
    
    -----
    
    cLuaObject.luaSystem:sendCommand(self.character, "set", { key="isOn", value=self.activate, x=oX, y=oY, z=oZ })
    cLuaObject.luaSystem:sendCommand(self.character, "findPower", { param1=true, x=oX, y=oY, z=oZ })

    --]]
    
	--[[if self.activate and self.object:getCondition() <= 50 and ZombRand(2) == 0 then
		self.object:failToStart()
	else
		self.object:setActivated(self.activate)
	end]]

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISActivateMachine:new(character, luaSystem, object, activate, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(character);
    o.luaSystem = luaSystem;
	o.activate = activate;
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	if getCore():getDebug() then o.maxTime = 1; end
	return o;
end
