--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--

require "BuildingObjects/ISBuildingObject"

-- This class extends ISBuildingObject. ISBuildingObject is a class to help you drag around and place an item/worldobject into the world.
IsoPowerSource = ISBuildingObject:derive("IsoPowerSource");

IsoPowerSource.NAME = "Power Source"
IsoPowerSource.GROUP_NAME = "Industrialization"
IsoPowerSource.FULL_NAME = IsoPowerSource.GROUP_NAME .. " " .. IsoPowerSource.NAME

IsoPowerSource.REQUIRED_MATERIALS = 
    {
        noNeedHammer=true,
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
        skill=4
    }

-- Custom XP. Call this to give XP to the player when they build this ISItem.
function IsoPowerSource.addMetalWeldingXpCustom(ISItem, xp)
	local playerObj = getSpecificPlayer(ISItem.player)
	playerObj:getXp():AddXP(Perks.MetalWelding, xp);
end

function IsoPowerSource:create(x, y, z, north, sprite)
	local cell = getWorld():getCell();
	self.sq = cell:getGridSquare(x, y, z);
	self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    
	buildUtil.setInfo(self.javaObject, self);
	buildUtil.consumeMaterial(self);
    
    self.javaObject:setName(IsoPowerSource.FULL_NAME)
    --self.javaObject:setSprite(sprite);
    self.javaObject:setIsContainer(true);
    --self.javaObject:getModData()["storageMax"] = IsoPowerSource.STORAGE_MAX; -- DEPRECATED: (NOTE: Set the container's max storage in a tileset def instead.)
    
	-- the object will have 300 base health + 100 per MetalWelding lvl
	self.javaObject:setMaxHealth(self:getHealth());
	self.javaObject:setHealth(self.javaObject:getMaxHealth());
    
	-- the sound that will be played when our object is broken
	self.javaObject:setBreakSound("BreakObject");
    
	-- add the item to the ground
    self.sq:AddSpecialObject(self.javaObject);
    
	-- add some xp for because you successfully built the object
	IsoPowerSource.addMetalWeldingXpCustom(self, 12);
    
	-- IsoObjects with 'waterAmount' 
    --self.javaObject:getModData()["waterMax"] = self.waterMax;
    --self.javaObject:getModData()["waterAmount"] = 0;
    
    self.javaObject:setSpecialTooltip(true)
	self.javaObject:transmitCompleteItemToServer();
    
	-- OnObjectAdded event will create the SPowerSourceGlobalObject on the server.
	-- This is only needed for singleplayer which doesn't trigger OnObjectAdded.
	triggerEvent("OnObjectAdded", self.javaObject)
    
    --~print(string.format("added an object () at : %.1f, %.1f", x, y));
end

function IsoPowerSource:new(player, sprite)
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
    
	o.name = IsoPowerSource.FULL_NAME;
    o.thumpDmg = 0.1;
	o.player = player;
    
    --o.storageMax = IsoPowerSource.STORAGE_MAX; -- DEPRECATED: (NOTE: Set the container's max storage in a tileset def instead.)
    
	-- the object will be dismantable (come from IsoThumpable stuff, check buildUtil.setInfo to see wich options are available)
	o.dismantable = true;
    
	-- you can't barricade it
	o.canBarricade = false;
    
	-- the item will block all the square where it placed (not like a wall for example)
	o.blockAllTheSquare = true;
	return o;
end

-- Calculates extra health for the object.
IsoPowerSource.HEALTH_FLAT = 10000
IsoPowerSource.HEALTH_PER_LEVEL = 500
IsoPowerSource.HEALTH_HANDY_TRAIT = 2000
function IsoPowerSource.getObjectHealth(ISItem)
	local playerObj = getSpecificPlayer(ISItem.player)
    
    -- Add Extra Health per level of MetalWelding.
	local health = (playerObj:getPerkLevel(Perks.MetalWelding) * IsoPowerSource.HEALTH_PER_LEVEL);
    
    -- Add Extra Health from Trait "Handy".
	if playerObj:HasTrait("Handy") then
		health = health + IsoPowerSource.HEALTH_HANDY_TRAIT;
	end
    
    -- Return Extra Health.
	return health;
end

-- Returns the health of the new object.
function IsoPowerSource:getHealth()
	return IsoPowerSource.HEALTH_FLAT + IsoPowerSource.getObjectHealth(self);
end

--[[
    Can this object can be placed on this square?
    This function is called everytime you move the mouse over a grid square.
    
    Return true to allow the player to build this object.
    Return false to disallow the player from building this object.
]]
function IsoPowerSource:isValid(square)
    if not ISBuildingObject.isValid(self, square) then return false end
    
    if ISBuildMenu.cheat then return true end
    
    -- square check
    if not square then return false end
    
    -- hammer/screwdriver check (does the player building this machine have these tools?)
    local playerObj = getSpecificPlayer(self.player)
    local inv = playerObj:getInventory();
    if (not self.noNeedHammer or not IsoPowerSource.REQUIRED_MATERIALS.noNeedHammer) and not inv:contains("Hammer") then 
        return false end;
    if (not self.noNeedScrewdriver or not IsoPowerSource.REQUIRED_MATERIALS.noNeedScrewdriver) and not inv:contains("Screwdriver") then 
        return false end;
    
    -- height check (prevents building this miner on high elevations)
    --if math.floor(square:getZ()) > 0 then return false end
    
    -- other checks
	if square:isSolid() or square:isSolidTrans() then return false end
	if square:HasStairs() then return false end
	if square:HasTree() then return false end
	if not square:getMovingObjects():isEmpty() then return false end
	if not square:TreatAsSolidFloor() then return false end
	if not self:haveMaterial(square) then return false end
    --[[
    local sharedSprite = getCell():getSpriteManager():getSprite(self:getSprite())
	if square and sharedSprite then --and sharedSprite:getProperties():Is("IsStackable") then
		local props = ISMoveableSpriteProps.new(sharedSprite)
		return props:canPlaceMoveable("bogus", square, nil)
	end
    --]]
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
function IsoPowerSource:render(x, y, z, square)
	ISBuildingObject.render(self, x, y, z, square)
end


