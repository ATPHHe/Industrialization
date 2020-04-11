ISTurnOnAutoMiner = {};

ISTurnOnAutoMiner.cheat = false -- take fuel even without generator

ISTurnOnAutoMiner.createMenu = function(Player, Context, worldObjects)
    -- work only if elestricity was already shut off
    if SandboxVars.ElecShutModifier >= -1 and GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier then
        local Pump = nil;

        for iter, Object in ipairs(worldObjects) do
            if Object:getSquare():getProperties():Is("fuelAmount") and (ISTurnOnAutoMiner.cheat == true or tonumber(Object:getSquare():getProperties():Val("fuelAmount")) > 0) then
                local PetrolCal = getSpecificPlayer(Player):getInventory():FindAndReturn("EmptyPetrolCan");
                if not PetrolCal then
                    local Cans = getSpecificPlayer(Player):getInventory():getItemsFromType("PetrolCan");
                    for i = 0, Cans:size() -1 do
                        PetrolCal = Cans:get(i);
                        if PetrolCal:getUsedDelta() <= 1.0 then
                            Pump = Object;
                            break;
                        end
                    end
                else
                    Pump = Object;
                end

            end
        end
        
        if Pump and ISTurnOnAutoMiner.cheat == true then
            Context:addOption(getText("ContextMenu_Industrialization_TurnOnAutoMiner"), worldObjects, ISWorldObjectContextMenu.onTakeFuel, getSpecificPlayer(Player), Pump:getSquare());
            return nil;
        end

        -- since game doesnt provide electricity availability on pump we search for nearby working generator
        local zoneSize = 30; -- size of zone to check; increase if you have troubles with gas pumps distance
        if Pump then
            for z = 0, 3 do
                for x = Pump:getSquare():getX() - zoneSize, Pump:getSquare():getX() + zoneSize do
                    for y = Pump:getSquare():getY() - zoneSize, Pump:getSquare():getY() + zoneSize do
                        local Square = Pump:getCell():getGridSquare(x, y, z);
                        if Square and Square:getGenerator() and Square:getGenerator():isActivated() then
                            Context:addOption(getText("ContextMenu_Industrialization_TurnOnAutoMiner"), worldObjects, ISWorldObjectContextMenu.onTakeFuel, getSpecificPlayer(Player), Pump:getSquare());
                            return nil;
                        end
                    end
                end
            end
        end
    end
 end

Events.OnPreFillWorldObjectContextMenu.Add(ISTurnOnAutoMiner.createMenu);