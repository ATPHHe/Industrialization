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
IsoIndustrializationObject = ISBuildingObject:derive("IsoIndustrializationObject");

-- Names/Other
IsoIndustrializationObject.NAME = "IsoIndustrializationObject"
IsoIndustrializationObject.GROUP_NAME = "Industrialization"
IsoIndustrializationObject.FULL_NAME = IsoIndustrializationObject.GROUP_NAME .. " " .. IsoIndustrializationObject.NAME
IsoIndustrializationObject.DEFAULT_SPRITE_NAME = ""

IsoIndustrializationObject.TRANSLATE_NAME = "ContextMenu_Industrialization_IsoIndustrializationObject"
IsoIndustrializationObject.TRANSLATE_DESC = "Tooltip_Industrialization_craft_IsoIndustrializationObjectDesc"

-- Health
IsoIndustrializationObject.HEALTH_FLAT = 1000
IsoIndustrializationObject.HEALTH_PER_PERK_LEVEL = { 100 , 100 , }
IsoIndustrializationObject.HEALTH_PERKS = { Perks.MetalWelding , Perks.Electricity , }
IsoIndustrializationObject.HEALTH_HANDY_TRAIT = 500

-- XP Gain
IsoIndustrializationObject.BUILD_XP_GAINS = { 12 , 12 , } -- XP Gained for building the object.
IsoIndustrializationObject.BUILD_XP_PERKS = { Perks.MetalWelding , Perks.Electricity , } -- perk for XP gain.

-- Settings
IsoIndustrializationObject.SETTINGS = 
    {
        firstItem = nil, -- STRING: The item you will equip in your primary slot when building the object.
        secondItem = nil, -- STRING: The item you will equip in your secondary slot when building the object.
        craftingBank = nil, -- STRING: TODO - fill in note
        thumpDmg = 1, -- Damage done when zombies attack the object.
        dismantable = true, -- the object will be dismantable (come from IsoThumpable stuff, check buildUtil.setInfo to see wich options are available)
        canBarricade = false, -- can be barricaded if true
        canBeAlwaysPlaced = true,
        blockAllTheSquare = true, -- the item will block all the squares where it placed (not like a wall for example)
    }

