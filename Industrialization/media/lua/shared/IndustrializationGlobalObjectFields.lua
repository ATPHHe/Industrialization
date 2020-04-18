--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
-- 
-- All fields here override each object's default fields in "SIndustrializationGlobalObject.lua".

IndustrializationGlobalObjectFields = {}

-----------------
----- Power -----
-----------------
IndustrializationGlobalObjectFields.IsoGenerator = 
{
    isPowerSource           = true,
    isMiner                 = false,
    isRefinery              = false,
}
------------------
----- Mining -----
------------------
IndustrializationGlobalObjectFields.IndustrializationSmallAutoMiner = 
{
    isPowerSource           = false,
    isMiner                 = true,
    isRefinery              = false,
}
IndustrializationGlobalObjectFields.IndustrializationLargeAutoMiner = 
{
    isPowerSource           = false,
    isMiner                 = true,
    isRefinery              = false,
}
--------------------
----- Refining -----
--------------------
IndustrializationGlobalObjectFields.IndustrializationSmallFurnace = 
{
    isPowerSource           = false,
    isMiner                 = false,
    isRefinery              = true,
}







