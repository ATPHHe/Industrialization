--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Some code is referenced from "ISBuildMenu.lua"
-- File Path: ..\ProjectZomboid\media\lua\client\BuildingObjects\ISUI\ISBuildMenu.lua
--*****************************
--

Industrialization_ISBuildMenu = {};


--[[
    Called when world object context menus are filed.
    
    LINK: https://pzwiki.net/wiki/Modding:Lua_Event/OnFillWorldObjectContextMenu
    
    Parameters:
        int player - The player who will see the menu. (The Player Index)
        ISContextMenu context - Context menu.
        table worldobjects - World objects.
        Boolean test - True if called for the purpose of testing for nearby objects.
]]
Industrialization_ISBuildMenu.doBuildMenu = function(player, context, worldobjects, test)

    if test and ISWorldObjectContextMenu.Test then return true end

    if getCore():getGameMode()=="LastStand" then
        return;
    end

    if test then return ISWorldObjectContextMenu.setTest() end
    local isoPlayer = getSpecificPlayer(player)

    if isoPlayer:getVehicle() then return; end
    
    --================================================================================================================================
    ----- Create an Industrialization Menu and add a SubMenu to it -----
    local optionIndustrializationBuildMenu = context:addOption(getText("ContextMenu_Industrialization_Menu"), worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context);
    context:addSubMenu(optionIndustrializationBuildMenu, subMenu);
    
    --================================================================================================================================
    -- Add some context options for building to "optionIndustrializationBuildMenu".
    --============================================
    ----- BuildCategory: Power -----
    --------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Power"), worldobjects, nil);
        
    --============================================
    ----- Category: Wiring -----
    --------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Wiring"), worldobjects, nil);
    
    --============================================
    ----- Category: Mining -----
    ------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Mining"), worldobjects, nil);
    
    --------------- /// Small Auto Miner \\\ ---------------
    local subMenuSmallAutoMiner = subMenu:getNew(subMenu);
    context:addSubMenu(optionBuildCategory, subMenuSmallAutoMiner);
    Industrialization_ISBuildMenu.buildAutoMinerMenu(subMenuSmallAutoMiner, optionBuildCategory, player, isoPlayer);
    --============================================
    ----- Category: Mining -----
    ------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Refining"), worldobjects, nil);
        
    --============================================
    ----- Category: Farming -----
    -------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Farming"), worldobjects, nil);
    
    
    --============================================
    ----- Category: Turrets -----
    -------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Turrets"), worldobjects, nil);
    
    
end

-- =============================================================================================================== //////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ///
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== //
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /

Industrialization_ISBuildMenu.buildAutoMinerMenu = function(subMenu, option, player, isoPlayer)
    
    -- sprite
    local sprite = IsoSmallAutoMiner.DEFAULT_SPRITE_NAME;
    
    -- context menu option
    local smallAutoMiner = subMenu:addOption(
        getText("ContextMenu_Industrialization_SmallAutoMiner"), 
        worldobjects, 
        Industrialization_ISBuildMenu.onBuildAutoMiner, player, sprite);
        
    -- tooltip
    local tooltip = ISBlacksmithMenu.addToolTip(smallAutoMiner, getText("ContextMenu_Industrialization_SmallAutoMiner"), sprite);
    tooltip.description = getText("Tooltip_Industrialization_craft_AutoMinerDesc") .. " <LINE>" .. tooltip.description;
    local isOk, tooltip = Industrialization_ISBuildMenu.checkElectricalMetalWeldingFurnitures(isoPlayer, tooltip, IsoSmallAutoMiner.REQUIRED_MATERIALS);
    
    --
    if not isOk then 
        --smallAutoMiner.onSelect = nil;
        smallAutoMiner.notAvailable = true; 
    end
    --ISBuildMenu.requireHammer(smallAutoMiner)
    
end

-- Create a auto miner and drag a ghost render of the object under the mouse.
Industrialization_ISBuildMenu.onBuildAutoMiner = function(worldobjects, player, sprite)
    --print("onBuildAutoMiner")
    
    -- ModData is all handled inside the "IsoSmallAutoMiner.lua" file now.
    local obj = IsoSmallAutoMiner:new(player, sprite);
    
    -- Now allow the item to be dragged by mouse
    getCell():setDrag(obj, player);
end

-- =============================================================================================================== //////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ///
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== //
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /

