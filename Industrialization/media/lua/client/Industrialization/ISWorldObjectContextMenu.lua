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
    industrializationAutoMiner = nil
    
    ---------------------------------
end

local original_fetch = ISWorldObjectContextMenu.fetch
ISWorldObjectContextMenu.fetch = function(v, player, doSquare)

    ---------------------------------
    -- write modified function here
    --local playerObj = getSpecificPlayer(player)
	--local playerInv = playerObj:getInventory()
    --local square = v:getSquare()
    
    if v:getName() == "Industrialization Small Auto Miner" then
        industrializationAutoMiner = v;
    end
    ---------------------------------
    
    -- call original function
    original_fetch(v, player, doSquare)
    
end

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

ISWorldObjectContextMenu.onInfoGenerator = function(worldobjects, generator, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISGeneratorInfoAction:new(playerObj, generator))
	end
end

ISWorldObjectContextMenu.onPlugGenerator = function(worldobjects, generator, player, plug)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISPlugGenerator:new(player, generator, plug, 300));
	end
end

ISWorldObjectContextMenu.onActivateGenerator = function(worldobjects, enable, generator, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISActivateGenerator:new(player, generator, enable, 30));
	end
end

ISWorldObjectContextMenu.onFixGenerator = function(worldobjects, generator, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISFixGenerator:new(getSpecificPlayer(player), generator, 150));
	end
end

ISWorldObjectContextMenu.onAddFuel = function(worldobjects, petrolCan, generator, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISAddFuel:new(player, generator, petrolCan, 70 + (petrolCan:getUsedDelta() * 40)));
	end
end

ISWorldObjectContextMenu.onTakeGenerator = function(worldobjects, generator, player)
	local playerObj = getSpecificPlayer(player)
	if luautils.walkAdj(playerObj, generator:getSquare()) then
		ISTimedActionQueue.add(ISTakeGenerator:new(player, generator, 100));
	end
end

-- maps object:getName() -> translated label
local ThumpableNameToLabel = {
	["Bar"] = "ContextMenu_Bar",
	["Barbed Fence"] = "ContextMenu_Barbed_Fence",
	["Bed"] = "ContextMenu_Bed",
	["Bookcase"] = "ContextMenu_Bookcase",
	["Double Shelves"] = "ContextMenu_DoubleShelves",
	["Gravel Bag Wall"] = "ContextMenu_Gravel_Bag_Wall",
	["Lamp on Pillar"] = "ContextMenu_Lamp_on_Pillar",
	["Large Table"] = "ContextMenu_Large_Table",
	["Log Wall"] = "ContextMenu_Log_Wall",
	["Rain Collector Barrel"] = "ContextMenu_Rain_Collector_Barrel",
	["Sand Bag Wall"] = "ContextMenu_Sang_Bag_Wall",
	["Shelves"] = "ContextMenu_Shelves",
	["Small Bookcase"] = "ContextMenu_SmallBookcase",
	["Small Table"] = "ContextMenu_Small_Table",
	["Small Table with Drawer"] = "ContextMenu_Table_with_Drawer",
	["Window Frame"] = "ContextMenu_Windows_Frame",
	["Wooden Crate"] = "ContextMenu_Wooden_Crate",
	["Wooden Door"] = "ContextMenu_Door",
	["Wooden Fence"] = "ContextMenu_Wooden_Fence",
	["Wooden Stairs"] = "ContextMenu_Stairs",
	["Wooden Stake"] = "ContextMenu_Wooden_Stake",
	["Wooden Wall"] = "ContextMenu_Wooden_Wall",
	["Wooden Pillar"] = "ContextMenu_Wooden_Pillar",
	["Wooden Chair"] = "ContextMenu_Wooden_Chair",
	["Wooden Stairs"] = "ContextMenu_Stairs",
	["Wooden Sign"] = "ContextMenu_Sign",
	["Wooden Door Frame"] = "ContextMenu_Door_Frame",
}

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
end]]

