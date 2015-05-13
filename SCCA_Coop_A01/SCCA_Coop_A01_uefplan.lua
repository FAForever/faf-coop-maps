-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A01/SCCA_Coop_A01_uefplan.lua
-- **  Author(s):  Greg
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

function BuildStructures( brain )
end

function BuildUnits( brain )
end

function ExecutePlan( brain )
    BuildStructures( brain )
    BuildUnits( brain )
end


function ExecutePlan(brain)
    if(not ScenarioInfo.UEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M6_UEFResourceBaseArea'), 35, 'UEFRESOURCE')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M7_UEFNavalBase'), 35, 'UEFNAVAL')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M7_UEF_AirBase'), 35, 'UEFAIR')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M7_UEF_MainBaseLocation'), 48, 'UEFISLAND')
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
