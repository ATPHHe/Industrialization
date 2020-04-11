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
    ----- Category: Power -----
    --------------------------
    local optionCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_Category_Power"), worldobjects, nil);
        
    --============================================
    ----- Category: Wiring -----
    --------------------------
    local optionCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_Category_Wiring"), worldobjects, nil);
    
    --============================================
    ----- Category: Mining -----
    ------------------------------
    local optionCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_Category_Mining"), worldobjects, nil);
    
    --------------------/// Small Auto Miner \\\--------------------
    local subMenuSmallAutoMiner = subMenu:getNew(subMenu);
    context:addSubMenu(optionCategory, subMenuSmallAutoMiner);
    Industrialization_ISBuildMenu.buildAutoMinerMenu(subMenuSmallAutoMiner, optionCategory, player, isoPlayer);
    
    --============================================
    ----- Category: Farming -----
    -------------------------------
    local optionCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_Category_Farming"), worldobjects, nil);
    
    
    --============================================
    ----- Category: Turrets -----
    -------------------------------
    local optionCategory = subMenu:addOption(
        getText("ContextMenu_Industrialization_Category_Turrets"), worldobjects, nil);
    
    
end

----- ----- -----

Industrialization_ISBuildMenu.buildAutoMinerMenu = function(subMenu, option, player, isoPlayer)
    
    -- sprite
    local sprite = "industrialization_auto_miners_01_0";
    
    -- context menu option
    local smallAutoMiner = subMenu:addOption(
        getText("ContextMenu_Industrialization_Small_Auto_Miner"), 
        worldobjects, 
        Industrialization_ISBuildMenu.onBuildAutoMiner, player, sprite);
        
    -- tooltip
    local tooltip = ISBlacksmithMenu.addToolTip(smallAutoMiner, getText("ContextMenu_Industrialization_Small_Auto_Miner"), sprite);
    tooltip.description = getText("Tooltip_Industrialization_craft_AutoMinerDesc") .. " <LINE>" .. tooltip.description;
    local isOk, tooltip = Industrialization_ISBuildMenu.checkElectricalMetalWeldingFurnitures(
                                IsoAutoMiner.REQUIRED_MATERIALS.noNeedHammer, IsoAutoMiner.REQUIRED_MATERIALS.noNeedScrewdriver, 
                                IsoAutoMiner.REQUIRED_MATERIALS.metalBar, IsoAutoMiner.REQUIRED_MATERIALS.metalPipe, 
                                IsoAutoMiner.REQUIRED_MATERIALS.smallMetalSheet, IsoAutoMiner.REQUIRED_MATERIALS.metalSheet, 
                                IsoAutoMiner.REQUIRED_MATERIALS.hinge, 
                                IsoAutoMiner.REQUIRED_MATERIALS.scrapMetal, IsoAutoMiner.REQUIRED_MATERIALS.electronicsScrap, 
                                IsoAutoMiner.REQUIRED_MATERIALS.electricWire, 
                                IsoAutoMiner.REQUIRED_MATERIALS.nails, IsoAutoMiner.REQUIRED_MATERIALS.screws, 
                                IsoAutoMiner.REQUIRED_MATERIALS.torchUse, IsoAutoMiner.REQUIRED_MATERIALS.skill, isoPlayer, tooltip);
    
    --
    if not isOk then 
        --smallAutoMiner.onSelect = nil;
        smallAutoMiner.notAvailable = true; 
    end
    --ISBuildMenu.requireHammer(smallAutoMiner)
    
end

