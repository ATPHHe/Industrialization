--
--***************************
--*** Utilities ***
--***************************
--* Coded by: ATPHHe
--* 
--*******************************
--
--============================================================
IndustrializationUtilities = {}
IndustrializationUtilities.__index = IndustrializationUtilities

IndustrializationUtilities.Author = "ATPHHe"
IndustrializationUtilities.DateCreated = "03/28/2020"
IndustrializationUtilities.DateModified = "04/16/2020"
IndustrializationUtilities.MOD_ID = "Industrialization"

IndustrializationUtilities.GameVersion = getCore():getVersionNumber()
IndustrializationUtilities.GameVersionNumber = 0

local tempIndex, _ = string.find(IndustrializationUtilities.GameVersion, " ")
if tempIndex ~= nil then
    
    IndustrializationUtilities.GameVersionNumber = tonumber(string.sub(IndustrializationUtilities.GameVersion, 0, tempIndex))
    if IndustrializationUtilities.GameVersionNumber == nil then 
        tempIndex, _ = string.find(IndustrializationUtilities.GameVersion, ".") + 1 
        IndustrializationUtilities.GameVersionNumber = tonumber(string.sub(IndustrializationUtilities.GameVersion, 0, tempIndex))
    end
else
    IndustrializationUtilities.GameVersionNumber = tonumber(IndustrializationUtilities.GameVersion)
end
tempIndex = nil

IndustrializationUtilities.DefaultSettingsFileName = "MOD DefaultSettings (".. IndustrializationUtilities.MOD_ID ..").lua"
IndustrializationUtilities.ConfigFileName = "MOD Config Options (".. IndustrializationUtilities.MOD_ID ..").lua"
--local configFileLocation = getMyDocumentFolder() .. getFileSeparator() .. configFileName
IndustrializationUtilities.ConfigFileLocation = IndustrializationUtilities.ConfigFileName


--============================================================
--**********************************************
-- Variables


--*********************************************
-- Other Useful Functions

function IndustrializationUtilities.tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            IndustrializationUtilities.tprint(v, indent+1)
        else
            print(formatting .. v)
        end
    end
end

function IndustrializationUtilities.deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not IndustrializationUtilities.deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not IndustrializationUtilities.deepcompare(v1,v2) then return false end
    end
    return true
end

function IndustrializationUtilities.compare_and_insert(t1, t2, ignore_mt)
    
    local isEqual = true
    
    if not t1 then
        return false
    end
    
    if not t2 then
        t2 = {}
        isEqual = false
    end
    
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if (v2 == nil) then 
            t2[k1] = v1
            isEqual = false
        end
        
        if type(t1[k1]) == "table" then
            isEqual = IndustrializationUtilities.compare_and_insert(t1[k1], t2[k1], ignore_mt)
        end
        
    end
    
    return isEqual
end

-- Splits the string apart.
--  EX: inputstr = "Hello There Friend."
--      sep = " "
--      t = {Hello, 
--          There, 
--          Friend.}
--  EX: inputstr = "Hello,There,Friend."
--      sep = ","
--      t = {Hello, 
--          There, 
--          Friend.}
--
-- Parameters:  inputstr - the string that will be split.
--              sep - the separator character that will be used to split the string
--              t - the table that will be returned.
--
function IndustrializationUtilities.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Returns true, if "a" a number. Otherwise return false.
function IndustrializationUtilities.isNumber(a)
    if tonumber(a) ~= nil then
        local number = tonumber(a)
        if number then
            return true
        end
    end
    
    return false
end


--*************************
-- I/O Functions


