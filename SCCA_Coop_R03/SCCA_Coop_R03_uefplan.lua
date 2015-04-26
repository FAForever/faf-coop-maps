-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R03/SCCA_Coop_R03_v01_uefplan.lua
-- **  Author(s):  Christopher Burns
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

ScenarioInfo.UEFPlanRunOnce = false

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan( brain )
    BuildStructures( brain )
    BuildUnits( brain )
end

function BuildStructures( brain )
end

function BuildUnits( brain )
end

function ExecutePlan(brain)
    if(not ScenarioInfo.UEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_UEF_Air_Base'), 40, 'M1_UEF_Air_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_UEF_Land_Air_Base'), 40, 'M1_UEF_Land_Air_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_UEF_Land_Base'), 40, 'M1_UEF_Land_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_UEF_Main_Land'), 40, 'M3_UEF_Main_Land')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_UEF_Sea_Base'), 40, 'M3_UEF_Sea_Base')
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
