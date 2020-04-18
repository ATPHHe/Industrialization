--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

--require "ISBaseObject"
require "Map/CGlobalObjectSystem"

CIndustrializationGlobalObjectSystem = CGlobalObjectSystem:derive("CIndustrializationGlobalObjectSystem")



function CIndustrializationGlobalObjectSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, "IsoGenerator") then
        return true
    end
    
    local objectName = isoObject:getName()
    if not objectName or objectName == "" then return false end
    
    for k, v in pairs(IndustrializationGlobalObjectFields) do
        objectName = string.gsub(objectName, "%s+", "")
        
        if instanceof(isoObject, "IsoThumpable") and objectName == k then
            return true
        end
    end
    
	return false
end

--[[
function CIndustrializationGlobalObjectSystem:sendCommand(playerObj, command, args)
	self.system:sendCommand(command, playerObj, args)
end--]]

function CIndustrializationGlobalObjectSystem:OnServerCommand(command, args)
	-- SGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
    if command == "message" then
        self:noise(tostring(args.message))
        
    elseif command == "DoAudioToggleOnOff" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioToggleOnOff(args.UID) end
    elseif command == "DoAudioRunning" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioRunning(args.UID) end
    elseif command == "DoAudioStart" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioStart(args.UID) end
    elseif command == "DoAudioStop" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then cLuaObject:DoAudioStop(args.UID) end
    elseif command == "DoAudioForceStop" then
        local cLuaObject = self:getLuaObjectAt(args.x, args.y, args.z)
        if cLuaObject then 
            cLuaObject:DoAudioForceStop(args.UID) 
        else 
            self:DoAudioForceStop(args.UID)
        end
    end
end


local AudioTable = CIndustrializationGlobalObject.AudioTable

-- Should be called when this object destroyed or non-existent.
-- The server will automatically attempt to call this via OnServerCommand when it sees that the machine does not exist anymore.
function CIndustrializationGlobalObjectSystem:DoAudioForceStop(UID)
    --self:noise('attempt to manage audio: DoAudioForceStop at '..self.x..','..self.y..','..self.z)
    --self:updateFromIsoObject()
    
    if AudioTable.audio[UID] and AudioTable.audio[UID]:isPlaying() then AudioTable.audio[UID]:stop() end
    if AudioTable.audio2[UID] and AudioTable.audio2[UID]:isPlaying() then AudioTable.audio2[UID]:stop() end
    if AudioTable.audioToggle[UID] and AudioTable.audioToggle[UID]:isPlaying() then AudioTable.audioToggle[UID]:stop() end
    
    AudioTable.audio[UID] = nil
    AudioTable.audio2[UID] = nil
    AudioTable.audioToggle[UID] = nil
end

----- -----

-- Register CIndustrializationGlobalObjectSystem
--CGlobalObjectSystem.RegisterSystemClass(CIndustrializationGlobalObjectSystem)

----- -----

function CIndustrializationGlobalObjectSystem.DoSpecialTooltip(tooltipUI, square)
    DoSpecialTooltip2(tooltipUI, square, CIndustrializationGlobalObjectSystem.instance)
end