-- Required Materials/Items needed to build this object goes here.
--  
-- noNeedHammer        = BOOLEAN,
-- noNeedScrewdriver   = BOOLEAN,
-- noNeedBlowTorch     = BOOLEAN,
-- torchUse            = INTEGER,
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- { itemID="Module.ItemID", itemText="Item Text", value=INTEGER, use=BOOLEAN },
-- ...
--[[
    itemID - the string name of the item.
    itemText - The translation to display for itemID. (Spaces are ignored when translating.)
    value - the amount of items for itemID, required to build this object.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoIndustrializationObject.REQUIRED_MATERIALS = 
    {
        noNeedHammer        = true,
        noNeedScrewdriver   = true,
        noNeedBlowTorch     = true,
        torchUse            = 0,
        { itemID="Base.MetalBar", itemText="Metal Bar",                      value=0 },
        { itemID="Base.MetalPipe", itemText="Metal Pipe",                    value=0 },
        { itemID="Base.SmallSheetMetal", itemText="Small Metal Sheet",       value=0 },
        { itemID="Base.SheetMetal", itemText="Metal Sheet",                  value=0 },
        { itemID="Base.Hinge", itemText="Hinge",                             value=0 },
        { itemID="Base.ScrapMetal", itemText="Scrap Metal",                  value=0 },
        { itemID="Base.ElectronicsScrap", itemText="Electronics Scrap",      value=0 },
        { itemID="Radio.ElectricWire", itemText="Electric Wire",             value=0 },
        { itemID="Base.Nails", itemText="Nails",                             value=0 },
        { itemID="Base.Screws", itemText="Screws",                           value=0 },
    }

-- Required Perks/Skills needed to build this object goes here.
-- { perk=Perks.PERKNAME, skillLevel=INTEGER, perkTranslation="IGUI_perks_PERKNAME" or nil },
--[[
    perk - The skill/perk required to build this object.
    skillLevel - The skill level needed to be reached in order to build this object.
    perkTranslation - The perk's translation name. Can be set to nil and "IGUI_perks_"..tostring(perk) will be used in buildmenu tooltips instead.
    use - if true, then ["use:Module.ItemID"] will be used instead of ["need:Module.ItemID"] when creating the ModData for this object.
--]]
IsoIndustrializationObject.REQUIRED_SKILLS = 
    {
        { perk=Perks.MetalWelding, skillLevel=1, perkTranslation=nil },
        { perk=Perks.Electricity, skillLevel=1, perkTranslation=nil },
    }



function IsoIndustrializationObject.createAndGetModData()
    local modData = {}
    
    --------------------------------------------------------
    -- Items (need)
    for _, t in ipairs(IsoIndustrializationObject.REQUIRED_MATERIALS) do
        if t.itemID ~= nil and t.value ~= nil then
            modData["need:" .. t.itemID] = t.value
        end
    end
    --------------------------------------------------------
    -- Items (use)
    for _, t in ipairs(IsoIndustrializationObject.REQUIRED_MATERIALS) do
        if t.use == true and t.itemID ~= nil and t.value ~= nil then
            modData["use:" .. t.itemID] = t.value
        end
    end
    --------------------------------------------------------
    -- Blowtorch
    if not IsoIndustrializationObject.REQUIRED_MATERIALS.noNeedBlowTorch then
        local torchUse                          = IsoIndustrializationObject.REQUIRED_MATERIALS.torchUse
        --modData["need:Base.Hammer"]             = "0";
        --modData["need:Base.Screwdriver"]        = "0";
        modData["use:Base.BlowTorch"]           = torchUse;
        modData["use:Base.WeldingRods"]         = torchUse / 2;
    end
    --------------------------------------------------------
    -- Skills (xp)
    for _, t in ipairs(IsoIndustrializationObject.REQUIRED_SKILLS) do
        if t.perk ~= nil and t.skillLevel ~= nil then
            modData["xp:" .. tostring(t.perk)]      = 5 * t.skillLevel;
        end
    end
    --------------------------------------------------------
    
    return modData
end

-- Custom XP. Call this to give XP to the player when they build this ISItem.
function IsoIndustrializationObject.addXpCustom(ISItem, perk, xp)
	local playerObj = getSpecificPlayer(ISItem.player)
	playerObj:getXp():AddXP(perk, xp);
end

-- Custom XP. Call this to give multiple XP to the player when they build this ISItem.
function IsoIndustrializationObject.addXpCustomMulti(ISItem, perkTable, xpTable)
    for i, _ in ipairs(perkTable) do
        local playerObj = getSpecificPlayer(ISItem.player)
        playerObj:getXp():AddXP(perkTable[i], xpTable[i]);
    end
end

-- Creates the object at a location.
function IsoIndustrializationObject:create(x, y, z, north, sprite)
	local cell = getWorld():getCell();
	self.sq = cell:getGridSquare(x, y, z);
	self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    
	buildUtil.setInfo(self.javaObject, self);
	buildUtil.consumeMaterial(self);
    
    self.javaObject:setName(self.FULL_NAME)
    --self.javaObject:setSprite(sprite);
    self.javaObject:setIsContainer(true);
    --self.javaObject:getModData()["storageMax"] = IsoIndustrializationObject.STORAGE_MAX; -- DEPRECATED: (NOTE: Set the container's max storage in a tileset def instead.)
    
	-- the object will have 300 base health + 100 per MetalWelding lvl
	self.javaObject:setMaxHealth(self:getHealth());
	self.javaObject:setHealth(self.javaObject:getMaxHealth());
    
	-- the sound that will be played when our object is broken
	self.javaObject:setBreakSound("BreakObject");
    
	-- add the item to the ground
    self.sq:AddSpecialObject(self.javaObject);
    
	-- add some xp for because you successfully built the object
	self.addXpCustomMulti(self, self.BUILD_XP_PERKS, self.BUILD_XP_GAINS);
    
	-- IsoObjects with 'waterAmount' 
    --self.javaObject:getModData()["waterMax"] = self.waterMax;
    --self.javaObject:getModData()["waterAmount"] = 0;
    
    self.javaObject:setSpecialTooltip(true)
	self.javaObject:transmitCompleteItemToServer();
    
	-- OnObjectAdded event will create the corresponding SGlobalObject on the server.
	-- This is only needed for singleplayer which doesn't trigger OnObjectAdded.
	triggerEvent("OnObjectAdded", self.javaObject)
    
    --~print(string.format("added an object () at : %.1f, %.1f", x, y));
end

function IsoIndustrializationObject:new(player, sprite)
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
    
    --------------------------------------------------------
    o.name = self.NAME
    
    for key, value in pairs(self.SETTINGS) do
        o[key] = value
    end
    
    o.modData = self.createAndGetModData()
    
    o.player = player;
    --------------------------------------------------------
    
    o.noNeedHammer = self.REQUIRED_MATERIALS.noNeedHammer;
    o.noNeedScrewdriver = self.REQUIRED_MATERIALS.noNeedScrewdriver;
    
	return o;
end

-- Calculates extra health for the object.
function IsoIndustrializationObject:getObjectHealth(ISItem)
	local playerObj = getSpecificPlayer(ISItem.player)
    
    -- Add Extra Health per level of MetalWelding.
	local health = 0
    for i, _ in ipairs(self.HEALTH_PERKS) do
        health = health + (playerObj:getPerkLevel(self.HEALTH_PERKS[i]) * self.HEALTH_PER_PERK_LEVEL[i]);
    end
    
    -- Add Extra Health from Trait "Handy".
	if playerObj:HasTrait("Handy") then
		health = health + self.HEALTH_HANDY_TRAIT;
	end
    
    -- Return Extra Health.
	return health;
end

-- Returns the health of the new object.
function IsoIndustrializationObject:getHealth()
	return self.HEALTH_FLAT + self:getObjectHealth(self);
end

--[[
    Can this object can be placed on this square?
    This function is called everytime you move the mouse over a grid square.
    
    Return true to allow the player to build this object.
    Return false to disallow the player from building this object.
]]
function IsoIndustrializationObject:isValid(square)
    if not ISBuildingObject.isValid(self, square) then return false end
    
    -- Build Cheat
    if ISBuildMenu.cheat then return true end
    
    -- square check
    if not square then return false end
    
    -- hammer/screwdriver check (does the player building this machine have these tools?)
    local playerObj = getSpecificPlayer(self.player)
    local inv = playerObj:getInventory();
    if (not self.noNeedHammer or not IsoIndustrializationObject.REQUIRED_MATERIALS.noNeedHammer) and not inv:contains("Hammer") then 
        return false end;
    if (not self.noNeedScrewdriver or not IsoIndustrializationObject.REQUIRED_MATERIALS.noNeedScrewdriver) and not inv:contains("Screwdriver") then 
        return false end;
    if (not self.noNeedBlowTorch or not IsoIndustrializationObject.REQUIRED_MATERIALS.noNeedBlowTorch) and not inv:contains("BlowTorch") then 
        return false end;
        
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
        if obj:getObjectName() == "IsoGenerator" then return false end
    end
    
    if buildUtil.stairIsBlockingPlacement( square, true ) then return false; end
	if square:isVehicleIntersecting() then return false end
    
	return true
end

-- Called to render the ghost objects
-- The ISBuildingObject only renders 1 sprite (north, south...), for example for stairs I can render the 2 others tile for stairs here
-- If isValid(square) returns false, the ghost render will be in red and the player cannot build the item.
function IsoIndustrializationObject:render(x, y, z, square)
	ISBuildingObject.render(self, x, y, z, square)
end


