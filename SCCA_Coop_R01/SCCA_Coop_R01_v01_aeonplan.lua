-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R01_v01/SCCA_Coop_R01_v01_aeonplan.lua
-- **  Author(s):  Greg
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

ScenarioInfo.AeonPlanRunOnce = false

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
    if(not ScenarioInfo.AeonPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3AeonBaseLocation'), 40, 'AEONMAIN')
        ScenarioInfo.AeonPlanRunOnce = true
    end
end