-- Check whether you have the correct amount of materials for electrical metal welding furnitures/machines. (Returns: isOk, tooltip)
Industrialization_ISBuildMenu.checkElectricalMetalWeldingFurnitures = function(isoPlayer, tooltip, REQUIRED_MATERIALS_TABLE)
    
    ----- ----- ----- ----- 
    -- Show this in tooltip if BuildMenu Cheat is active.
    
    if ISBuildMenu.cheat then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. "(" .. getText("IGUI_AdminPanel_BuildCheat") .. ")" ;
        return true, tooltip;
    end
    
    ----- ----- ----- ----- 
    -- Init variables
    
    local inv = isoPlayer:getInventory();
    local isOk = true;
    local hammer;
    local screwdriver;
    local blowTorch;
    local weldingRods;
    
    ----- ----- ----- ----- 
    -- Tools
    
    if not REQUIRED_MATERIALS_TABLE.noNeedHammer then
        if not inv:contains("Hammer") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Hammer") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Hammer") .. " 1/1" ;
            hammer = inv:getItemFromType("Hammer");
        end
    end
    if not REQUIRED_MATERIALS_TABLE.noNeedScrewdriver then
        if not inv:contains("Screwdriver") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Screwdriver") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Screwdriver") .. " 1/1" ;
            screwdriver = inv:getItemFromType("Screwdriver");
        end
    end
    if not REQUIRED_MATERIALS_TABLE.noNeedBlowTorch then
        if not inv:contains("BlowTorch") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Blow Torch") .. " 0/1" ;
            isOk = false;
        else
            --tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Blow Torch") .. " 1/1" ;
            blowTorch = inv:getItemFromType("BlowTorch");
        end
        if not inv:contains("WeldingRods") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Welding Rods") .. " 0/1" ;
            isOk = false;
        else
            --tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Blow Torch") .. " 1/1" ;
            weldingRods = inv:getItemFromType("BlowTorch");
        end
        if blowTorch then
            local blowTorchUseLeft = round(blowTorch:getUsedDelta() / blowTorch:getUseDelta());
            if blowTorchUseLeft < REQUIRED_MATERIALS_TABLE.torchUse then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Blow Torch") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. REQUIRED_MATERIALS_TABLE.torchUse;
                isOk = false;
            else
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Blow Torch") .. getText("ContextMenu_Uses") .. " " .. REQUIRED_MATERIALS_TABLE.torchUse .. "/" .. REQUIRED_MATERIALS_TABLE.torchUse;
            end
        end
        if weldingRods then
            local blowTorchUseLeft = round(weldingRods:getUsedDelta() / weldingRods:getUseDelta());
            if blowTorchUseLeft < REQUIRED_MATERIALS_TABLE.torchUse / 2 then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Welding Rods") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. REQUIRED_MATERIALS_TABLE.torchUse/2;
                isOk = false;
            else
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Welding Rods") .. getText("ContextMenu_Uses") .. " " .. REQUIRED_MATERIALS_TABLE.torchUse/2 .. "/" .. REQUIRED_MATERIALS_TABLE.torchUse/2;
            end
        end
        if not inv:contains("WeldingMask") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Welding Mask") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Welding Mask") .. " 1/1" ;
        end
    end
    
    ----- ----- ----- ----- 
    -- Materials
    
    -- All required materials will be stored in IsoObject files now such as "IsoSmallAutoMiner.lua".
    for _, t in ipairs(REQUIRED_MATERIALS_TABLE) do
        if t and t.value > 0 then
            if inv:getNumberOfItem(t.itemID, false, true) < t.value then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText(t.itemText) .. " " .. inv:getNumberOfItem(t.itemID, false, true) .. "/" .. t.value;
                isOk = false;
            else
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText(t.itemText) .. " " .. t.value .. "/" .. t.value ;
            end
        end
    end
    
    ----- ----- ----- ----- 
    -- Skills/Perks
    
    tooltip.description = tooltip.description .. " <LINE> ";
    if isoPlayer:getPerkLevel(Perks.MetalWelding) < REQUIRED_MATERIALS_TABLE.skill then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. REQUIRED_MATERIALS_TABLE.skill;
        isOk = false;
    else
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. REQUIRED_MATERIALS_TABLE.skill ;
    end
    if isOk then
        ISBlacksmithMenu.canDoSomething = true;
    end
    
    ----- ----- ----- ----- 
    -- Return isOk, tooltip
    
    return isOk, tooltip;
    
    ----- ----- ----- ----- 
end



-- Add build menu to Events.OnFillWorldObjectContextMenu
Events.OnFillWorldObjectContextMenu.Add(Industrialization_ISBuildMenu.doBuildMenu)




