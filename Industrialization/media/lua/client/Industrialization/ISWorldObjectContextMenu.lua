--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\client\ISUI\ISWorldObjectContextMenu.lua" as reference.
--*****************************
--


--ISWorldObjectContextMenu = {}
--ISWorldObjectContextMenu.fetchSquares = {}

local original_clearFetch = ISWorldObjectContextMenu.clearFetch
ISWorldObjectContextMenu.clearFetch = function()
    
    -- call original function
    original_clearFetch()
    
    ---------------------------------
    -- write modified function here
    industrializationObjects = {}
    
    ---------------------------------
end

local original_fetch = ISWorldObjectContextMenu.fetch
ISWorldObjectContextMenu.fetch = function(v, player, doSquare)

    ---------------------------------
    -- write modified function here
    --local playerObj = getSpecificPlayer(player)
	--local playerInv = playerObj:getInventory()
    --local square = v:getSquare()
    
    if v:getModData().MOD_ID == IndustrializationUtilities.MOD_ID then
        industrializationObjects[tostring(v:getModData().UID)] = v
    end
    ---------------------------------
    
    -- call original function
    original_fetch(v, player, doSquare)
    
end

local function createMenu(player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(player)
	local playerInv = playerObj:getInventory()
    
    -- SmallAutoMiner interaction
    if industrializationObjects and type(industrializationObjects) == "table" then
        
        for _, v in pairs(industrializationObjects) do
            if test == true then return true; end
            
            local cLuaSystem
            local cLuaObject
            
            local cLuaSystems = GlobalObjectSystems.getCObjectSystems()
            
            for k, system in pairs(cLuaSystems) do
                cLuaSystem = system
                cLuaObject = system:getLuaObjectOnSquare(v:getSquare())
                if cLuaSystem and cLuaObject then break end;
            end
            
            if cLuaSystem and not instanceof(v, "IsoGenerator") then
                
                if cLuaObject then
                    cLuaObject:updateFromIsoObject()
                    
                    --local healthPercent = (object:getHealth() / object:getMaxHealth()) * 100
                    local isOn = (cLuaObject and cLuaObject.isOn ~= nil)           and cLuaObject.isOn      or v:getModData().isOn
                    --local hasPower = (cLuaObject and cLuaObject.hasPower ~= nil) and cLuaObject.hasPower  or v:getModData().hasPower
                    --local isWired = (cLuaObject and cLuaObject.isWired ~= nil)   and cLuaObject.isWired   or v:getModData().isWired
                    
                    -- Get object's name translation.
                    local objName = v:getName()
                    local translation = ""
                    if objName and objName ~= "" then
                        translation = string.gsub(objName, "Industrialization", "Industrialization_")
                        translation = string.gsub(translation, "%s+", "")
                        translation = getText( "ContextMenu_"..translation )
                    end
                    
                    -- Info Window context options.
                    local option = context:addOption( translation .. " " ..getText("ContextMenu_Info"), 
                                                        worldobjects, ISWorldObjectContextMenu.onInfoMachine, v, player, cLuaSystem);
                    
                    -- Get rich text tooltip when context is hovered over with mouse
                    if playerObj:DistToSquared(v:getX() + 0.5, v:getY() + 0.5) < 2 * 2 then
                        local tooltip = ISWorldObjectContextMenu.addToolTip()
                        tooltip:setName( translation )
                        tooltip.description = ISMachineInfoWindow.getRichText(v, true, cLuaSystem)
                        option.toolTip = tooltip
                    end
                    
                    -- Turn on / off machine context options
                    if cLuaObject.isMiner or cLuaObject.isRefinery then
                        if isOn then
                            context:addOption(getText("ContextMenu_Turn_Off"), worldobjects, ISWorldObjectContextMenu.onActivateMachine, false, v, player, cLuaSystem);
                        else
                            context:addOption(getText("ContextMenu_Turn_On"), worldobjects, ISWorldObjectContextMenu.onActivateMachine, true, v, player, cLuaSystem);
                        end
                    end
                    
                    -- Fix Machine context options.
                    if not isOn and v:getHealth() < v:getMaxHealth() then
                            
                        local option = context:addOption(getText("ContextMenu_Industrialization_Repair").. " " ..getText("ContextMenu_Industrialization_SmallAutoMiner"), 
                                                        worldobjects, ISWorldObjectContextMenu.onFixMachine, v, player, cLuaSystem);
                        if not playerObj:getInventory():contains("ElectronicsScrap") then
                            local tooltip = ISWorldObjectContextMenu.addToolTip();
                            option.notAvailable = true;
                            tooltip.description = getText("ContextMenu_GeneratorFixTT");
                            option.toolTip = tooltip;
                        end
                    end
                    
                    -- Refinery context options.
                    
                end
            end
            
        end
        
    end
    
    --if generator then
    --    print("FUEL: "..generator:getFuel())
    --end
end
Events.OnPreFillWorldObjectContextMenu.Add(createMenu)

--[[local original_isSomethingTo = ISWorldObjectContextMenu.isSomethingTo
ISWorldObjectContextMenu.isSomethingTo = function(item, player)

    -- call original function
    local isSomethingTo = original_isSomethingTo(item, player)
    
    ---------------------------------
    -- write modified function here
    
    return isSomethingTo
    ---------------------------------
    
end]]

-- This is for controller users.  Functions bound to OnFillWorldObjectContextMenu should
-- call this if they have any commands to add to the context menu, but only when the 'test'
-- argument to those functions is true.
--[[function ISWorldObjectContextMenu.setTest()
	ISWorldObjectContextMenu.Test = true
	return true
end]]

-- MAIN METHOD FOR CREATING RIGHT CLICK CONTEXT MENU FOR WORLD ITEMS
--[[local original_createMenu = ISWorldObjectContextMenu.createMenu
ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    
    -- call original function
    local value = original_createMenu(player, worldobjects, x, y, test)
    
    ---------------------------------
    -- write modified function here
    
    return value;
    ---------------------------------
end]]

-- Pour water from an item in inventory into an IsoObject
--[[function ISWorldObjectContextMenu.addWaterFromItem(test, context, worldobjects, playerObj, playerInv)
	local pourWaterInto = rainCollectorBarrel -- TODO: other IsoObjects too?
	if pourWaterInto and tonumber(pourWaterInto:getModData().waterMax) and
			pourWaterInto:getWaterAmount() < pourWaterInto:getModData().waterMax then
		local pourOut = {}
		for i = 1,playerInv:getItems():size() do
			local item = playerInv:getItems():get(i-1)
			if item:canStoreWater() and item:isWaterSource() then
				table.insert(pourOut, item)
			end
		end
		if #pourOut > 0 then
			if test then return true end
			local subMenuOption = context:addOption(getText("ContextMenu_AddWaterFromItem"), worldobjects, nil);
			local subMenu = context:getNew(context)
			context:addSubMenu(subMenuOption, subMenu)
			for _,item in ipairs(pourOut) do
				subMenu:addOption(item:getName(), worldobjects, ISWorldObjectContextMenu.onAddWaterFromItem, pourWaterInto, item, playerObj);
			end
		end
	end
	return false
end
--]]
ISWorldObjectContextMenu.onInfoMachine = function(worldobjects, machine, player, luaSystem)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISMachineInfoAction:new(playerObj, luaSystem, machine))
	end