--[[

TablePersistence is a small code snippet that allows storing and loading of lua variables containing primitive types. It is licensed under the MIT license, use it how ever is needed. A more detailed description and complete source can be downloaded on http://the-color-black.net/blog/article/LuaTablePersistence. A fork has been created on github that included lunatest unit tests: https://github.com/hipe/lua-table-persistence

Shortcomings/Limitations:
- Does not export udata
- Does not export threads
- Only exports a small subset of functions (pure lua without upvalue)

]]
local write, writeIndent, writers, refCount;
IndustrializationUtilities.io_persistence =
{
	store = function (path, modID, ...)
		local file, e = getModFileWriter(modID, path, true, false) --e = io.open(path, "w");
		if not file then
			return error(e);
		end
		local n = select("#", ...);
		-- Count references
		local objRefCount = {}; -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)));
		end;
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {};
		local objRefIdx = 0;
		file:write("-- Persistent Data (for "..modID..")\n");
		file:write("local multiRefObjects = {\n");
		for obj, count in pairs(objRefCount) do
			if count > 1 then
				objRefIdx = objRefIdx + 1;
				objRefNames[obj] = objRefIdx;
				file:write("{};"); -- table objRefIdx
			end;
		end;
		file:write("\n} -- multiRefObjects\n");
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				file:write("multiRefObjects["..idx.."][");
				write(file, k, 0, objRefNames);
				file:write("] = ");
				write(file, v, 0, objRefNames);
				file:write(";\n");
			end;
		end;
		-- Create the remaining objects
		for i = 1, n do
			file:write("local ".."obj"..i.." = ");
			write(file, (select(i,...)), 0, objRefNames);
			file:write("\n");
		end
		-- Return them
		if n > 0 then
			file:write("return obj1");
			for i = 2, n do
				file:write(" ,obj"..i);
			end;
			file:write("\n");
		else
			file:write("return\n");
		end;
		if type(path) == "string" then
			file:close();
		end;
	end;

	load = function (path, modID)
		local f, e;
		if type(path) == "string" then
            --f, e = loadfile(path);
			f, e = getModFileReader(modID, path, true);
            if f == nil then f = getFileReader(sourceFile, true) end;
            
            local contents = "";
            local scanLine = f:readLine();
            local strfor = string.format
            while scanLine do
                
                --contents = contents.. scanLine .."\r\n";
                contents = strfor("%s%s\r\n", contents, scanLine);
                
                scanLine = f:readLine();
                if not scanLine then break end
            end
            
            f:close();
            
            f = contents;
		else
			f, e = path:read('*a');
		end
		if f then
            local func = loadstring(f);
            if func then
                return func();
            else
                return nil;
            end
		else
			return nil, e;
		end;
	end;
}

-- Private methods

-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
	for i = 1, level do
		file:write("\t");
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item)
			file:write("nil");
		end;
	["number"] = function (file, item)
			file:write(tostring(item));
		end;
	["string"] = function (file, item)
			file:write(string.format("%q", item));
		end;
	["boolean"] = function (file, item)
			if item then
				file:write("true");
			else
				file:write("false");
			end
		end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
				file:write("multiRefObjects["..refIdx.."]");
			else
				-- Single use table
				file:write("{\r\n");
				for k, v in pairs(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\r\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
			local dInfo = debug.getinfo(item, "uS");
			if dInfo.nups > 0 then
				file:write("nil --[[functions with upvalue not supported]]");
			elseif dInfo.what ~= "Lua" then
				file:write("nil --[[non-lua function not supported]]");
			else
				local r, s = pcall(string.dump,item);
				if r then
					file:write(string.format("loadstring(%q)", s));
				else
					file:write("nil --[[function could not be dumped]]");
				end
			end
		end;
	["thread"] = function (file, item)
			file:write("nil --[[thread]]\r\n");
		end;
	["userdata"] = function (file, item)
			file:write("nil --[[userdata]]\r\n");
		end;
}

-- Testing Persistence
--io_persistence.store("storage.lua", MOD_ID, configOpts)
--t_restored = io_persistence.load("storage.lua", MOD_ID);
--io_persistence.store("storage2.lua", MOD_ID, t_restored)



