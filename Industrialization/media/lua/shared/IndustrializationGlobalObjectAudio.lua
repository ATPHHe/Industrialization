--
--*****************************
--***   Industrialization   ***
--*****************************
-- Coded by: ATPHHe
-- 
--*****************************
--
-- All audio is handled and played by "CIndustrializationGlobalObject.lua".

IndustrializationGlobalObjectAudio = {}

-----------------
----- Power -----
-----------------
-- IsoGenerator has it's own sounds which cannot be edited.
-- Do not edit the sound list here for IsoGenerator or you may hear two sounds playing at the same time.
IndustrializationGlobalObjectAudio.IsoGenerator = 
{
    audioRunning            = "", --"GeneratorLoop",
    audioToggle             = "", --"LightSwitch",
    audioStart              = "", --"GeneratorStarting",
    audioFailedToStart      = "", --"GeneratorFailedToStart",
    audioStop               = "", --"GeneratorStopping",
    audioDestroy            = "", --"",
    audioExplode            = "", --"",
}
------------------
----- Mining -----
------------------
IndustrializationGlobalObjectAudio.IndustrializationSmallAutoMiner = 
{
    audioRunning            = "SmallAutoMinerRunning1",
    audioToggle             = "LightSwitch",
    audioStart              = "GeneratorStarting",
    audioFailedToStart      = "GeneratorFailedToStart",
    audioStop               = "GeneratorStopping",
    audioDestroy            = "",
    audioExplode            = "",
}
IndustrializationGlobalObjectAudio.IndustrializationLargeAutoMiner = 
{
    audioRunning            = "GeneratorLoop",
    audioToggle             = "LightSwitch",
    audioStart              = "GeneratorStarting",
    audioFailedToStart      = "GeneratorFailedToStart",
    audioStop               = "GeneratorStopping",
    audioDestroy            = "",
    audioExplode            = "",
}
--------------------
----- Refining -----
--------------------
IndustrializationGlobalObjectAudio.IndustrializationSmallFurnace = 
{
    audioRunning            = "GeneratorLoop",
    audioToggle             = "LightSwitch",
    audioStart              = "GeneratorStarting",
    audioFailedToStart      = "GeneratorFailedToStart",
    audioStop               = "GeneratorStopping",
    audioDestroy            = "",
    audioExplode            = "",
}






