-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_cybranplan.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan(brain)
    if(not ScenarioInfo.CybranPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran'), 80, 'Cybran_Base_W')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NW'), 80, 'Cybran_Base_NW')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NNW'), 80, 'Cybran_Base_NNW')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NNE'), 80, 'Cybran_Base_NNE')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NE'), 80, 'Cybran_Base_NE')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_LRA_Base_1'), 40, 'Cybran_LRA_Base_1')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_LRA_Base_2'), 40, 'Cybran_LRA_Base_2')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NW'), 300, 'Cybran_NW_Area')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base_NE'), 400, 'Cybran_NE_Area')
        ScenarioInfo.CybranPlanRunOnce = true
    end
end
