-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A01/SCCA_Coop_A01_v03_rhizaplan.lua
-- **  Author(s):  Greg
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

ScenarioInfo.RhizaPlanRunOnce = false

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
    if(not ScenarioInfo.RhizaPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Rhiza_Base_Location'), 45, 'RHIZA')
        ScenarioInfo.RhizaPlanRunOnce = true
    end
end
