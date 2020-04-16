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
    
    local cLuaObject = self.luaSystem:getLuaObjectOnSquare(self.object:getSquare())
    if cLuaObject then
        cLuaObject:updateFromIsoObject()
        
        --for k, v in pairs(cLuaObject) do
        --    print("k=".. tostring(k) .. " v=" .. tostring(v))
        --end
        
        if self.health ~= cLuaObject.health
                or self.maxHealth ~= cLuaObject.maxHealth
                or self.isOn ~= cLuaObject.isOn 
                or self.hasPower ~= cLuaObject.hasPower
                or self.isWired ~= cLuaObject.isWired then
            self:setObject(self.object)
        end
        
        self:setWidth(self.panel:getWidth())
        self:setHeight(self:titleBarHeight() + self.panel:getHeight())
    end
end

function ISMachineInfoWindow:setObject(object)
    
	self.object = object
    
    -- get object's translation name
    local objName = object:getName()
    local objName2 = string.gsub(objName, "Industrialization ", "Industrialization_")
    local translation = "ContextMenu_" .. string.gsub(objName2, "%s+", "")
    local translationName = getText(translation)
    
	self.panel:setName( translationName )
	self.panel:setTexture(object:getTextureName())
    
    local cLuaObject = self.luaSystem:getLuaObjectOnSquare(self.object:getSquare())
    if cLuaObject then
        cLuaObject:updateFromIsoObject()
        
        self.health = (cLuaObject and cLuaObject.health ~= nil)         and cLuaObject.health    or object:getModData().health
        self.maxHealth = (cLuaObject and cLuaObject.maxHealth ~= nil)   and cLuaObject.maxHealth or object:getModData().maxHealth
        self.healthPercent = (health and maxHealth) and (self.health / self.maxHealth) * 100 or 0 --(object:getHealth() / object:getMaxHealth()) * 100
        self.isOn = (cLuaObject and cLuaObject.isOn ~= nil)             and cLuaObject.isOn      or object:getModData().isOn
        self.hasPower = (cLuaObject and cLuaObject.hasPower ~= nil)     and cLuaObject.hasPower  or object:getModData().hasPower
        self.isWired = (cLuaObject and cLuaObject.isWired ~= nil)       and cLuaObject.isWired   or object:getModData().isWired
        
        self.panel.description = ISMachineInfoWindow.getRichText(object, true, self.luaSystem)
    end
end

function ISMachineInfoWindow.getRichText(object, displayStats, luaSystem)
	local square = object:getSquare()
    
	if not displayStats then
		local text = ""
		if square and not square:isOutside() and square:getBuilding() then
			--text = text .. " <RED> " .. getText("IGUI_Industrialization_IsToxic")
		end
		return text
	end
    
    local health, maxHealth, healthPercent, isOn, hasPower, isWired
    
    local cLuaObject = luaSystem:getLuaObjectOnSquare(square)
    if cLuaObject then
        cLuaObject:updateFromIsoObject()
        
        health = (cLuaObject and cLuaObject.health ~= nil)          and cLuaObject.health    or object:getModData().health
        maxHealth = (cLuaObject and cLuaObject.maxHealth ~= nil)    and cLuaObject.maxHealth or object:getModData().maxHealth
        healthPercent = (health and maxHealth) and (health / maxHealth) * 100 or 0 --(object:getHealth() / object:getMaxHealth()) * 100
        isOn = (cLuaObject and cLuaObject.isOn ~= nil)              and cLuaObject.isOn      or object:getModData().isOn
        hasPower = (cLuaObject and cLuaObject.hasPower ~= nil)      and cLuaObject.hasPower  or object:getModData().hasPower
        isWired = (cLuaObject and cLuaObject.isWired ~= nil)        and cLuaObject.isWired   or object:getModData().isWired
    end
    
    -----
    local healthText = ""
    if healthPercent < 100 then
        healthText = " <RGB:1,"..(healthPercent/100)..",0> "..tostring(health).."  <RGB:1,1,1>  / "..tostring(maxHealth)
    elseif 100 <= healthPercent then
        healthText = " <GREEN> "..tostring(health).."  <RGB:1,1,1>  / "..tostring(maxHealth)
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

function ISMachineInfoWindow:new(x, y, character, luaSystem, object)
	local width = 320
	local height = 16 + 64 + 16 + 16 + 16 + 16
	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.character = character
    o.luaSystem = luaSystem
	o.playerNum = character:getPlayerNum()
	o.object = object
	o:setResizable(false)
	return o
end