function CIndustrializationGlobalObjectSystem.DoSpecialTooltip2(tooltipUI, square, luaSystem)
	local playerObj = getSpecificPlayer(0)
	if not playerObj or playerObj:getZ() ~= square:getZ() or
			playerObj:DistToSquared(square:getX() + 0.5, square:getY() + 0.5) > 2 * 2 then
		return
	end
	
    -----
    
    --local luaSystem = CIndustrializationGlobalObjectSystem.instance
    local isoObject = luaSystem:getIsoObjectOnSquare(square)
	if not isoObject then return end
    local cLuaObject = luaSystem:getLuaObjectOnSquare(square)
    if not cLuaObject then return end
    
    -----
    
    local objName = isoObject:getName()
    local translation = ""
    if objName and objName ~= "" then
        translation = string.gsub(objName, "Industrialization ", "Industrialization_")
        translation = string.gsub(translation, "%s+", "")
        translation = getText("ContextMenu_"..translation)
    end

	--
    local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	tooltipUI:setHeight(6 + smallFontHgt + 6 + smallFontHgt + 12 + 12 + 12)

	local textX = 12
	local textY = 6 + smallFontHgt + 6

	local barX = textX + getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpanel_Remaining")) + 12 + 6
	local barWid = 80
	local barHgt = 4
	local barY = textY + (smallFontHgt - barHgt) / 2 + 2
    
	tooltipUI:setWidth(barX + barWid + 12)
	tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
	tooltipUI:DrawTextCentre( translation , tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
    
    local health, maxHealth, healthPercent, isOn, hasPower, isWired
    
    if cLuaObject then
        cLuaObject:updateFromIsoObject()
        
        health = (cLuaObject and cLuaObject.health ~= nil)          and cLuaObject.health    or isoObject:getModData().health
        maxHealth = (cLuaObject and cLuaObject.maxHealth ~= nil)    and cLuaObject.maxHealth or isoObject:getModData().maxHealth
        healthPercent = (health and maxHealth) and (health / maxHealth) * 100 or 0 --(isoObject:getHealth() / isoObject:getMaxHealth()) * 100
        isOn = (cLuaObject and cLuaObject.isOn ~= nil)              and cLuaObject.isOn      or isoObject:getModData().isOn
        hasPower = (cLuaObject and cLuaObject.hasPower ~= nil)      and cLuaObject.hasPower  or isoObject:getModData().hasPower
        isWired = (cLuaObject and cLuaObject.isWired ~= nil)        and cLuaObject.isWired   or isoObject:getModData().isWired
    end
    
    -----
    local healthText = ""
    if healthPercent < 100 then
        healthText = tostring(health).." / "..tostring(maxHealth)
    elseif 100 <= healthPercent then
        healthText = tostring(health).." / "..tostring(maxHealth)
    end
    
    local isOnText = isOn and           ""..tostring(isOn).."" or     ""..tostring(isOn)..""
    local hasPowerText = hasPower and   ""..tostring(hasPower).."" or ""..tostring(hasPower)..""
    local isWiredText = isWired and     ""..tostring(isWired).."" or  ""..tostring(isWired)..""
    
    tooltipUI:DrawText(getText("IGUI_Industrialization_HealthPercent", string.format("%.0f", healthPercent)) , textX, textY, 1, 1, 1, 1)
    --tooltipUI:DrawText(getText("IGUI_Industrialization_Health", healthText) , textX, textY, 1, 1, 1, 1)
    textY = textY + smallFontHgt;
    tooltipUI:DrawText(getText("IGUI_Industrialization_isOn", isOnText) , textX, textY, 1, 1, 1, 1)
    textY = textY + smallFontHgt;
    tooltipUI:DrawText(getText("IGUI_Industrialization_hasPower", hasPowerText) , textX, textY, 1, 1, 1, 1)
    --text = text .. " <LINE> " .. getText("IGUI_Industrialization_isWired", isWiredText)
    
	local f = health / maxHealth
	
	if f < 0.0 then f = 0.0 end
	if f > 1.0 then f = 1.0 end
    local fg = { r= f >= 1.0 and 0.0 or 1.0 , g= f >= 1.0 and 0.6 or f, b=0.0, a=0.7 }
    
	local done = math.floor(barWid * f)
	if f > 0 then done = math.max(done, 1) end
	tooltipUI:DrawTextureScaledColor(nil, barX, barY, done, barHgt, fg.r, fg.g, fg.b, fg.a)
	local bg = {r=0.15, g=0.15, b=0.15, a=1.0}
	tooltipUI:DrawTextureScaledColor(nil, barX + done, barY, barWid - done, barHgt, bg.r, bg.g, bg.b, bg.a)
    -----
    
    --]]
    
	--[[
    tooltipUI:DrawText(getText("IGUI_invpanel_Remaining") .. ":", textX, textY, 1, 1, 1, 1)

	local f = isoObject:getWaterAmount() / isoObject:getModData()["waterMax"]
	local fg = { r=0.0, g=0.6, b=0.0, a=0.7 }
	if f < 0.0 then f = 0.0 end
	if f > 1.0 then f = 1.0 end
	local done = math.floor(barWid * f)
	if f > 0 then done = math.max(done, 1) end
	tooltipUI:DrawTextureScaledColor(nil, barX, barY, done, barHgt, fg.r, fg.g, fg.b, fg.a)
	local bg = {r=0.15, g=0.15, b=0.15, a=1.0}
	tooltipUI:DrawTextureScaledColor(nil, barX + done, barY, barWid - done, barHgt, bg.r, bg.g, bg.b, bg.a)
    --]]
end

--Events.DoSpecialTooltip.Add(DoSpecialTooltip)


-- Every in-game ten minutes, call this function using Events.EveryTenMinutes.
local function EveryTenMinutes()
    CIndustrializationGlobalObjectSystem.instance:sendCommand(getPlayer(), "ping", {})
    return
end
--Events.EveryTenMinutes.Add(EveryTenMinutes)