-- Create a new metal drum to drag a ghost render of the drum under the mouse.
Industrialization_ISBuildMenu.onBuildAutoMiner = function(worldobjects, player, sprite)
    --print("onBuildAutoMiner")
    
    local obj = IsoAutoMiner:new(player, sprite);
    
    -- we now set the mod data for the needed material
    -- by doing this, all will be automatically consumed, drop on the ground if destoryed, etc.
    --------------------------------------------------------
    obj.name = IsoAutoMiner.NAME
    --------------------------------------------------------
    obj.firstItem = "BlowTorch";
    obj.secondItem = "WeldingMask";
    obj.craftingBank = "BlowTorch";
    obj.canBeAlwaysPlaced = true;
    obj.noNeedHammer = IsoAutoMiner.REQUIRED_MATERIALS.noNeedHammer;
    obj.noNeedScrewdriver = IsoAutoMiner.REQUIRED_MATERIALS.noNeedScrewdriver;
    --------------------------------------------------------
    obj.modData["need:Base.MetalPipe"] = IsoAutoMiner.REQUIRED_MATERIALS.metalPipe;
    obj.modData["need:Base.SmallSheetMetal"] = IsoAutoMiner.REQUIRED_MATERIALS.smallMetalSheet;
    obj.modData["need:Base.SheetMetal"] = IsoAutoMiner.REQUIRED_MATERIALS.metalSheet;
    obj.modData["need:Base.Hinge"] = IsoAutoMiner.REQUIRED_MATERIALS.hinge;
    --obj.modData["need:Base.ScrapMetal"] = IsoAutoMiner.REQUIRED_MATERIALS.scrapMetal;
    obj.modData["need:Base.ElectronicsScrap"] = IsoAutoMiner.REQUIRED_MATERIALS.electronicsScrap;
    obj.modData["need:Radio.ElectricWire"] = IsoAutoMiner.REQUIRED_MATERIALS.electricWire;
    obj.modData["need:Base.Nails"] = IsoAutoMiner.REQUIRED_MATERIALS.nails;
    obj.modData["need:Base.Screws"] = IsoAutoMiner.REQUIRED_MATERIALS.screws;
    --------------------------------------------------------
    local torchUse = IsoAutoMiner.REQUIRED_MATERIALS.torchUse;
    --obj.modData["need:Base.Hammer"] = "0";
    --obj.modData["need:Base.Screwdriver"] = "0";
    obj.modData["use:Base.BlowTorch"] = torchUse;
    obj.modData["use:Base.WeldingRods"] = torchUse / 2;
    --------------------------------------------------------
    obj.modData["xp:MetalWelding"] = 5 * IsoAutoMiner.REQUIRED_MATERIALS.skill ;
    --------------------------------------------------------
    
    -- and now allow the item to be dragged by mouse
    obj.player = player;
    getCell():setDrag(obj, player);
end

----- ----- -----