-- Save to a given file.
-- Returns true if successful, otherwise return false if an error occured.
function IndustrializationUtilities.SaveToFile(fileName, text)
    local fileWriter = getModFileWriter(IndustrializationUtilities.MOD_ID, fileName, true, false)
    if fileWriter == nil then fileWriter = getFileWriter(fileName, true, false) end
    
    fileWriter:write(tostring(text))
    fileWriter:close()
end

-- Load from a given file.
-- Returns a table of Strings, representing each line in the file.
function IndustrializationUtilities.LoadFromFile(fileName)

	local contents = {}
	local fileReader = getModFileReader(IndustrializationUtilities.MOD_ID, fileName, true)
    if fileReader == nil then fileReader = getFileReader(fileName, true) end
    
	local scanLine = fileReader:readLine()
	while scanLine do
        
        table.insert(contents, tostring(scanLine))
        
		scanLine = fileReader:readLine()
		if not scanLine then break end
	end
    
	fileReader:close();
    
	return contents
end

function IndustrializationUtilities.SaveTableDIS(fileName)
    
end

function IndustrializationUtilities.LoadTableDOS(fileName)
    
end

-- Recreates the default configuration files for this mod.
function IndustrializationUtilities.recreateConfigFiles()
    
    -- Use the default settings.
    local fileContents1 = IndustrializationUtilities.io_persistence.load(
        IndustrializationUtilities.DefaultSettingsFileName, 
        IndustrializationUtilities.MOD_ID)
    
    -- Store default settings into the configuration file.
    IndustrializationUtilities.io_persistence.store(
        IndustrializationUtilities.ConfigFileLocation, 
        IndustrializationUtilities.MOD_ID, 
        fileContents1)
        
    return fileContents1
end


--*********************************************
-- Custom Tables
IndustrializationUtilities.DEFAULT_SETTINGS = {
    ["testTable"] = {
        ["x"] = 0,
        ["y"] = 0,
    },
}

-- Load default settings from file.
IndustrializationUtilities.configOpts = IndustrializationUtilities.io_persistence.load(IndustrializationUtilities.DefaultSettingsFileName, IndustrializationUtilities.MOD_ID)

-- Make sure the file default settings are the same with the table "DEFAULT_SETTINGS".
if not IndustrializationUtilities.deepcompare(
        IndustrializationUtilities.configOpts, 
        IndustrializationUtilities.DEFAULT_SETTINGS, false) then
    
    -- If file default settings are not the same compared to the "DEFAULT_SETTINGS" table, 
    --      replace the file with a new file using the "DEFAULT_SETTINGS".
    IndustrializationUtilities.io_persistence.store(IndustrializationUtilities.DefaultSettingsFileName, IndustrializationUtilities.MOD_ID, IndustrializationUtilities.DEFAULT_SETTINGS)
     
    IndustrializationUtilities.configOpts = IndustrializationUtilities.io_persistence.load(IndustrializationUtilities.DefaultSettingsFileName, IndustrializationUtilities.MOD_ID)
    
end

--===============================================================================
-- Get/Setup all configuration settings from the config file.

-- Restore the settings from the configuration file.
local t_restored =  IndustrializationUtilities.io_persistence.load(IndustrializationUtilities.ConfigFileLocation, IndustrializationUtilities.MOD_ID)

-- If any new DEFAULT_SETTINGS are added, insert them into the t_restored table.
if not IndustrializationUtilities.compare_and_insert(IndustrializationUtilities.configOpts, t_restored, true) then
     IndustrializationUtilities.io_persistence.store(IndustrializationUtilities.ConfigFileLocation, IndustrializationUtilities.MOD_ID, t_restored)
end

-- If a t_restored table exists, set it as the new configOpts.
-- Else, the configuration file was never found or restored, recreate all of the configuration files.
if t_restored then 
    IndustrializationUtilities.configOpts = t_restored 
else 
    IndustrializationUtilities.configOpts =  IndustrializationUtilities.recreateConfigFiles()
end

