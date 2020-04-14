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
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
	if self.activate == luaObject.isOn then return false end
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
    
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
    
    local oX = self.object:getX()
    local oY = self.object:getY()
    local oZ = self.object:getZ()
    --local tempLuaObject = SSmallAutoMinerSystem.instance:getLuaObjectAt(oX, oY, oZ)
    --local tempObject = SSmallAutoMinerSystem.instance:getIsoObjectAt(oX, oY, oZ)
    
    -----
    
    luaObject.isOn = self.activate
    self.object:getModData().isOn = self.activate
    
    luaObject:DoAudioToggleOnOff()
    luaObject:findPower()
    
    --
    if luaObject.isOn and luaObject.hasPower then 
        luaObject:DoAudioStart()
        luaObject:DoAudioRunning()
    else
        if not luaObject.isOn and luaObject.hasPower then
            luaObject:DoAudioStop()
        end
    end
    --]]
    
    -- Transmit Mod Data
    if self.object then
        self.object:transmitModData()
    end
    
	--[[if self.activate and self.object:getCondition() <= 50 and ZombRand(2) == 0 then
		self.object:failToStart()
	else
		self.object:setActivated(self.activate)
	end]]

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISActivateMachine:new(character, object, activate, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(character);
	o.activate = activate;
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	if getCore():getDebug() then o.maxTime = 1; end
	return o;
end