-- Check whether you have the correct amount of materials for electrical metal welding furnitures/machines. (Returns: isOk, tooltip)
Industrialization_ISBuildMenu.checkElectricalMetalWeldingFurnitures = function(
                                    noNeedHammer, noNeedScrewdriver,
                                    metalBar, metalPipe, smallMetalSheet, metalSheet, hinge, scrapMetal, electronicsScrap, electricWire, nails, screws, 
                                    torchUse, skill, isoPlayer, tooltip)
    
    if ISBuildMenu.cheat then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. "(" .. getText("IGUI_AdminPanel_BuildCheat") .. ")" ;
        return true, tooltip;
    end
    
    -----
    
    local inv = isoPlayer:getInventory();
    local isOk = true;
    local hammer;
    local screwdriver;
    local blowTorch;
    local weldingRods;
    
    -----
    
    if not noNeedHammer then
        if not inv:contains("Hammer") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Hammer") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Hammer") .. " 1/1" ;
            hammer = inv:getItemFromType("Hammer");
        end
    end
    if not noNeedScrewdriver then
        if not inv:contains("Screwdriver") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Screwdriver") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Screwdriver") .. " 1/1" ;
            screwdriver = inv:getItemFromType("Screwdriver");
        end
    end
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
        if blowTorchUseLeft < torchUse then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Blow Torch") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Blow Torch") .. getText("ContextMenu_Uses") .. " " .. torchUse .. "/" .. torchUse;
        end
    end
    if weldingRods then
        local blowTorchUseLeft = round(weldingRods:getUsedDelta() / weldingRods:getUseDelta());
        if blowTorchUseLeft < torchUse / 2 then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Welding Rods") .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse/2;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Welding Rods") .. getText("ContextMenu_Uses") .. " " .. torchUse/2 .. "/" .. torchUse/2;
        end
    end
    if not inv:contains("WeldingMask") then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Welding Mask") .. " 0/1" ;
        isOk = false;
    else
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Welding Mask") .. " 1/1" ;
    end
    
    -----
    
    if metalBar and metalBar > 0 then
        if inv:getNumberOfItem("MetalBar", false, true) < metalBar then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Bar") .. " " .. inv:getNumberOfItem("MetalBar", false, true) .. "/" .. metalBar;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Bar") .. " " .. metalBar .. "/" .. metalBar ;
        end
    end
    if metalPipe > 0 then
        if inv:getNumberOfItem("MetalPipe", false, true) < metalPipe then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Pipe") .. " " .. inv:getNumberOfItem("MetalPipe", false, true) .. "/" .. metalPipe;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Pipe") .. " " .. metalPipe .. "/" .. metalPipe ;
        end
    end
    if smallMetalSheet > 0 then
        if inv:getNumberOfItem("SmallSheetMetal", false, true) < smallMetalSheet then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Small Metal Sheet") .. " " .. inv:getNumberOfItem("SmallSheetMetal", false, true) .. "/" .. smallMetalSheet;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Small Metal Sheet") .. " " .. smallMetalSheet .. "/" .. smallMetalSheet ;
        end
    end
    if metalSheet > 0 then
        if inv:getNumberOfItem("SheetMetal", false, true) < metalSheet then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Sheet") .. " " .. inv:getNumberOfItem("SheetMetal", false, true) .. "/" .. metalSheet;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Sheet") .. " " .. metalSheet .. "/" .. metalSheet ;
        end
    end
    if hinge > 0 then
        if inv:getNumberOfItem("Hinge", false, true) < hinge then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Hinge") .. " " .. inv:getNumberOfItem("Hinge", false, true) .. "/" .. hinge;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Hinge") .. " " .. hinge .. "/" .. hinge ;
        end
    end
    if scrapMetal > 0 then
        if inv:getNumberOfItem("ScrapMetal", false, true) < scrapMetal then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Scrap Metal") .. " " .. inv:getNumberOfItem("ScrapMetal", false, true) .. "/" .. scrapMetal;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Scrap Metal") .. " " .. scrapMetal .. "/" .. scrapMetal ;
        end
    end
    if electronicsScrap > 0 then
        if inv:getNumberOfItem("ElectronicsScrap", false, true) < electronicsScrap then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Electronics Scrap") .. " " .. inv:getNumberOfItem("ElectronicsScrap", false, true) .. "/" .. electronicsScrap;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Electronics Scrap") .. " " .. electronicsScrap .. "/" .. electronicsScrap ;
        end
    end
    if electricWire > 0 then
        if inv:getNumberOfItem("ElectricWire", false, true) < electricWire then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Electric Wire") .. " " .. inv:getNumberOfItem("ElectricWire", false, true) .. "/" .. electricWire;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Electric Wire") .. " " .. electricWire .. "/" .. electricWire ;
        end
    end
    if nails > 0 then
        if inv:getNumberOfItem("Nails", false, true) < nails then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Nails") .. " " .. inv:getNumberOfItem("Nails", false, true) .. "/" .. nails;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Nails") .. " " .. nails .. "/" .. nails ;
        end
    end
    if screws > 0 then
        if inv:getNumberOfItem("Screws", false, true) < screws then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Screws") .. " " .. inv:getNumberOfItem("Screws", false, true) .. "/" .. screws;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Screws") .. " " .. screws .. "/" .. screws ;
        end
    end
    
    -----
    
    tooltip.description = tooltip.description .. " <LINE> ";
    if isoPlayer:getPerkLevel(Perks.MetalWelding) < skill then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. skill;
        isOk = false;
    else
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. skill ;
    end
    if isOk then
        ISBlacksmithMenu.canDoSomething = true;
    end
    return isOk, tooltip;
    
end