-- Remove the variable pointing to the DEFAULT_SETTINGS table to conserve memory. 
-- Let LUA's Garbage collecting system take over.
DEFAULT_SETTINGS = nil


--**********************************************
-- Vanilla Functions


--*************************************
-- Custom Functions

--[[
    This function returns a boolean if the client (player) is near a valid cooking utility and the valid criteria is met.
    
    Returns true if ALL following criteria below are met:
        - The client (player) is close enough to one of the given cooking utilities.
        - And, the client (player) is within line of sight of a cooking util.
        - And, the cooking util must be turned on, lit, or be on fire.
        
    Returns false if ONE following criteria below is met:
        - The client (player) is too far from the given cooking utils
        - Or, The client (player) is not within light of sight.
        - Or, The cooking util is turned off, not lit, or is not on fire.
    
    Parameters:
        isoPlayer - (IsoPlayer) The player of object type IsoPlayer.
        maxDistance - The max distance a player can be from a given cooking utility.
]]
function IndustrializationUtilities.isCloseToCookingUtil(isoPlayer, maxDistance)

    --local objects = getCell():getObjectList();
    --local objects = getCell():getStaticUpdaterObjectList();
    --local objects = getCell():getPushableObjectList();
    
    
    --print("===================================")
    
    
    --===================--
    -- Cooking Utilities --
    --===================--
    local cookingUtilObjectNames = {
        ["Stove"] = true, 
        ["Barbecue"] = true, 
        ["Fireplace"] = true, 
        ["StoneFurnace"] = true, 
        ["Fire"] = true, -- "Fire" includes campfires, etc.
    }
    
    -- Localize some functions to speed up code.
    local mathsqrt = math.sqrt
    
    -- Find All Process and Static IsoObjects in the client's (player's) cell.
    ----local isoPlayer = getSpecificPlayer(0);
    ----local isoPlayer = getPlayer();
    local cell = isoPlayer:getCell();
    local objects = cell:getProcessIsoObjects(); -- This contains most cooking appliances.
    objects:addAll(cell:getStaticUpdaterObjectList()); -- This contains other stuff such as lights, campfires, etc.
    
    -- Look at each IsoObject and check if it's a cooking utility and if the player is close enough.
    for i=0, objects:size()-1 do
        
        local o = objects:get(i);
        --print(string.format("=== %s, %s", tostring(o:getName()), tostring(o:getObjectName()) ));
        
        -- Check if object is a cooking utility.
        if cookingUtilObjectNames[o:getObjectName()] then
            
            -- The object "o" is a cooking utility.
            -- Check if the player is close enough to a cooking util.
            
            -- get object position.
            local objX = o:getX() + 0.5; -- center with 0.5 offset
            local objY = o:getY() + 0.5; -- center with 0.5 offset
            local objZ = o:getZ();
            
            -- get player position.
            local pX = isoPlayer:getX();
            local pY = isoPlayer:getY();
            local pZ = isoPlayer:getZ();
            
            -- Is the player close enough to the cooking util?
            local dX = objX-pX
            local dY = objY-pY
            local dZ = objZ-pZ
            local distance = mathsqrt(dX*dX + dY*dY + dZ*dZ)
            --print(distance)
            
            if distance <= maxDistance then
                
                -- Can the player see the cooking util?
                local gridSquare = o:getSquare();
                local lineOfSightTestResults = LosUtil.lineClear(isoPlayer:getCell(), objX, objY, objZ, pX, pY, pZ, false);
                --print(string.format("%s", tostring(lineOfSightTestResults)));
                
                if tostring(lineOfSightTestResults) ~= "Blocked" then
                    
                    --print(string.format("%s, %s", tostring(o:getName()), tostring(o:getObjectName()) ));
                    
                    -- Is the fire still alive? Includes campfires, etc. (IsoFire)
                    if (o.getLife ~= nil and o:getLife() > 0) or (o.getLightRadius ~= nil and o:getLightRadius() > 1) then
                        --o:update();
                        --print(o:getLightRadius());
                        return true; -- The player is close enough to a working cooking util and can see it; return true.
                    end
                    
                    -- Is the fire lit? (IsoFireplace, IsoBarbecue)
                    if o.isLit ~= nil and o:isLit() == true then
                        return true; -- The player is close enough to a working cooking util and can see it; return true.
                    end
                    
                    -- Is the fire started? (BSFurnace --> ObjectName: "StoneFurnace")
                    if o.isFireStarted ~= nil and o:isFireStarted() == true then
                        return true; -- The player is close enough to a working cooking util and can see it; return true.
                    end
                    
                    -- Is the cooking util turned on? (IsoStove)
                    if o.Activated ~= nil and o:Activated() == true then
                        return true; -- The player is close enough to a working cooking util and can see it; return true.
                    end
                    
                end
            end
        end
        
    end
    
    return false; -- The player is too far away from all cooking utils, cannot see it, or they are not turned on or lit; return false.
