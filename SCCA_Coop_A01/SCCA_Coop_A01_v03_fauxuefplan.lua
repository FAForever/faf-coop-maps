#****************************************************************************
#**
#**  File     :  /maps/SCCA_Coop_A01_v03/SCCA_Coop_A01_v03_fauxuefplan.lua
#**  Author(s):  Greg
#**
#**  Summary  :
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

ScenarioInfo.FauxUEFPlanRunOnce = false

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
    if(not ScenarioInfo.FauxUEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('FauxUEF_Base_Location'), 40, 'FAUXUEF')
        ScenarioInfo.FauxUEFPlanRunOnce = true
    end
end