-- Check whether you have the correct amount of materials for electrical furnitures/machines (NO WELDING TOOLS). (Returns: isOk, tooltip)
Industrialization_ISBuildMenu.checkElectricalFurnitures = function(
                                    noNeedHammer, noNeedScrewdriver,
                                    metalBar, metalPipe, smallMetalSheet, metalSheet, hinge, scrapMetal, electronicsScrap, electricWire, nails, screws, 
                                    torchUse, skill, isoPlayer, tooltip)
    
    if ISBuildMenu.cheat then
        return true, tooltip;
    end
    
    -----
    
    local inv = isoPlayer:getInventory();
    local isOk = true;
    local hammer;
    local screwdriver;
    
    -----
    
    if not noNeedHammer then
        if not inv:contains("Hammer") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Hammer") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Hammer") .. " 1/1" ;
            hammer = inv:getItemFromType("Hammer");
        end
    end
    if not noNeedScrewdriver then
        if not inv:contains("Screwdriver") then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Screwdriver") .. " 0/1" ;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Screwdriver") .. " 1/1" ;
            screwdriver = inv:getItemFromType("Screwdriver");
        end
    end
    
    -----
    
    if metalBar and metalBar > 0 then
        if inv:getNumberOfItem("MetalBar", false, true) < metalBar then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Bar") .. " " .. inv:getNumberOfItem("MetalBar", false, true) .. "/" .. metalBar;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Bar") .. " " .. metalBar .. "/" .. metalBar ;
        end
    end
    if metalPipe > 0 then
        if inv:getNumberOfItem("MetalPipe", false, true) < metalPipe then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Pipe") .. " " .. inv:getNumberOfItem("MetalPipe", false, true) .. "/" .. metalPipe;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Pipe") .. " " .. metalPipe .. "/" .. metalPipe ;
        end
    end
    if smallMetalSheet > 0 then
        if inv:getNumberOfItem("SmallSheetMetal", false, true) < smallMetalSheet then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Small Metal Sheet") .. " " .. inv:getNumberOfItem("SmallSheetMetal", false, true) .. "/" .. smallMetalSheet;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Small Metal Sheet") .. " " .. smallMetalSheet .. "/" .. smallMetalSheet ;
        end
    end
    if metalSheet > 0 then
        if inv:getNumberOfItem("SheetMetal", false, true) < metalSheet then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Metal Sheet") .. " " .. inv:getNumberOfItem("SheetMetal", false, true) .. "/" .. metalSheet;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Metal Sheet") .. " " .. metalSheet .. "/" .. metalSheet ;
        end
    end
    if hinge > 0 then
        if inv:getNumberOfItem("Hinge", false, true) < hinge then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Hinge") .. " " .. inv:getNumberOfItem("Hinge", false, true) .. "/" .. hinge;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Hinge") .. " " .. hinge .. "/" .. hinge ;
        end
    end
    if scrapMetal > 0 then
        if inv:getNumberOfItem("ScrapMetal", false, true) < scrapMetal then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Scrap Metal") .. " " .. inv:getNumberOfItem("ScrapMetal", false, true) .. "/" .. scrapMetal;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Scrap Metal") .. " " .. scrapMetal .. "/" .. scrapMetal ;
        end
    end
    if electronicsScrap > 0 then
        if inv:getNumberOfItem("ElectronicsScrap", false, true) < electronicsScrap then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Electronics Scrap") .. " " .. inv:getNumberOfItem("ElectronicsScrap", false, true) .. "/" .. electronicsScrap;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Electronics Scrap") .. " " .. electronicsScrap .. "/" .. electronicsScrap ;
        end
    end
    if electricWire > 0 then
        if inv:getNumberOfItem("ElectricWire", false, true) < electricWire then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Electric Wire") .. " " .. inv:getNumberOfItem("ElectricWire", false, true) .. "/" .. electricWire;
            isOk = false;
        else
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getItemText("Electric Wire") .. " " .. electricWire .. "/" .. electricWire ;
        end
    end
    
    -----
    
    tooltip.description = tooltip.description .. " <LINE> ";
    if isoPlayer:getPerkLevel(Perks.MetalWelding) < skill then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. skill;
        isOk = false;
    else
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1> " .. getText("IGUI_perks_MetalWelding") .. " " .. isoPlayer:getPerkLevel(Perks.MetalWelding) .. "/" .. skill ;
    end
    if isOk then
        ISBlacksmithMenu.canDoSomething = true;
    end
    return isOk, tooltip;
    
end

-- Add function "buildAutoMiner" to Events.OnFillWorldObjectContextMenu
Events.OnFillWorldObjectContextMenu.Add(Industrialization_ISBuildMenu.doBuildMenu)




