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
    --------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Power"), worldobjects, nil);
        
    --============================================
    ----- Category: Wiring -----
    ----------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Wiring"), worldobjects, nil);
    
    --============================================
    ----- Category: Mining -----
    ----------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Mining"), worldobjects, nil);
    
    --------------- /// Small Auto Miner \\\ ---------------
    local subMenuIsoObj = subMenu:getNew(subMenu);
    context:addSubMenu(optionBuildCategory, subMenuIsoObj);
    Industrialization_ISBuildMenu.buildSmallAutoMinerMenu(subMenuIsoObj, optionBuildCategory, player, isoPlayer);
    --============================================
    ----- Category: Refining -----
    ------------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Refining"), worldobjects, nil);
        
    --------------- /// Small Furnace \\\ ---------------
    local subMenuIsoObj = subMenu:getNew(subMenu);
    context:addSubMenu(optionBuildCategory, subMenuIsoObj);
    Industrialization_ISBuildMenu.buildSmallFurnaceMenu(subMenuIsoObj, optionBuildCategory, player, isoPlayer);
    --============================================
    ----- Category: Farming -----
    -----------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Farming"), worldobjects, nil);
    
    
    --============================================
    ----- Category: Turrets -----
    -----------------------------
    local optionBuildCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_BuildCategory_Turrets"), worldobjects, nil);
    
    
end

-- =============================================================================================================== //////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ///
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== //
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /
------------------------------
--      Build functions
------------------------------

--
Industrialization_ISBuildMenu.buildSmallAutoMinerMenu = function(subMenu, option, player, isoPlayer)
    
    -- sprite/translation/other
    local sprite = IsoSmallAutoMiner.DEFAULT_SPRITE_NAME;
    local translateName = getText( IsoSmallAutoMiner.TRANSLATE_NAME )
    local translateTooltip = getText( IsoSmallAutoMiner.TRANSLATE_DESC )
    
    -- context menu option
    local buildOption = subMenu:addOption(
        translateName, 
        worldobjects, Industrialization_ISBuildMenu.onBuildSmallAutoMiner, player, sprite);
        
    -- tooltip
    local tooltip = ISBlacksmithMenu.addToolTip(buildOption, translateName, sprite);
    tooltip.description = translateTooltip .. " <LINE>" .. tooltip.description;
    local isOk, tooltip = Industrialization_ISBuildMenu.checkIndustrialFurnitures(isoPlayer, tooltip, 
                                                            IsoSmallAutoMiner.REQUIRED_MATERIALS, 
                                                            IsoSmallAutoMiner.REQUIRED_SKILLS );
    
    -- other
    if not isOk then 
        --buildOption.onSelect = nil;
        buildOption.notAvailable = true; 
    end
    --ISBuildMenu.requireHammer(buildOption)
    
end

-- Create a auto miner and drag a ghost render of the object under the mouse.
Industrialization_ISBuildMenu.onBuildSmallAutoMiner = function(worldobjects, player, sprite)
    -- ModData is all handled inside the "IsoIndustrializationObject.lua" file now.
    local obj = IsoSmallAutoMiner:new(player, sprite);
    
    -- Now allow the item to be dragged by mouse
    getCell():setDrag(obj, player);
end

----- ----- ----- ----- 

Industrialization_ISBuildMenu.buildSmallFurnaceMenu = function(subMenu, option, player, isoPlayer)
    
    -- sprite/translation/other
    local sprite = IsoSmallFurnace.DEFAULT_SPRITE_NAME;
    local translateName = getText( IsoSmallFurnace.TRANSLATE_NAME )
    local translateTooltip = getText( IsoSmallFurnace.TRANSLATE_DESC )
    
    -- context menu option
    local buildOption = subMenu:addOption(
        translateName, 
        worldobjects, Industrialization_ISBuildMenu.onBuildSmallFurnace, player, sprite);
        
    -- tooltip
    local tooltip = ISBlacksmithMenu.addToolTip(buildOption, translateName, sprite);
    tooltip.description = translateTooltip .. " <LINE>" .. tooltip.description;
    local isOk, tooltip = Industrialization_ISBuildMenu.checkIndustrialFurnitures(isoPlayer, tooltip, 
                                                            IsoSmallFurnace.REQUIRED_MATERIALS, 
                                                            IsoSmallFurnace.REQUIRED_SKILLS );
    
    -- other
    if not isOk then 
        --buildOption.onSelect = nil;
        buildOption.notAvailable = true; 
    end
    --ISBuildMenu.requireHammer(buildOption)
    
end

-- Create a auto miner and drag a ghost render of the object under the mouse.
Industrialization_ISBuildMenu.onBuildSmallFurnace = function(worldobjects, player, sprite)
    -- ModData is all handled inside the "IsoIndustrializationObject.lua" file now.
    local obj = IsoSmallFurnace:new(player, sprite);
    
    -- Now allow the item to be dragged by mouse
    getCell():setDrag(obj, player);
end
--]]

-- =============================================================================================================== //////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ////
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ///
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== //
----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== ----- ----- ----- ==== /

-- Check whether you have the correct amount of materials for electrical metal welding furnitures/machines. (Returns: isOk, tooltip)
Industrialization_ISBuildMenu.checkIndustrialFurnitures = function(isoPlayer, tooltip, REQUIRED_MATERIALS_TABLE, REQUIRED_SKILLS_TABLE)
    
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
    
    tooltip.description = tooltip.description .. " <LINE> ";
    
    ----- ----- ----- ----- 
    -- Skills/Perks
    
    for _, t in ipairs(REQUIRED_SKILLS_TABLE) do
        if t.perkTranslation and t.perkTranslation ~= "" then
            if isoPlayer:getPerkLevel(t.perk) < t.skillLevel then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getText(t.perkTranslation) .. " " .. isoPlayer:getPerkLevel(t.perk) .. "/" .. t.skillLevel;
                isOk = false;
            else
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getText(t.perkTranslation) .. " " .. isoPlayer:getPerkLevel(t.perk) .. "/" .. t.skillLevel;
            end
        else
            if isoPlayer:getPerkLevel(t.perk) < t.skillLevel then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_perks_"..tostring(t.perk)) .. " " .. isoPlayer:getPerkLevel(t.perk) .. "/" .. t.skillLevel;
                isOk = false;
            else
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getText("IGUI_perks_"..tostring(t.perk)) .. " " .. isoPlayer:getPerkLevel(t.perk) .. "/" .. t.skillLevel;
            end
        end
    end
    
    ----- ----- ----- ----- 
    
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




