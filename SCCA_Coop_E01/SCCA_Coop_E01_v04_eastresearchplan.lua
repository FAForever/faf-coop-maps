-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E01_v04/SCCA_Coop_E01_v04_eastresearchplan.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan(brain)
    return 100
end

function ExecutePlan(brain)
    if(not ScenarioInfo.EastResearchPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('EastResearch'), 50, 'EastResearch')

        AIBuildStructures.CreateBuildingTemplate(brain, 'EastResearch', 'EastResearchStructures')
        ScenarioInfo.EastResearchPlanRunOnce = true
    end
end
