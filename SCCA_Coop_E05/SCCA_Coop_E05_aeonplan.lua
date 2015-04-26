-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_aeonplan1.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan(brain)
    if(not ScenarioInfo.AeonPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon'), 80, 'Aeon_Main_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon_Nuke2_Base'), 80, 'Aeon_Nuke2_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon_Nuke3_Base'), 80, 'Aeon_Nuke3_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon_Second_Base'), 120, 'Aeon_Second_Base')
        ScenarioInfo.AeonPlanRunOnce = true
    end
end