end

--[[
    This function returns a boolean if the client (player) is near a valid cooking utility and the valid criteria is met.
    
    Returns true if ALL following criteria below are met:
        - The client (player) is close enough to one of the given cooking utilities.
        - And, the client (player) is within line of sight of a cooking util.
        - And, the cooking util must be turned on, lit, or be on fire.
        
    Returns false if ONE following criteria below is met:
        - The client (player) is too far from the given cooking utils
        - Or, The client (player) is not within light of sight.
        - Or, The cooking util is turned off, not lit, or is not on fire.
    
    Parameters:
        isoPlayer - (IsoPlayer) The player of object type IsoPlayer.
        maxDistance - The max distance a player can be from a given cooking utility.
]]
-- Localize some functions to speed up code.
local mathsqrt = math.sqrt
local prt = print
local strfor = string.format
local tableinsert = table.insert
local tostr = tostring
function IndustrializationUtilities.isCloseToInteractableObject(isoPlayer, maxDistance)
    
    if not isoPlayer then return {} end
    if not maxDistance or not tonumber(maxDistance) then return {} end
    
    --local objects = getCell():getObjectList();
    --local objects = getCell():getStaticUpdaterObjectList();
    --local objects = getCell():getPushableObjectList();
    
    local pX = isoPlayer:getX()
    local pY = isoPlayer:getY()
    local pZ = isoPlayer:getZ()
    local square = isoPlayer:getCell():getOrCreateGridSquare(pX, pY, pZ) 
    
    
    local sqX = square:getX()
    local sqY = square:getY()
    local sqZ = square:getZ()
    
    for x = sqX-maxDistance, sqX+maxDistance do
        for y = sqY-maxDistance, sqY+maxDistance do
        
            local cell = getWorld():getCell()
            local square2 = cell:getOrCreateGridSquare(x, y, sqZ)
            if square2 then 
                --local sq2X = square:getX()
                --local sq2Y = square:getY()
                --local sq2Z = square:getZ()
                
                local objects = ArrayList.new()
                local door = square:getDoorTo(square2)
                if door then objects:add(door) end
                local window = square:getWindowTo(square2)
                if window then objects:add(window) end
                
                for i=0, objects:size()-1 do
                    
                    local o = objects:get(i);
                    if o:getObjectName() == "Window" then
                        if o:isDestroyed() or o:isLocked() or o:isSmashed() or o:isBarricaded() then
                            break
                        end
                    end
                    
                    local oX = o:getX()
                    local oY = o:getY()
                    local oZ = o:getZ()
                    
                    local dX = oX-pX
                    local dY = oY-pY
                    local dZ = oZ-pZ
                    local distance = mathsqrt(dX*dX + dY*dY + dZ*dZ)
                    --print(distance)
                    
                    if distance <= maxDistance then
                        local lineOfSightTestResults = LosUtil.lineClear(cell, pX, pY, pZ, oX, oY, oZ, false);
                        --print(string.format("%s", tostring(lineOfSightTestResults)));
                        if tostr(lineOfSightTestResults) ~= "Blocked" then
                            
                            prt(strfor("%s, %s, %s, oX:%.2f oY:%.2f pX:%.2f pY:%.2f", tostr(o:getName()), tostr(o:getObjectName()), tostr(lineOfSightTestResults), oX, oY, pX, pY ));
                            local dX, dY = 0, 0
                            
                            if oX > pX then
                                dX = -maxDistance
                            else
                                dX = maxDistance
                            end
                            if oY > pY then
                                dY = -maxDistance
                            else
                                dY = maxDistance
                            end
                            
                            isoPlayer:setX(pX+dX)
                            isoPlayer:setY(pY+dY)
                            
                            return o:getObjectName();
                        end
                    end
                    
                end
            end
            
        end
    end
    
    return false;
    --[[
    --print("===================================")
    local closeObjects = {}
    
    --===================--
    -- Cooking Utilities --
    --===================--
    local objectNames = {
        ["Stove"] = true, 
        ["Barbecue"] = true, 
        ["Fireplace"] = true, 
        ["StoneFurnace"] = true, 
        ["Fire"] = true, -- "Fire" includes campfires, etc.
    }
    objectNames = {}
    
    
    
    -- Find All Process and Static IsoObjects in the client's (player's) cell.
    ----local isoPlayer = getSpecificPlayer(0);
    ----local isoPlayer = getPlayer();
    local cell = isoPlayer:getCell();
    local objects = cell:getStaticUpdaterObjectList()
    --cell:getProcessIsoObjects(); -- This contains most cooking appliances.
    --objects:addAll(cell:getStaticUpdaterObjectList()); -- This contains other stuff such as lights, campfires, etc.
    
    -- Look at each IsoObject and check if it's a cooking utility and if the player is close enough.
    prt(strfor("===================================="))
    for i=0, objects:size()-1 do
        
        local o = objects:get(i);
        --prt(strfor("=== %s, %s", tostr(o:getName()), tostr(o:getObjectName()) ));
        
        -- Check if object is a cooking utility.
        if objectNames[o:getObjectName()] then
            
            -- The object "o" is a cooking utility.
            -- Check if the player is close enough to a cooking util.
            
            -- get object position.
            local objX = o:getX() + 0.5; -- center with 0.5 offset
            local objY = o:getY() + 0.5; -- center with 0.5 offset
            local objZ = o:getZ();
            
            -- get player position.
            local pX = isoPlayer:getX();
            local pY = isoPlayer:getY();
            local pZ = isoPlayer:getZ();
            
            -- Is the player close enough to the cooking util?
            local dX = objX-pX
            local dY = objY-pY
            local dZ = objZ-pZ
            local distance = mathsqrt(dX*dX + dY*dY + dZ*dZ)
            --print(distance)
            
            if distance <= maxDistance then
                
                -- Can the player see the cooking util?
                local gridSquare = o:getSquare();
                local lineOfSightTestResults = LosUtil.lineClear(isoPlayer:getCell(), objX, objY, objZ, pX, pY, pZ, false);
                --print(string.format("%s", tostring(lineOfSightTestResults)));
                
                if lineOfSightTestResults ~= LosUtil.TestResults.Blocked then
                    
                    prt(strfor("%s, %s, %s", tostr(o:getName()), tostr(o:getObjectName()), tostr(lineOfSightTestResults) ));
                    
                    tableinsert(closeObjects, o);
                end
            end
        end
        
    end
    
    return closeObjects; -- The player is too far away from all cooking utils, cannot see it, or they are not turned on or lit; return false.
    ]]
end

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function IndustrializationUtilities.rgbToHsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    local s
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, l}
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
]]
function IndustrializationUtilities.hslToRgb(h, s, l)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return {r * 255, g * 255, b * 255}
end

--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
function IndustrializationUtilities.rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, v}
end

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function IndustrializationUtilities.hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return {r * 255, g * 255, b * 255}
end


--*************************************
-- Events



