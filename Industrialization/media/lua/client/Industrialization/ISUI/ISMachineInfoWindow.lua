--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "ISUI/ISCollapsableWindow"

ISMachineInfoWindow = ISCollapsableWindow:derive("ISMachineInfoWindow")
ISMachineInfoWindow.windows = {}

function ISMachineInfoWindow:createChildren()
	ISCollapsableWindow.createChildren(self)
	self.panel = ISToolTip:new()
	self.panel.followMouse = false
	self.panel:initialise()
	self:setObject(self.object)
	self:addView(self.panel)
end

function ISMachineInfoWindow:update()
	ISCollapsableWindow.update(self)

	if self:getIsVisible() and (not self.object or self.object:getObjectIndex() == -1) then
		if self.joyfocus then
			self.joyfocus.focus = nil
			updateJoypadFocus(self.joyfocus)
		end
		self:removeFromUIManager()
		return
	end
    
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
    
	if self.healthPercent ~= (self.object:getHealth() / self.object:getMaxHealth()) * 100
            or self.isOn ~= luaObject.isOn 
            or self.hasPower ~= luaObject.hasPower
            or self.isWired ~= luaObject.isWired then
		self:setObject(self.object)
	end
	self:setWidth(self.panel:getWidth())
	self:setHeight(self:titleBarHeight() + self.panel:getHeight())
end

local DEFAULT_STATS = 
    {
        ["exterior"] = false,
        ["isOn"] = false,
        ["hasPower"] = false,
        ["isWired"] = false,
        ["powerUsage"] = 2,
        ["minPowerUsage"] = 1,
        ["maxPowerUsage"] = 4,
        ["container"] = nil,
    }

function ISMachineInfoWindow:setObject(object)
    
	self.object = object
    
    -- get object's translation name
    local panelName = object:getName()
    panelName = string.gsub(panelName, "Industrialization ", "Industrialization_")
    panelName = "ContextMenu_" .. string.gsub(panelName, "%s+", "")
    panelName = getText(panelName)
    
	self.panel:setName( panelName )
	self.panel:setTexture(object:getTextureName())
    
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
    
    self.isOn = (luaObject and luaObject.isOn ~= nil)         and luaObject.isOn      or object:getModData().isOn
    self.hasPower = (luaObject and luaObject.hasPower ~= nil) and luaObject.hasPower  or object:getModData().hasPower
    self.isWired = (luaObject and luaObject.isWired ~= nil)   and luaObject.isWired   or object:getModData().isWired
    
	self.panel.description = ISMachineInfoWindow.getRichText(object, true)
end

function ISMachineInfoWindow.getRichText(object, displayStats)
	local square = object:getSquare()
    
	if not displayStats then
		local text = ""
		if square and not square:isOutside() and square:getBuilding() then
			--text = text .. " <RED> " .. getText("IGUI_Industrialization_IsToxic")
		end
		return text
	end
    
    local luaObject = SSmallAutoMinerSystem.instance:getLuaObjectOnSquare(square)
    
    local healthPercent = (object:getHealth() / object:getMaxHealth()) * 100
	local isOn = (luaObject and luaObject.isOn ~= nil)         and luaObject.isOn      or object:getModData().isOn
    local hasPower = (luaObject and luaObject.hasPower ~= nil) and luaObject.hasPower  or object:getModData().hasPower
    local isWired = (luaObject and luaObject.isWired ~= nil)   and luaObject.isWired   or object:getModData().isWired
    
    -----
    local healthText = ""
    if healthPercent < 100 then
        healthText = " <RGB:1,"..(healthPercent/100)..",0> "..tostring(object:getHealth()).."  <RGB:1,1,1>  / "..tostring(object:getMaxHealth())
    elseif 100 <= healthPercent then
        healthText = " <GREEN> "..tostring(object:getHealth()).."  <RGB:1,1,1>  / "..tostring(object:getMaxHealth())
    end
    
    local isOnText = isOn and           " <GREEN> "..tostring(isOn).." <RGB:1,1,1> " or     " <RED> "..tostring(isOn).." <RGB:1,1,1> "
    local hasPowerText = hasPower and   " <GREEN> "..tostring(hasPower).." <RGB:1,1,1> " or " <RED> "..tostring(hasPower).." <RGB:1,1,1> "
    local isWiredText = isWired and     " <GREEN> "..tostring(isWired).." <RGB:1,1,1> " or  " <RED> "..tostring(isWired).." <RGB:1,1,1> "
    
	local text = ""
    --text = text .. getText("IGUI_Industrialization_HealthPercent", string.format("%.1f", healthPercent)) 
    text = text .. getText("IGUI_Industrialization_Health", healthText) 
    text = text .. " <LINE> " .. getText("IGUI_Industrialization_isOn", isOnText)
    text = text .. " <LINE> " .. getText("IGUI_Industrialization_hasPower", hasPowerText)
    --text = text .. " <LINE> " .. getText("IGUI_Industrialization_isWired", isWiredText)
    text = text .. " <LINE> "
    if healthPercent < 100 then 
        text = text .. " <LINE> <RED> " .. getText("IGUI_Industrialization_MachineNeedRepair") .. " <RGB:1,1,1> "
        text = text .. " <LINE> "
        text = text .. " <LINE> "
    end
    
    -----
    
	if square and not square:isOutside() and square:getBuilding() then
		--text = text .. " <LINE> <RED> " .. getText("IGUI_Industrialization_isToxic")
	end
	return text
end

function ISMachineInfoWindow:onGainJoypadFocus(joypadData)
	self.drawJoypadFocus = true
end

function ISMachineInfoWindow:onJoypadDown(button)
	if button == Joypad.BButton then
		self:removeFromUIManager()
		setJoypadFocus(self.playerNum, nil)
	end
end

function ISMachineInfoWindow:close()
	self:removeFromUIManager()
end

function ISMachineInfoWindow:new(x, y, character, object)
	local width = 320
	local height = 16 + 64 + 16 + 16 + 16 + 16
	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.playerNum = character:getPlayerNum()
	o.object = object
	o:setResizable(false)
	return o
end
