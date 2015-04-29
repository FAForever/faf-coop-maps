-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E01/SCCA_Coop_E01_v04_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :  Custom PBM functions
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local MainScript = import('/maps/SCCA_Coop_E01/SCCA_Coop_E01_v04_script.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- ###############################################################################
-- function: ChooseMaster = BuildCallback    doc = ""
--
-- parameter 0:    string platoon  = "default_platoon"
--
-- ###############################################################################
function ChooseMaster(platoon)
    local num = Random(0,1)
    
    if(num == 0) then
        ScenarioInfo.VarTable['BuildAirMaster'] = true
        ScenarioInfo.VarTable['BuildLandMaster'] = false
    else
        ScenarioInfo.VarTable['BuildAirMaster'] = false
        ScenarioInfo.VarTable['BuildLandMaster'] = true
    end
end

-- ###############################################################################
-- function: LandMaster = BuildCondition   doc = ""
--
-- parameter 0: string    brain        = "default_brain"
--
-- ###############################################################################
function LandMaster(brain)
    return MainScript.CybranLandMasterFormCondition(ScenarioFramework.AMPlatoonCounter(brain, 'AM_Master_Land'))
end

-- ###############################################################################
-- function: LandChild = BuildCondition   doc = ""
--
-- parameter 0: string    brain        = "default_brain"
--
-- ###############################################################################
function LandChild(brain)
    return MainScript.CybranLandChildBuildCondition(ScenarioFramework.AMPlatoonCounter(brain, 'AM_Master_Land'))
end

-- ###############################################################################
-- function: AirMaster = BuildCondition   doc = ""
--
-- parameter 0: string    brain        = "default_brain"
--
-- ###############################################################################
function AirMaster(brain)
    return MainScript.CybranAirMasterFormCondition(ScenarioFramework.AMPlatoonCounter(brain, 'AM_Master_Air'))
end

-- ###############################################################################
-- function: AirChild = BuildCondition   doc = ""
--
-- parameter 0: string    brain        = "default_brain"
--
-- ###############################################################################
function AirChild(brain)
    return MainScript.CybranAirChildBuildCondition(ScenarioFramework.AMPlatoonCounter(brain, 'AM_Master_Air'))
end

-- ###############################################################################
-- function: AirRandomPatrolAndRestThread = AddFunction    doc = ""
--
-- parameter 0: string    platoon         = "default_platoon"
--
-- ###############################################################################
function AirRandomPatrolAndRestThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolChain) then
            while(true) do
                local patrol = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(data.PatrolChain))
                ScenarioFramework.PlatoonPatrolRoute(platoon, patrol)
                WaitSeconds(Random(30, 100))
                platoon:Stop()
                WaitSeconds(Random(80, 140))
            end
        else
            error('*AI WARNING: PatrolChain not defined', 2)
        end
    else
        error('*AI WARNING: PlatoonData not defined', 2)
    end
end
