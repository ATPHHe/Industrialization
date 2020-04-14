--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"

ISPlugMachine = ISBaseTimedAction:derive("ISPlugMachine");

function ISPlugMachine:isValid()
	return self.object:getObjectIndex() ~= -1 and
		self.object:isConnected() ~= self.plug
end

function ISPlugMachine:update()
	self.character:faceThisObject(self.object)
end

function ISPlugMachine:start()
end

function ISPlugMachine:stop()
    ISBaseTimedAction.stop(self);
end

function ISPlugMachine:perform()
    self.object:setConnected(self.plug);
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISPlugMachine:new(character, object, plug, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(character);
    o.plug = plug;
	o.object = object;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	if getCore():getDebug() then o.maxTime = 1; end
	return o;
end
