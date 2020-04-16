--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "TimedActions/ISBaseTimedAction"
require "ISUI/ISLayoutManager"

ISMachineInfoAction = ISBaseTimedAction:derive("ISMachineInfoAction")

function ISMachineInfoAction:isValid()
	return self.object:getObjectIndex() ~= -1
end

function ISMachineInfoAction:perform()
	local window = ISMachineInfoWindow.windows[self.character]
	if window then
		window:setObject(self.object)
	else
		local x = getPlayerScreenLeft(self.playerNum)
		local y = getPlayerScreenTop(self.playerNum)
		local w = getPlayerScreenWidth(self.playerNum)
		local h = getPlayerScreenHeight(self.playerNum)
		window = ISMachineInfoWindow:new(x + 70, y + 50, self.character, self.luaSystem, self.object)
		window:initialise()
		window:addToUIManager()
		ISMachineInfoWindow.windows[self.character] = window
		if self.character:getPlayerNum() == 0 then
			ISLayoutManager.RegisterWindow('machine', ISCollapsableWindow, window)
		end
	end
	window:setVisible(true)
	window:addToUIManager()
	local joypadData = JoypadState.players[self.playerNum+1]
	if joypadData then
		joypadData.focus = window
	end
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISMachineInfoAction:new(character, luaSystem, object)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.maxTime = 0
	o.stopOnWalk = true
	o.stopOnRun = true
	o.character = character
    o.luaSystem = luaSystem
	o.playerNum = character:getPlayerNum()
	o.object = object
	return o
end
