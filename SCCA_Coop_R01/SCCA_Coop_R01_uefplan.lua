-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R01/SCCA_Coop_R01_v01_uefplan.lua
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
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3UEFEastBaseLocation'), 35, 'UEFEAST')
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
