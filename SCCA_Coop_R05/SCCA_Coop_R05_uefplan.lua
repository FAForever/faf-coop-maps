-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R05/SCCA_Coop_R05_uefplan.lua
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

function ExecutePlan( brain )
    BuildStructures( brain )
    BuildUnits( brain )
end

function BuildStructures( brain )
end

function ExecutePlan(brain)
    if(not ScenarioInfo.UEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_UEFResourceBaseArea'), 40, 'M1MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_UEFAirOmniArea'), 65, 'M2EAST')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_UEFNavalBaseArea'), 65, 'M2NAVAL')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_UEFSWOmniArea'), 40, 'M2SW')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_UEFNorthOmniArea'), 70, 'M2NORTH')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_UEFMainBaseArea'), 100, 'M3MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_UEFAirBaseArea'), 80, 'M3AIR')
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