end

--[[ISWorldObjectContextMenu.onPlugMachine = function(worldobjects, machine, player, plug)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISPlugMachine:new(player, machine, plug, 300));
	end
end]]

ISWorldObjectContextMenu.onActivateMachine = function(worldobjects, enable, machine, player, luaSystem)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISActivateMachine:new(player, luaSystem, machine, enable, 30));
	end
end

ISWorldObjectContextMenu.onFixMachine = function(worldobjects, machine, player, luaSystem)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISFixMachine:new(getSpecificPlayer(player), luaSystem, machine, 150));
	end
end

--[[ISWorldObjectContextMenu.onAddFuelToMachine = function(worldobjects, petrolCan, machine, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISAddFuel:new(player, machine, petrolCan, 70 + (petrolCan:getUsedDelta() * 40)));
	end
end

ISWorldObjectContextMenu.onTakeMachine = function(worldobjects, machine, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, machine:getSquare()) then
		ISTimedActionQueue.add(ISTakeMachine:new(player, machine, 100));
	end
end]]

-- maps object:getName() -> translated label
--[[local ThumpableNameToLabel = {
	["Industrialization Small Auto Miner"] = "ContextMenu_Industrialization_SmallAutoMiner",
}]]
--[[
function ISWorldObjectContextMenu.getThumpableName(thump)
	if ThumpableNameToLabel[thump:getName()] then
		return getText(ThumpableNameToLabel[thump:getName()])
	end
	return thump:getName()
end

ISWorldObjectContextMenu.onInsertFuel = function(lightSource, fuel, playerObj)
	if luautils.walkAdj(playerObj, lightSource:getSquare()) then
		ISTimedActionQueue.add(ISInsertLightSourceFuelAction:new(playerObj, lightSource, fuel, 50))
    end
end

ISWorldObjectContextMenu.onRemoveFuel = function(lightSource, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, lightSource:getSquare()) then
		ISTimedActionQueue.add(ISRemoveLightSourceFuelAction:new(playerObj, lightSource, 50))
    end
end

ISWorldObjectContextMenu.onToggleLight = function(worldobjects, light, player)
	local playerObj = getSpecificPlayer(player)
	if light:getSquare() and luautils.walkAdj(playerObj, light:getSquare()) then
		ISTimedActionQueue.add(ISToggleLightAction:new(playerObj, light))
	end
end

ISWorldObjectContextMenu.onLightBulb = function(worldobjects, light, player, remove, bulbitem)
    local playerObj = getSpecificPlayer(player)
    if light:getSquare() and luautils.walkAdj(playerObj, light:getSquare()) then
        if remove then
            ISTimedActionQueue.add(ISLightActions:new("RemoveLightBulb",playerObj, light));
        else
            ISTimedActionQueue.add(ISLightActions:new("AddLightBulb",playerObj, light, bulbitem));
        end
    end
end

ISWorldObjectContextMenu.onLightModify = function(worldobjects, light, player, scrapitem)
    local playerObj = getSpecificPlayer(player)
    if light:getSquare() and luautils.walkAdj(playerObj, light:getSquare()) then
        ISTimedActionQueue.add(ISLightActions:new("ModifyLamp",playerObj, light, scrapitem));
    end
end

ISWorldObjectContextMenu.onLightBattery = function(worldobjects, light, player, remove, battery)
    local playerObj = getSpecificPlayer(player)
    if light:getSquare() and luautils.walkAdj(playerObj, light:getSquare()) then
        if remove then
            ISTimedActionQueue.add(ISLightActions:new("RemoveBattery",playerObj, light));
        else
            ISTimedActionQueue.add(ISLightActions:new("AddBattery",playerObj, light, battery));
        end
    end
end
--]]
