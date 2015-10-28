-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_A02/SCCA_A02_EditorFunctions.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is a set of functions for the platoon builder, used in
-- **              operation A2.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpScript = import ('/maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua')

--------------------------------------------------------------------------------------------------------------
-- function: M2ResetNorthAttack = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M2ResetNorthAttack(platoon)
    ScenarioInfo.VarTable['LaunchNorthAttack'] = false
end

--------------------------------------------------------------------------------------------------------------
-- function: M2ResetSouthAttack = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M2ResetSouthAttack(platoon)
    ScenarioInfo.VarTable['LaunchSouthAttack'] = false
end

--------------------------------------------------------------------------------------------------------------
-- function: M2CruiserDone = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M2CruiserDone(platoon)
    ScenarioInfo.VarTable['LaunchCruiserAttack'] = false
    ScenarioInfo.CruiserFinished = true
    for num, builder in ArmyBrains[ScenarioInfo.Cybran].PBM.Platoons.Sea do
        if builder.BuilderName == 'M2_Cruiser' then
            builder.Priority = 0
            break
        end
    end
    OpScript.M2CruiserBuilt( platoon )
end

--------------------------------------------------------------------------------------------------------------
-- function: M2CruiserBuildCallback = BuildCallback
-- 
-- parameter 0: string platoon = "default_platoon"
-- parameter 1: string table = "1"
-- 
--------------------------------------------------------------------------------------------------------------
function M2CruiserBuildCallback(platoon, table)
    ScenarioInfo.VarTable['LaunchCruiserAttack'] = false
    ScenarioInfo.CruiserStarted = true
    ForkThread( OpScript.M2CreateCruiserDeathTrigger )
end

--------------------------------------------------------------------------------------------------------------
-- function: M3ResetEastAttack = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M3ResetEastAttack(platoon)
    ScenarioInfo.VarTable['LaunchEastAttack'] = false
end

--------------------------------------------------------------------------------------------------------------
-- function: M3ResetArtilleryAttack = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M3ResetArtilleryAttack(platoon)
    ScenarioInfo.VarTable['LaunchArtilleryAttack'] = false
end

--------------------------------------------------------------------------------------------------------------
-- function: M3ResetWestAttack = AddFunction   doc = "Prevent continual attacks"
-- 
-- parameter 0: string	platoon		= "default_platoon"
-- 
--------------------------------------------------------------------------------------------------------------
function M3ResetWestAttack(platoon)
    ScenarioInfo.VarTable['LaunchWestAttack'] = false
end
