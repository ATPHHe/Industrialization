--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
-- Modified using "..\ProjectZomboid\media\lua\server\RainBarrel\BuildingObjects\RainCollectorBarrel.lua" as reference.
--*****************************
--

require "BuildingObjects/ISBuildingObject"

-- This class extends ISBuildingObject. ISBuildingObject is a class to help you drag around and place an item/worldobject into the world.
IsoAutoMiner = ISBuildingObject:derive("IsoAutoMiner");

IsoAutoMiner.GROUP_NAME = "Industrialization"
IsoAutoMiner.NAME = IsoAutoMiner.GROUP_NAME .. " " .. "Small Auto Miner"
IsoAutoMiner.REQUIRED_MATERIALS = {noNeedHammer=true,
                                noNeedScrewdriver=false,
                                metalBar=0, 
                                metalPipe=4, 
                                smallMetalSheet=8, 
                                metalSheet=4, 
                                hinge=0, 
                                scrapMetal=0, 
                                electronicsScrap=4, 
                                electricWire=1, 
                                nails=0, 
                                screws=(4*2 + 8*4 + 4*4), 
                                torchUse=12, 
                                skill=4}

function IsoAutoMiner.addMetalWeldingXpCustom(ISItem, xp)
	local playerObj = getSpecificPlayer(ISItem.player)
	playerObj:getXp():AddXP(Perks.MetalWelding, xp);
end

function IsoAutoMiner.getAutoMinerHealth(ISItem)
	local playerObj = getSpecificPlayer(ISItem.player)
	local health = (playerObj:getPerkLevel(Perks.MetalWelding) * 50);
	if playerObj:HasTrait("Handy") then
		health = health + 100;
	end
	return health;
end

function IsoAutoMiner:create(x, y, z, north, sprite)
	local cell = getWorld():getCell();
	self.sq = cell:getGridSquare(x, y, z);
	self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    
	buildUtil.setInfo(self.javaObject, self);
	buildUtil.consumeMaterial(self);
    
    --self.javaObject:setSprite(sprite);
    self.javaObject:setIsContainer(true);
    --self.javaObject:getModData()["storageMax"] = IsoAutoMiner.STORAGE_MAX; -- DEPRECATED: (NOTE: Set the container's max storage in a tileset def instead.)
    
	-- the object will have 300 base health + 100 per MetalWelding lvl
	self.javaObject:setMaxHealth(self:getHealth());
	self.javaObject:setHealth(self.javaObject:getMaxHealth());
    
	-- the sound that will be played when our object is broken
	self.javaObject:setBreakSound("BreakObject");
    
	-- add the item to the ground
    self.sq:AddSpecialObject(self.javaObject);
    
	-- add some xp for because you successfully built the object
	IsoAutoMiner.addMetalWeldingXpCustom(self, 12);
    
	-- IsoObjects with 'waterAmount' 
    --self.javaObject:getModData()["waterMax"] = self.waterMax;
    --self.javaObject:getModData()["waterAmount"] = 0;
    
    self.javaObject:setSpecialTooltip(true)
	self.javaObject:transmitCompleteItemToServer();
    
	-- OnObjectAdded event will create the SAutoMinerGlobalObject on the server.
	-- This is only needed for singleplayer which doesn't trigger OnObjectAdded.
	triggerEvent("OnObjectAdded", self.javaObject)
    
    --~print(string.format("added an object () at : %.1f, %.1f", x, y));
end

function IsoAutoMiner:new(player, sprite)
	-- OOP stuff
	-- we create an item (o), and return it
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o:init();
    
	-- the number of sprites can be up to 4, one for each direction, you ALWAYS need at least 2 sprites, south (Sprite) and north (NorthSprite)
	-- here we're not gonna be able to rotate our building without sprite support, so we set that the south sprite = north sprite
	o:setSprite(sprite); -- SOUTH SPRITE
	o:setNorthSprite(sprite); -- NORTH SPRITE
    
	o.name = IsoAutoMiner.NAME;
    o.thumpDmg = 2;
	o.player = player;
    
    --o.storageMax = IsoAutoMiner.STORAGE_MAX; -- DEPRECATED: (NOTE: Set the container's max storage in a tileset def instead.)
    
	-- the object will be dismantable (come from IsoThumpable stuff, check buildUtil.setInfo to see wich options are available)
	o.dismantable = true;
    
	-- you can't barricade it
	o.canBarricade = false;
    
	-- the item will block all the square where it placed (not like a wall for example)
	o.blockAllTheSquare = true;
	return o;
end

-- Returns the health of the new object, it's 200 + 100 per carpentry lvl
function IsoAutoMiner:getHealth()
	return 300 + IsoAutoMiner.getAutoMinerHealth(self);
end

--[[
    Can this object can be placed on this square?
    This function is called everytime you move the mouse over a grid square.
    
    Return true to allow the player to build this object.
    Return false to disallow the player from building this object.
]]
function IsoAutoMiner:isValid(square)
    if ISBuildingObject.isValid(self, square) then return true end
    
    if not square then return false end
    
    local playerObj = getSpecificPlayer(self.player)
    local inv = playerObj:getInventory();
    if (not self.noNeedHammer or not IsoAutoMiner.REQUIRED_MATERIALS.noNeedHammer) and not inv:contains("Hammer") then return false end;
    if (not self.noNeedScrewdriver or not IsoAutoMiner.REQUIRED_MATERIALS.noNeedScrewdriver) and not inv:contains("Screwdriver") then return false end;
    
	if square:isSolid() or square:isSolidTrans() then return false end
	if square:HasStairs() then return false end
	if square:HasTree() then return false end
	if not square:getMovingObjects():isEmpty() then return false end
	if not square:TreatAsSolidFloor() then return false end
	if not self:haveMaterial(square) then return false end
    
    --print("================================================")
	for i=1,square:getObjects():size() do
		local obj = square:getObjects():get(i-1)
        --print(tostring(self:getSprite()) .. " == " .. tostring(obj:getTextureName()))
        --print(tostring(self:getSprite()) .. " == " .. tostring(obj:getSpriteName()))
        --print(tostring(self.name) .. " == " .. tostring(obj:getName()))
        --print("=====")
		if self:getSprite() == obj:getTextureName() then return false end
        if self:getSprite() == obj:getSpriteName() then return false end
        if self.name == obj:getName() then return false end
    end
    
    if buildUtil.stairIsBlockingPlacement( square, true ) then return false; end
	if square:isVehicleIntersecting() then return false end
	return true
end

-- Called to render the ghost objects
-- The ISBuildingObject only renders 1 sprite (north, south...), for example for stairs I can render the 2 others tile for stairs here
-- If isValid(square) returns false, the ghost render will be in red and the player cannot build the item.
function IsoAutoMiner:render(x, y, z, square)
	ISBuildingObject.render(self, x, y, z, square)
end


